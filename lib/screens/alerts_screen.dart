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
        Icons.warning_rounded,
        AppColors.red,
        AppColors.redLight,
        '2h ago'),
    _Alert('Optimal spraying tomorrow 6-9am',
        'Dry, low wind — ideal window for fungicide.',
        Icons.water_drop_outlined,
        AppColors.info,
        AppColors.infoLight,
        '4h ago'),
    _Alert('Paddy market price up 4%',
        'RM 1,360/tonne in Selangor mills today.',
        Icons.trending_up_rounded,
        AppColors.accent,
        AppColors.accentLight,
        '6h ago'),
    _Alert('MOA subsidy disbursement',
        'Q2 SSP payments reach BSN accounts this week.',
        Icons.campaign_outlined,
        AppColors.info,
        AppColors.infoLight,
        '1d ago'),
  ];

  final List<_Reminder> _reminders = [];

  void _showAddReminderDialog() {
    final ctrl = TextEditingController();
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: ctx.card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Add Reminder',
              style: TextStyle(
                  fontWeight: FontWeight.w800, color: ctx.textPrimary)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: ctrl,
              autofocus: true,
              style: TextStyle(color: ctx.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Reminder title',
                labelStyle: TextStyle(color: ctx.textSecondary, fontSize: 13),
                hintText: 'e.g. Check fertiliser stock',
                hintStyle:
                    TextStyle(color: ctx.textSecondary, fontSize: 13),
                filled: true,
                fillColor: ctx.secondary,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: dueDate ??
                      DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate:
                      DateTime.now().add(const Duration(days: 365)),
                  builder: (_, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: ColorScheme.fromSeed(
                          seedColor: AppColors.primary),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setS(() => dueDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: ctx.secondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: dueDate != null
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : ctx.border.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 18,
                      color: dueDate != null
                          ? AppColors.primary
                          : ctx.textSecondary),
                  const SizedBox(width: 10),
                  Text(
                    dueDate != null
                        ? '${dueDate!.day} ${_monthName(dueDate!.month)} ${dueDate!.year}'
                        : 'Tap to set due date',
                    style: TextStyle(
                        fontSize: 13,
                        color: dueDate != null
                            ? ctx.textPrimary
                            : ctx.textSecondary),
                  ),
                ]),
              ),
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: ctx.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final title = ctrl.text.trim();
                if (title.isNotEmpty) {
                  setState(() {
                    _reminders.add(_Reminder(
                      title,
                      dueDate ??
                          DateTime.now().add(const Duration(days: 7)),
                      false,
                    ));
                  });
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];

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
                  border: Border(
                      bottom: BorderSide(
                          color: context.border.withValues(alpha: 0.5))),
                ),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: context.secondary,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Alerts',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary,
                                letterSpacing: -0.3)),
                        Text('Stay ahead of risk',
                            style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary)),
                      ])),
                ]),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Reminders section
                  _sectionLabel(context, 'YOUR REMINDERS'),
                  const SizedBox(height: 10),
                  if (_reminders.isEmpty)
                    _card(context,
                        child: Column(children: [
                          Icon(Icons.notifications_none_rounded,
                              size: 32, color: context.textSecondary),
                          const SizedBox(height: 8),
                          Text(
                              'No active reminders. Apply a treatment from a scan to add one.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: context.textSecondary)),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _showAddReminderDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: context.secondary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('Add test reminder',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: context.textPrimary)),
                            ),
                          ),
                        ]))
                  else
                    Column(
                      children: _reminders.asMap().entries.map((e) {
                        final r = e.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _card(context,
                              child: Row(children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    r.done
                                        ? Icons.check_circle_outlined
                                        : Icons.calendar_today_outlined,
                                    size: 18,
                                    color: r.done
                                        ? AppColors.accent
                                        : AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(r.title,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: context.textPrimary,
                                              decoration: r.done
                                                  ? TextDecoration.lineThrough
                                                  : null)),
                                      Text(
                                          'Due ${r.dueAt.day}/${r.dueAt.month}/${r.dueAt.year}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: context.textSecondary)),
                                    ])),
                                if (!r.done)
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => r.done = true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: context.secondary,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text('Done',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: context.textPrimary)),
                                    ),
                                  ),
                              ])),
                        );
                      }).toList(),
                    ),

                  if (_reminders.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _showAddReminderDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: context.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text('+ Add reminder',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary)),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  _sectionLabel(context, 'REGIONAL ALERTS'),
                  const SizedBox(height: 10),
                  ..._regionalAlerts.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _card(context,
                            child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: a.bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(a.icon, size: 18, color: a.color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                Text(a.title,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: context.textPrimary)),
                                const SizedBox(height: 2),
                                Text(a.body,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: context.textSecondary,
                                        height: 1.4)),
                                const SizedBox(height: 4),
                                Text(a.time,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: context.textSecondary)),
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
          border:
              Border.all(color: context.border.withValues(alpha: 0.4)),
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
        child: child,
      );

  Widget _sectionLabel(BuildContext context, String t) => Text(t,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: context.textSecondary,
          letterSpacing: 1.2));
}

class _Alert {
  final String title, body, time;
  final IconData icon;
  final Color color, bgColor;
  const _Alert(
      this.title, this.body, this.icon, this.color, this.bgColor, this.time);
}

class _Reminder {
  final String title;
  final DateTime dueAt;
  bool done;
  _Reminder(this.title, this.dueAt, this.done);
}
