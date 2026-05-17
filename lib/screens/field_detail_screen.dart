import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../models/field.dart';
import '../models/weather.dart';
import '../services/field_service.dart';
import '../services/weather_service.dart';
import '../services/scan_service.dart';
import '../widgets/rice_plant.dart';
import 'field_map_screen.dart';

// Maps days since planting to the correct growth stage
GrowthStage _stageFromDays(int days) {
  if (days < 20) return GrowthStage.seedling;
  if (days < 45) return GrowthStage.vegetative;
  if (days < 65) return GrowthStage.tillering;
  if (days < 85) return GrowthStage.flowering;
  if (days < 110) return GrowthStage.ripening;
  return GrowthStage.harvest;
}

// Stage-aware farming suggestion based on current weather
String _farmingSuggestion(GrowthStage stage, WeatherData w) {
  final cond = w.condition.toLowerCase();
  final isRaining = cond.contains('rain') || cond.contains('drizzle') || cond.contains('thunderstorm');
  final isDry = w.humidity < 60 && !isRaining;
  final isHumid = w.humidity > 80;

  switch (stage) {
    case GrowthStage.seedling:
      if (isDry) return 'Keep seedbed moist — irrigate lightly today.';
      if (isRaining) return 'Good germination moisture; watch for damping-off.';
      return 'Ensure clean seed and adequate warmth for germination.';
    case GrowthStage.vegetative:
      if (isDry) return 'Irrigate now — nitrogen uptake needs adequate soil moisture.';
      if (isHumid) return 'High humidity (${w.humidity}%) — watch for leaf blight.';
      return 'Good conditions; apply top-dressing nitrogen this week.';
    case GrowthStage.tillering:
      if (isDry) return 'Critical: maintain 5 cm water depth for max tiller formation.';
      if (isRaining) return 'Check water level — prevent flooding deeper than 10 cm.';
      return 'Maintain water depth and inspect for stem borers.';
    case GrowthStage.flowering:
      if (isHumid || isRaining) return 'High blast risk (${w.humidity}% humidity) — apply preventive fungicide.';
      if (isDry) return 'Maintain water during flowering — drought reduces grain set.';
      return 'Monitor for blast; avoid spraying during pollination hours.';
    case GrowthStage.ripening:
      if (isRaining) return 'Rain during ripening risks grain discolouration — plan early harvest.';
      return 'Drain field 10 days before target harvest date.';
    case GrowthStage.harvest:
      if (!isRaining && w.windSpeed < 4) return 'Good harvest window — act within 3–5 days for best quality.';
      if (isRaining) return 'Delay harvest if rain continues — wet grain risks mould.';
      return 'Harvest in the morning for optimal grain quality.';
  }
}

class FieldDetailScreen extends StatefulWidget {
  final PaddyField field;
  const FieldDetailScreen({super.key, required this.field});
  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  late PaddyField f;
  late GrowthStage _viewedStage;
  final _noteCtrl = TextEditingController();
  final List<String> _notes = [];
  bool _uploading = false;
  WeatherData? _weather;

  @override
  void initState() {
    super.initState();
    f = widget.field;
    final days = DateTime.now().difference(f.plantedDate).inDays;
    _viewedStage = _stageFromDays(days);
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final w = await WeatherService.fetchForLocation(f.location);
      if (mounted) setState(() => _weather = w);
    } catch (_) {}
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 72,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    setState(() => _uploading = true);
    try {
      final url = await FieldService().uploadPhoto(f.id, bytes);
      await FieldService().updateField(f..photoUrl = url);
      if (mounted) setState(() => _uploading = false);
    } catch (e) {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete Field',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.red)),
        content: Text(
            'Are you sure you want to remove "${f.name}"? This action cannot be undone.',
            style: TextStyle(fontSize: 13, color: ctx.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: ctx.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FieldService().deleteField(f.id);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Delete failed: $e'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                }
              }
            },
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
  }

