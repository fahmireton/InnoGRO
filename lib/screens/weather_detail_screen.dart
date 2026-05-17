import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherDetailScreen extends StatefulWidget {
  const WeatherDetailScreen({super.key});
  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  WeatherData? _weather;

  static const _forecast = [
    _DayForecast('Today', '30°', '24°', '0.5mm', 0, true),
    _DayForecast('Mon',   '28°', '22°', '2.1mm', 3, false),
    _DayForecast('Tue',   '26°', '21°', '8.3mm', 2, false),
    _DayForecast('Wed',   '29°', '23°', '1.2mm', 3, true),
    _DayForecast('Thu',   '31°', '25°', '0.0mm', 0, true),
    _DayForecast('Fri',   '30°', '24°', '0.8mm', 1, true),
    _DayForecast('Sat',   '27°', '22°', '4.2mm', 3, false),
  ];

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final w = await WeatherService.fetchCurrent();
      if (mounted) setState(() => _weather = w);
    } catch (_) {}
  }

  int get _riskScore => _weather?.diseaseRiskScore ?? 30;
  String get _riskLabel => _riskScore <= 33
      ? 'Low'
      : _riskScore < 65
          ? 'Moderate'
          : 'High';
  Color get _riskColor => _riskScore <= 33
      ? AppColors.accent
      : _riskScore < 65
          ? AppColors.amber
          : AppColors.red;

  @override
  Widget build(BuildContext context) {
    final w = _weather;
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: context.bg,
                  border: Border(
                      bottom: BorderSide(
                          color: context.border.withValues(alpha: 0.5))),
                ),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: context.secondary,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                    Text('Weather',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                            letterSpacing: -0.3)),
                    Text(
                        w != null
                            ? w.cityName
                            : 'Sekinchan, Selangor',
                        style: TextStyle(
                            fontSize: 12, color: context.textSecondary)),
                  ])),
                ]),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Current weather — live data
                  _card(context,
                      child: Column(children: [
                    Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                        Text(
                            w != null
                                ? '${w.temp.round()}°C'
                                : '30°C',
                            style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary,
                                letterSpacing: -2)),
                        Text(
                            w != null ? w.condition : 'Partly Cloudy',
                            style: TextStyle(
                                fontSize: 16,
                                color: context.textSecondary)),
                      ])),
                      _WeatherIconBadge(weather: w),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: _MiniStat(
                              icon: Icons.water_drop_outlined,
                              label: 'Humidity',
                              value: w != null
                                  ? '${w.humidity}%'
                                  : '76%')),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _MiniStat(
                              icon: Icons.water_rounded,
                              label: 'Rainfall',
                              value: '0.5mm')),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _MiniStat(
                              icon: Icons.air_rounded,
                              label: 'Wind',
                              value: w != null
                                  ? '${(w.windSpeed * 3.6).toStringAsFixed(0)} km/h'
                                  : '9 km/h')),
                    ]),
                  ])),

                  const SizedBox(height: 24),
                  _sectionLabel(context, 'DISEASE RISK'),
                  const SizedBox(height: 10),

                  // Disease risk — synced to real weather data
                  _card(context,
                      child: Column(children: [
                    Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                        Text(_riskLabel,
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: _riskColor)),
                        Text(
                            'Based on humidity, rain, and temperature',
                            style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary)),
                      ])),
                      _RiskRing(score: _riskScore, color: _riskColor),
                    ]),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _riskScore / 100,
                        backgroundColor: context.secondary,
                        valueColor:
                            AlwaysStoppedAnimation(_riskColor),
                        minHeight: 8,
                      ),
                    ),
                  ])),

                  const SizedBox(height: 24),
                  _sectionLabel(context, 'FARMING SUGGESTIONS'),
                  const SizedBox(height: 10),
                  _FarmingSuggestionsCard(weather: _weather),

                  const SizedBox(height: 24),
                  _sectionLabel(context, '7-DAY FORECAST'),
                  const SizedBox(height: 10),
                  _card(context,
                      child: Column(
                        children: _forecast.asMap().entries.map((e) {
                          final i = e.key;
                          final d = e.value;
                          return Column(children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              child: Row(children: [
                                SizedBox(
                                  width: 52,
                                  child: Text(d.day,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: context.textPrimary)),
                                ),
                                _forecastIcon(d.wmoCode),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(children: [
                                    Icon(Icons.water_drop_outlined,
                                        size: 13,
                                        color: context.textSecondary),
                                    const SizedBox(width: 2),
                                    Text(d.rain,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: context.textSecondary)),
                                  ]),
                                ),
                                Text(d.high,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: context.textPrimary)),
                                const SizedBox(width: 4),
                                Text(d.low,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: context.textSecondary)),
                              ]),
                            ),
                            if (i < _forecast.length - 1)
                              Divider(height: 1, color: context.border),
                          ]);
                        }).toList(),
                      )),

                  const SizedBox(height: 24),
                  _sectionLabel(context, 'OPTIMAL SPRAYING WINDOWS'),
                  const SizedBox(height: 10),
                  _card(context,
                      child: Column(
                        children: _forecast
                            .take(5)
                            .toList()
                            .asMap()
                            .entries
                            .map((e) {
                          final i = e.key;
                          final d = e.value;
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: i < 4 ? 12 : 0),
                            child: Row(children: [
                              Text(d.day,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: context.textPrimary)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: d.goodToSpray
                                      ? AppColors.accentLight
                                      : AppColors.redLight,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  d.goodToSpray
                                      ? 'Good to spray'
                                      : 'Skip — rain',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: d.goodToSpray
                                          ? AppColors.accent
                                          : AppColors.red),
                                ),
                              ),
                            ]),
                          );
                        }).toList(),
                      )),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _forecastIcon(int wmoCode) {
    final IconData icon;
    final Color color;
    if (wmoCode == 0) {
      icon = Icons.wb_sunny_rounded;
      color = const Color(0xFFFFA726);
    } else if (wmoCode == 1) {
      icon = Icons.wb_cloudy_rounded;
      color = const Color(0xFF90A4AE);
    } else if (wmoCode == 2) {
      icon = Icons.flash_on_rounded;
      color = const Color(0xFF7E57C2);
    } else {
      icon = Icons.cloud_rounded;
      color = const Color(0xFF78909C);
    }
    return Icon(icon, size: 22, color: color);
  }

  Widget _card(BuildContext context, {required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: context.border.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2)),
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 28,
                offset: const Offset(0, 10)),
          ],
        ),
        child: child,
      );

  Widget _sectionLabel(BuildContext context, String t) => Text(t,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: context.textSecondary,
          letterSpacing: 1.2));
}

