import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/field.dart';
import '../services/field_service.dart';
import '../transitions.dart';
import '../widgets/growing_tree.dart';
import 'field_detail_screen.dart';
import 'add_field_screen.dart';

class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});
  @override
  State<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends State<FieldsScreen> {
  final _service = FieldService();
  List<PaddyField>? _fields;
  StreamSubscription<List<PaddyField>>? _fieldsSub;

  @override
  void initState() {
    super.initState();
    _fields = _service.cachedFields;
    _fieldsSub = _service.watchFields().listen((f) {
      if (mounted) setState(() => _fields = f);
    });
  }

  @override
  void dispose() {
    _fieldsSub?.cancel();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, PaddyField field) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete Field',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.red)),
        content: Text(
            'Remove "${field.name}"? This cannot be undone.',
            style: TextStyle(fontSize: 13, color: ctx.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: ctx.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _service.deleteField(field.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Delete failed: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      }
    }
  }

  Future<void> _addField() async {
    final result = await showModalBottomSheet<PaddyField>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddFieldScreen(),
    );
    if (result != null) await _service.addField(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final fields = _fields ?? [];
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('My Fields',
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: context.textPrimary,
                                    letterSpacing: -0.5)),
                            Text(
                                '${fields.length} field${fields.length == 1 ? '' : 's'}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: context.textSecondary)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _addField,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ]),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                if (fields.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.grass_rounded,
                              size: 48, color: context.textSecondary.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text('No fields yet',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: context.textSecondary)),
                          const SizedBox(height: 4),
                          Text('Tap + to add your first field',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: context.textSecondary.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _FieldCard(
                          field: fields[i],
                          onTap: () async {
                            await Navigator.push(
                                context,
                                slideRoute(
                                    FieldDetailScreen(field: fields[i])));
                          },
                          onLongPress: () => _confirmDelete(context, fields[i]),
                        ),
                        childCount: fields.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FieldCard extends StatefulWidget {
  final PaddyField field;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const _FieldCard({required this.field, required this.onTap, this.onLongPress});
  @override
  State<_FieldCard> createState() => _FieldCardState();
}

class _FieldCardState extends State<_FieldCard> {
  bool _pressed = false;

  Widget _fieldGradientBg(PaddyField f) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [f.healthStatus.gradientStart, f.healthStatus.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(child: GrowingTreeWidget(stage: f.stage, size: 72)),
      );

  @override
  Widget build(BuildContext context) {
    final f = widget.field;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.border.withValues(alpha: 0.4)),
            boxShadow: iosShadow,
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (f.photoUrl != null)
                      Image.network(
                        f.photoUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
                        errorBuilder: (_, __, ___) => _fieldGradientBg(f),
                      )
                    else
                      _fieldGradientBg(f),
                    if (f.photoUrl != null)
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0x33000000),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: f.healthStatus.color,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                                color: f.healthStatus.color
                                    .withValues(alpha: 0.4),
                                blurRadius: 4)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.name,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: context.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 1),
                    Text('Paddy (${f.variety})',
                        style: TextStyle(
                            fontSize: 11, color: context.textSecondary)),
                    const SizedBox(height: 2),
                    Text('${f.areaMorgen} ac · ${f.stage.label}',
                        style: TextStyle(
                            fontSize: 10, color: context.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
