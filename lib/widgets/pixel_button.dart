import 'package:flutter/material.dart';

import '../theme/shapes.dart';
import '../theme/text.dart';
import '../theme/tokens.dart';

enum PixelButtonTone { plum, amber, surface }

/// Primary button. Shifts 3px,3px on press and the shadow shrinks to 2px.
/// The press is a single step, no easing.
class PixelButton extends StatefulWidget {
  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = PixelButtonTone.plum,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PixelButtonTone tone;
  final bool expand;

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _pressed = false;

  Color get _fill => switch (widget.tone) {
        PixelButtonTone.plum => Tokens.plum,
        PixelButtonTone.amber => Tokens.amber,
        PixelButtonTone.surface => Tokens.surface,
      };

  Color get _ink => switch (widget.tone) {
        PixelButtonTone.plum => Tokens.cream,
        PixelButtonTone.amber => Tokens.inkOnCream,
        PixelButtonTone.surface => Tokens.cream,
      };

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final offset = _pressed ? Tokens.pressTranslate : Offset.zero;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onPressed,
        child: Transform.translate(
          offset: offset,
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: Container(
              width: widget.expand ? double.infinity : null,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              decoration: raised(
                color: _fill,
                pressed: _pressed,
                shadowColor: Tokens.outline,
              ),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: pix(size: 17, color: _ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A quiet text action, used for Skip. Always visible, never discouraged.
class QuietButton extends StatelessWidget {
  const QuietButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Tokens.dim,
        shape: kSquareShape,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      child: Text(
        label,
        style: body(size: 15.5, color: Tokens.dim).copyWith(
          decoration: TextDecoration.underline,
          decorationColor: Tokens.surfaceAlt,
        ),
      ),
    );
  }
}
