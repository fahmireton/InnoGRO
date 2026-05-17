import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'login_screen_new.dart';

// ── Slide data ─────────────────────────────────────────────────────────────────

class _Slide {
  final String? imageUrl;
  final String? assetPath;
  final Color fallbackColor;
  final IconData icon;
  final String tag;
  final String title;
  final String body;
  final Color accent;
  const _Slide({
    this.imageUrl,
    this.assetPath,
    required this.fallbackColor,
    required this.icon,
    required this.tag,
    required this.title,
    required this.body,
    required this.accent,
  });
}

const _kSlides = <_Slide>[
  _Slide(
    imageUrl:
        'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&w=900&q=80',
    fallbackColor: Color(0xFF0F2318),
    icon: Icons.eco_rounded,
    tag: 'WELCOME TO INNOGRO',
    title: 'Your Farm,\nSmarter.',
    body: 'AI-powered crop management built for Malaysian paddy farmers — right in your pocket.',
    accent: Color(0xFF4ADE80),
  ),
  _Slide(
    assetPath: 'assets/images/problem1.png',
    fallbackColor: Color(0xFF2A1010),
    icon: Icons.document_scanner_rounded,
    tag: 'PROBLEM #1 · CROP DISEASE',
    title: 'Disease\nSpreads Fast.',
    body:
        'Blast, blight and brown spot can wipe out your season in days. InnoGro\'s AI scans leaves in seconds — before the damage spreads.',
    accent: Color(0xFFFB923C),
  ),
  _Slide(
    assetPath: 'assets/images/problem2.jpeg',
    fallbackColor: Color(0xFF0D1E2E),
    icon: Icons.cloud_outlined,
    tag: 'PROBLEM #2 · WEATHER RISK',
    title: 'Flood or\nDrought?',
    body:
        'Unpredictable weather is every farmer\'s nightmare. Get hyperlocal alerts days ahead — so you act, not react.',
    accent: Color(0xFF60A5FA),
  ),
  _Slide(
    assetPath: 'assets/images/problem3.jpeg',
    fallbackColor: Color(0xFF2A200A),
    icon: Icons.dashboard_rounded,
    tag: 'PROBLEM #3 · FARM MANAGEMENT',
    title: 'Every Field,\nEvery Season.',
    body:
        'Track multiple plots, record harvests, log expenses — all from one smart dashboard.',
    accent: Color(0xFFFBBF24),
  ),
];

