import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/field.dart';
import 'field_detail_screen.dart';
import 'add_field_screen.dart';

class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});

  @override
  State<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends State<FieldsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('My Fields'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AddFieldScreen()));
              if (result != null && mounted) setState(() => sampleFields.add(result));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _summaryRow(),
          const SizedBox(height: 24),
          ...sampleFields.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _FieldCard(
              field: f,
              onTap: () async {
                await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => FieldDetailScreen(field: f)));
                setState(() {});
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _summaryRow() {
    final totalArea = sampleFields.fold(0.0, (s, f) => s + f.areaMorgen);
    final healthy = sampleFields.where((f) => f.healthStatus == HealthStatus.healthy).length;
    return Row(
      children: [
        Expanded(child: _summaryTile('${sampleFields.length}', 'Total Fields', AppColors.primary, AppColors.accentLight)),
        const SizedBox(width: 12),
        Expanded(child: _summaryTile(totalArea.toStringAsFixed(1), 'Morgen', const Color(0xFF0EA5E9), const Color(0xFFE0F2FE))),
        const SizedBox(width: 12),
        Expanded(child: _summaryTile('$healthy/${sampleFields.length}', 'Healthy', AppColors.accent, AppColors.accentLight)),
      ],
    );
  }

  Widget _summaryTile(String val, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(children: [
        Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final PaddyField field;
  final VoidCallback onTap;
  const _FieldCard({required this.field, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final days = DateTime.now().difference(field.plantedDate).inDays;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(field.stage.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(field.name, style: const TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                      Text('${field.location} • ${field.areaMorgen} morgen',
                        style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  )),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: field.healthStatus.bgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(field.healthStatus.label,
                        style: TextStyle(color: field.healthStatus.color, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 6),
                    Text('Day $days', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(field.stage.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text('${(field.stage.progress * 100).toInt()}% complete',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: field.stage.progress,
                      backgroundColor: AppColors.bg,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    _metric(Icons.water_drop_rounded, '${field.waterLevel}%', 'Water', const Color(0xFF0EA5E9)),
                    const SizedBox(width: 24),
                    _metric(Icons.science_rounded, '${field.fertilizerLevel}%', 'Fertiliser', const Color(0xFF7C3AED)),
                    const SizedBox(width: 24),
                    _metric(Icons.favorite_rounded, '${field.healthScore}%', 'Health', field.healthStatus.color),
                    const Spacer(),
                    if (field.scanHistory.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.redLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${field.scanHistory.length} alert${field.scanHistory.length > 1 ? 's' : ''}',
                          style: const TextStyle(color: AppColors.red, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(IconData icon, String value, String label, Color color) => Row(
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ]),
    ],
  );
}
