import 'package:flutter/material.dart';
import '../theme.dart';

class EconomicToolsScreen extends StatefulWidget {
  const EconomicToolsScreen({super.key});

  @override
  State<EconomicToolsScreen> createState() => _EconomicToolsScreenState();
}

class _EconomicToolsScreenState extends State<EconomicToolsScreen> {
  int _selectedSeverity = 0; // 0=Low, 1=Medium, 2=High

  static const _severityLabels = ['Low', 'Medium', 'High'];
  static const _yieldLoss = [5, 20, 40];
  static const _rmLoss = [60, 240, 480];

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      );

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
      );

  Widget _dividerLine() => const Divider(color: AppColors.divider, height: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.bg,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.textPrimary,
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Economic Tools',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── MARKET PRICES ──────────────────────────────────────
                _sectionLabel('MARKET PRICES'),
                Container(
                  decoration: _cardDecoration,
                  child: Column(
                    children: [
                      _marketPriceRow('Paddy (MR219)', 'RM 1,200/mt', true),
                      _dividerLine(),
                      _marketPriceRow('Paddy (MR263)', 'RM 1,250/mt', true),
                      _dividerLine(),
                      _marketPriceRow('Beras Wangi', 'RM 2,800/mt', null),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── TREATMENT COSTS ────────────────────────────────────
                _sectionLabel('TREATMENT COSTS'),
                Container(
                  decoration: _cardDecoration,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      _costRow('Tricyclazole 75WP', 'RM 45/acre'),
                      _dividerLine(),
                      _costRow('Neem Oil (Organic)', 'RM 28/acre'),
                      _dividerLine(),
                      _costRow('Isoprothiolane', 'RM 38/acre'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── YIELD LOSS ESTIMATOR ───────────────────────────────
                _sectionLabel('YIELD LOSS ESTIMATOR'),
                Container(
                  decoration: _cardDecoration,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Disease Severity',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(3, (i) {
                          final selected = _selectedSeverity == i;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedSeverity = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected ? AppColors.primary : AppColors.accentLight,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _severityLabels[i],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? Colors.white : AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.divider, height: 1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _estimatorMetric(
                              'Yield Loss',
                              '${_yieldLoss[_selectedSeverity]}%',
                              AppColors.amber,
                            ),
                          ),
                          Container(width: 1, height: 48, color: AppColors.divider),
                          Expanded(
                            child: _estimatorMetric(
                              'RM Loss / Acre',
                              'RM ${_rmLoss[_selectedSeverity]}',
                              AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── INPUT COST TRACKER ─────────────────────────────────
                _sectionLabel('INPUT COST TRACKER'),
                Container(
                  decoration: _cardDecoration,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      _inputCostRow('Seeds', 'RM 120'),
                      _dividerLine(),
                      _inputCostRow('Fertiliser', 'RM 340'),
                      _dividerLine(),
                      _inputCostRow('Pesticide', 'RM 180'),
                      _dividerLine(),
                      _inputCostRow('Labour', 'RM 600'),
                      _dividerLine(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'RM 1,240',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── ROI CALCULATOR ─────────────────────────────────────
                _sectionLabel('ROI CALCULATOR'),
                Container(
                  decoration: _cardDecoration,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _roiRow('Yield', '4.5 mt/acre', false),
                      const SizedBox(height: 10),
                      _roiRow('Revenue', 'RM 5,400', false),
                      const SizedBox(height: 10),
                      _roiRow('Total Cost', 'RM 1,240', false),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppColors.divider, height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Net Profit',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'RM 4,160',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Return on Investment',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.accentLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '335%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marketPriceRow(String crop, String price, bool? trendingUp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              crop,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          if (trendingUp == null)
            const Icon(Icons.remove_rounded, size: 16, color: AppColors.textSecondary)
          else if (trendingUp)
            const Icon(Icons.arrow_upward_rounded, size: 16, color: Color(0xFF16A34A))
          else
            const Icon(Icons.arrow_downward_rounded, size: 16, color: AppColors.red),
        ],
      ),
    );
  }

  Widget _costRow(String name, String cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              cost,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _estimatorMetric(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _inputCostRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roiRow(String label, String value, bool highlight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: highlight ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            color: highlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
