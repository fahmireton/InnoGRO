import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'scan_screen.dart';
import 'fields_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void setIndex(int i) {
    HapticFeedback.lightImpact();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onScanTap: () => setIndex(2)),
      const FieldsScreen(),
      const ScanScreen(),
      const CommunityScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: context.bg,
      body: Stack(
        children: [
          IndexedStack(index: _index, children: screens),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomNav(currentIndex: _index, onTap: setIndex),
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
      ),
      child: Stack(
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
          // Scan button — centered in nav content area
          Positioned(
            top: 0, bottom: bottomPad, left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap(2);
                },
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.card, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
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
