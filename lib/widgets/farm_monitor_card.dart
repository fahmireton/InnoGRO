import 'package:flutter/material.dart';
import '../models/field.dart';
import '../theme.dart';
import '../transitions.dart';
import '../screens/field_detail_screen.dart';

class FarmMonitorSection extends StatelessWidget {
  final List<PaddyField> fields;
  const FarmMonitorSection({super.key, required this.fields});

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.border.withValues(alpha: 0.4)),
        ),
        child: Text(
          'No fields yet. Tap + to add your first field.',
          style: TextStyle(fontSize: 13, color: context.textSecondary),
        ),
      );
    }
    return SizedBox(
      height: 182,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: fields.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) => _CropCard(field: fields[i]),
      ),
    );
  }
}

// ── Single crop card ───────────────────────────────────────────────────────────

class _CropCard extends StatelessWidget {
  final PaddyField field;
  const _CropCard({required this.field});

  GrowthStage _stageFromDays(int days) {
    if (days < 20) return GrowthStage.seedling;
    if (days < 45) return GrowthStage.vegetative;
    if (days < 65) return GrowthStage.tillering;
    if (days < 85) return GrowthStage.flowering;
    if (days < 110) return GrowthStage.ripening;
    return GrowthStage.harvest;
  }

  @override
  Widget build(BuildContext context) {
    final days = DateTime.now().difference(field.plantedDate).inDays;
    final stage = _stageFromDays(days);
    final stageColor = stage.color;
    final daysLeft = (110 - days).clamp(0, 110);

    return GestureDetector(
      onTap: () =>
          Navigator.push(context, slideRoute(FieldDetailScreen(field: field))),
      child: Container(
        width: 178,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: stageColor.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stage badge + emoji row
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: stageColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  stage.shortLabel,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: stageColor),
                ),
              ),
              const Spacer(),
              Text(stage.emoji, style: const TextStyle(fontSize: 20)),
            ]),
            const SizedBox(height: 10),

            // Field name
            Text(
              field.name,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              field.variety,
              style:
                  TextStyle(fontSize: 11, color: context.textSecondary),
            ),
            const SizedBox(height: 10),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: stage.progress,
                minHeight: 5,
                backgroundColor: context.secondary,
                valueColor: AlwaysStoppedAnimation(stageColor),
              ),
            ),
            const SizedBox(height: 10),

            // Days row
            Row(children: [
              Icon(Icons.calendar_today_outlined,
                  size: 11, color: context.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Day $days',
                style: TextStyle(
                    fontSize: 11, color: context.textSecondary),
              ),
              const Spacer(),
              Icon(Icons.agriculture_rounded,
                  size: 11, color: AppColors.accent),
              const SizedBox(width: 4),
              Text(
                daysLeft == 0 ? 'Harvest!' : '$daysLeft d left',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: daysLeft == 0
                      ? AppColors.accent
                      : context.textSecondary,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
