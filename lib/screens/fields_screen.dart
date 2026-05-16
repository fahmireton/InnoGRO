import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/field.dart';
import '../transitions.dart';
import 'field_detail_screen.dart';
import 'add_field_screen.dart';

class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});
  @override
  State<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends State<FieldsScreen> {
  Future<void> _addField() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddFieldScreen()),
    );
    if (result != null && mounted) setState(() => sampleFields.add(result));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('My Fields',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary, letterSpacing: -0.5)),
                    Text('${sampleFields.length} field${sampleFields.length == 1 ? '' : 's'}',
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ])),
                  GestureDetector(
                    onTap: _addField,
                    child: Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ]),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Field list
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ...sampleFields.asMap().entries.map((e) {
                    final f = e.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FieldCard(
                        field: f,
                        onTap: () async {
                          await Navigator.push(context, slideRoute(FieldDetailScreen(field: f)));
                          setState(() {});
                        },
                      ),
                    );
                  }),
                  // Add field dashed button
                  GestureDetector(
                    onTap: _addField,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.6),
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                        ),
                      ),
                      child: const Center(
                        child: Text('+ Add new field',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldCard extends StatefulWidget {
  final PaddyField field;
  final VoidCallback onTap;
  const _FieldCard({required this.field, required this.onTap});
  @override
  State<_FieldCard> createState() => _FieldCardState();
}

class _FieldCardState extends State<_FieldCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.field;
    final days = DateTime.now().difference(f.plantedDate).inDays;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Gradient header
            Container(
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    f.healthStatus.gradientStart,
                    f.healthStatus.gradientEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(children: [
                // Health badge
                Positioned(
                  bottom: 12, left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: f.healthStatus.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: f.healthStatus.color.withValues(alpha: 0.4)),
                    ),
                    child: Text(f.healthStatus.label,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: f.healthStatus.color)),
                  ),
                ),
                // Emoji
                Positioned(
                  top: 12, right: 16,
                  child: Text(f.stage.emoji, style: const TextStyle(fontSize: 28)),
                ),
              ]),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16,
                    color: AppColors.textPrimary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(f.location,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(children: [
                  Text('${f.areaMorgen} ac',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const Text(' · ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text(f.stage.label,
                    style: TextStyle(fontSize: 12, color: f.healthStatus.color,
                      fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('$days days',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
