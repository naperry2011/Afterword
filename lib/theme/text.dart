import 'package:flutter/material.dart';

import 'tokens.dart';

/// Pixelify Sans for headings, buttons, tags, counts. Never for body copy.
const String kDisplayFamily = 'Pixelify Sans';

/// Nunito for everything you actually read.
const String kBodyFamily = 'Nunito';

const double kBodyLineHeight = 1.65;

TextStyle pix({
  double size = 16,
  FontWeight weight = FontWeight.w500,
  Color color = Tokens.cream,
}) =>
    TextStyle(
      fontFamily: kDisplayFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: 0.02 * size,
      height: 1.12,
    );

TextStyle body({
  double size = 17,
  FontWeight weight = FontWeight.w400,
  Color color = Tokens.cream,
  FontStyle style = FontStyle.normal,
}) =>
    TextStyle(
      fontFamily: kBodyFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontStyle: style,
      height: kBodyLineHeight,
    );

TextTheme buildTextTheme() => TextTheme(
      displayLarge: pix(size: 44, weight: FontWeight.w600),
      displayMedium: pix(size: 36, weight: FontWeight.w600),
      displaySmall: pix(size: 30, weight: FontWeight.w600),
      headlineLarge: pix(size: 28, weight: FontWeight.w600),
      headlineMedium: pix(size: 24, weight: FontWeight.w600),
      headlineSmall: pix(size: 21, weight: FontWeight.w600),
      titleLarge: pix(size: 20, weight: FontWeight.w600),
      titleMedium: pix(size: 17),
      titleSmall: pix(size: 14),
      labelLarge: pix(size: 17),
      labelMedium: pix(size: 14),
      labelSmall: pix(size: 12, color: Tokens.dim),
      bodyLarge: body(size: 17.5),
      bodyMedium: body(size: 16.5),
      bodySmall: body(size: 14.5, color: Tokens.dim),
    );
