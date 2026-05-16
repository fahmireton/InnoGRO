import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/field.dart';
import '../transitions.dart';
import 'economic_tools_screen.dart';
import 'knowledge_hub_screen.dart';
import 'weather_detail_screen.dart';
import 'alerts_screen.dart';

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 18) return 'Good afternoon';
  return 'Good evening';
}

class HomeScreen extends StatefulWidget {
  final VoidCallback? onScanTap;
  const HomeScreen({super.key, this.onScanTap});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<Animation<double>> _fades = [];
  final List<Animation<Offset>> _slides = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    for (int i = 0; i < 8; i++) {
      final start = (i * 0.09).clamp(0.0, 0.65);
      final end = (start + 0.35).clamp(0.0, 1.0);
      _fades.add(Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _ctrl, curve: Interval(start, end, curve: Curves.easeOut))));
      _slides.add(Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: _ctrl, curve: Interval(start, end, curve: Curves.easeOut))));
    }
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _a(int i, Widget child) => FadeTransition(
    opacity: _fades[i],
    child: SlideTransition(position: _slides[i], child: child),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            // Header
            _a(0, Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${_greeting()}, Farmer',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                const Text('Your Farm',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary, letterSpacing: -0.8)),
              ]),
            )),

            const SizedBox(height: 16),

            // Weather pill card
            _a(1, Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _WeatherCard(),
            )),

            // At a glance
            _a(2, _Section(title: 'At a glance', child: _GlanceGrid())),

            // Disease risk
            _a(3, _Section(title: "Today's disease risk", child: _DiseaseRiskCard(score: 30))),

            // Scan CTA
            _a(4, Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ScanBanner(onTap: widget.onScanTap),
            )),

            const SizedBox(height: 20),

            // Recent scans
            _a(5, _Section(
              title: 'Recent scans',
              child: _EmptyScanCard(),
            )),

            // Smart alerts
            _a(6, _Section(
              title: 'Smart alerts',
              action: GestureDetector(
                onTap: () => Navigator.push(context, slideRoute(const AlertsScreen())),
                child: const Text('All',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
              child: _AlertsCard(),
            )),

            // Explore
            _a(7, _Section(title: 'Explore', child: _ExploreGrid())),
          ],
        ),
      ),
    );
  }
}

// ── Section wrapper ──────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget child;
  const _Section({required this.title, this.action, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title.isNotEmpty || action != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Expanded(child: Text(title,
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary, letterSpacing: 0.5))),
              if (action != null) action!,
            ]),
          ),
        child,
      ]),
    );
  }
}

// ── Card helper ──────────────────────────────────────────────────────────────

BoxDecoration _cardDecoration({double radius = 24}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
  boxShadow: [
    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
  ],
);

// ── Weather card ─────────────────────────────────────────────────────────────

class _WeatherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, slideRoute(const WeatherDetailScreen())),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud_rounded, color: AppColors.info, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('30°C · Cloudy',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
            const SizedBox(height: 1),
            Text('Sekinchan, Selangor · Humidity 76%',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          const Row(children: [
            Text('7-day', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
            SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
          ]),
        ]),
      ),
    );
  }
}

// ── At a glance grid ─────────────────────────────────────────────────────────

class _GlanceGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.grass_rounded, '${sampleFields.length}', 'Fields', AppColors.accent, AppColors.accentLight),
      (Icons.document_scanner_rounded, '0', 'Scans (30d)', AppColors.primary, AppColors.secondary),
      (Icons.water_drop_rounded, '0', 'Active treatments', AppColors.info, AppColors.infoLight),
      (Icons.warning_rounded, '1', 'Critical fields', AppColors.red, AppColors.redLight),
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: items.map((item) => Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: item.$5,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.$1, size: 20, color: item.$4),
          ),
          const SizedBox(height: 12),
          Text(item.$2,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
              color: item.$4 == AppColors.red ? AppColors.red : AppColors.textPrimary,
              letterSpacing: -0.5)),
          Text(item.$3, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      )).toList(),
    );
  }
}

// ── Disease risk card ─────────────────────────────────────────────────────────

class _DiseaseRiskCard extends StatelessWidget {
  final int score;
  const _DiseaseRiskCard({required this.score});

  String get _label {
    if (score <= 33) return 'Low';
    if (score < 65) return 'Moderate';
    return 'High';
  }

  Color get _color {
    if (score <= 33) return AppColors.accent;
    if (score < 65) return AppColors.amber;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Weather-derived',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(_label,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                color: _color, letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text('Score $score/100',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          _RiskRing(score: score, color: _color),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _mini(Icons.thermostat_rounded, '30°', 'Temp')),
          const SizedBox(width: 8),
          Expanded(child: _mini(Icons.water_drop_outlined, '76%', 'Humidity')),
          const SizedBox(width: 8),
          Expanded(child: _mini(Icons.air_rounded, '9 km/h', 'Wind')),
        ]),
      ]),
    );
  }

  Widget _mini(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ]),
    );
  }
}

// ── Risk ring — full circle starting from top ─────────────────────────────────

class _RiskRing extends StatelessWidget {
  final int score;
  final Color color;
  const _RiskRing({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84, height: 84,
      child: CustomPaint(
        painter: _RingPainter(score / 100, color),
        child: Center(
          child: Text('$score',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RingPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final trackPaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Full circle track starting from top (-π/2)
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, 2 * math.pi, false, trackPaint);
    // Progress arc
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, 2 * math.pi * progress, false, fillPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Scan CTA banner ───────────────────────────────────────────────────────────

class _ScanBanner extends StatelessWidget {
  final VoidCallback? onTap;
  const _ScanBanner({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI SCAN',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            const SizedBox(height: 4),
            const Text('Diagnose a leaf',
              style: TextStyle(color: Colors.white, fontSize: 22,
                fontWeight: FontWeight.w800, letterSpacing: -0.3)),
            const SizedBox(height: 2),
            Text('Camera or upload · 5-second result',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
          ])),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 28),
          ),
        ]),
      ),
    );
  }
}

// ── Empty scan card ────────────────────────────────────────────────────────────

class _EmptyScanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: _cardDecoration(),
      child: Column(children: [
        Icon(Icons.document_scanner_rounded, size: 32, color: AppColors.textSecondary.withValues(alpha: 0.5)),
        const SizedBox(height: 8),
        const Text('No scans yet. Tap Scan to diagnose your first leaf.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ]),
    );
  }
}

// ── Alerts card ────────────────────────────────────────────────────────────────

class _AlertsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, slideRoute(const AlertsScreen())),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: const Row(children: [
          Expanded(child: Text("All clear. We'll notify you of risks.",
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}

// ── Explore grid ──────────────────────────────────────────────────────────────

class _ExploreGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.trending_up_rounded, 'Economic tools',
        () => Navigator.push(context, slideRoute(const EconomicToolsScreen()))),
      (Icons.menu_book_rounded, 'Knowledge hub',
        () => Navigator.push(context, slideRoute(const KnowledgeHubScreen()))),
      (Icons.cloud_rounded, 'Weather',
        () => Navigator.push(context, slideRoute(const WeatherDetailScreen()))),
      (Icons.notifications_rounded, 'Alerts',
        () => Navigator.push(context, slideRoute(const AlertsScreen()))),
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: items.map((item) => GestureDetector(
        onTap: item.$3,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.$1, color: AppColors.primary, size: 20),
            ),
            Text(item.$2,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
                color: AppColors.textPrimary)),
          ]),
        ),
      )).toList(),
    );
  }
}
