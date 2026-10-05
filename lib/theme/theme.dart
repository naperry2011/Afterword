import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shapes.dart';
import 'text.dart';
import 'tokens.dart';

/// Screen transitions: a cut or a fast fade. Nothing fancy (spec §2.4).
class _CutTransitionsBuilder extends PageTransitionsBuilder {
  const _CutTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final stepped = animation.drive(CurveTween(curve: const _Steps(3)));
    return FadeTransition(opacity: stepped, child: child);
  }
}

/// Stepped timing, never smooth easing. Smooth motion on pixel art breaks it.
class _Steps extends Curve {
  const _Steps(this.steps);
  final int steps;

  @override
  double transformInternal(double t) => (t * steps).floor() / steps;
}

/// Light status and nav bar icons over the dark room; bars stay transparent
/// so Android's edge-to-edge shows the room colour behind them.
const SystemUiOverlayStyle kSystemBars = SystemUiOverlayStyle(
  statusBarColor: Color(0x00000000),
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Color(0x00000000),
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: false,
);

ThemeData buildTheme() {
  final text = buildTextTheme();
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Tokens.plum,
    onPrimary: Tokens.cream,
    secondary: Tokens.amber,
    onSecondary: Tokens.inkOnCream,
    error: Tokens.rose,
    onError: Tokens.inkOnCream,
    surface: Tokens.surface,
    onSurface: Tokens.cream,
    outline: Tokens.outline,
    surfaceContainerHighest: Tokens.surfaceAlt,
    onSurfaceVariant: Tokens.dim,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Tokens.bg,
    canvasColor: Tokens.bg,
    fontFamily: kBodyFamily,
    textTheme: text,
    splashFactory: NoSplash.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: _CutTransitionsBuilder(),
        TargetPlatform.android: _CutTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Tokens.bg,
      foregroundColor: Tokens.cream,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
      systemOverlayStyle: kSystemBars,
      shape: Border(bottom: pixelSide()),
    ),
    cardTheme: const CardThemeData(
      color: Tokens.surface,
      shape: kSquareShape,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Tokens.surface,
      shape: kSquareShape,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Tokens.surface,
      shape: kSquareShape,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Tokens.surface,
      contentTextStyle: text.bodyMedium,
      shape: kSquareShape,
      behavior: SnackBarBehavior.floating,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Tokens.surface,
      hintStyle: body(color: Tokens.dim),
      labelStyle: pix(size: 14, color: Tokens.dim),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: kNoRadius,
        borderSide: pixelSide(),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: kNoRadius,
        borderSide: pixelSide(),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: kNoRadius,
        borderSide: pixelSide(Tokens.rose),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Tokens.amber,
      inactiveTrackColor: Tokens.surfaceAlt,
      thumbColor: Tokens.amber,
      overlayColor: Colors.transparent,
      trackHeight: 6,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9),
    ),
    dividerTheme: const DividerThemeData(
      color: Tokens.surfaceAlt,
      thickness: 2,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Tokens.amber,
      selectionColor: Tokens.surfaceAlt,
      selectionHandleColor: Tokens.amber,
    ),
  );
}
