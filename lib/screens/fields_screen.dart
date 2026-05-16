import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/field.dart';
import 'field_detail_screen.dart';
import 'add_field_screen.dart';

class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});
  @override
  State<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends State<FieldsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('My Fields', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                    Text('${sampleFields.length} fields', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ])),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFieldScreen()));
                      if (result != null && mounted) setState(() => sampleFields.add(result));
                    },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.85),
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: sampleFields.length + 1,
                  itemBuilder: (context, i) {
                    if (i == sampleFields.length) {
                      return _AddFieldCard(onTap: () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFieldScreen()));
                        if (result != null && mounted) setState(() => sampleFields.add(result));
                      });
                    }
                    final f = sampleFields[i];
                    return _FieldGridCard(field: f, onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => FieldDetailScreen(field: f)));
                      setState(() {});
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldGridCard extends StatelessWidget {
  final PaddyField field;
  final VoidCallback onTap;
  const _FieldGridCard({required this.field, required this.onTap});

  Color get _bgTop {
    switch (field.healthStatus) {
      case HealthStatus.healthy: return const Color(0xFFD4EDD9);
      case HealthStatus.watch: return const Color(0xFFFFF0CC);
      case HealthStatus.critical: return const Color(0xFFFFD4D4);
    }
  }

  Color get _bgBottom {
    switch (field.healthStatus) {
      case HealthStatus.healthy: return const Color(0xFFF0FAF2);
      case HealthStatus.watch: return const Color(0xFFFFFAF0);
      case HealthStatus.critical: return const Color(0xFFFFF0F0);
    }
  }

  Color get _iconColor {
    switch (field.healthStatus) {
      case HealthStatus.healthy: return AppColors.accent;
      case HealthStatus.watch: return AppColors.amber;
      case HealthStatus.critical: return AppColors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_bgTop, _bgBottom], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Center(child: Icon(Icons.grass_rounded, size: 52, color: _iconColor)),
                ),
                Positioned(
                  top: 10, right: 10,
                  child: Container(width: 10, height: 10,
                    decoration: BoxDecoration(color: _iconColor, shape: BoxShape.circle)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(field.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(field.location.split(',').first, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${field.areaMorgen} ac · ${field.stage.label}',
                  style: TextStyle(fontSize: 11, color: _iconColor, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddFieldCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddFieldCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 32, color: AppColors.textSecondary),
            SizedBox(height: 8),
            Text('Add field', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
