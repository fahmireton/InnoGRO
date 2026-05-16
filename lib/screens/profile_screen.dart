import 'package:flutter/material.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: AppColors.primary,
            title: const Text('Profile'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 2),
                      ),
                      child: const Center(child: Text('👨‍🌾', style: TextStyle(fontSize: 36))),
                    ),
                    const SizedBox(height: 10),
                    const Text('Ahmad Razif', style: TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                    const Text('Kedah, Malaysia • Paddy Farmer', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _statsRow(),
                const SizedBox(height: 24),
                _section('Farm Details', [
                  _tile(Icons.grass_rounded, 'Farm Type', 'Paddy / Rice', AppColors.accent),
                  _tile(Icons.straighten_rounded, 'Total Area', '4.3 morgen', const Color(0xFF0EA5E9)),
                  _tile(Icons.location_on_rounded, 'Location', 'Kedah, Malaysia', AppColors.red),
                  _tile(Icons.agriculture_rounded, 'Experience', '12 years', AppColors.amber),
                ]),
                const SizedBox(height: 16),
                _section('Preferences', [
                  _tile(Icons.language_rounded, 'Language', 'Bahasa Melayu', AppColors.primary),
                  _tile(Icons.notifications_rounded, 'Notifications', 'Enabled', AppColors.accent),
                  _tile(Icons.dark_mode_rounded, 'Dark Mode', 'Off', AppColors.textSecondary),
                ]),
                const SizedBox(height: 16),
                _section('Support', [
                  _tile(Icons.help_rounded, 'Help & FAQ', '', AppColors.primary),
                  _tile(Icons.star_rounded, 'Rate VisionGRO', '', AppColors.amber),
                  _tile(Icons.info_rounded, 'About', 'v1.0.0', AppColors.textSecondary),
                ]),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Text('🌟', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Upgrade to Premium', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
                        const Text('Unlimited scans, expert consultations & advanced analytics',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                          child: const Text('Learn More', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    )),
                  ]),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow() {
    return Row(children: [
      Expanded(child: _stat('12', 'Total Scans')),
      const SizedBox(width: 12),
      Expanded(child: _stat('2', 'Active Fields')),
      const SizedBox(width: 12),
      Expanded(child: _stat('3', 'Harvests')),
    ]);
  }

  Widget _stat(String value, String label) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))],
    ),
    child: Column(children: [
      Text(value, style: const TextStyle(
        fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -0.5)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]),
  );

  Widget _section(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(children: children),
      ),
    ]);
  }

  Widget _tile(IconData icon, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Container(width: 32, height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 16)),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
        if (value.isNotEmpty)
          Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
      ]),
    );
  }
}
