import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../models/field.dart';
import '../services/field_service.dart';
import '../services/scan_history_service.dart';
import '../services/weather_service.dart';

// Anthropic Messages API — no official Flutter SDK, plain HTTP is fine.
// Model: claude-haiku-4-5  →  $0.80/MTok input + $4/MTok output
// Typical cost per exchange: ~$0.002  →  $5 ≈ 2,500 exchanges

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiChatService extends ChangeNotifier {
  static final AiChatService _i = AiChatService._();
  factory AiChatService() => _i;
  AiChatService._();

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _thinking = false;
  bool get thinking => _thinking;

  // Raw conversation history sent to Anthropic on every turn.
  // Format: [{"role": "user"|"assistant", "content": "..."}]
  final List<Map<String, String>> _history = [];

  String? _cachedSystemPrompt;

  // ── System prompt ────────────────────────────────────────────────────────────

  static const _systemBase = '''
You are PaddyAI — the intelligent agricultural assistant built into the VisionGRO app for Malaysian paddy farmers. You are friendly, expert, and concise.

Capabilities:
• Analyse the farmer's active fields and recommend actions
• Explain paddy disease symptoms, causes, and treatments with Malaysian market product names
• Interpret weather conditions and calculate disease risk
• Guide through each growth stage: Seedling → Vegetative → Tillering → Flowering → Ripening → Harvest
• Estimate treatment costs in Malaysian Ringgit (RM)
• Understand and respond naturally in both English and Bahasa Malaysia
• Give irrigation, fertilisation, and pest management advice for Malaysian conditions

Response format rules (strictly follow):
• Use ### for section headers with emoji — e.g. ### 🚨 URGENT, ### ✅ ACTION PLAN, ### ⚠️ AVOID Today, ### 💡 TIPS
• Use numbered lists (1. 2. 3.) for ordered action steps
• Use bullet points (•) for supporting details under each step
• Use **bold** for field names, product names, costs, and critical terms
• Skip --- dividers; use ### section headers to separate content
• For disease/treatment: name 1–2 specific products available in Malaysia with RM cost
• Concise and practical — no filler phrases, no unnecessary intro sentences
• Only reference field data explicitly provided in the context — never fabricate numbers
• If unrelated to farming, politely redirect in one sentence

The live farm data below is injected at session start and reflects the farmer's current situation.
''';

  Future<String> _buildSystemPrompt() async {
    final fields = FieldService().cachedFields ?? [];
    final scans = await ScanHistoryService().getScans();

    String weatherLine = 'Unavailable';
    try {
      final w = await WeatherService.fetchCurrent();
      weatherLine =
          '${w.temp.round()}°C, ${w.condition}, Humidity ${w.humidity}%, Wind ${w.windSpeed.toStringAsFixed(1)} m/s, Disease risk ${w.diseaseRiskScore}/100';
    } catch (_) {}

    final buf = StringBuffer();
    buf.writeln(_systemBase);
    buf.writeln('=== LIVE FARM DATA (${DateTime.now().toString().substring(0, 10)}) ===');
    buf.writeln('Weather: $weatherLine');
    buf.writeln();

    if (fields.isEmpty) {
      buf.writeln('Fields: None registered yet.');
    } else {
      buf.writeln('Active fields (${fields.length}):');
      for (final f in fields) {
        final days = DateTime.now().difference(f.plantedDate).inDays;
        final stage = _stageFromDays(days);
        final pct = ((days / 110) * 100).clamp(0, 100).round();
        buf.writeln(
            '  • ${f.name} — ${f.location}, ${f.areaMorgen.toStringAsFixed(1)} ac, Day $days ($pct%), ${stage.label}, Health: ${f.healthStatus.label}, Variety: ${f.variety}');
        if (f.scanHistory.isNotEmpty) {
          final d = f.scanHistory.first;
          buf.writeln(
              '    Last disease: ${d.diseaseName} (${d.severity}) on ${d.date.toString().substring(0, 10)}');
        }
      }
    }

    buf.writeln();
    if (scans.isNotEmpty) {
      buf.writeln('Recent AI scans (latest 5):');
      for (final s in scans.take(5)) {
        buf.writeln(
            '  • ${s.diseaseName} — ${s.confidence.toStringAsFixed(0)}% confidence, ${s.severity} (${s.scannedAt.toString().substring(0, 10)})');
      }
    }
    buf.writeln('=== END FARM DATA ===');

    return buf.toString();
  }

  GrowthStage _stageFromDays(int days) {
    if (days < 20) return GrowthStage.seedling;
    if (days < 45) return GrowthStage.vegetative;
    if (days < 65) return GrowthStage.tillering;
    if (days < 85) return GrowthStage.flowering;
    if (days < 110) return GrowthStage.ripening;
    return GrowthStage.harvest;
  }

  // ── Send message ─────────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_u',
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _thinking = true;
    notifyListeners();

    try {
      if (kAnthropicKey.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        _addAiMessage(
          '⚠️ **Anthropic API key not set.**\n\nTo activate PaddyAI:\n• Open `lib/config/api_keys.dart`\n• Paste your key into `kAnthropicKey`\n• Get a key at **console.anthropic.com** (free \$5 credit for new accounts)\n\n`claude-haiku-4-5` costs ~\$0.002 per exchange — \$5 lasts ~2,500 messages.',
        );
        return;
      }

      // Build system prompt once per session (includes live farm data)
      _cachedSystemPrompt ??= await _buildSystemPrompt();

      // Append user turn to history
      _history.add({'role': 'user', 'content': text.trim()});

      final response = await http
          .post(
            Uri.parse('https://api.anthropic.com/v1/messages'),
            headers: {
              'x-api-key': kAnthropicKey,
              'anthropic-version': '2023-06-01',
              'content-type': 'application/json',
              // Required header for direct browser (Flutter Web) access
              'anthropic-dangerous-direct-browser-access': 'true',
            },
            body: jsonEncode({
              'model': 'claude-haiku-4-5-20251001',
              'max_tokens': 800,
              'system': _cachedSystemPrompt,
              'messages': _history,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final reply =
            (body['content'] as List).first['text'] as String? ?? 'No response.';

        // Append assistant turn to history
        _history.add({'role': 'assistant', 'content': reply});
        _addAiMessage(reply);
      } else {
        final err = _parseError(response.statusCode, response.body);
        // Remove the user turn we appended since it failed
        if (_history.isNotEmpty) _history.removeLast();
        _addAiMessage(err);
      }
    } catch (e) {
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
      _addAiMessage('Connection error. Please check your internet and try again.\n\n`${e.toString().split('\n').first}`');
    } finally {
      _thinking = false;
      notifyListeners();
    }
  }

  String _parseError(int code, String body) {
    if (code == 401) return '❌ **Invalid API key.** Check `kAnthropicKey` in `api_keys.dart`.';
    if (code == 429) return '⏳ **Rate limit reached.** Wait a moment and try again.';
    if (code == 529) return '🔧 **Anthropic is overloaded.** Try again in a few seconds.';
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final msg = decoded['error']?['message']?.toString() ?? '';
      if (msg.isNotEmpty) return '⚠️ API error: $msg';
    } catch (_) {}
    return '⚠️ API error $code. Please try again.';
  }

  void _addAiMessage(String text) {
    _messages.add(ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_ai',
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  // ── Reset ────────────────────────────────────────────────────────────────────

  void reset() {
    _messages.clear();
    _history.clear();
    _cachedSystemPrompt = null; // rebuild context on next session
    notifyListeners();
  }
}
