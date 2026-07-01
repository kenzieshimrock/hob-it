import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// hob-it typography system built on Poppins.
///
/// All weights follow VGV brand guidelines:
/// - Bold (w700) for headlines and card titles
/// - SemiBold (w600) for labels, prices, buttons
/// - Regular (w400) for body copy and descriptions
abstract final class HobItTypography {
  /// Base Poppins [TextTheme] with hob-it color defaults.
  static TextTheme get textTheme {
    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: _style(
        size: 57,
        weight: FontWeight.w700,
        color: HobItColors.navy,
      ),
      displayMedium: _style(
        size: 45,
        weight: FontWeight.w700,
        color: HobItColors.navy,
      ),
      displaySmall: _style(
        size: 36,
        weight: FontWeight.w700,
        color: HobItColors.navy,
      ),
      headlineLarge: _style(
        size: 32,
        weight: FontWeight.w700,
        color: HobItColors.navy,
      ),
      headlineMedium: _style(
        size: 28,
        weight: FontWeight.w700,
        color: HobItColors.navy,
      ),
      headlineSmall: _style(
        size: 24,
        weight: FontWeight.w700,
        color: HobItColors.navy,
      ),
      titleLarge: _style(
        size: 20,
        weight: FontWeight.w700,
        color: HobItColors.navy,
      ),
      titleMedium: _style(
        size: 16,
        weight: FontWeight.w600,
        color: HobItColors.navy,
      ),
      titleSmall: _style(
        size: 14,
        weight: FontWeight.w600,
        color: HobItColors.navy,
      ),
      bodyLarge: _style(
        size: 16,
        weight: FontWeight.w400,
        color: HobItColors.black,
      ),
      bodyMedium: _style(
        size: 14,
        weight: FontWeight.w400,
        color: HobItColors.black,
      ),
      bodySmall: _style(
        size: 12,
        weight: FontWeight.w400,
        color: HobItColors.navy40,
      ),
      labelLarge: _style(
        size: 14,
        weight: FontWeight.w600,
        color: HobItColors.navy,
      ),
      labelMedium: _style(
        size: 12,
        weight: FontWeight.w600,
        color: HobItColors.navy,
      ),
      labelSmall: _style(
        size: 10,
        weight: FontWeight.w600,
        color: HobItColors.navy40,
      ),
    );
  }

  /// Agent attribution label style — "HOB-IT · Some message here."
  ///
  /// Amber, uppercase, letter-spaced. Used above generated widget cards
  /// to attribute the message to the hob-it agent.
  static TextStyle get agentLabel => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: HobItColors.amber,
    letterSpacing: 0.5,
  );

  /// Category tag style — "COMMUNITY", "GEAR", "LEARN", "ADMIN".
  ///
  /// Uppercase, letter-spaced, colored per [HobItCategory].
  static TextStyle categoryLabel(HobItCategory category) => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: HobItColors.categoryColor(category),
    letterSpacing: 1.2,
  );

  /// Category tag style for an open category keyword, colored via
  /// [HobItColors.categoryColorFor] with a neutral fallback.
  static TextStyle categoryLabelFor(String category) => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: HobItColors.categoryColorFor(category),
    letterSpacing: 1.2,
  );

  /// Price style — large blue amounts like "$180" or "$152".
  static TextStyle get price => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: HobItColors.blue,
  );

  /// Inline price style — right-aligned item prices like "$75".
  static TextStyle get priceInline => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: HobItColors.navy,
  );

  /// Total price style — blue, used in StarterKit totals.
  static TextStyle get priceTotal => GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: HobItColors.blue,
  );

  static TextStyle _style({
    required double size,
    required FontWeight weight,
    required Color color,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }
}
