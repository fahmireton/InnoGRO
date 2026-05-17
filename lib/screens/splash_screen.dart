import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/field_service.dart';
import 'onboarding_screen.dart';
import 'login_screen_new.dart';
import 'shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _spinCtrl;
  late final AnimationController _barCtrl;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeCtrl,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeCtrl,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );

    Timer(const Duration(milliseconds: 3000), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    if (!mounted) return;
    Widget next;
    if (!seen) {
      next = const OnboardingScreen();
    } else if (user == null) {
      next = const LoginScreen();
    } else {
      await FieldService().ensureDemoData();
      if (!mounted) return;
      next = const AppShell();
    }
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => next,
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _spinCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeCtrl, _spinCtrl, _barCtrl]),
        builder: (context, _) {
          return Stack(
            children: [
              // Gradient background
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0A2E14),
                        Color(0xFF14391E),
                        Color(0xFF0D2410),
                      ],
                    ),
                  ),
                ),
              ),

              // Subtle radial glow behind the logo
              Center(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF9CCC65).withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),

                      // Logo block
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Column(children: [
                            // Ring spinner with eco icon inside
                            SizedBox(
                              width: 88,
                              height: 88,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Spinning arc
                                  CustomPaint(
                                    size: const Size(88, 88),
                                    painter: _SpinnerPainter(
                                      _spinCtrl.value,
                                      const Color(0xFF9CCC65),
                                    ),
                                  ),
                                  // Static background ring
                                  CustomPaint(
                                    size: const Size(88, 88),
                                    painter: _RingTrackPainter(
                                      Colors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  // Center icon
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.asset(
                                      'assets/images/logo.jpeg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // App name
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(children: [
                                TextSpan(
                                  text: 'INNO',
                                  style: TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                    height: 1,
                                  ),
                                ),
                                TextSpan(
                                  text: 'GRO',
                                  style: TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF9CCC65),
                                    letterSpacing: 2,
                                    height: 1,
                                  ),
                                ),
                              ]),
                            ),
                          ]),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tagline
                      FadeTransition(
                        opacity: _taglineOpacity,
                        child: SlideTransition(
                          position: _taglineSlide,
                          child: Column(children: [
                            const Text(
                              'Smart Paddy Farming, Made Simple',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AI-powered support for everyday paddy farming',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ]),
                        ),
                      ),

                      const Spacer(flex: 4),

                      // Loading bar
                      FadeTransition(
                        opacity: _taglineOpacity,
                        child: Column(children: [
                          Text(
                            'Preparing your farm assistant…',
                            style: TextStyle(
                              color: const Color(0xFF9CCC65).withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: 4,
                              child: Stack(children: [
                                Container(
                                    color: Colors.white.withValues(alpha: 0.12)),
                                FractionallySizedBox(
                                  widthFactor:
                                      math.min(_barCtrl.value, 1.0),
                                  alignment: Alignment.centerLeft,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF7CB342),
                                          Color(0xFF9CCC65),
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF9CCC65)
                                              .withValues(alpha: 0.5),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Spinning arc painter ───────────────────────────────────────────────────────

class _SpinnerPainter extends CustomPainter {
  final double t;
  final Color color;
  _SpinnerPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Trailing glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final startAngle = 2 * math.pi * t - math.pi / 2;
    const sweepAngle = math.pi * 1.1;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.t != t;
}

// ── Ring track painter ────────────────────────────────────────────────────────

class _RingTrackPainter extends CustomPainter {
  final Color color;
  _RingTrackPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_RingTrackPainter old) => false;
}
