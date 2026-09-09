import 'package:flutter/material.dart';

import 'tokens.dart';

/// Zero border radius everywhere. This is the rule that holds the whole thing together.
const BorderRadius kNoRadius = BorderRadius.zero;

const RoundedRectangleBorder kSquareShape =
    RoundedRectangleBorder(borderRadius: kNoRadius);

/// 3px outline in [Tokens.outline] on every raised element.
Border pixelBorder([Color color = Tokens.outline]) =>
    Border.all(color: color, width: Tokens.outlineWidth);

/// Offset shadow, not blur: 5px 5px 0 rgba(0,0,0,.45).
List<BoxShadow> offsetShadow({
  Offset offset = Tokens.shadowOffset,
  Color color = Tokens.shadowColor,
}) =>
    [BoxShadow(color: color, offset: offset, blurRadius: 0, spreadRadius: 0)];

BoxDecoration raised({
  Color color = Tokens.surface,
  bool pressed = false,
  Color shadowColor = Tokens.shadowColor,
}) =>
    BoxDecoration(
      color: color,
      border: pixelBorder(),
      boxShadow: offsetShadow(
        offset: pressed ? Tokens.shadowOffsetPressed : Tokens.shadowOffset,
        color: shadowColor,
      ),
    );
