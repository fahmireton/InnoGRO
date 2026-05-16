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

  @override
  void initState() {
    super.initState();
    f = widget.field;
  }

  void _water() {
    setState(() {
      f.waterLevel = (f.waterLevel + 10).clamp(0, 100);
      f.activityLog.insert(0, '💧 Watered field — level now ${f.waterLevel}%');
    });
    _snack('Field watered successfully 💧');
  }

  void _fertilize() {
    setState(() {
      f.fertilizerLevel = (f.fertilizerLevel + 15).clamp(0, 100);
      f.activityLog.insert(0, '🌿 Fertiliser applied — level now ${f.fertilizerLevel}%');
    });
    _snack('Fertiliser applied 🌿');
  }

  void _nextStage() {
    final stages = GrowthStage.values;
    final idx = stages.indexOf(f.stage);
    if (idx < stages.length - 1) {
      setState(() {
        f.stage = stages[idx + 1];
        f.activityLog.insert(0, '📈 Stage advanced to ${f.stage.label}');
      });
      _snack('Advanced to ${f.stage.label} ${f.stage.emoji}');
    } else {
      _snack('Already at final stage ✅');
    }
  }

  void _pestCheck() {
    setState(() {
      f.healthScore = (f.healthScore + 5).clamp(0, 100);
      f.activityLog.insert(0, '🔍 Pest check — all clear');
    });
    _snack('Pest check done — all clear! 🔍');
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2)));

  @override
  Widget build(BuildContext context) {
    final days = DateTime.now().difference(f.plantedDate).inDays;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(children: [
                      Text(f.stage.emoji, style: const TextStyle(fontSize: 36)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.name, style: const TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                          Text('${f.location} • ${f.areaMorgen} morgen • Day $days',
                            style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      )),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: f.healthStatus.bgColor, borderRadius: BorderRadius.circular(20)),
                        child: Text(f.healthStatus.label,
                          style: TextStyle(color: f.healthStatus.color, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _stageCard(),
                const SizedBox(height: 16),
                _metricsCard(),
                const SizedBox(height: 16),
                _actionsCard(),
                if (f.scanHistory.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _diseaseHistoryCard(),
                ],
                const SizedBox(height: 16),
                _activityCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stageCard() => _card(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _cardHeader('Growth Stage', Icons.trending_up_rounded, AppColors.accent, AppColors.accentLight),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${f.stage.emoji} ${f.stage.label}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
        Text('${(f.stage.progress * 100).toInt()}%',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.accent)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: f.stage.progress,
          backgroundColor: AppColors.bg,
          valueColor: const AlwaysStoppedAnimation(AppColors.accent),
          minHeight: 10,
        ),
      ),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: GrowthStage.values.map((s) {
          final active = s.index <= f.stage.index;
          return Opacity(
            opacity: active ? 1.0 : 0.3,
            child: Column(children: [
              Text(s.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 2),
              Text(s.label.split(' ').first,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                  color: active ? AppColors.accent : AppColors.textSecondary)),
            ]),
          );
        }).toList(),
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text('~${f.stage.daysToHarvest} days to harvest',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ]),
      ),
    ],
  ));

  Widget _metricsCard() => _card(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _cardHeader('Field Metrics', Icons.bar_chart_rounded, const Color(0xFF7C3AED), const Color(0xFFF3E8FF)),
      const SizedBox(height: 14),
      _metricBar('💧 Water Level', f.waterLevel, const Color(0xFF0EA5E9)),
      const SizedBox(height: 12),
      _metricBar('🌿 Fertiliser', f.fertilizerLevel, const Color(0xFF7C3AED)),
      const SizedBox(height: 12),
      _metricBar('❤️ Health Score', f.healthScore, f.healthStatus.color),
    ],
  ));

  Widget _metricBar(String label, int value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text('$value%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value / 100,
          backgroundColor: AppColors.bg,
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 8,
        ),
      ),
    ],
  );

  Widget _actionsCard() => _card(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _cardHeader('Quick Actions', Icons.flash_on_rounded, AppColors.amber, AppColors.amberLight),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _actionBtn('💧 Water', const Color(0xFF0EA5E9), _water)),
        const SizedBox(width: 10),
        Expanded(child: _actionBtn('🌿 Fertilise', const Color(0xFF7C3AED), _fertilize)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _actionBtn('📈 Next Stage', AppColors.accent, _nextStage)),
        const SizedBox(width: 10),
        Expanded(child: _actionBtn('🔍 Pest Check', AppColors.amber, _pestCheck)),
      ]),
    ],
  ));

  Widget _actionBtn(String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Center(child: Text(label,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color))),
    ),
  );

  Widget _diseaseHistoryCard() => _card(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _cardHeader('Disease History', Icons.bug_report_rounded, AppColors.red, AppColors.redLight),
      const SizedBox(height: 12),
      ...f.scanHistory.map((s) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Container(width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: s.severity == 'High' ? AppColors.red : AppColors.amber,
            )),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.diseaseName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text('${s.confidence}% confidence • ${_formatDate(s.date)}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: s.severity == 'High' ? AppColors.redLight : AppColors.amberLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(s.severity,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: s.severity == 'High' ? AppColors.red : AppColors.amber)),
          ),
        ]),
      )),
    ],
  ));

  Widget _activityCard() => _card(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _cardHeader('Activity Log', Icons.history_rounded, AppColors.primary, AppColors.accentLight),
      const SizedBox(height: 12),
      ...f.activityLog.take(6).map((log) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 5),
            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(log, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4))),
        ]),
      )),
    ],
  ));

  Widget _cardHeader(String title, IconData icon, Color color, Color bg) => Row(children: [
    Container(width: 32, height: 32,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 17)),
    const SizedBox(width: 10),
    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
  ]);

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: child,
  );

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }
}
