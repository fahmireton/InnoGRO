import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/field.dart';

class FieldDetailScreen extends StatefulWidget {
  final PaddyField field;
  const FieldDetailScreen({super.key, required this.field});
  @override
  State<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends State<FieldDetailScreen> {
  late PaddyField f;
  final _noteCtrl = TextEditingController();
  final List<String> _notes = [];

  @override
  void initState() {
    super.initState();
    f = widget.field;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = DateTime.now().difference(f.plantedDate).inDays;
    final stages = GrowthStage.values;
    final currentIdx = f.stage.index;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Sticky header
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.bg,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: AppColors.primary,
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(f.name,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18,
                  color: AppColors.textPrimary)),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.redLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.red, size: 20),
                  ),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Location row
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(child: Text(f.location,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 16),

                  // Stat boxes
                  _sectionLabel('Details'),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.2,
                    children: [
                      _statBox('${f.areaMorgen.toStringAsFixed(1)} ac', 'Size', AppColors.textPrimary),
                      _statBox('${days}d', 'Days in field', AppColors.textPrimary),
                      _statBox(f.healthStatus.label, 'Health', f.healthStatus.color),
                      _statBox('${f.waterLevel}%', 'Water level', AppColors.info),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Growth tracking
                  _sectionLabel('Growth stage'),
                  const SizedBox(height: 10),
                  _growthCard(stages, currentIdx, days),
                  const SizedBox(height: 24),

                  // Disease history
                  _sectionLabel('Disease history'),
                  const SizedBox(height: 10),
                  _diseaseCard(),
                  const SizedBox(height: 24),

                  // Notes
                  _sectionLabel('Notes'),
                  const SizedBox(height: 10),
                  _notesCard(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: valueColor,
            letterSpacing: -0.3)),
      ]),
    );
  }

  Widget _growthCard(List<GrowthStage> stages, int currentIdx, int days) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Scrollable stage pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: stages.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              final active = i <= currentIdx;
              return Padding(
                padding: EdgeInsets.only(right: i < stages.length - 1 ? 6 : 0),
                child: GestureDetector(
                  onTap: () => setState(() {
                    f.stage = s;
                    f.activityLog.insert(0, 'Stage updated to ${s.label}');
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(s.label,
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: active ? Colors.white : AppColors.textSecondary)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Progress bar
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Day 0', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Text('${days}d / ~110d',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (days / 110).clamp(0.0, 1.0),
            backgroundColor: AppColors.secondary,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 14),

        // Current stage tip
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accentLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${f.stage.emoji}  ${f.stage.label}  ·  ${f.stage.dayRange}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(f.stage.note,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
          ]),
        ),
      ]),
    );
  }

  Widget _diseaseCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: f.scanHistory.isEmpty
        ? Column(children: [
            const Icon(Icons.grass_rounded, size: 36, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            const Text('No disease history.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: const Text('Run first scan →',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
          ])
        : Column(children: f.scanHistory.asMap().entries.map((e) {
            final s = e.value;
            final isLast = e.key == f.scanHistory.length - 1;
            return Column(children: [
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: s.severity == 'High' ? AppColors.redLight : AppColors.amberLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.bug_report_outlined,
                    color: s.severity == 'High' ? AppColors.red : AppColors.amber, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.diseaseName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                      color: AppColors.textPrimary)),
                  Text('${s.date.day}/${s.date.month}/${s.date.year} · ${s.confidence.toStringAsFixed(0)}% confidence',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: s.severity == 'High' ? AppColors.redLight : AppColors.amberLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(s.severity,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: s.severity == 'High' ? AppColors.red : AppColors.amber)),
                ),
              ]),
              if (!isLast) const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: AppColors.border),
              ),
            ]);
          }).toList()),
    );
  }

  Widget _notesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                hintText: 'Add observation...',
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                filled: true,
                fillColor: AppColors.secondary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('Add',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ]),
        if (_notes.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._notes.map((n) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(
                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ]),
          )),
        ] else ...[
          const SizedBox(height: 8),
          const Text('No notes yet.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ]),
    );
  }

  Widget _sectionLabel(String t) => Text(t,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
      color: AppColors.textSecondary, letterSpacing: 0.3));
}
