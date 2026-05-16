import 'dart:math' as math;
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
  bool _organicSelected = true;
  double _acres = 3.2;
  final _acresCtrl = TextEditingController(text: '3.2');

  Disease get d => widget.disease;

  Color get _severityColor => d.severity == 'High' ? AppColors.red : d.severity == 'Medium' ? AppColors.amber : AppColors.accent;
  Color get _severityBg => d.severity == 'High' ? AppColors.redLight : d.severity == 'Medium' ? AppColors.amberLight : AppColors.accentLight;
  String get _severityLabel => d.severity == 'None' ? 'HEALTHY' : d.severity.toUpperCase();

  @override
  void dispose() { _acresCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: context.bg,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Diagnosis', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(delegate: SliverChildListDelegate([
              _photoRow(),
              const SizedBox(height: 16),
              _diseaseCard(context),
              const SizedBox(height: 24),
              if (d.symptoms.isNotEmpty || d.causes.isNotEmpty) ...[
                _sectionLabel('DISEASE INFO'),
                const SizedBox(height: 12),
                _accordionCard(context),
                const SizedBox(height: 24),
              ],
              if (d.organicTreatments.isNotEmpty || d.chemicalTreatments.isNotEmpty) ...[
                _sectionLabel('TREATMENT'),
                const SizedBox(height: 12),
                _treatmentCard(context),
              ],
            ])),
          ),
        ],
      ),
    );
  }

  Widget _photoRow() {
    final colors = [const Color(0xFF8B6914), const Color(0xFF5A7A3A), const Color(0xFF7A4A3A)];
    return Row(
      children: List.generate(3, (i) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: colors[i % colors.length].withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.grass_rounded, color: colors[i % colors.length], size: 36),
            ),
          ),
        ),
      )),
    );
  }

  Widget _diseaseCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: _severityBg, borderRadius: BorderRadius.circular(20)),
              child: Text(_severityLabel, style: TextStyle(color: _severityColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ),
            const SizedBox(width: 10),
            const Text('Paddy/Rice', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 10),
          Text(d.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
          if (d.scientificName.isNotEmpty)
            Text(d.scientificName, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
          const SizedBox(height: 16),
          Row(children: [
            _ConfidenceRing(confidence: d.confidence),
            const SizedBox(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('CONFIDENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
              Text('${d.confidence.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -1)),
              Text('Recovery ≈ ${d.recoveryTime}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ]),
          const SizedBox(height: 14),
          Text(d.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _accordionCard(BuildContext context) {
    final sections = [
      ('Symptoms', Icons.warning_amber_rounded, d.symptoms),
      ('Causes', Icons.eco_rounded, d.causes),
      ('Lifecycle', Icons.schedule_rounded, ['Spores spread by wind and water splash', 'Germination occurs within 6–8 hours at high humidity', 'New lesions appear within 7–10 days of infection']),
      ('Prevention', Icons.shield_rounded, d.prevention),
    ];
    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: List.generate(sections.length, (i) {
          final s = sections[i];
          final isLast = i == sections.length - 1;
          return Column(children: [
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: i == 0,
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)),
                  child: Icon(s.$2, color: AppColors.primary, size: 18),
                ),
                title: Text(s.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                iconColor: AppColors.textSecondary,
                collapsedIconColor: AppColors.textSecondary,
                children: [
                  ...s.$3.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 6),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5))),
                    ]),
                  )),
                ],
              ),
            ),
            if (!isLast) Divider(height: 1, indent: 16, endIndent: 16, color: context.border),
          ]);
        }),
      ),
    );
  }

  Widget _treatmentCard(BuildContext context) {
    final treatments = _organicSelected ? d.organicTreatments : d.chemicalTreatments;
    final costPerAcre = _organicSelected ? 50.0 : 75.0;
    final products = _organicSelected
      ? ['Neem oil', 'Bacillus subtilis based biofungicides']
      : ['Tricyclazole 75WP', 'Isoprothiolane'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: context.bg, borderRadius: BorderRadius.circular(30)),
            child: Row(children: [
              _tabBtn(context, '🌱  Organic', _organicSelected, () => setState(() => _organicSelected = true)),
              _tabBtn(context, '⚗️  Chemical', !_organicSelected, () => setState(() => _organicSelected = false)),
            ]),
          ),
          const SizedBox(height: 18),
          ...List.generate(treatments.isNotEmpty ? math.min(treatments.length * 2, 5) : 5, (i) {
            final steps = treatments.isNotEmpty
              ? treatments.expand((t) => t.instructions.split('. ')).where((s) => s.isNotEmpty).take(5).toList()
              : ['Remove and destroy infected plant debris to reduce fungal inoculum.',
                 'Improve field sanitation and water management.',
                 'Use resistant rice varieties if available.',
                 'Apply treatment as per label instructions.',
                 'Monitor and repeat after 7-10 days.'];
            if (i >= steps.length) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(steps[i].trim(), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5))),
              ]),
            );
          }),
          const SizedBox(height: 8),
          const Text('RECOMMENDED PRODUCTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: products.map((p) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: context.bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.border),
              ),
              child: Text(p, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: context.bg, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('COST CALCULATOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                const Icon(Icons.attach_money_rounded, size: 16, color: AppColors.textSecondary),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _acresCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => setState(() => _acres = double.tryParse(v) ?? _acres),
                    decoration: InputDecoration(
                      filled: true, fillColor: context.card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('acres', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const Spacer(),
                Text('RM ${(_acres * costPerAcre).toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
              ]),
              const SizedBox(height: 4),
              Align(alignment: Alignment.centerLeft,
                child: Text('≈ RM ${costPerAcre.toStringAsFixed(0)} per acre',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: const Text('Mark treatment applied', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(BuildContext context, String label, bool selected, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? context.card : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: selected ? [BoxShadow(color: AppColors.cardShadow, blurRadius: 4)] : null,
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
          color: selected ? AppColors.textPrimary : AppColors.textSecondary))),
      ),
    ),
  );

  Widget _sectionLabel(String t) => Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.2));
}

class _ConfidenceRing extends StatelessWidget {
  final double confidence;
  const _ConfidenceRing({required this.confidence});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 70, height: 70,
    child: CustomPaint(
      painter: _RingPainter(confidence / 100),
      child: const Center(),
    ),
  );
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 5;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, math.pi * 2, false,
      Paint()..color = AppColors.accentLight..strokeWidth = 7..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, math.pi * 2 * progress, false,
      Paint()..color = AppColors.primary..strokeWidth = 7..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
