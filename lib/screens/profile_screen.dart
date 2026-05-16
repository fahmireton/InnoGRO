import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _bg = Color(0xFF0D1F0F);
  static const _card = Color(0xFF1A2E1C);
  static const _card2 = Color(0xFF162617);
  static const _greenDark = Color(0xFF2D5A3D);
  static const _textPrimary = Color(0xFFEEEEEE);
  static const _textSecondary = Color(0xFF7A9E82);
  static const _divider = Color(0xFF243826);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          children: [
            const Text('Profile',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _textPrimary, letterSpacing: -0.5)),
            const SizedBox(height: 2),
            const Text('Personalise your farm',
              style: TextStyle(fontSize: 14, color: _textSecondary)),
            const SizedBox(height: 20),
            _avatarCard(),
            const SizedBox(height: 16),
            _premiumCard(),
            const SizedBox(height: 24),
            _sectionLabel('PREFERENCES'),
            const SizedBox(height: 10),
            _prefsCard(),
            const SizedBox(height: 24),
            _sectionLabel('DATA'),
            const SizedBox(height: 10),
            _dataCard(),
            const SizedBox(height: 32),
            const Center(
              child: Text('PadiGuard AI · v1.0 · Made for smallholder farmers',
                style: TextStyle(fontSize: 11, color: _textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: _greenDark, shape: BoxShape.circle),
          child: const Center(
            child: Text('F', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 16),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Farmer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textPrimary)),
          SizedBox(height: 2),
          Text('My Paddy Farm', style: TextStyle(fontSize: 13, color: _textSecondary)),
        ]),
      ]),
    );
  }

  Widget _premiumCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E4D2B), Color(0xFF2D6A3F)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PadiGuard Premium', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
          SizedBox(height: 2),
          Text('Unlock advanced AI features', style: TextStyle(fontSize: 12, color: Colors.white70)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Upgrade', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E4D2B))),
        ),
      ]),
    );
  }

  Widget _prefsCard() {
    return Container(
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        _prefRow('Region', 'Selangor, Malaysia', false),
        _dividerLine(),
        _prefDropdown('Theme', 'System'),
        _dividerLine(),
        _prefDropdown('Units', 'Metric'),
        _dividerLine(),
        _prefDropdown('Language', 'English'),
      ]),
    );
  }

  Widget _prefRow(String label, String value, bool isDropdown) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 14, color: _textPrimary, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, color: _textSecondary)),
        if (isDropdown) const SizedBox(width: 4),
        if (isDropdown) const Icon(Icons.keyboard_arrow_down_rounded, color: _textSecondary, size: 18),
      ]),
    );
  }

  Widget _prefDropdown(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 14, color: _textPrimary, fontWeight: FontWeight.w500)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _card2,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(value, style: const TextStyle(fontSize: 12, color: _textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, color: _textSecondary, size: 14),
          ]),
        ),
      ]),
    );
  }

  Widget _dataCard() {
    return Container(
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        _dataRow('Export data', const Color(0xFFEEEEEE), isFirst: true),
        _dividerLine(),
        _dataRow('Privacy controls', const Color(0xFFEEEEEE)),
        _dividerLine(),
        _dataRow('Clear all data', const Color(0xFFDC2626), isLast: true),
      ]),
    );
  }

  Widget _dataRow(String label, Color color, {bool isFirst = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(children: [
        Text(label, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500)),
        const Spacer(),
        Icon(Icons.chevron_right_rounded, color: _textSecondary, size: 18),
      ]),
    );
  }

  Widget _dividerLine() => Container(height: 1, color: _divider, margin: const EdgeInsets.symmetric(horizontal: 16));

  Widget _sectionLabel(String t) => Text(t,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _textSecondary, letterSpacing: 1.2));
}
