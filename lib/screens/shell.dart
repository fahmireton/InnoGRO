import 'package:flutter/material.dart';
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

  void setIndex(int i) => setState(() => _index = i);

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
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: _BottomNav(
        currentIndex: _index,
        onTap: setIndex,
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _item(context, 0, Icons.home_rounded, 'Home'),
              _item(context, 1, Icons.grass_rounded, 'Fields'),
              _scanButton(context),
              _item(context, 3, Icons.people_rounded, 'Community'),
              _item(context, 4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int index, IconData icon, String label) {
    final selected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
              size: 22,
              color: selected ? AppColors.primary : const Color(0xFFAAAAAA)),
            const SizedBox(height: 3),
            Text(label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? AppColors.primary : const Color(0xFFAAAAAA),
              )),
          ],
        ),
      ),
    );
  }

  Widget _scanButton(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(2),
        child: Center(
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
