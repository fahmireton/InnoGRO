import 'package:flutter/material.dart';
import '../models/paddy_field.dart';

class FieldCard extends StatelessWidget {
  final PaddyField field;
  final VoidCallback onTap;

  const FieldCard({super.key, required this.field, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final daysSincePlanted = DateTime.now().difference(field.plantedDate).inDays;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [field.stage.color.withValues(alpha: 0.8), field.stage.color],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(field.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(field.location, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  Text(field.stage.emoji, style: const TextStyle(fontSize: 36)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _chip(field.stage.label, field.stage.color),
                      Text('Day $daysSincePlanted', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Growth Progress', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: field.stage.progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(field.stage.color),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _indicator(Icons.water_drop, '${field.waterLevel}%', const Color(0xFF1565C0)),
                      const SizedBox(width: 16),
                      _indicator(Icons.science, '${field.fertilizerLevel}%', const Color(0xFF6A1B9A)),
                      const SizedBox(width: 16),
                      _indicator(Icons.favorite, '${field.healthScore}%', const Color(0xFFC62828)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _indicator(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
