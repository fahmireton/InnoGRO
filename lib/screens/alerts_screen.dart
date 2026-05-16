import 'package:flutter/material.dart';
import '../theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  static const _regionalAlerts = [
    _Alert('Brown planthopper outbreak nearby',
      '5km from your farm — inspect undersides of leaves daily.',
      Icons.warning_rounded, AppColors.red, AppColors.redLight, '2h ago'),
    _Alert('Optimal spraying tomorrow 6-9am',
      'Dry, low wind — ideal window for fungicide.',
      Icons.water_drop_outlined, AppColors.info, AppColors.infoLight, '4h ago'),
    _Alert('Paddy market price up 4%',
      'RM 1,360/tonne in Selangor mills today.',
      Icons.trending_up_rounded, AppColors.accent, AppColors.accentLight, '6h ago'),
    _Alert('MOA subsidy disbursement',
      'Q2 SSP payments reach BSN accounts this week.',
      Icons.campaign_outlined, AppColors.info, AppColors.infoLight, '1d ago'),
  ];

  final List<_Reminder> _reminders = [];

  void _addReminder() {
    setState(() {
      _reminders.add(_Reminder(
        'Follow-up inspection',
        DateTime.now().add(const Duration(days: 7)),
        false,
      ));
    });
  }

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
                        color: context.secondary, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Alerts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary, letterSpacing: -0.3)),
                    Text('Stay ahead of risk',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ])),
                ]),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Reminders section
                  _sectionLabel('YOUR REMINDERS'),
                  const SizedBox(height: 10),
                  if (_reminders.isEmpty)
                    _card(context, child: Column(children: [
                      const Icon(Icons.notifications_none_rounded, size: 32,
                        color: AppColors.textSecondary),
                      const SizedBox(height: 8),
                      const Text('No active reminders. Apply a treatment from a scan to add one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _addReminder,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: context.secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Add test reminder',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                        ),
                      ),
                    ]))
                  else
                    Column(
                      children: _reminders.asMap().entries.map((e) {
                        final r = e.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _card(context, child: Row(children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: r.done ? AppColors.accentLight : AppColors.accentLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                r.done ? Icons.check_circle_outlined : Icons.calendar_today_outlined,
                                size: 18,
                                color: r.done ? AppColors.accent : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(r.title,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  decoration: r.done ? TextDecoration.lineThrough : null)),
                              Text('Due ${r.dueAt.day}/${r.dueAt.month}/${r.dueAt.year}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ])),
                            if (!r.done)
                              GestureDetector(
                                onTap: () => setState(() => r.done = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: context.secondary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Done',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                                ),
                              ),
                          ])),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 24),
                  _sectionLabel('REGIONAL ALERTS'),
                  const SizedBox(height: 10),
                  ..._regionalAlerts.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _card(context, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: a.bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(a.icon, size: 18, color: a.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(a.body, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary,
                          height: 1.4)),
                        const SizedBox(height: 4),
                        Text(a.time, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ])),
                    ])),
                  )),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
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

class _Alert {
  final String title, body, time;
  final IconData icon;
  final Color color, bgColor;
  const _Alert(this.title, this.body, this.icon, this.color, this.bgColor, this.time);
}

class _Reminder {
  final String title;
  final DateTime dueAt;
  bool done;
  _Reminder(this.title, this.dueAt, this.done);
}
