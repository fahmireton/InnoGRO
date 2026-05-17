import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../models/field.dart';
import '../models/weather.dart';
import '../models/user_profile.dart';
import '../services/weather_service.dart';
import '../services/auth_service.dart';
import '../services/field_service.dart';
import '../services/scan_history_service.dart';
import '../transitions.dart';
import '../widgets/crop_slider.dart';
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
  final VoidCallback? onFieldsTap;
  const HomeScreen({super.key, this.onScanTap, this.onFieldsTap});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<Animation<double>> _fades = [];
  final List<Animation<Offset>> _slides = [];
  WeatherData? _weather;
  UserProfile? _userProfile;
  final _authService = AuthService();
  List<PaddyField>? _fields;
  StreamSubscription<List<PaddyField>>? _fieldsSub;
  List<ScanHistoryRecord> _recentScans = [];
  int _scanCount30d = 0;

  @override
  void initState() {
    super.initState();
    final svc = FieldService();
    _fields = svc.cachedFields;
    _fieldsSub = svc.watchFields().listen((f) {
      if (mounted) setState(() => _fields = f);
    });
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    for (int i = 0; i < 9; i++) {
      final start = (i * 0.08).clamp(0.0, 0.65);
      final end = (start + 0.35).clamp(0.0, 1.0);
      _fades.add(Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: _ctrl,
              curve: Interval(start, end, curve: Curves.easeOut))));
      _slides.add(
          Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(
              CurvedAnimation(
                  parent: _ctrl,
                  curve: Interval(start, end, curve: Curves.easeOut))));
    }
    _ctrl.forward();
    _fetchWeather();
    _fetchUserProfile();
    _fetchScanHistory();
    ScanHistoryService().addListener(_fetchScanHistory);
  }

  Future<void> _fetchScanHistory() async {
    final svc = ScanHistoryService();
    final scans = await svc.getScans();
    final count = await svc.countLast30Days();
    if (mounted) setState(() { _recentScans = scans.take(4).toList(); _scanCount30d = count; });
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await _authService.getUserProfile(user.uid);
      if (mounted) setState(() => _userProfile = profile);
    }
  }

  Future<void> _fetchWeather() async {
    try {
      final w = await WeatherService.fetchCurrent();
      if (mounted) setState(() => _weather = w);
    } catch (_) {}
  }

  @override
  void dispose() {
    ScanHistoryService().removeListener(_fetchScanHistory);
    _fieldsSub?.cancel();
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
      backgroundColor: context.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            // Header with animated greeting
            _a(
                0,
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                            '${_greeting()}, ${_userProfile?.name ?? 'Farmer'}',
                            style: TextStyle(
                                fontSize: 14, color: context.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                              _userProfile?.farmName ?? 'Your Farm',
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: context.textPrimary,
                                  letterSpacing: -0.8)),
                        ]),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, slideRoute(const AlertsScreen())),
                        child: Stack(clipBehavior: Clip.none, children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: context.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: context.border.withValues(alpha: 0.4)),
                              boxShadow: iosShadow,
                            ),
                            child: Icon(Icons.notifications_outlined, color: context.textPrimary, size: 22),
                          ),
                          Positioned(
                            top: -4, right: -4,
                            child: Container(
                              width: 18, height: 18,
                              decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                              child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 16),

            // Weather pill card
            _a(
                1,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _WeatherCard(weather: _weather),
                )),

            // My Crops section
            _a(
                2,
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: Row(
                          children: [
                            Text(
                              'My Crops',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accentLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Live tracking',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: widget.onFieldsTap,
                              child: const Row(children: [
                                Text('See all',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary)),
                                Icon(Icons.chevron_right_rounded,
                                    size: 16, color: AppColors.primary),
                              ]),
                            ),
                          ],
                        ),
                      ),
                      CropSlider(
                        fields: _fields ?? [],
                        onAddTap: widget.onFieldsTap,
                      ),
                    ],
                  ),
                )),

            // At a glance
            _a(3, _Section(title: 'AT A GLANCE', child: _GlanceGrid(fields: _fields, scanCount: _scanCount30d))),

            // Disease risk
            _a(4,
                _Section(
                    title: "Today's disease risk",
                    child: _DiseaseRiskCard(weather: _weather))),

            // Scan CTA
            _a(
                5,
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _ScanBanner(onTap: widget.onScanTap),
                )),

            const SizedBox(height: 20),

            // Recent scans
            _a(6,
                _Section(
                  title: 'Recent scans',
                  child: _RecentScansCard(scans: _recentScans, onScanTap: widget.onScanTap),
                )),

            // Smart alerts
            _a(
                7,
                _Section(
                  title: 'Smart alerts',
                  action: GestureDetector(
                    onTap: () => Navigator.push(
                        context, slideRoute(const AlertsScreen())),
                    child: const Text('All',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ),
                  child: _AlertsCard(),
                )),

            // Explore
            _a(8, _Section(title: 'Explore', child: _ExploreGrid())),
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
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                          letterSpacing: 0.5))),
              if (action != null) action!,
            ]),
          ),
        child,
      ]),
    );
  }
}

