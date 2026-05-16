import 'dart:math';
import 'package:flutter/material.dart';
import '../models/field.dart';

class GrowingTreeWidget extends StatefulWidget {
  final GrowthStage stage;
  final double size;
  const GrowingTreeWidget({super.key, required this.stage, this.size = 150});

  @override
  State<GrowingTreeWidget> createState() => _GrowingTreeWidgetState();
}

class _GrowingTreeWidgetState extends State<GrowingTreeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(GrowingTreeWidget old) {
    super.didUpdateWidget(old);
    if (old.stage != widget.stage) _ctrl.forward(from: 0.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: TreePainter(stageIndex: widget.stage.index, t: _anim.value),
      ),
    );
  }
}

class TreePainter extends CustomPainter {
  final int stageIndex;
  final double t;
  const TreePainter({required this.stageIndex, required this.t});

  @override
  bool shouldRepaint(TreePainter old) =>
      old.stageIndex != stageIndex || old.t != t;

  static const _brown = Color(0xFF7A4E2D);
  static const _brownLight = Color(0xFFA0724A);
  static const _green = Color(0xFF3FB87A);
  static const _greenDark = Color(0xFF1E7A4A);
  static const _greenLight = Color(0xFF7DD9A8);
  static const _pink = Color(0xFFF9A8C9);
  static const _pinkLight = Color(0xFFFFD5E8);
  static const _gold = Color(0xFFFFCC00);
  static const _goldDark = Color(0xFFE8950A);
  static const _soil = Color(0xFF9A6B40);
  static const _grass = Color(0xFF52AA60);

  // Growth factor at each stage (0-5)
  static const _stageFactor = [0.13, 0.30, 0.52, 0.70, 0.86, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final groundY = h * 0.82;

    final p = (_stageFactor[stageIndex] * t).clamp(0.0, 1.0);
    final trunkH = p * h * 0.56;
    final trunkTop = groundY - trunkH;
    final canopyR = p * w * 0.32;

    _drawGround(canvas, cx, groundY, w, p);
    _drawTrunk(canvas, cx, groundY, trunkTop, p);

    if (stageIndex == 0) {
      _drawSprout(canvas, cx, trunkTop, p);
    } else {
      _drawCanopy(canvas, cx, trunkTop, canopyR, stageIndex, p);
      if (stageIndex >= 3) {
        _drawDots(canvas, cx, trunkTop, canopyR, stageIndex);
      }
    }
  }

  void _drawGround(Canvas canvas, double cx, double groundY, double w, double p) {
    // Soil ellipse
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, groundY + 8), width: w * 0.50, height: 14),
      Paint()..color = _soil,
    );
    // Grass cap
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, groundY), width: w * 0.44, height: 9),
      Paint()..color = _grass,
    );
  }

  void _drawTrunk(Canvas canvas, double cx, double groundY, double trunkTop, double p) {
    if (p < 0.01) return;
    final thick = 3.0 + p * 7.0;

    // Bark shadow
    final shadowPaint = Paint()
      ..color = _brownLight
      ..strokeWidth = thick + 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(cx + 1.5, groundY - 2)
      ..quadraticBezierTo(cx + p * 6 + 1.5, (groundY + trunkTop) / 2, cx + 1.5, trunkTop);
    canvas.drawPath(path, shadowPaint);

    // Main trunk
    final trunkPaint = Paint()
      ..color = _brown
      ..strokeWidth = thick
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final trunkPath = Path()
      ..moveTo(cx, groundY - 2)
      ..quadraticBezierTo(cx + p * 6, (groundY + trunkTop) / 2, cx, trunkTop);
    canvas.drawPath(trunkPath, trunkPaint);
  }

  void _drawSprout(Canvas canvas, double cx, double trunkTop, double p) {
    final paint = Paint()..color = _green..style = PaintingStyle.fill;
    final lw = 9.0 * p;
    final lh = 15.0 * p;
    // Left leaf
    canvas.save();
    canvas.translate(cx - 5 * p, trunkTop - 1);
    canvas.rotate(-0.5);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(0, -lh / 2), width: lw, height: lh), paint);
    canvas.restore();
    // Right leaf
    canvas.save();
    canvas.translate(cx + 5 * p, trunkTop - 1);
    canvas.rotate(0.5);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(0, -lh / 2), width: lw, height: lh), paint);
    canvas.restore();
  }

  void _drawCanopy(Canvas canvas, double cx, double trunkTop, double r,
      int stage, double p) {
    if (r < 1) return;
    final isRipening = stage >= 4;
    final isHarvest = stage == 5;

    // Bottom shadow puff
    canvas.drawCircle(
        Offset(cx, trunkTop + r * 0.14), r * 0.88, Paint()..color = _greenDark);

    // Side puffs (stage 2+)
    if (stage >= 2) {
      canvas.drawCircle(
          Offset(cx - r * 0.68, trunkTop + r * 0.18), r * 0.65, Paint()..color = _green);
      canvas.drawCircle(
          Offset(cx + r * 0.68, trunkTop + r * 0.18), r * 0.65, Paint()..color = _green);
    }

    // Main canopy
    canvas.drawCircle(Offset(cx, trunkTop), r, Paint()..color = _green);

    // Highlight
    canvas.drawCircle(
      Offset(cx - r * 0.26, trunkTop - r * 0.26),
      r * 0.40,
      Paint()..color = _greenLight,
    );

    // Golden tint for ripening/harvest
    if (isRipening) {
      canvas.drawCircle(
        Offset(cx, trunkTop),
        r,
        Paint()..color = _gold.withValues(alpha: isHarvest ? 0.38 : 0.22),
      );
    }
  }

  void _drawDots(Canvas canvas, double cx, double trunkTop, double r, int stage) {
    final rng = Random(13); // stable seed → same positions every repaint
    final isRipening = stage >= 4;
    final isHarvest = stage == 5;

    final color = isRipening ? _goldDark : _pink;
    final rimColor = isRipening ? _gold : _pinkLight;
    final count = isHarvest ? 18 : (isRipening ? 13 : 9);

    for (int i = 0; i < count; i++) {
      final ang = rng.nextDouble() * pi * 2;
      final dist = rng.nextDouble() * r * 0.82;
      final dotR = 2.0 + rng.nextDouble() * 2.6;
      final dx = cx + cos(ang) * dist;
      final dy = trunkTop + sin(ang) * dist * 0.62;

      // Rim
      canvas.drawCircle(Offset(dx, dy), dotR + 1,
          Paint()..color = rimColor..style = PaintingStyle.fill);
      // Fill
      canvas.drawCircle(Offset(dx, dy), dotR,
          Paint()..color = color..style = PaintingStyle.fill);
    }
  }
}
