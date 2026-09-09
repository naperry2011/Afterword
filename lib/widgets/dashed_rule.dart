import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// 2px dashed divider. Separates, never contains.
class DashedRule extends StatelessWidget {
  const DashedRule({
    super.key,
    this.color = Tokens.surfaceAlt,
    this.thickness = 2,
    this.dash = 6,
    this.gap = 5,
    this.margin = const EdgeInsets.symmetric(vertical: 16),
  });

  final Color color;
  final double thickness;
  final double dash;
  final double gap;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: SizedBox(
        height: thickness,
        width: double.infinity,
        child: CustomPaint(
          painter: _DashPainter(color, thickness, dash, gap),
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color, this.thickness, this.dash, this.gap);
  final Color color;
  final double thickness;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawRect(Rect.fromLTWH(x, 0, dash, thickness), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) =>
      old.color != color || old.thickness != thickness;
}