// ── Card helper ──────────────────────────────────────────────────────────────

BoxDecoration _cardDecoration(BuildContext context, {double radius = 24}) =>
    BoxDecoration(
      color: context.card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: context.border.withValues(alpha: 0.4)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1)),
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8)),
      ],
    );

// ── Weather card ─────────────────────────────────────────────────────────────

class _WeatherCard extends StatelessWidget {
  final WeatherData? weather;
  const _WeatherCard({this.weather});

  @override
  Widget build(BuildContext context) {
    final w = weather;
    final tempStr = w != null
        ? '${w.temp.round()}°C · ${w.condition}'
        : '-- · Loading…';
    final locationStr = w != null
        ? '${w.cityName} · Humidity ${w.humidity}%'
        : 'Fetching weather…';
    final iconData = w?.weatherIconData ?? Icons.wb_cloudy_rounded;
    final iconColor = w?.weatherIconColor ?? const Color(0xFF78909C);

    return GestureDetector(
      onTap: () =>
          Navigator.push(context, slideRoute(const WeatherDetailScreen())),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(context),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(iconData, color: iconColor, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Text(tempStr,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: context.textPrimary)),
            const SizedBox(height: 1),
            Text(locationStr,
                style: TextStyle(
                    fontSize: 12, color: context.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ])),
          const Row(children: [
            Text('7-day',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
            SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.primary),
          ]),
        ]),
      ),
    );
  }
}

// ── At a glance grid ─────────────────────────────────────────────────────────

class _GlanceGrid extends StatelessWidget {
  final List<PaddyField>? fields;
  final int scanCount;
  const _GlanceGrid({this.fields, this.scanCount = 0});

  @override
  Widget build(BuildContext context) {
    final count = fields?.length ?? 0;
    final critical = fields?.where((f) => f.healthStatus.index == 2).length ?? 0;
    return _buildGrid(context, count, critical);
  }

  Widget _buildGrid(BuildContext context, int fieldCount, int critical) {
    final items = [
      (Icons.grass_rounded, '$fieldCount', 'Fields',
          AppColors.accent, AppColors.accentLight),
      (Icons.crop_free_rounded, '$scanCount', 'Scans (30d)', AppColors.primary,
          AppColors.secondary),
      (Icons.water_drop_rounded, '0', 'Active treatments', AppColors.info,
          AppColors.infoLight),
      (Icons.warning_rounded, '$critical', 'Critical fields', AppColors.red,
          AppColors.redLight),
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: items
          .map((item) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: _cardDecoration(context),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: item.$5,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.$1, size: 18, color: item.$4),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.$2,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: item.$4 == AppColors.red
                                  ? AppColors.red
                                  : context.textPrimary,
                              letterSpacing: -0.3)),
                      Text(item.$3,
                          style: TextStyle(
                              fontSize: 10, color: context.textSecondary)),
                    ],
                  )),
                ]),
              ))
          .toList(),
    );
  }
}

// ── Disease risk card ─────────────────────────────────────────────────────────

class _DiseaseRiskCard extends StatelessWidget {
  final WeatherData? weather;
  const _DiseaseRiskCard({this.weather});

  int get score => weather?.diseaseRiskScore ?? 30;

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
      decoration: _cardDecoration(context),
      child: Column(children: [
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Text('Weather-derived',
                style: TextStyle(
                    fontSize: 13, color: context.textSecondary)),
            const SizedBox(height: 4),
            Text(_label,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _color,
                    letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text('Score $score/100',
                style: TextStyle(
                    fontSize: 12, color: context.textSecondary)),
          ])),
          _RiskRing(score: score, color: _color),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: _mini(context, Icons.thermostat_rounded,
                  weather != null ? '${weather!.temp.round()}°C' : '--°C', 'Temp')),
          const SizedBox(width: 8),
          Expanded(
              child: _mini(context, Icons.water_drop_outlined,
                  weather != null ? '${weather!.humidity}%' : '--%', 'Humidity')),
          const SizedBox(width: 8),
          Expanded(
              child: _mini(context, Icons.air_rounded,
                  weather != null ? '${weather!.windSpeed.toStringAsFixed(1)} m/s' : '-- m/s', 'Wind')),
        ]),
      ]),
    );
  }

  Widget _mini(BuildContext context, IconData icon, String value,
      String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: context.secondary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Icon(icon, size: 16, color: context.textSecondary),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: context.textPrimary)),
        Text(label,
            style:
                TextStyle(fontSize: 10, color: context.textSecondary)),
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
      width: 84,
      height: 84,
      child: CustomPaint(
        painter: _RingPainter(score / 100, color, context.secondary),
        child: Center(
          child: Text('$score',
              style: TextStyle(
                  fontSize: 20,
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
    final radius = size.width / 2 - 8;
    final trackPaint = Paint()
      ..color = trackColor
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
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Text('AI SCAN',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2)),
            const SizedBox(height: 4),
            const Text('Diagnose a leaf',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3)),
            const SizedBox(height: 2),
            Text('Camera or upload · 5-second result',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13)),
          ])),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.document_scanner_rounded,
                color: Colors.white, size: 28),
          ),
        ]),
      ),
    );
  }
}

