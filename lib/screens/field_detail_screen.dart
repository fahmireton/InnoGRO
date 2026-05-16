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
  void initState() { super.initState(); f = widget.field; }
  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final days = DateTime.now().difference(f.plantedDate).inDays;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.bg,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
                Text(f.location.split(',').first == 'Paddy' ? f.location : 'Paddy (MR219)',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w400)),
              ]),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 20),
                  ),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(delegate: SliverChildListDelegate([
                _statsRow(days),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(f.location, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 24),
                _sectionLabel('GROWTH STAGE'),
                const SizedBox(height: 12),
                _growthStageCard(),
                const SizedBox(height: 24),
                _sectionLabel('DISEASE HISTORY'),
                const SizedBox(height: 12),
                _diseaseHistoryCard(),
                const SizedBox(height: 24),
                _sectionLabel('NOTES'),
                const SizedBox(height: 12),
                _notesCard(),
              ])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsRow(int days) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Expanded(child: _statItem('${f.areaMorgen.toStringAsFixed(1)} Ac', 'SIZE', AppColors.textPrimary)),
        _vertDivider(),
        Expanded(child: _statItem('$days', 'DAYS', AppColors.textPrimary)),
        _vertDivider(),
        Expanded(child: _statItem(f.healthStatus.label, 'HEALTH', f.healthStatus.color)),
      ]),
    );
  }

  Widget _statItem(String value, String label, Color valueColor) => Column(children: [
    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: valueColor, letterSpacing: -0.3)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 1)),
  ]);

  Widget _vertDivider() => Container(height: 36, width: 1, color: AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: 8));

  Widget _growthStageCard() {
    final stages = GrowthStage.values;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: stages.take(4).map((s) {
              final selected = s == f.stage;
              final passed = s.index < f.stage.index;
              return GestureDetector(
                onTap: () => setState(() {
                  f.stage = s;
                  f.activityLog.insert(0, 'Stage updated to ${s.label}');
                }),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : passed ? AppColors.accentLight : AppColors.bg,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(s.label, style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : passed ? AppColors.accent : AppColors.textSecondary)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: f.stage.progress,
            backgroundColor: AppColors.bg,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ]),
    );
  }

  Widget _diseaseHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: f.scanHistory.isEmpty
        ? Column(children: [
            const Icon(Icons.grass_rounded, size: 36, color: AppColors.textSecondary),
            const SizedBox(height: 10),
            const Text('No scans for this field yet.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
              child: const Text('Scan now', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ])
        : Column(children: f.scanHistory.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(
                color: s.severity == 'High' ? AppColors.red : AppColors.amber, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(s.diseaseName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              Text('${s.confidence.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          )).toList()),
    );
  }

  Widget _notesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                hintText: 'Add observation...',
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                filled: true, fillColor: AppColors.bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              if (_noteCtrl.text.trim().isNotEmpty) {
                setState(() { _notes.insert(0, _noteCtrl.text.trim()); _noteCtrl.clear(); });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
            child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 12),
        if (_notes.isEmpty)
          const Text('No notes yet.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
        else
          ..._notes.map((n) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(n, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
            ]),
          )),
      ]),
    );
  }

  Widget _sectionLabel(String t) => Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.2));
}
