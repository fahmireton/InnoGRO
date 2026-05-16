import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/disease.dart';

class ResultScreen extends StatefulWidget {
  final Disease disease;
  const ResultScreen({super.key, required this.disease});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _treatmentTab = 0;

  Color get _severityColor {
    switch (widget.disease.severity) {
      case 'High': return AppColors.red;
      case 'Medium': return AppColors.amber;
      case 'None': return AppColors.accent;
      default: return AppColors.textSecondary;
    }
  }

  Color get _severityBg {
    switch (widget.disease.severity) {
      case 'High': return AppColors.redLight;
      case 'Medium': return AppColors.amberLight;
      case 'None': return AppColors.accentLight;
      default: return AppColors.bg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.disease;
    final isHealthy = d.severity == 'None';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: isHealthy ? AppColors.accent : _severityColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Scan Result', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isHealthy
                      ? [AppColors.primaryLight, AppColors.accent]
                      : [_severityColor.withValues(alpha: 0.9), _severityColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(isHealthy ? '✅' : '🔬', style: const TextStyle(fontSize: 52)),
                    const SizedBox(height: 8),
                    Text(d.name, style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                    if (d.scientificName.isNotEmpty)
                      Text(d.scientificName, style: const TextStyle(
                        color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _confidenceCard(),
                const SizedBox(height: 16),
                _descriptionCard(),
                if (d.symptoms.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _listCard('Symptoms', Icons.search_rounded, d.symptoms, const Color(0xFF7C3AED), const Color(0xFFF3E8FF)),
                ],
                if (d.causes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _listCard('Causes', Icons.info_rounded, d.causes, AppColors.amber, AppColors.amberLight),
                ],
                if (d.organicTreatments.isNotEmpty || d.chemicalTreatments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _treatmentCard(),
                ],
                const SizedBox(height: 16),
                _listCard('Prevention Tips', Icons.shield_rounded, d.prevention, AppColors.accent, AppColors.accentLight),
                if (!isHealthy) ...[
                  const SizedBox(height: 16),
                  _recoveryCard(),
                ],
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Scan Another Field'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _confidenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Confidence', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Text('${widget.disease.confidence}%',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -1)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: widget.disease.confidence / 100,
                    backgroundColor: AppColors.bg,
                    valueColor: AlwaysStoppedAnimation(AppColors.accent),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Severity', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: _severityBg, borderRadius: BorderRadius.circular(20)),
                child: Text(widget.disease.severity,
                  style: TextStyle(color: _severityColor, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _descriptionCard() {
    return _card(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(widget.disease.description,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
      ],
    ));
  }

  Widget _listCard(String title, IconData icon, List<String> items, Color color, Color bg) {
    return _card(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(width: 30, height: 30,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16)),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Text(item, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5))),
          ]),
        )),
      ],
    ));
  }

  Widget _treatmentCard() {
    final d = widget.disease;
    final tabs = [
      if (d.organicTreatments.isNotEmpty) ('🌿 Organic', d.organicTreatments),
      if (d.chemicalTreatments.isNotEmpty) ('⚗️ Chemical', d.chemicalTreatments),
    ];

    return _card(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Treatment Options', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Row(children: List.generate(tabs.length, (i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _treatmentTab = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _treatmentTab == i ? AppColors.primary : AppColors.bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(tabs[i].$1,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: _treatmentTab == i ? Colors.white : AppColors.textSecondary)),
            ),
          ),
        ))),
        const SizedBox(height: 16),
        ...tabs[_treatmentTab].$2.map((t) => _treatmentItem(t)),
      ],
    ));
  }

  Widget _treatmentItem(Treatment t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
          Text(t.estimatedCost, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 6),
        Text(t.instructions, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 8),
        Row(children: [
          const Text('Effectiveness: ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ...List.generate(5, (i) => Icon(Icons.star_rounded,
            size: 14, color: i < t.effectivenessRating ? AppColors.amber : AppColors.divider)),
        ]),
      ]),
    );
  }

  Widget _recoveryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 28),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Expected Recovery', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          Text(widget.disease.recoveryTime,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ]),
      ]),
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: child,
  );
}
