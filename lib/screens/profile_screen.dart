import 'package:flutter/material.dart';
import '../app_theme_notifier.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController(text: 'Farmer');
  final _farmCtrl = TextEditingController(text: 'My Paddy Farm');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _farmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            const Text('Profile',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, letterSpacing: -0.5)),
            const SizedBox(height: 2),
            const Text('Personalise your farm',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 20),

            // Avatar + editable name card
            _card(context, child: Row(children: [
              // Avatar gradient circle
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'F',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                TextField(
                  controller: _farmCtrl,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ])),
            ])),

            const SizedBox(height: 14),

            // Premium card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('VisionGRO Premium',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                  SizedBox(height: 2),
                  Text('Unlock advanced AI features',
                    style: TextStyle(fontSize: 12, color: Colors.white70)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Upgrade',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ]),
            ),

            const SizedBox(height: 24),
            _sectionLabel('PREFERENCES'),
            const SizedBox(height: 10),

            // Preferences card
            _card(context, child: Column(children: [
              // Region
              _prefRow(
                label: 'Region',
                right: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Selangor', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ),
              ),
              _divLine(context),
              // Theme toggle
              _prefRow(
                label: 'Theme',
                right: ListenableBuilder(
                  listenable: appTheme,
                  builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(appTheme.isDark ? 'Dark' : 'Light',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: appTheme.toggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 44, height: 24,
                        decoration: BoxDecoration(
                          color: appTheme.isDark ? AppColors.accent : const Color(0xFFD0D0D0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 250),
                          alignment: appTheme.isDark ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            width: 20, height: 20,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              _divLine(context),
              // Units
              _prefRow(
                label: 'Units',
                right: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [
                    Text('Metric', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 16),
                  ]),
                ),
              ),
              _divLine(context),
              // Language
              _prefRow(
                label: 'Language',
                right: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [
                    Text('English', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 16),
                  ]),
                ),
              ),
            ])),

            const SizedBox(height: 24),
            _sectionLabel('DATA'),
            const SizedBox(height: 10),

            // Data card
            _card(context, child: Column(children: [
              _dataRow('Export data', AppColors.textPrimary),
              _divLine(context),
              _dataRow('Privacy controls', AppColors.textPrimary),
              _divLine(context),
              _dataRow('Clear all data', AppColors.red),
            ])),

            const SizedBox(height: 32),
            const Center(
              child: Text('VisionGRO · v1.0 · Made for smallholder farmers',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }

  Widget _prefRow({required String label, required Widget right}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary,
          fontWeight: FontWeight.w500)),
        const Spacer(),
        right,
      ]),
    );
  }

  Widget _dataRow(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(children: [
        Text(label, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500)),
        const Spacer(),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
      ]),
    );
  }

  Widget _divLine(BuildContext context) => Divider(height: 1, color: context.border);

  Widget _sectionLabel(String t) => Text(t,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
      color: AppColors.textSecondary, letterSpacing: 1.2));
}
