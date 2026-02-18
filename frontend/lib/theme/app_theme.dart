import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the Dydat AI tutoring application.
/// Implements the Warm Academic Palette with Conversational Minimalism design style.
class AppTheme {
  AppTheme._();

  // Primary Amber Colors
  static const Color primaryAmber = Color(0xFFD4A843);
  static const Color brightAmber = Color(0xFFF0C85A);
  static const Color mutedAmber = Color(0xFFA68A3A);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A1A1E);
  static const Color darkSurface = Color(0xFF242428);
  static const Color darkBorder = Color(0xFF3A3A42);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F2ED);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFD9D5CE);

  // Semantic Colors
  static const Color successGreen = Color(0xFF7EBF8E);
  static const Color errorRed = Color(0xFFC97070);

  // Text Colors - Dark Theme
  static const Color textHighEmphasisDark = Color(0xDEFFFFFF); // 87% opacity
  static const Color textMediumEmphasisDark = Color(0x99FFFFFF); // 60% opacity
  static const Color textDisabledDark = Color(0x61FFFFFF); // 38% opacity

  // Text Colors - Light Theme
  static const Color textHighEmphasisLight = Color(0xDE000000); // 87% opacity
  static const Color textMediumEmphasisLight = Color(0x99000000); // 60% opacity
  static const Color textDisabledLight = Color(0x61000000); // 38% opacity

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x1AFFFFFF);

  /// Light theme configuration
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryAmber,
      onPrimary: Color(0xFF000000),
      primaryContainer: brightAmber,
      onPrimaryContainer: Color(0xFF000000),
      secondary: mutedAmber,
      onSecondary: Color(0xFF000000),
      secondaryContainer: mutedAmber,
      onSecondaryContainer: Color(0xFF000000),
      tertiary: successGreen,
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: successGreen,
      onTertiaryContainer: Color(0xFFFFFFFF),
      error: errorRed,
      onError: Color(0xFFFFFFFF),
      surface: lightSurface,
      onSurface: textHighEmphasisLight,
      onSurfaceVariant: textMediumEmphasisLight,
      outline: lightBorder,
      outlineVariant: lightBorder,
      shadow: shadowLight,
      scrim: shadowLight,
      inverseSurface: darkSurface,
      onInverseSurface: textHighEmphasisDark,
      inversePrimary: primaryAmber,
    ),
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightSurface,
    dividerColor: lightBorder,
    appBarTheme: AppBarThemeData(
      backgroundColor: lightSurface,
      foregroundColor: textHighEmphasisLight,
      elevation: 1.0,
      shadowColor: shadowLight,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textHighEmphasisLight,
        letterSpacing: 0.15,
      ),
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 2.0,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: primaryAmber,
      unselectedItemColor: textMediumEmphasisLight,
      type: BottomNavigationBarType.fixed,
      elevation: 3.0,
      selectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryAmber,
      foregroundColor: Color(0xFF000000),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Color(0xFF000000),
        backgroundColor: primaryAmber,
        elevation: 2.0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryAmber,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: const BorderSide(color: primaryAmber, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryAmber,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: true),
    inputDecorationTheme: InputDecorationThemeData(
      fillColor: lightSurface,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: lightBorder, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: lightBorder, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primaryAmber, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorRed, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorRed, width: 2.0),
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        color: textMediumEmphasisLight,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        color: textDisabledLight,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.plusJakartaSans(
        color: errorRed,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryAmber;
        }
        return textDisabledLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryAmber.withValues(alpha: 0.5);
        }
        return textDisabledLight.withValues(alpha: 0.3);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryAmber;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Color(0xFF000000)),
      side: BorderSide(color: lightBorder, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryAmber;
        }
        return textMediumEmphasisLight;
      }),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryAmber,
      linearTrackColor: lightBorder,
      circularTrackColor: lightBorder,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryAmber,
      thumbColor: primaryAmber,
      overlayColor: primaryAmber.withValues(alpha: 0.2),
      inactiveTrackColor: lightBorder,
      valueIndicatorColor: primaryAmber,
      valueIndicatorTextStyle: GoogleFonts.plusJakartaSans(
        color: Color(0xFF000000),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryAmber,
      unselectedLabelColor: textMediumEmphasisLight,
      indicatorColor: primaryAmber,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textHighEmphasisLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.plusJakartaSans(
        color: lightSurface,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkSurface,
      contentTextStyle: GoogleFonts.plusJakartaSans(
        color: textHighEmphasisDark,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: primaryAmber,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 3.0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: lightSurface,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      modalBackgroundColor: lightSurface,
      modalElevation: 3.0,
    ), dialogTheme: DialogThemeData(backgroundColor: lightSurface),
  );

  /// Dark theme configuration
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryAmber,
      onPrimary: Color(0xFF000000),
      primaryContainer: brightAmber,
      onPrimaryContainer: Color(0xFF000000),
      secondary: mutedAmber,
      onSecondary: Color(0xFF000000),
      secondaryContainer: mutedAmber,
      onSecondaryContainer: Color(0xFF000000),
      tertiary: successGreen,
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: successGreen,
      onTertiaryContainer: Color(0xFFFFFFFF),
      error: errorRed,
      onError: Color(0xFFFFFFFF),
      surface: darkSurface,
      onSurface: textHighEmphasisDark,
      onSurfaceVariant: textMediumEmphasisDark,
      outline: darkBorder,
      outlineVariant: darkBorder,
      shadow: shadowDark,
      scrim: shadowDark,
      inverseSurface: lightSurface,
      onInverseSurface: textHighEmphasisLight,
      inversePrimary: primaryAmber,
    ),
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkSurface,
    dividerColor: darkBorder,
    appBarTheme: AppBarThemeData(
      backgroundColor: darkSurface,
      foregroundColor: textHighEmphasisDark,
      elevation: 1.0,
      shadowColor: shadowDark,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textHighEmphasisDark,
        letterSpacing: 0.15,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 2.0,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryAmber,
      unselectedItemColor: textMediumEmphasisDark,
      type: BottomNavigationBarType.fixed,
      elevation: 3.0,
      selectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryAmber,
      foregroundColor: Color(0xFF000000),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Color(0xFF000000),
        backgroundColor: primaryAmber,
        elevation: 2.0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryAmber,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: const BorderSide(color: primaryAmber, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryAmber,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: false),
    inputDecorationTheme: InputDecorationThemeData(
      fillColor: darkSurface,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: darkBorder, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: darkBorder, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primaryAmber, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorRed, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorRed, width: 2.0),
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        color: textMediumEmphasisDark,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        color: textDisabledDark,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.plusJakartaSans(
        color: errorRed,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryAmber;
        }
        return textDisabledDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryAmber.withValues(alpha: 0.5);
        }
        return textDisabledDark.withValues(alpha: 0.3);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryAmber;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Color(0xFF000000)),
      side: BorderSide(color: darkBorder, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryAmber;
        }
        return textMediumEmphasisDark;
      }),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryAmber,
      linearTrackColor: darkBorder,
      circularTrackColor: darkBorder,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryAmber,
      thumbColor: primaryAmber,
      overlayColor: primaryAmber.withValues(alpha: 0.2),
      inactiveTrackColor: darkBorder,
      valueIndicatorColor: primaryAmber,
      valueIndicatorTextStyle: GoogleFonts.plusJakartaSans(
        color: Color(0xFF000000),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryAmber,
      unselectedLabelColor: textMediumEmphasisDark,
      indicatorColor: primaryAmber,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textHighEmphasisDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.plusJakartaSans(
        color: darkSurface,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: lightSurface,
      contentTextStyle: GoogleFonts.plusJakartaSans(
        color: textHighEmphasisLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: primaryAmber,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 3.0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: darkSurface,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      modalBackgroundColor: darkSurface,
      modalElevation: 3.0,
    ), dialogTheme: DialogThemeData(backgroundColor: darkSurface),
  );

  /// Helper method to build text theme based on brightness
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textHighEmphasis = isLight
        ? textHighEmphasisLight
        : textHighEmphasisDark;
    final Color textMediumEmphasis = isLight
        ? textMediumEmphasisLight
        : textMediumEmphasisDark;
    final Color textDisabled = isLight ? textDisabledLight : textDisabledDark;

    return TextTheme(
      // Display styles - Plus Jakarta Sans w700
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: textHighEmphasis,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles - Plus Jakarta Sans w600
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles - Plus Jakarta Sans w500/w600
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles - Plus Jakarta Sans w400/w500 with 1.55 line height
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0.5,
        height: 1.55,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0.25,
        height: 1.55,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMediumEmphasis,
        letterSpacing: 0.4,
        height: 1.55,
      ),

      // Label styles - Plus Jakarta Sans w500/w600 for data display
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMediumEmphasis,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textDisabled,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }
}
