import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_keys.dart';
import '../models/field.dart';
import '../models/weather.dart';

class HarvestPrediction {
  final int daysToHarvest;
  final DateTime estimatedDate;
  final String harvestWindow;
  final double expectedYieldTonsPerHa;
  final List<String> riskFactors;
  final String advice;
  final int confidence;

  const HarvestPrediction({
    required this.daysToHarvest,
    required this.estimatedDate,
    required this.harvestWindow,
    required this.expectedYieldTonsPerHa,
    required this.riskFactors,
    required this.advice,
    required this.confidence,
  });
}

class PredictionService {
  static final Map<String, HarvestPrediction> _cache = {};

  static Future<HarvestPrediction> predictHarvest(
    PaddyField field, {
    WeatherData? weather,
  }) async {
    final key =
        '${field.id}_${field.plantedDate.millisecondsSinceEpoch ~/ 86400000}';
    if (_cache.containsKey(key)) return _cache[key]!;

    final days = DateTime.now().difference(field.plantedDate).inDays;
    final weatherInfo = weather != null
        ? 'Temp: ${weather.temp.toStringAsFixed(1)}°C, '
            'Humidity: ${weather.humidity}%, '
            'Wind: ${weather.windSpeed.toStringAsFixed(1)} km/h, '
            'Condition: ${weather.condition}'
        : 'Weather data not available';

    final prompt = 'You are an expert paddy farming advisor for Malaysia '
        'with 20 years of experience.\n\n'
        'Field Data:\n'
        '- Variety: ${field.variety}\n'
        '- Days since planting: $days days\n'
        '- Current growth stage: ${field.stage.label}\n'
        '- Health score: ${field.healthScore}/100\n'
        '- Location: ${field.location}\n'
        '- Field area: ${field.areaMorgen} morgen\n'
        '- Current weather: $weatherInfo\n\n'
        'Provide a harvest prediction. Return ONLY a valid JSON object '
        '(no markdown, no code fences):\n'
        '{\n'
        '  "days_to_harvest": 45,\n'
        '  "harvest_window": "Jun 20 \u2013 Jul 5, 2026",\n'
        '  "expected_yield_tons_per_ha": 5.5,\n'
        '  "risk_factors": ["string"],\n'
        '  "advice": "One actionable sentence for this farmer right now.",\n'
        '  "confidence": 82\n'
        '}\n\n'
        'Malaysian paddy typical cycle: MR219=105\u2013110d, '
        'MR263=95\u2013100d, MR297=100\u2013105d. '
        'Standard yield: 5\u20137 tons/ha.';

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: kGeminiKey,
        generationConfig: GenerationConfig(
          temperature: 0.2,
          maxOutputTokens: 512,
        ),
      );
      final response =
          await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final prediction = _parse(text, days);
      _cache[key] = prediction;
      return prediction;
    } catch (_) {
      return _fallback(days);
    }
  }

  static HarvestPrediction _parse(String text, int daysSincePlanting) {
    try {
      String s = text.trim();
      final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
      final m = fence.firstMatch(s);
      if (m != null) s = m.group(1)!.trim();
      final start = s.indexOf('{');
      final end = s.lastIndexOf('}');
      if (start >= 0 && end > start) s = s.substring(start, end + 1);

      final json = jsonDecode(s) as Map<String, dynamic>;
      final dth =
          (json['days_to_harvest'] as num?)?.toInt() ??
              (110 - daysSincePlanting).clamp(0, 110);
      return HarvestPrediction(
        daysToHarvest: dth,
        estimatedDate: DateTime.now().add(Duration(days: dth)),
        harvestWindow:
            json['harvest_window']?.toString() ?? 'In ~$dth days',
        expectedYieldTonsPerHa:
            (json['expected_yield_tons_per_ha'] as num?)?.toDouble() ??
                5.5,
        riskFactors: (json['risk_factors'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        advice: json['advice']?.toString() ??
            'Monitor your crop daily for best yield.',
        confidence: (json['confidence'] as num?)?.toInt() ?? 70,
      );
    } catch (_) {
      return _fallback(daysSincePlanting);
    }
  }

  static HarvestPrediction _fallback(int daysSincePlanting) {
    final dth = (110 - daysSincePlanting).clamp(0, 110);
    return HarvestPrediction(
      daysToHarvest: dth,
      estimatedDate: DateTime.now().add(Duration(days: dth)),
      harvestWindow: 'In ~$dth days',
      expectedYieldTonsPerHa: 5.5,
      riskFactors: [],
      advice: 'Keep monitoring your field and maintain water levels.',
      confidence: 60,
    );
  }
}
