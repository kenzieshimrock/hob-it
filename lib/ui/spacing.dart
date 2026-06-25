/// hob-it spacing tokens based on an 8pt grid.
///
/// Use these constants instead of hardcoded numeric values
/// to keep layout consistent across all screens and widgets.
abstract final class HobItSpacing {
  /// 4pt — icon gaps, tight internal padding.
  static const double xs = 4;

  /// 8pt — small gaps between related elements.
  static const double sm = 8;

  /// 12pt — compact card internal padding.
  static const double smd = 12;

  /// 16pt — standard card internal padding.
  static const double md = 16;

  /// 24pt — screen horizontal padding, section gaps.
  static const double lg = 24;

  /// 32pt — large vertical separation between sections.
  static const double xl = 32;

  /// 40pt — hero spacing, top-of-screen breathing room.
  static const double xxl = 40;

  /// 16pt — standard card border radius.
  static const double radiusMd = 16;

  /// 12pt — input field and button border radius.
  static const double radiusSm = 12;

  /// 8pt — chip and badge border radius.
  static const double radiusXs = 8;

  /// 100pt — fully pill-shaped elements (suggestion chips).
  static const double radiusPill = 100;
}
