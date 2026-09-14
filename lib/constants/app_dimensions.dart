/// Design system dimensions and tokens following Apple Human Interface Guidelines.
class AppDimensions {
  // Spacing tokens
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Corner radius tokens
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // Icon size tokens
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;

  // Component sizes
  static const double buttonHeight = 48.0;
  static const double inputHeight = 50.0;
  static const double minTouchTarget = 44.0;

  // Elevations
  static const double cardElevation = 0.0; // Flat Apple-style
}

typedef AppDim = AppDimensions;
