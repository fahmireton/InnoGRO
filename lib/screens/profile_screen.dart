import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_theme_notifier.dart';
import '../theme.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import 'login_screen_new.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  UserProfile? _userProfile;
  bool _loading = true;

  String _region = 'Selangor';
  String _units = 'Metric';
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await _authService.getUserProfile(user.uid);
      if (mounted) setState(() { _userProfile = profile; _loading = false; });
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.card,
        title: Text('Sign Out', style: TextStyle(color: context.textPrimary)),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showRegionSheet() {
    final regions = ['Selangor', 'Kedah', 'Perak', 'Johor', 'Sabah', 'Sarawak'];
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
                style:
                    TextStyle(color: ctx.textSecondary)),
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

  Future<void> _showEditProfileSheet() async {
    if (_userProfile == null) return;
    final nameCtrl = TextEditingController(text: _userProfile!.name);
    final farmCtrl = TextEditingController(text: _userProfile!.farmName);
    final locCtrl = TextEditingController(text: _userProfile!.location);
    // Capture before entering the bottom sheet to avoid stale-context crashes
    final messenger = ScaffoldMessenger.of(context);
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setS) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: sheetCtx.card,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                    color: sheetCtx.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Text('Edit Profile',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: sheetCtx.textPrimary)),
              const SizedBox(height: 20),
              _editField(sheetCtx, nameCtrl, 'Your Name', Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _editField(sheetCtx, farmCtrl, 'Farm Name', Icons.agriculture_rounded),
              const SizedBox(height: 12),
              _editField(sheetCtx, locCtrl, 'Location', Icons.location_on_outlined),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setS(() => saving = true);
                          final nav = Navigator.of(sheetCtx);
                          try {
                            final updated = UserProfile(
                              uid: _userProfile!.uid,
                              email: _userProfile!.email,
                              name: nameCtrl.text.trim(),
                              farmName: farmCtrl.text.trim(),
                              location: locCtrl.text.trim(),
                              latitude: _userProfile!.latitude,
                              longitude: _userProfile!.longitude,
                              createdAt: _userProfile!.createdAt,
                            );
                            await _authService.updateProfile(updated);
                            if (mounted) setState(() => _userProfile = updated);
                            nav.pop();
                            messenger.showSnackBar(SnackBar(
                              content: const Text('Profile updated'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ));
                          } catch (e) {
                            if (mounted) setS(() => saving = false);
                            messenger.showSnackBar(SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: AppColors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );

    nameCtrl.dispose();
    farmCtrl.dispose();
    locCtrl.dispose();
  }

  Widget _editField(BuildContext ctx, TextEditingController ctrl,
      String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: ctx.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: ctx.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: ctx.textSecondary, size: 20),
        filled: true,
        fillColor: ctx.secondary,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: ctx.card,
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Header badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('PREMIUM', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            ),
            const SizedBox(height: 14),
            Text('VisionGRO Premium', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: ctx.textPrimary, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            // Price
            Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('RM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ctx.textSecondary)),
              const SizedBox(width: 2),
              Text('10', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: -2, height: 1)),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('/month', style: TextStyle(fontSize: 14, color: ctx.textSecondary)),
              ),
            ]),
            const SizedBox(height: 4),
            Text('Cancel anytime · No hidden fees', style: TextStyle(fontSize: 12, color: ctx.textSecondary)),
            const SizedBox(height: 20),
            // Feature list
            _premiumFeature(ctx, Icons.document_scanner_rounded, 'Unlimited AI Scans', 'No daily cap — diagnose all day'),
            const SizedBox(height: 12),
            _premiumFeature(ctx, Icons.people_rounded, 'Expert Consultation', 'Direct booking with MARDI agronomists'),
            const SizedBox(height: 12),
            _premiumFeature(ctx, Icons.map_rounded, 'Advanced Disease Map', 'Field-level outbreak alerts'),
            const SizedBox(height: 12),
            _premiumFeature(ctx, Icons.flash_on_rounded, 'Priority Support', '24/7 response, under 2 hours'),
            const SizedBox(height: 12),
            _premiumFeature(ctx, Icons.download_rounded, 'Export Reports', 'PDF season summaries for banks & DOA'),
            const SizedBox(height: 24),
            // CTA buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Premium launching soon — you\'ll be notified!'),
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text('Notify Me at Launch', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Maybe later', style: TextStyle(fontSize: 13, color: ctx.textSecondary)),
            ),
          ]),
        ),
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
    if (_loading) {
      return Scaffold(
        backgroundColor: context.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final userName = _userProfile?.name ?? 'Farmer';
    final farmName = _userProfile?.farmName ?? 'My Farm';
    final userEmail = _userProfile?.email ?? 'email@example.com';

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
                  // Avatar gradient circle
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
                    child: Center(
                      child: Text(
                        userName.isNotEmpty
                            ? userName[0].toUpperCase()
                            : 'F',
                        style: const TextStyle(
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
                        Text(
                          userName,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          farmName,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: context.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail,
                          style: TextStyle(
                              fontSize: 11,
                              color: context.textSecondary.withValues(alpha: 0.7)),
                        ),
                      ])),
                  GestureDetector(
                    onTap: _showEditProfileSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.edit_rounded, size: 13, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ]),
                    ),
                  ),
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

            // Preferences card
            _card(context,
                child: Column(children: [
                  // Region
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
                  // Theme toggle
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
                  // Units
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
                  // Language
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

            // Data card
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
            // Sign Out Button
            GestureDetector(
              onTap: _signOut,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
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
