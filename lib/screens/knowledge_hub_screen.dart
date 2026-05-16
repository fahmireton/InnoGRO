import 'package:flutter/material.dart';
import '../theme.dart';

class KnowledgeHubScreen extends StatelessWidget {
  const KnowledgeHubScreen({super.key});

  static const _diseases = [
    _DiseaseData('Rice Blast', 'Magnaporthe oryzae',
      'Diamond-shaped lesions on leaves; can destroy whole panicles.', Icons.bug_report_outlined),
    _DiseaseData('Sheath Blight', 'Rhizoctonia solani',
      'Greyish lesions on leaf sheaths near waterline.', Icons.eco_outlined),
    _DiseaseData('Bacterial Leaf Blight', 'Xanthomonas oryzae',
      'Yellow streaks turning to grey-white wilting on leaves.', Icons.water_drop_outlined),
    _DiseaseData('Brown Spot', 'Bipolaris oryzae',
      'Small brown oval spots; common in nutrient-poor soils.', Icons.grass_outlined),
  ];

  static const _tips = [
    'Drain field briefly between rain spells to suppress sheath blight.',
    'Avoid excess nitrogen — it boosts blast susceptibility.',
    'Rotate fungicide modes of action to prevent resistance.',
    'Inspect lower canopy weekly; most issues start there.',
  ];

  static const _stages = [
    _StageData('Seedling', '0–20', 'Nursery: ensure clean seed and shaded warmth.'),
    _StageData('Tillering', '20–45', 'Top dressing nitrogen; watch for stem borers.'),
    _StageData('Booting', '45–65', 'Critical water — keep 5cm flooded depth.'),
    _StageData('Flowering', '65–85', 'Most vulnerable to blast; preventive spray helps.'),
    _StageData('Ripening', '85–110', 'Drain field 10 days before harvest.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
                ),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Knowledge', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary, letterSpacing: -0.3)),
                    Text('Learn, prevent, thrive',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ])),
                ]),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _sectionLabel('COMMON PADDY DISEASES'),
                  const SizedBox(height: 10),
                  ..._diseases.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _card(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.amberLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(d.icon, size: 20, color: AppColors.amber),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(d.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                        Text(d.sci, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(d.desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary,
                          height: 1.4)),
                      ])),
                    ])),
                  )),

                  const SizedBox(height: 24),
                  _sectionLabel('PREVENTION TIPS'),
                  const SizedBox(height: 10),
                  _card(child: Column(
                    children: _tips.asMap().entries.map((e) => Padding(
                      padding: EdgeInsets.only(bottom: e.key < _tips.length - 1 ? 14 : 0),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.verified_user_outlined, size: 20, color: AppColors.accent),
                        const SizedBox(width: 10),
                        Expanded(child: Text(e.value,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4))),
                      ]),
                    )).toList(),
                  )),

                  const SizedBox(height: 24),
                  _sectionLabel('GROWTH STAGES'),
                  const SizedBox(height: 10),
                  _card(child: Column(
                    children: _stages.asMap().entries.map((e) {
                      final i = e.key;
                      final s = e.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: i < _stages.length - 1 ? 16 : 0),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(
                              color: AppColors.accentLight,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('${i + 1}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                                  color: AppColors.primary)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            RichText(text: TextSpan(
                              text: s.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary),
                              children: [
                                TextSpan(
                                  text: '  (${s.days} days)',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400,
                                    color: AppColors.textSecondary),
                                ),
                              ],
                            )),
                            const SizedBox(height: 2),
                            Text(s.note, style: const TextStyle(fontSize: 12,
                              color: AppColors.textSecondary, height: 1.4)),
                          ])),
                        ]),
                      );
                    }).toList(),
                  )),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
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
    child: child,
  );

  Widget _sectionLabel(String t) => Text(t,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
      color: AppColors.textSecondary, letterSpacing: 1.2));
}

class _DiseaseData {
  final String name, sci, desc;
  final IconData icon;
  const _DiseaseData(this.name, this.sci, this.desc, this.icon);
}

class _StageData {
  final String name, days, note;
  const _StageData(this.name, this.days, this.note);
}
