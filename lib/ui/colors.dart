import 'package:flutter/material.dart';

/// VGV and hob-it color design tokens.
///
/// Primary VGV colors follow brand guidelines exactly.
/// hob-it surface and category colors extend the palette
/// for the mobile hobby-discovery context.
abstract final class HobItColors {
  // ── VGV Primary ──────────────────────────────────────────

  /// VGV Blue — primary brand and interactive color.
  static const Color blue = Color(0xFF2A48DE);

  /// VGV Navy — dark surfaces, primary text, step indicators.
  static const Color navy = Color(0xFF0A1530);

  /// VGV Black — body copy.
  static const Color black = Color(0xFF232326);

  /// VGV White — card surfaces, text on dark backgrounds.
  static const Color white = Color(0xFFFFFFFF);

  // ── VGV Blue Tints ────────────────────────────────────────

  /// VGV Blue at 80% tint.
  static const Color blue80 = Color(0xFF5570E5);

  /// VGV Blue at 40% tint — chip backgrounds, subtle accents.
  static const Color blue40 = Color(0xFFAABBF2);

  /// VGV Blue at 20% tint — light chip/badge fills.
  static const Color blue20 = Color(0xFFD5DDF8);

  // ── VGV Navy Tints ────────────────────────────────────────

  /// VGV Navy at 40% tint — muted body text, placeholders.
  static const Color navy40 = Color(0xFF9DA4AF);

  /// VGV Navy at 20% tint — card borders, dividers.
  static const Color navy20 = Color(0xFFCED1D7);

  // ── VGV Secondary (≤10% of any design) ───────────────────

  /// VGV Orange — LEARN category label, alert accents.
  static const Color orange = Color(0xFFFC5D42);

  /// VGV Purple — ADMIN category label.
  static const Color purple = Color(0xFF6420C6);

  // ── hob-it Surface Colors ─────────────────────────────────

  /// Warm tan — primary scaffold background.
  ///
  /// A warm saturated surface that grounds the card-on-scaffold
  /// visual language seen throughout the hob-it flows.
  static const Color scaffold = Color.fromRGBO(252, 247, 238, 1);

  /// Card surface — white cards on [scaffold].
  static const Color cardSurface = Color(0xFFFFFFFF);

  /// Icon tile background — warm beige for gear icon squares.
  ///
  /// Matches the scaffold tone; used as the background of
  /// item icon containers inside [StarterKit] and [GearCard].
  static const Color iconTile = Color(0xFFF5ECD9);

  // ── hob-it Accent Colors ──────────────────────────────────

  /// Amber — agent attribution labels ("HOB-IT ·"), ROADMAP tags,
  /// budget labels, and contextual category text.
  static const Color amber = Color(0xFFC4783A);

  /// Green — COMMUNITY category label and completion checkmarks.
  static const Color green = Color(0xFF2A9D5C);

  // ── Category Label Colors ─────────────────────────────────

  /// Returns the color for a given [HobItCategory].
  static Color categoryColor(HobItCategory category) {
    return switch (category) {
      HobItCategory.community => green,
      HobItCategory.gear => blue,
      HobItCategory.learn => orange,
      HobItCategory.admin => purple,
      HobItCategory.roadmap => amber,
    };
  }

  // ── VGV Gradient ──────────────────────────────────────────

  /// VGV brand gradient: Navy → Blue (diagonal, preferred direction).
  ///
  /// Used in [RecommendedHobby] hero image area.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, blue],
  );
}

/// Hobby step and card category labels.
///
/// Each value maps to a distinct color via [HobItColors.categoryColor].
enum HobItCategory {
  /// Community steps — gyms, clubs, local groups.
  community,

  /// Gear steps — equipment lists and starter kits.
  gear,

  /// Learning steps — courses, certifications, resources.
  learn,

  /// Admin steps — licenses, permits, registrations.
  admin,

  /// Roadmap — full journey overview label.
  roadmap,
}