  void _applyTreatment() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Apply Treatment',
            style: TextStyle(fontWeight: FontWeight.w800, color: ctx.textPrimary)),
        content: Text(
            'Mark a treatment as applied to "${f.name}"? This will be logged in the field\'s activity history.',
            style: TextStyle(fontSize: 13, color: ctx.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: ctx.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => f.activityLog.insert(0, 'Treatment applied'));
              FieldService().updateField(f);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Treatment logged successfully'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = DateTime.now().difference(f.plantedDate).inDays;
    final progressPct = (days / 110).clamp(0.0, 1.0);
    final currentStage = _stageFromDays(days);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: context.bg,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: AppColors.primary,
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(f.name,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: context.textPrimary)),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: _confirmDelete,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.redLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.red, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo zone
                    _photoZone(context),
                    const SizedBox(height: 14),

                    // Stats row
                    _statsRow(context, days),
                    const SizedBox(height: 12),

                    // Location + map button
                    _locationRow(context),
                    const SizedBox(height: 18),

                    // Per-field weather + suggestion
                    _fieldWeatherCard(context, currentStage),
                    const SizedBox(height: 22),

                    // Growth tracking section
                    _sectionHeader(context, 'GROWTH TRACKING'),
                    const SizedBox(height: 10),
                    _growthTimelineCard(context, currentStage),
                    const SizedBox(height: 12),
                    _stageDetailCard(context, days, progressPct),
                    const SizedBox(height: 24),

                    // Disease history
                    Row(children: [
                      Expanded(child: _sectionHeader(context, 'DISEASE HISTORY')),
                      // Scan button
                      GestureDetector(
                        onTap: _quickScanForField,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.document_scanner_rounded, size: 12, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text('Scan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Manual log button
                      GestureDetector(
                        onTap: _showLogDiseaseDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.redLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.add_rounded, size: 12, color: AppColors.red),
                            SizedBox(width: 4),
                            Text('Log', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.red)),
                          ]),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    _diseaseCard(context),
                    const SizedBox(height: 24),

                    // Notes
                    _sectionHeader(context, 'NOTES'),
                    const SizedBox(height: 10),
                    _notesCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldWeatherCard(BuildContext context, GrowthStage currentStage) {
    final w = _weather;
    final riskScore = w?.diseaseRiskScore ?? 0;
    final riskColor = riskScore <= 33
        ? AppColors.accent
        : riskScore < 65
            ? AppColors.amber
            : AppColors.red;
    final riskLabel = riskScore <= 33 ? 'Low' : riskScore < 65 ? 'Moderate' : 'High';
    final suggestion = w != null ? _farmingSuggestion(currentStage, w) : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border.withValues(alpha: 0.4)),
        boxShadow: iosShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Weather summary
          Expanded(
            child: Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: (w?.weatherIconColor ?? AppColors.info).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  w?.weatherIconData ?? Icons.wb_cloudy_rounded,
                  size: 20,
                  color: w?.weatherIconColor ?? AppColors.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    w != null ? '${w.temp.round()}°C · ${w.condition}' : 'Loading weather…',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary),
                  ),
                  Text(
                    w != null
                        ? '${w.cityName} · ${w.humidity}% humidity · ${w.windSpeed.toStringAsFixed(1)} m/s'
                        : 'Fetching local weather…',
                    style: TextStyle(fontSize: 11, color: context.textSecondary),
                  ),
                ]),
              ),
            ]),
          ),
          // Disease risk badge
          if (w != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: riskColor.withValues(alpha: 0.3)),
              ),
              child: Column(children: [
                Text(riskLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: riskColor)),
                Text('risk', style: TextStyle(fontSize: 9, color: riskColor)),
              ]),
            ),
        ]),
        if (suggestion != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentLight.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.tips_and_updates_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(suggestion,
                    style: TextStyle(fontSize: 12, color: context.textSecondary, height: 1.4)),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _photoZone(BuildContext context) {
    return GestureDetector(
      onTap: _pickPhoto,
      child: Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.secondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.border.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.hardEdge,
        child: _uploading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2.5))
            : f.photoUrl != null
                ? Stack(fit: StackFit.expand, children: [
                    Image.network(
                      f.photoUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5)),
                      errorBuilder: (_, __, ___) => const Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.broken_image_outlined, color: Colors.white54, size: 32),
                          SizedBox(height: 8),
                          Text('Image unavailable', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ]),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_rounded,
                                color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('Change',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: context.border.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.add_photo_alternate_outlined,
                            size: 26, color: context.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      Text('Add a field photo',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: context.textSecondary)),
                      const SizedBox(height: 2),
                      Text('Tap to upload from gallery',
                          style: TextStyle(
                              fontSize: 11,
                              color: context.textSecondary
                                  .withValues(alpha: 0.6))),
                    ],
                  ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String t) => Text(t,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: context.textSecondary,
          letterSpacing: 1.2));

  Widget _statsRow(BuildContext context, int days) => Row(children: [
        _statCard(context, '${f.areaMorgen.toStringAsFixed(1)} Ac', 'SIZE', context.textPrimary),
        const SizedBox(width: 10),
        _statCard(context, '$days', 'DAYS', context.textPrimary),
        const SizedBox(width: 10),
        _statCard(context, f.healthStatus.label, 'HEALTH', f.healthStatus.color),
      ]);

  Widget _statCard(BuildContext context, String value, String label, Color valueColor) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.border.withValues(alpha: 0.4)),
            boxShadow: iosShadow,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(value,
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: valueColor),
                textAlign: TextAlign.center),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 0.8,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      );

  Widget _locationRow(BuildContext context) => Row(children: [
        Icon(Icons.location_on_outlined, size: 14, color: context.textSecondary),
        const SizedBox(width: 4),
        Expanded(
            child: Text(f.location,
                style: TextStyle(fontSize: 12, color: context.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => FieldMapScreen(field: f))),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.map_rounded, size: 13, color: AppColors.primary),
              const SizedBox(width: 4),
              const Text('View Map',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ]),
          ),
        ),
      ]);

  Widget _growthTimelineCard(BuildContext context, GrowthStage currentStage) {
    final stages = GrowthStage.values;
    final currentIdx = currentStage.index;
    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border.withValues(alpha: 0.4)),
        boxShadow: iosShadow,
      ),
      child: SizedBox(
        height: 152,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: stages.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              final isViewed = s == _viewedStage;
              final isPast = i <= currentIdx;
              return GestureDetector(
                onTap: () => setState(() => _viewedStage = s),
                child: SizedBox(
                  width: 76,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: RicePlantPainter(i, active: isPast),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 22,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (i > 0)
                              Positioned(
                                left: 0,
                                top: 10,
                                child: Container(
                                  width: 38,
                                  height: 2,
                                  color: i <= currentIdx
                                      ? AppColors.primary
                                      : context.border,
                                ),
                              ),
                            if (i < stages.length - 1)
                              Positioned(
                                right: 0,
                                top: 10,
                                child: Container(
                                  width: 38,
                                  height: 2,
                                  color: i < currentIdx
                                      ? AppColors.primary
                                      : context.border,
                                ),
                              ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isViewed ? 15 : 10,
                              height: isViewed ? 15 : 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isPast
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width:
                                      isViewed ? 2.5 : (isPast ? 0 : 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s.shortLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight:
                              isViewed ? FontWeight.w700 : FontWeight.w500,
                          color: isViewed
                              ? AppColors.primary
                              : context.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _stageDetailCard(BuildContext context, int days, double progressPct) {
    final s = _viewedStage;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border.withValues(alpha: 0.4)),
        boxShadow: iosShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.shortLabel,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary)),
              const SizedBox(height: 6),
              Text(s.description,
                  style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary,
                      height: 1.4)),
              const SizedBox(height: 12),
              Text('Estimated days',
                  style: TextStyle(fontSize: 11, color: context.textSecondary)),
              Text(s.dayRange,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ]),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            height: 110,
            child: CustomPaint(painter: RicePlantPainter(s.index, active: true)),
          ),
        ]),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accentLight.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Tips',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(s.note,
                style: TextStyle(
                    fontSize: 12, color: context.textSecondary, height: 1.5)),
          ]),
        ),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Progress',
              style: TextStyle(fontSize: 12, color: context.textSecondary)),
          Text('${(progressPct * 100).round()}%',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progressPct,
            backgroundColor: context.secondary,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            minHeight: 8,
          ),
        ),
      ]),
    );
  }

  Future<void> _quickScanForField() async {
    final messenger = ScaffoldMessenger.of(context);

    // 1. Let user pick image source
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: ctx.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text('Scan Leaf for Disease',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ctx.textPrimary)),
            const SizedBox(height: 4),
            Text('AI will analyse the leaf and auto-record any disease found.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: ctx.textSecondary)),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: AppColors.primary.withValues(alpha: 0.08),
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              ),
              title: Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600, color: ctx.textPrimary)),
              subtitle: Text('Point camera at the leaf', style: TextStyle(fontSize: 12, color: ctx.textSecondary)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: AppColors.accent.withValues(alpha: 0.08),
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.photo_library_outlined, color: AppColors.accent),
              ),
              title: Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600, color: ctx.textPrimary)),
              subtitle: Text('Select an existing photo', style: TextStyle(fontSize: 12, color: ctx.textSecondary)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ]),
        ),
      ),
    );

    if (source == null || !mounted) return;

    // 2. Pick the image
    final file = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (file == null || !mounted) return;

    // 3. Show scanning overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ScanningOverlay(),
    );

    try {
      final disease = await ScanService.analyzeXFiles([file]);

      if (!mounted) return;
      Navigator.of(context).pop(); // close overlay

      if (disease.severity == 'None') {
        // Healthy — do not record
        messenger.showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            const Text('No disease detected — field looks healthy!'),
          ]),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      } else {
        // Disease found — auto-record
        final record = ScanRecord(
          diseaseName: disease.name,
          severity: disease.severity,
          date: DateTime.now(),
          confidence: disease.confidence,
        );
        final newHealth = disease.severity == 'High'
            ? HealthStatus.critical
            : HealthStatus.watch;
        setState(() {
          f.scanHistory.insert(0, record);
          f.healthStatus = newHealth;
        });
        FieldService().updateField(f);
        messenger.showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.bug_report_outlined, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text('${disease.name} detected — recorded to disease history.')),
          ]),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // close overlay
      messenger.showSnackBar(SnackBar(
        content: Text('Scan failed: $e'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  void _showLogDiseaseDialog() {
    final nameCtrl = TextEditingController();
    String severity = 'Medium';
    DateTime date = DateTime.now();
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: ctx.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Log Disease',
              style: TextStyle(fontWeight: FontWeight.w800, color: ctx.textPrimary)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: TextStyle(color: ctx.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Disease name',
                hintText: 'e.g. Rice Blast, Brown Spot',
                labelStyle: TextStyle(color: ctx.textSecondary, fontSize: 13),
                hintStyle: TextStyle(color: ctx.textSecondary, fontSize: 13),
                filled: true,
                fillColor: ctx.secondary,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            // Severity selector
            Row(children: ['Low', 'Medium', 'High'].map((s) {
              final selected = severity == s;
              final color = s == 'High'
                  ? AppColors.red
                  : s == 'Medium'
                      ? AppColors.amber
                      : AppColors.accent;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: s != 'High' ? 6 : 0),
                  child: GestureDetector(
                    onTap: () => setS(() => severity = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: 0.15)
                            : ctx.secondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? color : ctx.border.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(s,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: selected ? color : ctx.textSecondary)),
                    ),
                  ),
                ),
              );
            }).toList()),
            const SizedBox(height: 10),
            // Date picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: date,
                  firstDate: f.plantedDate,
                  lastDate: DateTime.now(),
                  builder: (_, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary)),
                    child: child!,
                  ),
                );
                if (picked != null) setS(() => date = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: ctx.secondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(fontSize: 13, color: ctx.textPrimary),
                  ),
                ]),
              ),
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: ctx.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final record = ScanRecord(
                  diseaseName: name,
                  severity: severity,
                  date: date,
                  confidence: 100.0,
                );
                // Auto-update health status based on logged severity
                final newHealth = severity == 'High'
                    ? HealthStatus.critical
                    : HealthStatus.watch;
                setState(() {
                  f.scanHistory.insert(0, record);
                  f.healthStatus = newHealth;
                });
                FieldService().updateField(f);
                Navigator.pop(ctx);
                messenger.showSnackBar(SnackBar(
                  content: Text('Disease "$name" logged for ${f.name}'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _diseaseCard(BuildContext context) {
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
      child: f.scanHistory.isEmpty
          ? Column(children: [
              Icon(Icons.grass_rounded, size: 36, color: context.textSecondary),
              const SizedBox(height: 8),
              Text('No disease history yet.',
                  style:
                      TextStyle(fontSize: 13, color: context.textSecondary)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton.icon(
                  onPressed: _showLogDiseaseDialog,
                  icon: const Icon(Icons.add_rounded, size: 14, color: AppColors.primary),
                  label: const Text('Log disease',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
              ]),
            ])
          : Column(
              children: f.scanHistory.asMap().entries.map((e) {
                final s = e.value;
                final isLast = e.key == f.scanHistory.length - 1;
                final color = s.severity == 'High'
                    ? AppColors.red
                    : s.severity == 'Medium'
                        ? AppColors.amber
                        : AppColors.accent;
                final bgColor = s.severity == 'High'
                    ? AppColors.redLight
                    : s.severity == 'Medium'
                        ? AppColors.amberLight
                        : AppColors.accentLight;
                return Column(children: [
                  Row(children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.bug_report_outlined, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(s.diseaseName,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: context.textPrimary)),
                          Text(
                              '${s.date.day}/${s.date.month}/${s.date.year} · ${s.confidence.toStringAsFixed(0)}% confidence',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: context.textSecondary)),
                        ])),
                    GestureDetector(
                      onTap: _applyTreatment,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(s.severity,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: color)),
                      ),
                    ),
                  ]),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: context.border),
                    ),
                ]);
              }).toList()),
    );
  }

  Widget _notesCard(BuildContext context) {
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                hintText: 'Add observation...',
                hintStyle: TextStyle(color: context.textSecondary, fontSize: 13),
                filled: true,
                fillColor: context.secondary,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (_noteCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _notes.insert(0, _noteCtrl.text.trim());
                  _noteCtrl.clear();
                });
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('Add',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ),
        ]),
        if (_notes.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._notes.map((n) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.secondary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(n,
                      style:
                          TextStyle(fontSize: 13, color: context.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style:
                        TextStyle(fontSize: 11, color: context.textSecondary),
                  ),
                ]),
              )),
        ] else ...[
          const SizedBox(height: 8),
          Text('No notes yet.',
              style: TextStyle(fontSize: 13, color: context.textSecondary)),
        ],
      ]),
    );
  }
}

// ── Scanning overlay dialog ───────────────────────────────────────────────────

class _ScanningOverlay extends StatefulWidget {
  const _ScanningOverlay();
  @override
  State<_ScanningOverlay> createState() => _ScanningOverlayState();
}

class _ScanningOverlayState extends State<_ScanningOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _step = 0;

  static const _messages = [
    'Uploading image…',
    'Analysing with AI…',
    'Preparing results…',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
    Timer.periodic(const Duration(milliseconds: 1400), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() { if (_step < 2) _step++; });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 40, offset: const Offset(0, 12)),
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.rotate(
              angle: _ctrl.value * 2 * 3.14159,
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.primary],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 20, spreadRadius: 2)],
                ),
                child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 34),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _messages[_step],
              key: ValueKey(_step),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary),
            ),
          ),
          const SizedBox(height: 6),
          Text('AI-powered paddy disease diagnosis',
              style: TextStyle(fontSize: 12, color: context.textSecondary)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _step ? 24 : 8, height: 8,
              decoration: BoxDecoration(
                color: i <= _step ? AppColors.primary : context.secondary,
                borderRadius: BorderRadius.circular(4),
              ),
            )),
          ),
        ]),
      ),
    );
  }
}
