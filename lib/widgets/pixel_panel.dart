import 'package:flutter/material.dart';

import '../theme/shapes.dart';
import '../theme/tokens.dart';

/// A raised surface: fill, 3px outline, offset shadow. No radius.
class PixelPanel extends StatelessWidget {
  const PixelPanel({
    super.key,
    required this.child,
    this.color = Tokens.surface,
    this.shadowColor = Tokens.shadowColor,
    this.padding = const EdgeInsets.all(20),
    this.shadow = true,
  });

  final Widget child;
  final Color color;
  final Color shadowColor;
  final EdgeInsetsGeometry padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: pixelBorder(),
        boxShadow: shadow ? offsetShadow(color: shadowColor) : null,
      ),
      padding: padding,
      child: child,
    );
  }
}