// ── Screen ─────────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _idx = 0;
  bool _busy = false;
  double _dragStartX = 0;

  late AnimationController _progressCtrl;
  late AnimationController _contentCtrl;

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _advance();
      })
      ..forward();

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      value: 1.0,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final s in _kSlides) {
        if (s.imageUrl != null) {
          precacheImage(NetworkImage(s.imageUrl!), context);
        }
      }
    });
  }

  void _advance() => _goTo((_idx + 1) % _kSlides.length);

  Future<void> _goTo(int next) async {
    if (_busy || next == _idx) return;
    _busy = true;
    _progressCtrl.stop();

    await _contentCtrl.animateTo(0,
        duration: const Duration(milliseconds: 180), curve: Curves.easeIn);
    if (!mounted) {
      _busy = false;
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _idx = next);

    await _contentCtrl.animateTo(1,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    if (!mounted) {
      _busy = false;
      return;
    }

    _progressCtrl.reset();
    _progressCtrl.forward();
    _busy = false;
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    _progressCtrl.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _kSlides[_idx];
    final isLast = _idx == _kSlides.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: slide.fallbackColor,
        body: GestureDetector(
          onHorizontalDragStart: (d) => _dragStartX = d.globalPosition.dx,
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            final dx = d.globalPosition.dx - _dragStartX;
            if (v < -300 || dx < -60) {
              _advance();
            } else if ((v > 300 || dx > 60) && _idx > 0) {
              _goTo(_idx - 1);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 900),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _KenBurnsImage(
                  key: ValueKey(_idx),
                  imageUrl: slide.imageUrl,
                  assetPath: slide.assetPath,
                  fallbackColor: slide.fallbackColor,
                  progressCtrl: _progressCtrl,
                ),
              ),

              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [Color(0x99000000), Colors.transparent],
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.65,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xF5000000),
                          Color(0xBB000000),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.48,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          slide.accent.withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/logo.jpeg',
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('InnoGro',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2)),
                          ]),
                          Text(
                            '${_idx + 1} / ${_kSlides.length}',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.38),
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: List.generate(_kSlides.length, (i) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: i < _kSlides.length - 1 ? 6 : 0),
                              child: i == _idx
                                  ? _GlowBar(controller: _progressCtrl)
                                  : Container(
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                            alpha: i < _idx ? 0.85 : 0.18),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.50),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                            ),
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedBuilder(
                                  animation: _contentCtrl,
                                  builder: (_, __) {
                                    final v = _contentCtrl.value;
                                    final s = _kSlides[_idx];
                                    return Opacity(
                                      opacity: v.clamp(0.0, 1.0),
                                      child: Transform.translate(
                                        offset: Offset(0, (1 - v) * 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 500),
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: s.accent
                                                      .withValues(alpha: 0.18),
                                                  borderRadius:
                                                      BorderRadius.circular(9),
                                                  border: Border.all(
                                                    color: s.accent
                                                        .withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                child: Icon(s.icon,
                                                    size: 14, color: s.accent),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  s.tag,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.52),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                            const SizedBox(height: 12),

                                            Text(
                                              s.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 40,
                                                fontWeight: FontWeight.w900,
                                                height: 1.05,
                                                letterSpacing: -1.5,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black45,
                                                    offset: Offset(0, 2),
                                                    blurRadius: 10,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10),

                                            Text(
                                              s.body,
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.62),
                                                fontSize: 14,
                                                height: 1.62,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),

                                if (isLast) ...[
                                  Row(children: [
                                    _PressBtn(
                                      onTap: _finish,
                                      color: AppColors.primary,
                                      width: 52,
                                      height: 52,
                                      child: const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _PressBtn(
                                        onTap: _finish,
                                        color: AppColors.primary,
                                        height: 52,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Get Started Free',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              Icon(Icons.arrow_forward_rounded,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.65),
                                                  size: 16),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ] else ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: _finish,
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 4),
                                          child: Text('Skip',
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.38),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ),
                                      _PressBtn(
                                        onTap: _advance,
                                        color: AppColors.primary,
                                        width: 52,
                                        height: 52,
                                        child: const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 20),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KenBurnsImage extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final Color fallbackColor;
  final AnimationController progressCtrl;

  const _KenBurnsImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    required this.fallbackColor,
    required this.progressCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final Widget image;
    if (assetPath != null) {
      image = Image.asset(
        assetPath!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => ColoredBox(color: fallbackColor),
      );
    } else if (imageUrl != null) {
      image = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => ColoredBox(color: fallbackColor),
        loadingBuilder: (_, child, prog) =>
            prog == null ? child : ColoredBox(color: fallbackColor),
      );
    } else {
      image = ColoredBox(color: fallbackColor);
    }

    return AnimatedBuilder(
      animation: progressCtrl,
      builder: (_, child) => Transform.scale(
        scale: 1.0 + progressCtrl.value * 0.06,
        child: child,
      ),
      child: image,
    );
  }
}

class _GlowBar extends StatelessWidget {
  final AnimationController controller;
  const _GlowBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) => Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            FractionallySizedBox(
              widthFactor: controller.value,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.80),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PressBtn extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;
  final Widget child;
  final double? width;
  final double height;

  const _PressBtn({
    required this.onTap,
    required this.color,
    required this.child,
    this.width,
    required this.height,
  });

  @override
  State<_PressBtn> createState() => _PressBtnState();
}

class _PressBtnState extends State<_PressBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 220),
      value: 0.0,
    );
    _scale = Tween(begin: 1.0, end: 0.90)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.animateTo(1.0),
      onTapUp: (_) {
        _ctrl.animateTo(0.0);
        widget.onTap();
      },
      onTapCancel: () => _ctrl.animateTo(0.0),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.42),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
