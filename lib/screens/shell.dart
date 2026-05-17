import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../transitions.dart';
import 'home_screen.dart';
import 'scan_screen.dart';
import 'fields_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onScanTap: () => setIndex(2), onFieldsTap: () => setIndex(1)),
      const FieldsScreen(),
      const ScanScreen(),
      const CommunityScreen(),
      const ProfileScreen(),
    ];
  }

  void setIndex(int i) {
    HapticFeedback.lightImpact();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final screens = _screens;

    return Scaffold(
      backgroundColor: context.bg,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          IndexedStack(index: _index, children: screens),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomNav(currentIndex: _index, onTap: setIndex),
          ),
          // Floating AI chat button — above bottom nav, right side
          Positioned(
            bottom: 80 + MediaQuery.of(context).padding.bottom,
            right: 16,
            child: _ChatFab(),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    const navH = 64.0;

    return Container(
      height: navH + bottomPad,
      decoration: BoxDecoration(
        color: context.card,
        border: Border(top: BorderSide(color: context.border, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Nav items row
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPad),
              child: Row(
                children: [
                  _item(context, 0, Icons.home_rounded, 'Home'),
                  _item(context, 1, Icons.grass_rounded, 'Fields'),
                  const SizedBox(width: 72),
                  _item(context, 3, Icons.people_rounded, 'Community'),
                  _item(context, 4, Icons.person_rounded, 'Profile'),
                ],
              ),
            ),
          ),
          // Scan button — floats ABOVE the nav bar (like -mt-7 in Tailwind)
          Positioned(
            top: -22,
            left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap(2);
                },
                child: Container(
                  width: 62, height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    // White ring around the button (ring-4 ring-background effect)
                    border: Border.all(color: context.card, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 26),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, int index, IconData icon, String label) {

    final selected = currentIndex == index;
    final inactive = context.isDark ? const Color(0xFF6A6A6A) : const Color(0xFFAAAAAA);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Icon(icon, size: 22,
                color: selected ? AppColors.primary : inactive),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? AppColors.primary : inactive,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Floating AI chat button ───────────────────────────────────────────────────

class _ChatFab extends StatefulWidget {
  const _ChatFab();
  @override
  State<_ChatFab> createState() => _ChatFabState();
}

class _ChatFabState extends State<_ChatFab> with TickerProviderStateMixin {
  late AnimationController _beamCtrl; // shimmer sweep while pill is showing
  late AnimationController _peekCtrl; // slides the button to the right edge

  // right: 16 in Positioned → to show ~half the 44px circle, we translate +38
  static const _peekDx = 38.0;

  bool _pillVisible = true; // true = pill, false = circle

  @override
  void initState() {
    super.initState();

    _beamCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();

    _peekCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));

    // Collapse pill → circle, then slide to peek
    Future.delayed(const Duration(milliseconds: 4000), _collapseAndPeek);
  }

  void _collapseAndPeek() {
    if (!mounted) return;
    setState(() => _pillVisible = false);
    // Wait for pill→circle animation (300ms), then peek to edge
    Future.delayed(const Duration(milliseconds: 320), () {
      if (mounted) _peekCtrl.forward();
    });
  }

  void _revealAndOpen(BuildContext context) {
    HapticFeedback.lightImpact();
    // Slide back immediately, show pill, open chat
    _peekCtrl.reverse();
    setState(() => _pillVisible = true);
    Navigator.push(context, slideRoute(const ChatScreen())).then((_) {
      // After returning, collapse again after 3.5 s
      Future.delayed(const Duration(milliseconds: 3500), _collapseAndPeek);
    });
  }

  @override
  void dispose() {
    _beamCtrl.dispose();
    _peekCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_beamCtrl, _peekCtrl]),
      builder: (_, __) {
        final peek = CurvedAnimation(parent: _peekCtrl, curve: Curves.easeInOut).value;
        return Transform.translate(
          offset: Offset(peek * _peekDx, 0),
          child: GestureDetector(
            onTap: () => _revealAndOpen(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 44,
              width: _pillVisible ? 156 : 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B7A4A), Color(0xFF0F3D25)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B7A4A)
                        .withValues(alpha: _pillVisible ? 0.5 : 0.18),
                    blurRadius: _pillVisible ? 18 : 7,
                    spreadRadius: _pillVisible ? 2 : 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                          child: _pillVisible
                              ? const Row(children: [
                                  SizedBox(width: 7),
                                  Text('Ask PaddyAI',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.1,
                                      )),
                                ])
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    // Shimmer beam — only during pill phase
                    if (_pillVisible)
                      Positioned.fill(
                        child: _BeamSweep(progress: _beamCtrl.value),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Shimmer beam sweeping left→right
class _BeamSweep extends StatelessWidget {
  final double progress;
  const _BeamSweep({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [
            (progress - 0.35).clamp(0.0, 1.0),
            progress.clamp(0.0, 1.0),
            (progress + 0.35).clamp(0.0, 1.0),
          ],
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.15),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