// ── Weather icon badge ────────────────────────────────────────────────────────

class _WeatherIconBadge extends StatelessWidget {
  final WeatherData? weather;
  const _WeatherIconBadge({this.weather});

  @override
  Widget build(BuildContext context) {
    final iconData = weather?.weatherIconData ?? Icons.wb_cloudy_rounded;
    final iconColor = weather?.weatherIconColor ?? const Color(0xFF78909C);
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, size: 44, color: iconColor),
    );
  }
}

// ── Mini stat tile ────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _MiniStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: context.secondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Icon(icon, size: 18, color: context.textSecondary),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: context.textPrimary)),
        Text(label,
            style:
                TextStyle(fontSize: 10, color: context.textSecondary)),
      ]),
    );
  }
}

// ── Risk ring (mirrored from home_screen) ────────────────────────────────────

class _RiskRing extends StatelessWidget {
  final int score;
  final Color color;
  const _RiskRing({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: CustomPaint(
        painter: _RingPainter(score / 100, color, context.secondary),
        child: Center(
          child: Text('$score',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  _RingPainter(this.progress, this.color, this.trackColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi,
        false,
        Paint()
          ..color = trackColor
          ..strokeWidth = 7
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = 7
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Farming suggestions card ─────────────────────────────────────────────────

class _FarmingSuggestionsCard extends StatelessWidget {
  final WeatherData? weather;
  const _FarmingSuggestionsCard({this.weather});

  List<_Tip> _tips(WeatherData? w) {
    if (w == null) {
      return [_Tip(Icons.cloud_outlined, 'Loading weather data…', const Color(0xFF78909C))];
    }
    final cond = w.condition.toLowerCase();
    final isRaining = cond.contains('rain') || cond.contains('drizzle') || cond.contains('thunderstorm');
    final isDry = w.humidity < 60 && !isRaining;
    final isHumid = w.humidity > 80;
    final isHot = w.temp > 33;

    final tips = <_Tip>[];

    if (isDry) {
      tips.add(_Tip(
        Icons.water_drop_outlined,
        'Kemarau detected — irrigate fields now, especially at tillering stage.',
        AppColors.amber,
      ));
      if (isHot) {
        tips.add(_Tip(
          Icons.thermostat_rounded,
          'Heat stress at ${w.temp.round()}°C — water early morning to reduce soil temperature.',
          AppColors.red,
        ));
      }
    }

    if (isRaining) {
      tips.add(_Tip(
        Icons.umbrella_rounded,
        'Rain today — skip pesticide and fertiliser spraying to prevent runoff.',
        AppColors.info,
      ));
      tips.add(_Tip(
        Icons.bug_report_outlined,
        'Post-rain humidity favours fungal diseases — inspect leaves tomorrow morning.',
        AppColors.amber,
      ));
    }

    if (isHumid && !isRaining) {
      tips.add(_Tip(
        Icons.air_rounded,
        'High humidity (${w.humidity}%) — blast and blight risk elevated; consider preventive fungicide.',
        AppColors.red,
      ));
    }

    if (!isDry && !isRaining && w.windSpeed < 4) {
      tips.add(_Tip(
        Icons.eco_rounded,
        'Good spraying window — calm wind and dry air, ideal for pesticide application.',
        AppColors.accent,
      ));
    }

    if (w.windSpeed > 8) {
      tips.add(_Tip(
        Icons.storm_rounded,
        'Strong wind (${w.windSpeed.toStringAsFixed(0)} m/s) — delay spraying until wind calms.',
        AppColors.amber,
      ));
    }

    if (tips.isEmpty) {
      tips.add(_Tip(
        Icons.check_circle_outline_rounded,
        'Weather conditions are favourable for paddy farming today.',
        AppColors.accent,
      ));
    }

    return tips;
  }

  @override
  Widget build(BuildContext context) {
    final tips = _tips(weather);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 28, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: tips.asMap().entries.map((e) {
          final i = e.key;
          final tip = e.value;
          return Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tip.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(tip.icon, size: 18, color: tip.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(tip.message,
                      style: TextStyle(fontSize: 13, color: context.textPrimary, height: 1.4)),
                ),
              ),
            ]),
            if (i < tips.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: context.border),
              ),
          ]);
        }).toList(),
      ),
    );
  }
}

class _Tip {
  final IconData icon;
  final String message;
  final Color color;
  const _Tip(this.icon, this.message, this.color);
}

// ── Data model ────────────────────────────────────────────────────────────────

class _DayForecast {
  final String day, high, low, rain;
  final int wmoCode;
  final bool goodToSpray;
  const _DayForecast(
      this.day, this.high, this.low, this.rain, this.wmoCode, this.goodToSpray);
}
