import 'package:flutter/material.dart';

class RicePlantPainter extends CustomPainter {
  final int stageIndex; // 0-5
  final bool active;    // false = future stage, draw at 35% opacity

  const RicePlantPainter(this.stageIndex, {this.active = true});

  @override
  bool shouldRepaint(RicePlantPainter old) =>
      old.stageIndex != stageIndex || old.active != active;

  Color _c(Color c) => active ? c : c.withValues(alpha: 0.35);

  static const _stemGreen = Color(0xFF4A9E5A);
  static const _leafGreen = Color(0xFF3DAA6A);
  static const _leafLight = Color(0xFF7DD9A8);
  static const _soil = Color(0xFF9A6B40);
  static const _grass = Color(0xFF5AA859);
  static const _grain = Color(0xFF8BAA50);
  static const _grainGold = Color(0xFFE8A820);
  static const _grainGoldLight = Color(0xFFFFCC00);
  static const _stemGold = Color(0xFFCCA020);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final cx = w * 0.5;
    final groundY = h * 0.82;

    // Soil
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, groundY + h * 0.05), width: w * 0.65, height: h * 0.07),
      Paint()..color = _c(_soil),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, groundY), width: w * 0.54, height: h * 0.04),
      Paint()..color = _c(_grass),
    );

    if (stageIndex == 0) { _drawSeed(canvas, cx, groundY, w, h); return; }

    final isHarvest = stageIndex == 5;
    final stemC = _c(isHarvest ? _stemGold : _stemGreen);
    final leafC = _c(isHarvest ? _stemGold : _leafGreen);
    final leafLightC = _c(isHarvest ? const Color(0xFFE8C050) : _leafLight);

    final stemFracs = [0.0, 0.18, 0.34, 0.50, 0.63, 0.65];
    final stemH = stemFracs[stageIndex] * h;
    final tipY = groundY - stemH;

    // Draw stem
    final stemPaint = Paint()
      ..color = stemC
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final stemPath = Path()
      ..moveTo(cx, groundY - 2)
      ..quadraticBezierTo(cx + 3, groundY - stemH * 0.5, cx, tipY);
    canvas.drawPath(stemPath, stemPaint);

    // Leaves
    _drawLeaves(canvas, cx, groundY, stemH, stageIndex, leafC, leafLightC, w, h);

    // Grain head (stage 3+)
    if (stageIndex >= 3) {
      _drawGrainHead(canvas, cx, tipY, h, isHarvest);
    }
  }

  void _drawSeed(Canvas canvas, double cx, double groundY, double w, double h) {
    final seedPaint = Paint()..color = _c(const Color(0xFF9B6E3A))..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, groundY - h * 0.06), width: w * 0.24, height: h * 0.11),
      seedPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.04, groundY - h * 0.08), width: w * 0.08, height: h * 0.04),
      Paint()..color = _c(Colors.white.withValues(alpha: 0.35)),
    );
  }

  void _drawLeaves(Canvas canvas, double cx, double groundY, double stemH, int stage,
      Color leafC, Color leafLightC, double w, double h) {
    void leaf(double relY, double angle, double len, double wid) {
      final y = groundY - stemH * relY;
      canvas.save();
      canvas.translate(cx, y);
      canvas.rotate(angle);
      final p = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-wid, -len * 0.45, 0, -len)
        ..quadraticBezierTo(wid, -len * 0.45, 0, 0);
      canvas.drawPath(p, Paint()..color = leafC..style = PaintingStyle.fill);
      // Midrib
      canvas.drawLine(Offset(0, 0), Offset(0, -len * 0.85),
          Paint()..color = leafLightC..strokeWidth = 0.8..style = PaintingStyle.stroke);
      canvas.restore();
    }

    switch (stage) {
      case 1: // Baby plant: 2 small leaves
        leaf(0.7, -0.6, h * 0.14, h * 0.028);
        leaf(0.7, 0.6, h * 0.14, h * 0.028);
        break;
      case 2: // Growing: 4 leaves
        leaf(0.35, -0.65, h * 0.18, h * 0.034);
        leaf(0.35, 0.65, h * 0.18, h * 0.034);
        leaf(0.72, -0.50, h * 0.20, h * 0.038);
        leaf(0.72, 0.50, h * 0.20, h * 0.038);
        break;
      case 3: // Flowering: 6 leaves
        leaf(0.28, -0.68, h * 0.20, h * 0.036);
        leaf(0.28, 0.68, h * 0.20, h * 0.036);
        leaf(0.54, -0.52, h * 0.23, h * 0.040);
        leaf(0.54, 0.52, h * 0.23, h * 0.040);
        leaf(0.80, -0.35, h * 0.18, h * 0.034);
        leaf(0.80, 0.35, h * 0.18, h * 0.034);
        break;
      case 4: // Mature: 6 leaves larger
        leaf(0.26, -0.70, h * 0.22, h * 0.040);
        leaf(0.26, 0.70, h * 0.22, h * 0.040);
        leaf(0.52, -0.54, h * 0.26, h * 0.044);
        leaf(0.52, 0.54, h * 0.26, h * 0.044);
        leaf(0.78, -0.36, h * 0.20, h * 0.036);
        leaf(0.78, 0.36, h * 0.20, h * 0.036);
        break;
      case 5: // Harvest: 6 golden leaves
        leaf(0.26, -0.70, h * 0.22, h * 0.040);
        leaf(0.26, 0.70, h * 0.22, h * 0.040);
        leaf(0.52, -0.54, h * 0.26, h * 0.044);
        leaf(0.52, 0.54, h * 0.26, h * 0.044);
        leaf(0.78, -0.36, h * 0.20, h * 0.036);
        leaf(0.78, 0.36, h * 0.20, h * 0.036);
        break;
    }
  }

  void _drawGrainHead(Canvas canvas, double cx, double tipY, double h, bool golden) {
    final stalkC = _c(golden ? _grainGold : _grain);
    final dotC = _c(golden ? _grainGoldLight : const Color(0xFFB8D060));
    final count = golden ? 8 : (stageIndex == 3 ? 4 : 7);
    final spread = h * 0.12;
    final droopMax = h * (golden ? 0.22 : (stageIndex == 3 ? 0.10 : 0.18));

    for (int i = 0; i < count; i++) {
      final t = count == 1 ? 0.5 : i / (count - 1).toDouble();
      final x = cx - spread * 0.5 + spread * t;
      final droop = droopMax * (0.5 + 0.5 * (2 * (t - 0.5)).abs());
      final endY = tipY + droop;
      final path = Path()
        ..moveTo(cx, tipY)
        ..quadraticBezierTo(x, tipY + droop * 0.4, x, endY);
      canvas.drawPath(path, Paint()..color = stalkC..strokeWidth = 1.4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
      canvas.drawCircle(Offset(x, endY), golden ? 2.8 : 2.0, Paint()..color = dotC);
    }
  }
}
