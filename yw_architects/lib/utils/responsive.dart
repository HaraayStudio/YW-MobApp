import 'package:flutter/material.dart';

/// Global Responsive Utility for YW Architects.
/// Provides relative scaling factors for widths, heights, and text sizing
/// based on a target design width (375px - generic iPhone).
class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;


  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static late double scaleFactor;

  /// Call this in the main build method or a base widget.
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;


    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    // Use 375 as base design width (iPhone SE/12/13/14/15 family)
    scaleFactor = screenWidth / 375;
  }

  /// Relative Width based on design pixels (px)
  static double w(double px) => px * scaleFactor;

  /// Relative Height based on design pixels (px)
  /// Usually better to keep vertical spacing relative to height if it's full-screen,
  /// but for most app layouts, relative-to-width scaling keeps aspect ratios.
  static double h(double px) => px * scaleFactor;

  /// Scalable font size based on screen width
  /// Clamped to prevent font from becoming too small on tiny screens
  static double sp(double fontSize) =>
      (fontSize * scaleFactor).clamp(fontSize * 0.8, fontSize * 1.5);

  /// Helper for responsive padding
  static EdgeInsets padding({double? all, double? h, double? v}) {
    if (all != null) return EdgeInsets.all(w(all));
    return EdgeInsets.symmetric(horizontal: w(h ?? 0), vertical: w(v ?? 0));
  }
}

/// Extension for easy access on double values: 20.w, 15.sp, etc.
extension ResponsiveDouble on num {
  double get w => Responsive.w(toDouble());
  double get h => Responsive.h(toDouble());
  double get sp => Responsive.sp(toDouble());
}
