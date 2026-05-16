import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/field.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onScanTap;
  const HomeScreen({super.key, this.onScanTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            _WeatherCard(),
            const SizedBox(height: 24),
            _sectionLabel('AT A GLANCE'),
            const SizedBox(height: 12),
            _buildGlanceGrid(),
            const SizedBox(height: 24),
            _sectionLabel('TODAY\'S DISEASE RISK'),
            const SizedBox(height: 12),
            _DiseaseRiskCard(score: 30),
            const SizedBox(height: 16),
            _ScanBanner(onTap: onScanTap),
            const SizedBox(height: 24),
            _sectionLabel('RECENT SCANS'),
            const SizedBox(height: 12),
            _RecentScansCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionLabel('SMART ALERTS'),
                Text('All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 12),
            _AlertsCard(),
            const SizedBox(height: 24),
            _sectionLabel('EXPLORE'),
            const SizedBox(height: 12),
            _ExploreGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Good morning, Farmer',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w400)),
        const SizedBox(height: 3),
        const Text('Your Farm',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.8)),
      ],
    );
  }

  Widget _buildGlanceGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.15,
      children: [
        _GlanceCard(icon: Icons.grass_rounded, value: '${sampleFields.length}', label: 'Fields', iconColor: AppColors.primary),
        _GlanceCard(icon: Icons.document_scanner_rounded, value: '0', label: 'Scans (30d)', iconColor: AppColors.primary),
        _GlanceCard(icon: Icons.water_drop_rounded, value: '0', label: 'Active treatments', iconColor: AppColors.primary),
        _GlanceCard(icon: Icons.warning_rounded, value: '1', label: 'Critical fields', iconColor: AppColors.red, valueColor: AppColors.red),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ));
  }
}

class _WeatherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud_rounded, color: Color(0xFF5BAFF5), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('30°C · Cloudy',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('Sekinchan, Selangor · Humidity 76%',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Row(
            children: [
              Text('7-day', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlanceCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color iconColor;
  final Color? valueColor;
  const _GlanceCard({required this.icon, required this.value, required this.label, required this.iconColor, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800,
                color: valueColor ?? AppColors.textPrimary, letterSpacing: -0.5)),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiseaseRiskCard extends StatelessWidget {
  final int score;
  const _DiseaseRiskCard({required this.score});

  String get _label {
    if (score <= 33) return 'Low';
    if (score < 65) return 'Moderate';
    return 'High';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weather-derived',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(_label,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                    const SizedBox(height: 2),
                    Text('Score $score/100',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              _RiskDial(score: score),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _weatherMetric(Icons.thermostat_rounded, '30°', 'Temp')),
              Expanded(child: _weatherMetric(Icons.water_drop_outlined, '76%', 'Humidity')),
              Expanded(child: _weatherMetric(Icons.air_rounded, '9', 'Wind')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weatherMetric(IconData icon, String value, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _RiskDial extends StatelessWidget {
  final int score;
  const _RiskDial({required this.score});

  Color get _color {
    if (score <= 33) return AppColors.accent;
    if (score < 65) return AppColors.amber;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80, height: 80,
      child: CustomPaint(
        painter: _DialPainter(score / 100, _color),
        child: Center(
          child: Text('$score',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final double progress;
  final Color color;
  _DialPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final trackPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi * 0.75;
    const sweepTotal = math.pi * 1.5;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepTotal, false, trackPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepTotal * progress, false, fillPaint);
  }

  @override
  bool shouldRepaint(_DialPainter old) => old.progress != progress;
}

class _ScanBanner extends StatelessWidget {
  final VoidCallback? onTap;
  const _ScanBanner({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI SCAN',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  const Text('Diagnose a leaf',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  const SizedBox(height: 2),
                  Text('Camera or upload · 5-second result',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                ],
              ),
            ),
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentScansCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(Icons.document_scanner_rounded, size: 32, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 10),
          const Text('No scans yet. Tap Scan to diagnose your first leaf.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: const Text('All clear. We\'ll notify you of risks.',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    );
  }
}

class _ExploreGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.trending_up_rounded, 'Economic tools'),
      (Icons.menu_book_rounded, 'Knowledge hub'),
      (Icons.cloud_rounded, 'Weather'),
      (Icons.notifications_rounded, 'Alerts'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: items.map((item) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.$1, color: AppColors.primary, size: 20),
            ),
            Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
          ],
        ),
      )).toList(),
    );
  }
}
