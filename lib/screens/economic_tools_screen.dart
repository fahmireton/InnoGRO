import 'package:flutter/material.dart';
import '../theme.dart';

class EconomicToolsScreen extends StatefulWidget {
  const EconomicToolsScreen({super.key});
  @override
  State<EconomicToolsScreen> createState() => _EconomicToolsScreenState();
}

class _EconomicToolsScreenState extends State<EconomicToolsScreen> {
  static const _priceHistory = [1280.0, 1295.0, 1310.0, 1305.0, 1325.0, 1340.0, 1335.0, 1350.0, 1345.0, 1360.0];

  double _costAcres = 2;
  double _costPerAcre = 180;
  double _yieldNormal = 6;
  double _yieldLost = 1.2;
  double _pricePerTonne = 1360;

  double get _treatmentCost => _costAcres * _costPerAcre;
  double get _lossValue => _yieldLost * _costAcres * _pricePerTonne;
  double get _savedValue => (_yieldNormal - _yieldLost) * _costAcres * _pricePerTonne;
  int get _roi => _treatmentCost > 0
    ? ((_lossValue - _treatmentCost) / _treatmentCost * 100).round()
    : 0;

  static const _inputs = [
    ('Seeds', 'RM 320'),
    ('Fertilizer', 'RM 540'),
    ('Pesticides', 'RM 280'),
    ('Labour', 'RM 460'),
    ('Fuel', 'RM 180'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: context.bg,
                  border: Border(bottom: BorderSide(color: context.border.withValues(alpha: 0.5))),
                ),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: context.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Economic tools', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary, letterSpacing: -0.3)),
                    Text('Plan & maximise returns',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ])),
                ]),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Market price
                  _sectionLabel('PADDY MARKET PRICE (RM/TONNE)'),
                  const SizedBox(height: 10),
                  _card(context, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('RM ${_priceHistory.last.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary, letterSpacing: -1)),
                        const Row(children: [
                          Icon(Icons.trending_up_rounded, size: 14, color: AppColors.accent),
                          SizedBox(width: 4),
                          Text('+6.3% this month',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
                        ]),
                      ])),
                      const Text('Selangor mills',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ]),
                    const SizedBox(height: 12),
                    _Sparkline(data: _priceHistory),
                  ])),

                  const SizedBox(height: 24),
                  _sectionLabel('TREATMENT COST CALCULATOR'),
                  const SizedBox(height: 10),
                  _card(context, child: Column(children: [
                    _numberInput(context, 'Area (acres)', _costAcres, 1, (v) => setState(() => _costAcres = v)),
                    _numberInput(context, 'Cost per acre (RM)', _costPerAcre, 10, (v) => setState(() => _costPerAcre = v)),
                    const SizedBox(height: 4),
                    _resultBox(context, 'Total treatment cost', 'RM ${_treatmentCost.toStringAsFixed(0)}'),
                  ])),

                  const SizedBox(height: 24),
                  _sectionLabel('YIELD LOSS & ROI'),
                  const SizedBox(height: 10),
                  _card(context, child: Column(children: [
                    _numberInput(context, 'Normal yield (t/acre)', _yieldNormal, 0.1, (v) => setState(() => _yieldNormal = v)),
                    _numberInput(context, 'Expected loss (t/acre)', _yieldLost, 0.1, (v) => setState(() => _yieldLost = v)),
                    _numberInput(context, 'Price (RM/tonne)', _pricePerTonne, 20, (v) => setState(() => _pricePerTonne = v)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: _statBox('Loss value', 'RM ${_lossValue.toStringAsFixed(0)}',
                        AppColors.red, AppColors.redLight, Icons.trending_down_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: _statBox('If treated', 'RM ${_savedValue.toStringAsFixed(0)}',
                        AppColors.accent, AppColors.accentLight, Icons.grass_rounded)),
                    ]),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(children: [
                        const Text('TREATMENT ROI',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                            color: AppColors.primary, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text('$_roi%',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800,
                            color: AppColors.primary, letterSpacing: -1)),
                        const Text('Per RM spent on treatment',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ]),
                    ),
                  ])),

                  const SizedBox(height: 24),
                  _sectionLabel('INPUT COST TRACKER'),
                  const SizedBox(height: 10),
                  _card(context, child: Column(children: [
                    ..._inputs.asMap().entries.map((e) {
                      final i = e.key;
                      final item = e.value;
                      return Column(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(children: [
                            Text(item.$1, style: const TextStyle(fontSize: 14,
                              color: AppColors.textSecondary)),
                            const Spacer(),
                            Text(item.$2, style: const TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          ]),
                        ),
                        if (i < _inputs.length - 1)
                          Divider(height: 1, color: context.border),
                      ]);
                    }),
                    Divider(height: 16, color: context.border),
                    const Row(children: [
                      Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                      Spacer(),
                      Text('RM 1,780', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
                    ]),
                  ])),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberInput(BuildContext context, String label, double value, double step, ValueChanged<double> onChange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: AppColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: context.secondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.border),
              ),
              child: Text(value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () { if (value > step) onChange((value - step * 10).roundToDouble() / 10); },
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: context.secondary, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.remove_rounded, size: 18, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onChange(((value + step) * 10).roundToDouble() / 10),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _resultBox(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.secondary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
          color: AppColors.textPrimary)),
      ]),
    );
  }

  Widget _statBox(String label, String value, Color color, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
          color: color, letterSpacing: -0.5)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.card,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: context.border.withValues(alpha: 0.4)),
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

// Sparkline chart
class _Sparkline extends StatelessWidget {
  final List<double> data;
  const _Sparkline({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: CustomPaint(painter: _SparklinePainter(data)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  _SparklinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = max - min;

    List<Offset> pts = [];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - min) / (range == 0 ? 1 : range)) * size.height;
      pts.add(Offset(x, y));
    }

    // Fill area
    final fillPath = Path()..moveTo(pts.first.dx, size.height);
    for (final p in pts) { fillPath.lineTo(p.dx, p.dy); }
    fillPath..lineTo(pts.last.dx, size.height)..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.primary.withValues(alpha: 0.3), AppColors.primary.withValues(alpha: 0)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) { linePath.lineTo(pts[i].dx, pts[i].dy); }
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => false;
}
