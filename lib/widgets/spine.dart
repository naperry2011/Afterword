import 'package:flutter/material.dart';

import '../theme/shapes.dart';
import '../theme/tokens.dart';
import 'dither_fill.dart';

/// Procedural spine geometry from the book id. Stable forever.
({double width, double height}) spineGeometry(String bookId, double maxHeight) {
  final h = stableHash(bookId);
  final width = 18.0 + (h % 5) * 4; // 18..34
  final height = maxHeight * (0.66 + ((h ~/ 7) % 6) * 0.06); // 66%..96%
  return (width: width, height: height);
}

/// A finished book: solid colour, outlined.
class SolidSpine extends StatelessWidget {
  const SolidSpine({super.key, required this.bookId, required this.maxHeight});
  final String bookId;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final g = spineGeometry(bookId, maxHeight);
    return Container(
      width: g.width,
      height: g.height,
      decoration: BoxDecoration(
        color: spineColorFor(bookId),
        border: pixelBorder(),
      ),
    );
  }
}

/// The book in progress: outlined, filled from the bottom to its progress.
class ProgressSpine extends StatelessWidget {
  const ProgressSpine({
    super.key,
    required this.bookId,
    required this.maxHeight,
    required this.progress,
  });
  final String bookId;
  final double maxHeight;

  /// 0..100
  final int progress;

  @override
  Widget build(BuildContext context) {
    final g = spineGeometry(bookId, maxHeight);
    final fill = (progress.clamp(0, 100) / 100) * (g.height - 6);
    return Container(
      width: g.width,
      height: g.height,
      decoration: BoxDecoration(
        color: Tokens.bg,
        border: pixelBorder(spineColorFor(bookId)),
      ),
      alignment: Alignment.bottomCenter,
      child: Container(
        height: fill,
        color: spineColorFor(bookId),
      ),
    );
  }
}

/// The next slot. Dithered and empty. The most important pixel on the screen.
class EmptySlot extends StatelessWidget {
  const EmptySlot({super.key, required this.maxHeight});
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: maxHeight * 0.8,
      child: const DitherFill(),
    );
  }
}
