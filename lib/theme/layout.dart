import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// Screen-fit numbers for one build. Hero elements (art, the shelf, covers)
/// grow on tall screens; type stays on its fixed scale.
class Fit {
  const Fit._(this.usableHeight, this.bottomInset);

  factory Fit.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    return Fit._(size.height - padding.vertical, padding.bottom);
  }

  /// Usable height of an iPhone 16e, the smallest screen we design for.
  static const double baseHeight = 780;

  final double usableHeight;

  /// System inset below the content: home indicator or Android nav bar.
  final double bottomInset;

  /// 1.0 on iPhones, up to 1.25 on tall Android phones.
  double get heroScale => (usableHeight / baseHeight).clamp(1.0, 1.25);

  double hero(double value) => value * heroScale;
}

/// Snaps the 3px outline and offset shadows to whole device pixels. At a
/// fractional density (Android 2.625) unsnapped borders render soft.
abstract final class PixelGrid {
  static double _ratio = 3;

  static void init(double devicePixelRatio) {
    if (devicePixelRatio > 0) _ratio = devicePixelRatio;
  }

  static double snap(double value) => (value * _ratio).roundToDouble() / _ratio;

  static Offset snapOffset(Offset offset) =>
      Offset(snap(offset.dx), snap(offset.dy));

  static double get outline => snap(Tokens.outlineWidth);
}
