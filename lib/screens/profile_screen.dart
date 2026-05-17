import 'package:flutter/material.dart';
import '../app_theme_notifier.dart';
import '../theme.dart';
import '../models/field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _region = 'Malaysia';
  String _units = 'Metric';
  String _language = 'English';

  static const String _displayName = 'Farmer';
  static const String _email = 'farmer@visiongro.app';
  static const String _initials = 'F';

  void _showRegionSheet() {
    final regions = ['Selangor', 'Kedah', 'Perak', 'Johor', 'Sabah', 'Sarawak', 'Malaysia'];
    showModalBottomSheet(
      context: context,
      backgroundColor: context.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
                color: ctx.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Text('Select Region',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ctx.textPrimary)),
          const SizedBox(height: 12),
          ...regions.map((r) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(r,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: ctx.textPrimary)),
                trailing: _region == r
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primary, size: 20)
                    : null,
                onTap: () {
                  setState(() => _region = r);
                  Navigator.pop(ctx);
                },
              )),
        ]),
      ),
    );
  }

  void _showUnitsSheet() {
    final options = ['Metric', 'Imperial'];
    showModalBottomSheet(
      context: context,
      backgroundColor: context.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
                color: ctx.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Text('Select Units',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ctx.textPrimary)),
          const SizedBox(height: 12),
          ...options.map((o) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(o,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: ctx.textPrimary)),
                trailing: _units == o
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primary, size: 20)
                    : null,
                onTap: () {
                  setState(() => _units = o);
                  Navigator.pop(ctx);
                },
              )),
        ]),
      ),
    );
  }

  void _showLanguageSheet() {
    final options = ['English', 'Bahasa Malaysia'];
    showModalBottomSheet(
      context: context,
      backgroundColor: context.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
                color: ctx.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Text('Select Language',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ctx.textPrimary)),
          const SizedBox(height: 12),
          ...options.map((o) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(o,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: ctx.textPrimary)),
                trailing: _language == o
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primary, size: 20)
                    : null,
                onTap: () {
                  setState(() => _language = o);
                  Navigator.pop(ctx);
                },
              )),
        ]),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Export Data',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: ctx.textPrimary)),
        content: Text(
            'Exporting your farm data including fields, scan history, and notes as a CSV file.',
            style: TextStyle(fontSize: 13, color: ctx.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: ctx.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Data exported successfully'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    bool shareUsage = true;
    bool locationTracking = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: ctx.card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Privacy Controls',
              style: TextStyle(
                  fontWeight: FontWeight.w800, color: ctx.textPrimary)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(
                  child: Text('Share anonymous usage data',
                      style: TextStyle(
                          fontSize: 14, color: ctx.textPrimary))),
              Switch(
                value: shareUsage,
                onChanged: (v) => setS(() => shareUsage = v),
                activeColor: AppColors.primary,
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: Text('Location tracking',
                      style: TextStyle(
                          fontSize: 14, color: ctx.textPrimary))),
              Switch(
                value: locationTracking,
                onChanged: (v) => setS(() => locationTracking = v),
                activeColor: AppColors.primary,
              ),
            ]),
          ]),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Clear All Data',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.red)),
        content: Text(
            'This will permanently delete all your farm data, including fields, scan history, and notes. Are you sure?',
            style: TextStyle(fontSize: 13, color: ctx.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: ctx.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All data cleared'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('VisionGRO Premium',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: ctx.textPrimary)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _premiumFeature(ctx, Icons.document_scanner_rounded,
              'Unlimited AI Scans',
              'No cap on daily diagnoses'),
          const SizedBox(height: 12),
          _premiumFeature(ctx, Icons.people_rounded,
              'Expert Consultation',
              'Direct access to MARDI agronomists'),
          const SizedBox(height: 12),
          _premiumFeature(ctx, Icons.flash_on_rounded,
              'Priority Support',
              'Faster response times, 24/7'),
        ]),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Coming Soon'),
          ),
        ],
      ),
    );
  }

  Widget _premiumFeature(
      BuildContext ctx, IconData icon, String title, String subtitle) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: ctx.textPrimary)),
        Text(subtitle,
            style:
                TextStyle(fontSize: 12, color: ctx.textSecondary)),
      ])),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            Text('Profile',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                    letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text('Personalise your farm',
                style:
                    TextStyle(fontSize: 14, color: context.textSecondary)),
            const SizedBox(height: 20),

            // Avatar + user info card
            _card(context,
                child: Row(children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.6)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        _initials,
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(_displayName,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary)),
                        const SizedBox(height: 2),
                        Text(_email,
                            style: TextStyle(
                                fontSize: 13, color: context.textSecondary)),
                        const SizedBox(height: 2),
                        Text('Region: $_region',
                            style: TextStyle(
                                fontSize: 12, color: context.textSecondary)),
                        Text('Fields: ${sampleFields.length}',
                            style: TextStyle(
                                fontSize: 12, color: context.textSecondary)),
                      ])),
                ])),

            const SizedBox(height: 14),

            // Premium card
            GestureDetector(
              onTap: _showUpgradeDialog,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.workspace_premium_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('VisionGRO Premium',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        SizedBox(height: 2),
                        Text('Unlock advanced AI features',
                            style:
                                TextStyle(fontSize: 12, color: Colors.white70)),
                      ])),
                  GestureDetector(
                    onTap: _showUpgradeDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('Upgrade',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 24),
            _sectionLabel(context, 'PREFERENCES'),
            const SizedBox(height: 10),

            _card(context,
                child: Column(children: [
                  GestureDetector(
                    onTap: _showRegionSheet,
                    child: _prefRow(
                      context,
                      label: 'Region',
                      right: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(_region,
                            style: TextStyle(
                                fontSize: 13,
                                color: context.textSecondary)),
                      ),
                    ),
                  ),
                  _divLine(context),
                  _prefRow(
                    context,
                    label: 'Theme',
                    right: ListenableBuilder(
                      listenable: appTheme,
                      builder: (_, __) =>
                          Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(appTheme.isDark ? 'Dark' : 'Light',
                            style: TextStyle(
                                fontSize: 12, color: context.textSecondary)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: appTheme.toggle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 44,
                            height: 24,
                            decoration: BoxDecoration(
                              color: appTheme.isDark
                                  ? AppColors.accent
                                  : const Color(0xFFD0D0D0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 250),
                              alignment: appTheme.isDark
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 2),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  _divLine(context),
                  GestureDetector(
                    onTap: _showUnitsSheet,
                    child: _prefRow(
                      context,
                      label: 'Units',
                      right: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_units,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: context.textSecondary)),
                              const SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down_rounded,
                                  color: context.textSecondary, size: 16),
                            ]),
                      ),
                    ),
                  ),
                  _divLine(context),
                  GestureDetector(
                    onTap: _showLanguageSheet,
                    child: _prefRow(
                      context,
                      label: 'Language',
                      right: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_language,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: context.textSecondary)),
                              const SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down_rounded,
                                  color: context.textSecondary, size: 16),
                            ]),
                      ),
                    ),
                  ),
                ])),

            const SizedBox(height: 24),
            _sectionLabel(context, 'DATA'),
            const SizedBox(height: 10),

            _card(context,
                child: Column(children: [
                  _dataRow(context, 'Export data', context.textPrimary,
                      _showExportDialog),
                  _divLine(context),
                  _dataRow(context, 'Privacy controls', context.textPrimary,
                      _showPrivacyDialog),
                  _divLine(context),
                  _dataRow(context, 'Clear all data', AppColors.red,
                      _showClearDataDialog),
                ])),

            const SizedBox(height: 24),
            Center(
              child: Text(
                  'VisionGRO · v1.0 · Made for smallholder farmers',
                  style: TextStyle(
                      fontSize: 11, color: context.textSecondary)),
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
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 2,
              offset: const Offset(0, 1)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }

  Widget _prefRow(BuildContext context,
      {required String label, required Widget right}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                color: context.textPrimary,
                fontWeight: FontWeight.w500)),
        const Spacer(),
        right,
      ]),
    );
  }

  Widget _dataRow(
      BuildContext context, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14, color: color, fontWeight: FontWeight.w500)),
          const Spacer(),
          Icon(Icons.chevron_right_rounded,
              color: context.textSecondary, size: 18),
        ]),
      ),
    );
  }

  Widget _divLine(BuildContext context) =>
      Divider(height: 1, color: context.border);

  Widget _sectionLabel(BuildContext context, String t) => Text(t,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: context.textSecondary,
          letterSpacing: 1.2));
}
