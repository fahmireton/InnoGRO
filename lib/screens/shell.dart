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
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: _BottomNav(currentIndex: _index, onTap: setIndex),
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
              _item(0, Icons.home_rounded, 'Home'),
              _item(1, Icons.grass_rounded, 'Fields'),
              _scanButton(),
              _item(3, Icons.people_rounded, 'Community'),
              _item(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final selected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Icon(icon, size: 22,
                  color: selected ? AppColors.primary : const Color(0xFFAAAAAA)),
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
      ),
    );
  }

  Widget _scanButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(2),
        child: Center(child: _PulsingScanButton(selected: currentIndex == 2)),
      ),
    );
  }
}

class _PulsingScanButton extends StatefulWidget {
  final bool selected;
  const _PulsingScanButton({required this.selected});
  @override
  State<_PulsingScanButton> createState() => _PulsingScanButtonState();
}

class _PulsingScanButtonState extends State<_PulsingScanButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(
        scale: _pulse.value,
        child: child,
      ),
      child: Container(
        width: 54, height: 54,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}
