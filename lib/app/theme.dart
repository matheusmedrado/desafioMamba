import 'package:flutter/material.dart';

/// Color tokens for the app.
abstract final class MambaColors {
  static const background = Color(0xFF0B0B0D);
  static const surface = Color(0xFF141418);
  static const surfaceElevated = Color(0xFF1B1B21);
  static const surfaceHover = Color(0xFF25252C);
  static const border = Color(0xFF2A2730);

  static const purple = Color(0xFF7B2CBF);
  static const purpleDeep = Color(0xFF5A189A);
  static const purpleSoft = Color(0xFF9D4EDD);
  static const purpleTint = Color(0xFF251832);

  static const yellow = Color(0xFFF2C94C);
  static const yellowDim = Color(0xFFD4A72C);

  static const pathTrack = Color(0xFF24212A);
  static const pathTrackIdle = Color(0xFF302038);

  static const textPrimary = Color(0xFFF5F2F7);
  static const textSecondary = Color(0xFFA9A3B2);

  static const success = Color(0xFF7BC67E);
  static const danger = Color(0xFFD96B6B);
  static const dangerTint = Color(0xFF2D1D21);
}

abstract final class MambaRadius {
  static const small = 10.0;
  static const medium = 16.0;
  static const large = 24.0;
}

abstract final class MambaTextStyles {
  static const heroNumber = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 76,
    fontWeight: FontWeight.w800,
    letterSpacing: -4.9,
    height: 1.05,
    color: MambaColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const screenTitle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.08,
    height: 1.15,
    color: MambaColors.textPrimary,
  );
}

/// Dark theme: off-white primary buttons, purple for progress and selection.
ThemeData buildMambaTheme() {
  const colorScheme = ColorScheme.dark(
    surface: MambaColors.background,
    onSurface: MambaColors.textPrimary,
    onSurfaceVariant: MambaColors.textSecondary,
    surfaceContainerLow: MambaColors.surface,
    surfaceContainer: MambaColors.surfaceElevated,
    surfaceContainerHigh: MambaColors.surfaceHover,
    primary: MambaColors.purple,
    onPrimary: MambaColors.textPrimary,
    primaryContainer: MambaColors.purpleTint,
    onPrimaryContainer: MambaColors.textPrimary,
    secondary: MambaColors.purpleSoft,
    onSecondary: MambaColors.textPrimary,
    tertiary: MambaColors.yellow,
    onTertiary: MambaColors.background,
    error: MambaColors.danger,
    onError: MambaColors.textPrimary,
    errorContainer: MambaColors.dangerTint,
    onErrorContainer: MambaColors.textPrimary,
    outline: MambaColors.border,
    outlineVariant: MambaColors.border,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: MambaColors.background,
    splashFactory: NoSplash.splashFactory,
  );

  final textTheme = base.textTheme.apply(
    bodyColor: MambaColors.textPrimary,
    displayColor: MambaColors.textPrimary,
  );

  const buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(MambaRadius.medium)),
  );
  const buttonMinimumSize = Size.fromHeight(54);
  const buttonTextStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  return base.copyWith(
    textTheme: textTheme.copyWith(
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.56,
        height: 1.15,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.33,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: textTheme.titleSmall?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 16),
      bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: 14),
      bodySmall: textTheme.bodySmall?.copyWith(
        fontSize: 13,
        color: MambaColors.textSecondary,
      ),
      labelMedium: textTheme.labelMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: MambaColors.textSecondary,
      ),
      labelSmall: textTheme.labelSmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: MambaColors.textSecondary,
        letterSpacing: 0,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: MambaColors.background,
      foregroundColor: MambaColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: MambaColors.textPrimary,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MambaColors.textPrimary,
        foregroundColor: MambaColors.background,
        disabledBackgroundColor: MambaColors.surfaceElevated,
        disabledForegroundColor: MambaColors.textSecondary,
        minimumSize: buttonMinimumSize,
        shape: buttonShape,
        textStyle: buttonTextStyle,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MambaColors.surfaceElevated,
        foregroundColor: MambaColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: buttonMinimumSize,
        shape: buttonShape,
        textStyle: buttonTextStyle,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MambaColors.textPrimary,
        minimumSize: const Size(44, 44),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(MambaRadius.small)),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MambaColors.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(
        color: MambaColors.textSecondary,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: MambaColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      border: _inputBorder(MambaColors.border),
      enabledBorder: _inputBorder(MambaColors.border),
      focusedBorder: _inputBorder(MambaColors.textPrimary),
      errorBorder: _inputBorder(MambaColors.danger),
      focusedErrorBorder: _inputBorder(MambaColors.danger),
    ),
    dividerTheme: const DividerThemeData(
      color: MambaColors.border,
      thickness: 1,
      space: 1,
    ),
    cardTheme: const CardThemeData(
      color: MambaColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(MambaRadius.medium)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: MambaColors.textPrimary,
      foregroundColor: MambaColors.background,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(MambaRadius.medium)),
      ),
      extendedTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: MambaColors.surface,
      modalBackgroundColor: MambaColors.surface,
      modalBarrierColor: Color(0xCC0B0B0D),
      elevation: 0,
      modalElevation: 0,
      dragHandleColor: MambaColors.surfaceHover,
      dragHandleSize: Size(32, 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MambaRadius.large),
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: MambaColors.surfaceElevated,
      contentTextStyle: TextStyle(
        fontFamily: 'Manrope',
        color: MambaColors.textPrimary,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

OutlineInputBorder _inputBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(MambaRadius.small)),
    borderSide: BorderSide(color: color),
  );
}
