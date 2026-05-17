import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../services/ai_chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _svc = AiChatService();
  bool _showSuggestions = true;
  final _focusNode = FocusNode();

  static const _suggestions = [
    ('📊', 'How are my fields?'),
    ('🌤', 'Weather risk today?'),
    ('🦟', 'Any disease alerts?'),
    ('💡', 'What should I do today?'),
    ('💊', 'Best treatment for Rice Blast?'),
    ('🌱', 'Tillering stage tips'),
    ('💰', 'Estimate treatment cost'),
    ('🚿', 'Irrigation advice'),
  ];

  @override
  void initState() {
    super.initState();
    _svc.addListener(_onUpdate);
    _showSuggestions = _svc.messages.isEmpty;
  }

  @override
  void dispose() {
    _svc.removeListener(_onUpdate);
    _ctrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() => _showSuggestions = _svc.messages.isEmpty && !_svc.thinking);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? quick]) async {
    final text = quick ?? _ctrl.text.trim();
    if (text.isEmpty || _svc.thinking) return;
    _ctrl.clear();
    setState(() => _showSuggestions = false);
    HapticFeedback.lightImpact();
    await _svc.sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: Column(
        children: [
          _Header(onReset: () {
            _svc.reset();
            setState(() => _showSuggestions = true);
          }),
          Expanded(child: _buildBody(context)),
          if (_showSuggestions) _SuggestionRow(items: _suggestions, onTap: _send),
          _InputBar(
            ctrl: _ctrl,
            focusNode: _focusNode,
            thinking: _svc.thinking,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final msgs = _svc.messages;
    final thinking = _svc.thinking;

    if (msgs.isEmpty && !thinking) {
      return _EmptyState();
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: msgs.length + (thinking ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == msgs.length) return const _TypingBubble();
        final m = msgs[i];
        return _Bubble(message: m, key: ValueKey(m.id));
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onReset;
  const _Header({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F3D25), Color(0xFF1B7A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            const _PulsingAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('PaddyAI',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
                Row(children: [
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(color: Color(0xFF6EF7A7), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text('Online · Powered by Claude',
                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
                ]),
              ]),
            ),
            GestureDetector(
              onTap: onReset,
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _PulsingAvatar extends StatefulWidget {
  const _PulsingAvatar();
  @override
  State<_PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<_PulsingAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _glow = Tween(begin: 0.2, end: 0.65).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6EF7A7).withValues(alpha: _glow.value),
              blurRadius: 16, spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.eco_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B7A4A), Color(0xFF0F3D25)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.28), blurRadius: 28, spreadRadius: 4),
              ],
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 42),
          ),
          const SizedBox(height: 22),
          Text('PaddyAI is ready',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                  color: context.textPrimary, letterSpacing: -0.3)),
          const SizedBox(height: 8),
          Text(
            'Ask about your fields, disease risk, treatments, or anything about paddy farming.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Context-aware · Knows your farm',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Suggestion chips ──────────────────────────────────────────────────────────

class _SuggestionRow extends StatelessWidget {
  final List<(String, String)> items;
  final void Function(String) onTap;
  const _SuggestionRow({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final item = items[i];
          return GestureDetector(
            onTap: () => onTap(item.$2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(item.$1, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(item.$2,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focusNode;
  final bool thinking;
  final void Function([String?]) onSend;
  const _InputBar({
    required this.ctrl,
    required this.focusNode,
    required this.thinking,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: context.card,
        border: Border(top: BorderSide(color: context.border.withValues(alpha: 0.5))),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -3)),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: context.secondary,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: context.border.withValues(alpha: 0.5)),
            ),
            child: TextField(
              controller: ctrl,
              focusNode: focusNode,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontSize: 14, color: context.textPrimary),
              decoration: InputDecoration(
                hintText: 'Ask PaddyAI anything…',
                hintStyle: TextStyle(color: context.textSecondary, fontSize: 14),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: thinking ? null : () => onSend(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: thinking
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF1B7A4A), Color(0xFF0F3D25)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
              color: thinking ? null : null,
              shape: BoxShape.circle,
              boxShadow: thinking
                  ? []
                  : [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 4))],
            ),
            child: thinking
                ? _MiniSpinner()
                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}

class _MiniSpinner extends StatefulWidget {
  @override
  State<_MiniSpinner> createState() => _MiniSpinnerState();
}

class _MiniSpinnerState extends State<_MiniSpinner> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Transform.rotate(
      angle: _ctrl.value * 2 * math.pi,
      child: Icon(Icons.refresh_rounded, size: 20, color: context.textSecondary),
    ),
  );
}

// ── Chat bubble ───────────────────────────────────────────────────────────────

class _Bubble extends StatefulWidget {
  final ChatMessage message;
  const _Bubble({super.key, required this.message});
  @override
  State<_Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<_Bubble> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _opacity = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    final dx = widget.message.isUser ? 0.12 : -0.12;
    _slide = Tween(begin: Offset(dx, 0.04), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: m.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!m.isUser) ...[
                _SmallAvatar(),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: m.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.74),
                      decoration: BoxDecoration(
                        gradient: m.isUser
                            ? const LinearGradient(
                                colors: [Color(0xFF1B7A4A), Color(0xFF0F3D25)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: m.isUser ? null : context.card,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: m.isUser ? const Radius.circular(20) : const Radius.circular(4),
                          bottomRight: m.isUser ? const Radius.circular(4) : const Radius.circular(20),
                        ),
                        border: m.isUser
                            ? null
                            : Border.all(color: context.border.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: m.isUser
                                ? AppColors.primary.withValues(alpha: 0.22)
                                : Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: m.isUser
                          ? Text(m.text,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white, height: 1.45))
                          : _AiContent(text: m.text),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _fmt(m.timestamp),
                      style: TextStyle(fontSize: 10, color: context.textSecondary.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              if (m.isUser) ...[
                const SizedBox(width: 8),
                _UserDot(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _SmallAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 30, height: 30,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B7A4A), Color(0xFF0F3D25)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.eco_rounded, color: Colors.white, size: 15),
      );
}

class _UserDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 17),
      );
}

// ── AI message renderer ───────────────────────────────────────────────────────

enum _BT { h1, h2, h3, divider, numbered, bullet, paragraph, spacer }

class _Block {
  final _BT type;
  final String? content;
  final int? number;
  const _Block({required this.type, this.content, this.number});
}

class _AiContent extends StatelessWidget {
  final String text;
  const _AiContent({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _parse(text).map((b) => _render(context, b)).toList(),
    );
  }

  List<_Block> _parse(String raw) {
    final result = <_Block>[];
    for (final line in raw.split('\n')) {
      final t = line.trim();
      if (t.isEmpty) { result.add(const _Block(type: _BT.spacer)); continue; }
      if (t == '---' || t == '***' || t == '___') { result.add(const _Block(type: _BT.divider)); continue; }
      if (t.startsWith('### ')) { result.add(_Block(type: _BT.h3, content: t.substring(4))); continue; }
      if (t.startsWith('## '))  { result.add(_Block(type: _BT.h2, content: t.substring(3))); continue; }
      if (t.startsWith('# '))   { result.add(_Block(type: _BT.h1, content: t.substring(2))); continue; }
      final numMatch = RegExp(r'^(\d+)\.\s(.+)').firstMatch(t);
      if (numMatch != null) {
        result.add(_Block(type: _BT.numbered,
            number: int.parse(numMatch.group(1)!), content: numMatch.group(2)!));
        continue;
      }
      if (t.startsWith('• ') || t.startsWith('- ') || t.startsWith('* ')) {
        result.add(_Block(type: _BT.bullet, content: t.substring(2)));
        continue;
      }
      result.add(_Block(type: _BT.paragraph, content: line));
    }
    while (result.isNotEmpty && result.last.type == _BT.spacer) { result.removeLast(); }
    return result;
  }

  Widget _render(BuildContext context, _Block b) {
    switch (b.type) {
      case _BT.spacer:
        return const SizedBox(height: 6);
      case _BT.divider:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: context.border.withValues(alpha: 0.5), thickness: 0.5, height: 1),
        );
      case _BT.h1:
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(b.content!,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                  color: context.textPrimary, letterSpacing: -0.4)),
        );
      case _BT.h2:
        return Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 5),
          child: Text(b.content!,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
        );
      case _BT.h3:
        return _SectionPill(text: b.content!);
      case _BT.numbered:
        return _NumberStep(num: b.number!, text: b.content!, richText: _richText);
      case _BT.bullet:
        return _BulletRow(text: b.content!, richText: _richText);
      case _BT.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: _richText(context, b.content ?? ''),
        );
    }
  }

  Widget _richText(BuildContext context, String raw) {
    final spans = <InlineSpan>[];
    final reg = RegExp(r'\*\*(.+?)\*\*|`(.+?)`');
    int last = 0;
    for (final m in reg.allMatches(raw)) {
      if (m.start > last) spans.add(TextSpan(text: raw.substring(last, m.start)));
      if (m.group(1) != null) {
        spans.add(TextSpan(
            text: m.group(1), style: const TextStyle(fontWeight: FontWeight.w700)));
      } else if (m.group(2) != null) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(m.group(2)!,
                style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.primary)),
          ),
        ));
      }
      last = m.end;
    }
    if (last < raw.length) spans.add(TextSpan(text: raw.substring(last)));
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14, color: context.textPrimary, height: 1.5),
        children: spans,
      ),
    );
  }
}