// ── Recent scans card ─────────────────────────────────────────────────────────

class _RecentScansCard extends StatelessWidget {
  final List<ScanHistoryRecord> scans;
  final VoidCallback? onScanTap;
  const _RecentScansCard({required this.scans, this.onScanTap});

  Color _severityColor(String severity) {
    switch (severity) {
      case 'High': return AppColors.red;
      case 'Medium': return AppColors.amber;
      case 'None': return AppColors.accent;
      default: return AppColors.accent;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    if (scans.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: _cardDecoration(context),
        child: Column(children: [
          Icon(Icons.center_focus_weak_rounded,
              size: 32, color: context.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          Text('No scans yet. Tap Scan to diagnose your first leaf.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.textSecondary)),
        ]),
      );
    }
    return Container(
      decoration: _cardDecoration(context),
      child: Column(
        children: List.generate(scans.length, (i) {
          final s = scans[i];
          final isLast = i == scans.length - 1;
          final color = _severityColor(s.severity);
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    s.diseaseName == 'Healthy'
                        ? Icons.check_circle_outline_rounded
                        : Icons.pest_control_rounded,
                    size: 20, color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.diseaseName,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary)),
                  Text('${s.confidence.toStringAsFixed(0)}% · ${s.severity.toLowerCase()}',
                      style: TextStyle(fontSize: 11, color: context.textSecondary)),
                ])),
                Text(_timeAgo(s.scannedAt),
                    style: TextStyle(fontSize: 11, color: context.textSecondary)),
              ]),
            ),
            if (!isLast) Divider(height: 1, color: context.border.withValues(alpha: 0.5)),
          ]);
        }),
      ),
    );
  }
}

// ── Alerts card ────────────────────────────────────────────────────────────────

class _AlertsCard extends StatelessWidget {
  static const _alerts = [
    _HomeAlert(
      icon: Icons.warning_rounded,
      color: AppColors.red,
      bg: AppColors.redLight,
      title: 'Brown planthopper nearby',
      body: 'Detected 5 km away — inspect leaf undersides daily.',
    ),
    _HomeAlert(
      icon: Icons.water_drop_outlined,
      color: AppColors.info,
      bg: AppColors.infoLight,
      title: 'Best spraying window tomorrow',
      body: 'Low wind 6–9 am — ideal for fungicide application.',
    ),
    _HomeAlert(
      icon: Icons.trending_up_rounded,
      color: AppColors.accent,
      bg: AppColors.accentLight,
      title: 'Paddy price up 4%',
      body: 'RM 1,360/tonne at Selangor mills today.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, slideRoute(const AlertsScreen())),
      child: Container(
        decoration: _cardDecoration(context),
        child: Column(
          children: List.generate(_alerts.length, (i) {
            final a = _alerts[i];
            final isLast = i == _alerts.length - 1;
            return Column(children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: a.bg, borderRadius: BorderRadius.circular(10)),
                    child: Icon(a.icon, color: a.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(a.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary)),
                    Text(a.body, style: TextStyle(fontSize: 11, color: context.textSecondary, height: 1.3)),
                  ])),
                  Icon(Icons.chevron_right_rounded, size: 16, color: context.textSecondary),
                ]),
              ),
              if (!isLast) Divider(height: 1, color: context.border.withValues(alpha: 0.5)),
            ]);
          }),
        ),
      ),
    );
  }
}

class _HomeAlert {
  final IconData icon;
  final Color color, bg;
  final String title, body;
  const _HomeAlert({required this.icon, required this.color, required this.bg, required this.title, required this.body});
}

// ── Explore grid ──────────────────────────────────────────────────────────────

class _ExploreGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.trending_up_rounded, 'Economic tools',
          () => Navigator.push(
              context, slideRoute(const EconomicToolsScreen()))),
      (Icons.menu_book_rounded, 'Knowledge hub',
          () => Navigator.push(
              context, slideRoute(const KnowledgeHubScreen()))),
      (Icons.cloud_rounded, 'Weather',
          () => Navigator.push(
              context, slideRoute(const WeatherDetailScreen()))),
      (Icons.notifications_rounded, 'Alerts',
          () =>
              Navigator.push(context, slideRoute(const AlertsScreen()))),
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: items
          .map((item) => GestureDetector(
                onTap: item.$3,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(context),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.$1,
                          color: AppColors.primary, size: 20),
                    ),
                    Text(item.$2,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: context.textPrimary)),
                  ]),
                ),
              ))
          .toList(),
    );
  }
}
