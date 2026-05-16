import 'package:flutter/material.dart';
import '../theme.dart';

class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  static const _forecast = [
    _DayForecast('Today', '30°', '24°', '0.5mm', Icons.wb_sunny_rounded, false),
    _DayForecast('Mon', '28°', '22°', '2.1mm', Icons.cloud_rounded, true),
    _DayForecast('Tue', '26°', '21°', '8.3mm', Icons.thunderstorm_rounded, false),
    _DayForecast('Wed', '29°', '23°', '1.2mm', Icons.wb_cloudy_rounded, true),
    _DayForecast('Thu', '31°', '25°', '0.0mm', Icons.wb_sunny_rounded, true),
    _DayForecast('Fri', '30°', '24°', '0.8mm', Icons.wb_sunny_rounded, true),
    _DayForecast('Sat', '27°', '22°', '4.2mm', Icons.cloud_rounded, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: context.bg,
                  border: Border(bottom: BorderSide(color: context.border.withValues(alpha: 0.5))),
                ),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: context.secondary, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Weather', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary, letterSpacing: -0.3)),
                    Text('Sekinchan, Selangor',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ])),
                ]),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Current weather
                  _card(context, child: Column(children: [
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('30°C',
                          style: TextStyle(fontSize: 56, fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary, letterSpacing: -2)),
                        const Text('Partly Cloudy',
                          style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      ])),
                      const Icon(Icons.wb_cloudy_rounded, size: 72, color: AppColors.info),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _MiniStat(context: context, icon: Icons.water_drop_outlined, label: 'Humidity', value: '76%')),
                      const SizedBox(width: 8),
                      Expanded(child: _MiniStat(context: context, icon: Icons.water_rounded, label: 'Rainfall', value: '0.5mm')),
                      const SizedBox(width: 8),
                      Expanded(child: _MiniStat(context: context, icon: Icons.air_rounded, label: 'Wind', value: '9 km/h')),
                    ]),
                  ])),

                  const SizedBox(height: 24),
                  _sectionLabel('DISEASE RISK'),
                  const SizedBox(height: 10),
                  _card(context, child: Column(children: [
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Low', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                          color: AppColors.accent)),
                        const Text('Based on humidity, rain, and temperature',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ])),
                      const Text('30', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                    ]),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 0.30,
                        backgroundColor: context.secondary,
                        valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                        minHeight: 8,
                      ),
                    ),
                  ])),

                  const SizedBox(height: 24),
                  _sectionLabel('7-DAY FORECAST'),
                  const SizedBox(height: 10),
                  _card(context, child: Column(
                    children: _forecast.asMap().entries.map((e) {
                      final i = e.key;
                      final d = e.value;
                      return Column(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(children: [
                            SizedBox(
                              width: 52,
                              child: Text(d.day,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                            ),
                            Icon(d.icon, size: 22, color: AppColors.info),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(children: [
                                const Icon(Icons.water_drop_outlined, size: 13, color: AppColors.textSecondary),
                                const SizedBox(width: 2),
                                Text(d.rain, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ]),
                            ),
                            Text(d.high,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                            const SizedBox(width: 4),
                            Text(d.low, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ]),
                        ),
                        if (i < _forecast.length - 1)
                          Divider(height: 1, color: context.border),
                      ]);
                    }).toList(),
                  )),

                  const SizedBox(height: 24),
                  _sectionLabel('OPTIMAL SPRAYING WINDOWS'),
                  const SizedBox(height: 10),
                  _card(context, child: Column(
                    children: _forecast.take(5).toList().asMap().entries.map((e) {
                      final i = e.key;
                      final d = e.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: i < 4 ? 12 : 0),
                        child: Row(children: [
                          Text(d.day, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: d.goodToSpray ? AppColors.accentLight : AppColors.redLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              d.goodToSpray ? 'Good to spray' : 'Skip — rain',
                              style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600,
                                color: d.goodToSpray ? AppColors.accent : AppColors.red),
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

  Widget _card(BuildContext context, {required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.card,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: context.border.withValues(alpha: 0.4)),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
        BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
      ],
    ),
    child: child,
  );

  Widget _sectionLabel(String t) => Text(t,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
      color: AppColors.textSecondary, letterSpacing: 1.2));
}

class _MiniStat extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String label, value;
  const _MiniStat({required this.context, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: context.secondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _DayForecast {
  final String day, high, low, rain;
  final IconData icon;
  final bool goodToSpray;
  const _DayForecast(this.day, this.high, this.low, this.rain, this.icon, this.goodToSpray);
}
