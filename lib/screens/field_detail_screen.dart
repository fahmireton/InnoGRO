import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/field.dart';
import '../widgets/rice_plant.dart';
import 'field_map_screen.dart';

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

  @override
  void initState() {
    super.initState();
    f = widget.field;
    _viewedStage = f.stage;
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
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
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
              setState(() {
                f.activityLog.insert(0, 'Treatment applied');
              });
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
                    // Variety subtitle
                    Text('Paddy (${f.variety})',
                        style: TextStyle(fontSize: 13, color: context.textSecondary)),
                    const SizedBox(height: 14),

                    // Stats row
                    _statsRow(context, days),
                    const SizedBox(height: 12),

                    // Location + map button
                    _locationRow(context),
                    const SizedBox(height: 22),

                    // Growth tracking section
                    _sectionHeader(context, 'GROWTH TRACKING'),
                    const SizedBox(height: 10),
                    _growthTimelineCard(context),
                    const SizedBox(height: 12),
                    _stageDetailCard(context, days, progressPct),
                    const SizedBox(height: 24),

                    // Disease history
                    _sectionHeader(context, 'DISEASE HISTORY'),
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

  Widget _growthTimelineCard(BuildContext context) {
    final stages = GrowthStage.values;
    final currentIdx = f.stage.index;
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
                      // Dot row
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
              Text('No disease history.',
                  style:
                      TextStyle(fontSize: 13, color: context.textSecondary)),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _applyTreatment,
                child: const Text('Run first scan →',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ),
            ])
          : Column(
              children: f.scanHistory.asMap().entries.map((e) {
                final s = e.value;
                final isLast = e.key == f.scanHistory.length - 1;
                return Column(children: [
                  Row(children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: s.severity == 'High'
                            ? AppColors.redLight
                            : AppColors.amberLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.bug_report_outlined,
                          color: s.severity == 'High'
                              ? AppColors.red
                              : AppColors.amber,
                          size: 20),
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
                          color: s.severity == 'High'
                              ? AppColors.redLight
                              : AppColors.amberLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(s.severity,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: s.severity == 'High'
                                    ? AppColors.red
                                    : AppColors.amber)),
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