class _SectionPill extends StatelessWidget {
  final String text;
  const _SectionPill({required this.text});

  Color _color() {
    final u = text.toUpperCase();
    if (u.contains('URGENT') || u.contains('PENTING') || u.contains('SEGERA') || u.contains('KECEMASAN')) {
      return const Color(0xFFE53935);
    }
    if (u.contains('AVOID') || u.contains('JANGAN') || u.contains('ELAK') ||
        u.contains('WARNING') || u.contains('AMARAN')) {
      return const Color(0xFFF57C00);
    }
    if (u.contains('TIP') || u.contains('INFO') || u.contains('NOTE') || u.contains('NOTA')) {
      return const Color(0xFF1976D2);
    }
    return const Color(0xFF1B7A4A);
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.withValues(alpha: 0.3), width: 0.8),
        ),
        child: Text(text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                color: c, letterSpacing: 0.1)),
      ),
    );
  }
}

class _NumberStep extends StatelessWidget {
  final int num;
  final String text;
  final Widget Function(BuildContext, String) richText;
  const _NumberStep({required this.num, required this.text, required this.richText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7, top: 2),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 22, height: 22,
          margin: const EdgeInsets.only(top: 1, right: 10),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B7A4A), Color(0xFF0F3D25)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text('$num',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
        Expanded(child: richText(context, text)),
      ]),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String text;
  final Widget Function(BuildContext, String) richText;
  const _BulletRow({required this.text, required this.richText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3, left: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 8),
          child: Container(
            width: 5, height: 5,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ),
        ),
        Expanded(child: richText(context, text)),
      ]),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SmallAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: context.border.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _Dot(delay: 0.0, ctrl: _ctrl),
              const SizedBox(width: 5),
              _Dot(delay: 0.33, ctrl: _ctrl),
              const SizedBox(width: 5),
              _Dot(delay: 0.66, ctrl: _ctrl),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final double delay;
  final AnimationController ctrl;
  const _Dot({required this.delay, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final v = ((ctrl.value - delay + 1) % 1.0);
        final y = -math.sin(v * math.pi) * 5.0;
        return Transform.translate(
          offset: Offset(0, y),
          child: Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.7 + 0.3 * math.sin(v * math.pi)),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
