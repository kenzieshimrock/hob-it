import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hob_it/ui/ui.dart';

/// Builds and exposes the hob-it [ThemeData].
///
/// Apply via [MaterialApp.theme]. All component themes derive from
/// [HobItColors], [HobItTypography], and [HobItSpacing] — individual
/// widgets must not hardcode color or spacing values.
abstract final class HobItTheme {
  /// The hob-it light theme.
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: HobItColors.blue,
      primary: HobItColors.blue,
      onPrimary: HobItColors.white,
      secondary: HobItColors.navy,
      onSecondary: HobItColors.white,
      surface: HobItColors.cardSurface,
      onSurface: HobItColors.navy,
      error: HobItColors.orange,
      onError: HobItColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: HobItColors.scaffold,
      textTheme: HobItTypography.textTheme,
      cardTheme: CardThemeData(
        color: HobItColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HobItSpacing.radiusMd),
          side: const BorderSide(color: HobItColors.navy20, width: 0.75),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HobItColors.cardSurface,
        hintStyle: GoogleFonts.poppins(color: HobItColors.navy40, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HobItSpacing.md,
          vertical: HobItSpacing.smd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HobItSpacing.radiusSm),
          borderSide: const BorderSide(color: HobItColors.navy20),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HobItSpacing.radiusSm),
          borderSide: const BorderSide(color: HobItColors.navy20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HobItSpacing.radiusSm),
          borderSide: const BorderSide(color: HobItColors.blue, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: HobItColors.blue,
          foregroundColor: HobItColors.white,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: HobItSpacing.lg,
            vertical: HobItSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HobItSpacing.radiusSm),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: HobItColors.navy,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: HobItColors.navy20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HobItSpacing.radiusSm),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: HobItColors.navy20,
        thickness: 0.75,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: HobItColors.white,
        side: const BorderSide(color: HobItColors.navy20),
        labelStyle: GoogleFonts.poppins(
          color: HobItColors.navy,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HobItSpacing.radiusPill),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: HobItSpacing.smd,
          vertical: HobItSpacing.xs,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: HobItColors.navy,
        contentTextStyle: GoogleFonts.poppins(
          color: HobItColors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HobItSpacing.radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: HobItColors.blue,
        thumbColor: HobItColors.blue,
        inactiveTrackColor: HobItColors.navy20,
        overlayColor: Color(0x1A2A48DE),
      ),
    );
  }
}
