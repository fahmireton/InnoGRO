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
      backgroundColor: AppColors.bg,
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
    // Total height = 32px (half of 64px scan button) + 64px nav + safe area
    // Scan button center sits at the top border of the nav bar
    const navH = 62.0;
    const scanR = 32.0; // half of 64px scan button

    return SizedBox(
      height: scanR + navH + bottomPad,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Nav bar background
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: navH + bottomPad,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    _item(0, Icons.home_rounded, 'Home'),
                    _item(1, Icons.grass_rounded, 'Fields'),
                    // Space for floating scan button
                    const SizedBox(width: 72),
                    _item(3, Icons.people_rounded, 'Community'),
                    _item(4, Icons.person_rounded, 'Profile'),
                  ],
                ),
              ),
            ),
          ),
          // Floating scan button — center aligns with nav top border
          Positioned(
            top: 0, left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap(2);
                },
                child: Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.document_scanner_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final selected = currentIndex == index;
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
              child: Icon(
                icon,
                size: 22,
                color: selected ? AppColors.primary : const Color(0xFFAAAAAA),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? AppColors.primary : const Color(0xFFAAAAAA),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
