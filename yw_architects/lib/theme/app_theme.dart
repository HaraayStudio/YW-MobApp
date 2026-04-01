import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF755B00);
  static const primaryContainer = Color(0xFFB8952A);
  static const primaryFixed = Color(0xFFFFE08F);
  static const primaryFixedDim = Color(0xFFE9C254);
  static const onPrimary = Colors.white;
  static const secondary = Color(0xFF705D00);
  static const secondaryContainer = Color(0xFFFCDE6C);
  static const onSecondaryContainer = Color(0xFF756100);
  static const surface = Color(0xFFF9FBEC);
  static const surfaceContainer = Color(0xFFEDEFE0);
  static const surfaceContainerLow = Color(0xFFF3F5E6);
  static const surfaceContainerLowest = Colors.white;
  static const surfaceContainerHigh = Color(0xFFE7E9DB);
  static const surfaceContainerHighest = Color(0xFFE2E4D5);
  static const surfaceDim = Color(0xFFD9DBCD);
  static const surfaceBright = Color(0xFFF9FBEC);
  static const onSurface = Color(0xFF1A1D14);
  static const onSurfaceVariant = Color(0xFF4D4636);
  static const outline = Color(0xFF7F7664);
  static const outlineVariant = Color(0xFFD0C5B0);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onError = Colors.white;
  static const inverseSurface = Color(0xFF2E3228);
  static const inverseOnSurface = Color(0xFFF0F2E3);
  static const tertiary = Color(0xFF655D4E);

  static const goldGradientStart = Color(0xFF755B00);
  static const goldGradientEnd = Color(0xFFB8952A);

  // Status chip colors
  static const chipPlanningBg = Color(0x1F2196F3);
  static const chipPlanningFg = Color(0xFF1565C0);
  static const chipProgressBg = Color(0x1FFF9800);
  static const chipProgressFg = Color(0xFFE65100);
  static const chipReviewBg = Color(0x1F9C27B0);
  static const chipReviewFg = Color(0xFF6A1B9A);
  static const chipDoneBg = Color(0x1F4CAF50);
  static const chipDoneFg = Color(0xFF2E7D32);
  static const chipHoldBg = Color(0x1F755B00);
  static const chipHoldFg = Color(0xFF755B00);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      useMaterial3: true,
    );
  }
}

LinearGradient get goldGradient => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.goldGradientStart, AppColors.goldGradientEnd],
    );
