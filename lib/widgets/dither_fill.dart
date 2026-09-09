import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Checkerboard dither for texture and empty states. Never gradients.
class DitherFill extends StatelessWidget {
  const DitherFill({
    super.key,
    this.color = Tokens.surfaceAlt,
    this.cell = Tokens.ditherCell,
    this.child,
  });

  final Color color;
  final double cell;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DitherPainter(color, cell / 2),
      child: child,
    );
  }
}

class _DitherPainter extends CustomPainter {
  _DitherPainter(this.color, this.px);
  final Color color;
  final double px;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cols = (size.width / px).ceil();
    final rows = (size.height / px).ceil();
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if ((r + c).isOdd) continue;
        canvas.drawRect(Rect.fromLTWH(c * px, r * px, px, px), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DitherPainter old) => old.color != color || old.px != px;
}
