import 'package:flutter/material.dart';

/// Colour tokens from the build spec §2.1.
/// Dark room, single warm light source. Never pure black, never pure white.
abstract final class Tokens {
  /// App background, the room.
  static const Color bg = Color(0xFF241F33);

  /// Cards, sheets, raised things.
  static const Color surface = Color(0xFF2C2640);

  /// Dividers, dashed rules, inactive.
  static const Color surfaceAlt = Color(0xFF3A3352);

  /// Every border. 3px. Non-negotiable.
  static const Color outline = Color(0xFF141120);

  /// Primary text, share card background.
  static const Color cream = Color(0xFFEDE3CE);

  /// Secondary text, captions, metadata.
  static const Color dim = Color(0xFF9C92B8);

  /// The lamp. Primary accent, warmth, highlights.
  static const Color amber = Color(0xFFD9A45E);

  /// Primary buttons.
  static const Color plum = Color(0xFF9179A6);

  /// Prompt labels, accents.
  static const Color rose = Color(0xFFC4837A);

  /// Success, finished state.
  static const Color sage = Color(0xFF6D8B71);

  /// Accents, spine variety.
  static const Color teal = Color(0xFF5E8785);

  /// Ink on light surfaces (share card text).
  static const Color inkOnCream = Color(0xFF241F33);

  /// Secondary ink on the cream card.
  static const Color dimOnCream = Color(0xFF6A6180);

  /// Dashed rule on the cream card.
  static const Color ruleOnCream = Color(0xFFCFC2A8);

  /// Spine palette, cycled deterministically from the book id.
  static const List<Color> spinePalette = [rose, sage, amber, plum, cream, teal];

  static const double outlineWidth = 3;
  static const Offset shadowOffset = Offset(5, 5);
  static const Offset shadowOffsetPressed = Offset(2, 2);
  static const Offset pressTranslate = Offset(3, 3);
  static const Color shadowColor = Color(0x73000000); // rgba(0,0,0,.45)
  static const double ditherCell = 8;
}

/// Stable, non-cryptographic hash so a book always gets the same spine.
int stableHash(String input) {
  var h = 0x811C9DC5;
  for (final unit in input.codeUnits) {
    h ^= unit;
    h = (h * 0x01000193) & 0x7FFFFFFF;
  }
  return h;
}

Color spineColorFor(String bookId) =>
    Tokens.spinePalette[stableHash(bookId) % Tokens.spinePalette.length];
