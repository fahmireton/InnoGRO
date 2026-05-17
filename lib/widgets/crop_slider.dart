import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/field.dart';
import '../theme.dart';
import '../transitions.dart';
import '../screens/field_detail_screen.dart';

String _stageAsset(GrowthStage stage) {
  switch (stage) {
    case GrowthStage.seedling:
      return 'assets/images/paddyphase/Seed.png';
    case GrowthStage.vegetative:
      return 'assets/images/paddyphase/Baby Plant.png';
    case GrowthStage.tillering:
      return 'assets/images/paddyphase/Growing.png';
    case GrowthStage.flowering:
      return 'assets/images/paddyphase/Growing.png';
    case GrowthStage.ripening:
      return 'assets/images/paddyphase/Mature.png';
    case GrowthStage.harvest:
      return 'assets/images/paddyphase/Harvest.png';
  }
}

class CropSlider extends StatelessWidget {
  final List<PaddyField> fields;
  final VoidCallback? onAddTap;
  const CropSlider({super.key, required this.fields, this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          ...fields.map((f) => _CropCard(field: f)),
          _AddFieldCard(onTap: onAddTap),
        ],
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  final PaddyField field;
  const _CropCard({required this.field});

  GrowthStage _calculateStage(int days) {
    if (days < 20) return GrowthStage.seedling;
    if (days < 45) return GrowthStage.vegetative;
    if (days < 65) return GrowthStage.tillering;
    if (days < 85) return GrowthStage.flowering;
    if (days < 110) return GrowthStage.ripening;
    return GrowthStage.harvest;
  }

  String _plantedLabel(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return 'Planted ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _pill(Widget child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
        ),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    const totalDays = 120;
    final days = DateTime.now().difference(field.plantedDate).inDays;
    final stage = _calculateStage(days);
    final progress = (days / totalDays).clamp(0.0, 1.0);
    final daysLeft = math.max(0, totalDays - days);
    final pct = (progress * 100).toInt();
    final showAlert = field.healthStatus != HealthStatus.healthy;
    final alertColor = field.healthStatus == HealthStatus.critical
        ? Colors.red
        : const Color(0xFFFF8C42);

    return GestureDetector(
      onTap: () =>
          Navigator.of(context).push(slideRoute(FieldDetailScreen(field: field))),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full-card background image: user photo or stage default
              field.photoUrl != null
                  ? Image.network(
                      field.photoUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(color: Colors.black45, child: const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))),
                      errorBuilder: (_, __, ___) => Image.asset(_stageAsset(stage), fit: BoxFit.cover),
                    )
                  : Image.asset(_stageAsset(stage), fit: BoxFit.cover),

              // Gradient: light at top, dark at bottom
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.15, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.18),
                      Colors.black.withValues(alpha: 0.82),
                    ],
                  ),
                ),
              ),

              // Overlaid content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row: stage badge + alert badge ──
                    Row(
                      children: [
                        _pill(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.eco_rounded,
                                color: Colors.white, size: 11),
                            const SizedBox(width: 4),
                            Text(
                              stage.label.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        )),
                        const Spacer(),
                        if (showAlert)
                          _pill(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: alertColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                field.healthStatus.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ── Day counter ──
                    const Text(
                      'DAY',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$days',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            height: 0.9,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            ' / $totalDays',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // ── Field name + location ──
                    Text(
                      field.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: Colors.white60, size: 10),
                        const SizedBox(width: 3),
                        Text(
                          _plantedLabel(field.plantedDate),
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 10),
                        ),
                        const SizedBox(width: 6),
                        const Text('·', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        const SizedBox(width: 6),
                        Text(
                          field.variety,
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ── Progress bar ──
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.25),
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.accent),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$pct% to harvest',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 10),
                        ),
                        Text(
                          daysLeft == 0 ? 'Ready!' : '${daysLeft}d left',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 10),
                        ),
                      ],
                    ),
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

class _AddFieldCard extends StatelessWidget {
  final VoidCallback? onTap;
  const _AddFieldCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: context.secondary.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.border,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 10),
            Text('Add field',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary)),
            const SizedBox(height: 3),
            Text('Track a new crop',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    color: context.textSecondary,
                    height: 1.3)),
          ],
        ),
      ),
    );
  }
}
