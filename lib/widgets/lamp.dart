import 'package:flutter/widgets.dart';

import '../theme/layout.dart';
import '../theme/tokens.dart';

/// The pixel lamp from the app icon, drawn cell by cell so it stays crisp at
/// any size. It stands on whatever is below it: the shelf plank supplies the
/// floor, so the icon's own floor row is left out.
class PixelLamp extends StatelessWidget {
  const PixelLamp({super.key, required this.cell});

  /// Size of one art pixel, in logical pixels. Snapped to device pixels.
  final double cell;

  static const int columns = 18;
  static const int rows = 22;

  /// Width and height for a given [cell] size, after snapping.
  static Size sizeFor(double cell) {
    final c = PixelGrid.snap(cell);
    return Size(columns * c, rows * c);
  }

  @override
  Widget build(BuildContext context) {
    final c = PixelGrid.snap(cell);
    return CustomPaint(
      size: Size(columns * c, rows * c),
      painter: _LampPainter(c),
    );
  }
}

// g glow, o outline, a amber, c cream, s surfaceAlt, . nothing.
const _art = [
  'gggggggggggggggggg',
  'gggggooooooooggggg',
  'ggggoaaaaaaaaogggg',
  'gggoaaaaaaaaaaoggg',
  'ggoaaaaaaaaaaaaogg',
  'goaaaaaaaaaaaaaaog',
  'goccccccccccccccog',
  'goooooooooooooooog',
  'ggggccccooccccgggg',
  'gggggaaaooaaaggggg',
  'ggggggggaagggggggg',
  'ggggggggaagggggggg',
  'ggggggggaagggggggg',
  'ggggggggaagggggggg',
  'ggggggggaagggggggg',
  '........aa........',
  '........aa........',
  '........aa........',
  '........oo........',
  '...oooooooooooo...',
  '..osssssssssssso..',
  '..oooooooooooooo..',
];

const _colors = {
  'g': Tokens.lampGlow,
  'o': Tokens.outline,
  'a': Tokens.amber,
  'c': Tokens.cream,
  's': Tokens.surfaceAlt,
};

class _LampPainter extends CustomPainter {
  _LampPainter(this.cell);
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = false;
    for (var r = 0; r < _art.length; r++) {
      final row = _art[r];
      for (var col = 0; col < row.length; col++) {
        final color = _colors[row[col]];
        if (color == null) continue;
        paint.color = color;
        canvas.drawRect(Rect.fromLTWH(col * cell, r * cell, cell, cell), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_LampPainter old) => old.cell != cell;
}
