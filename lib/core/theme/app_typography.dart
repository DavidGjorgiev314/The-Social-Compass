import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextTheme build(TextTheme base) {
    final display = GoogleFonts.spaceGrotesk(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
    );
    final body = GoogleFonts.inter(color: AppColors.textPrimary);

    return base.copyWith(
      displayLarge: display.copyWith(fontSize: 40, letterSpacing: -0.5),
      displayMedium: display.copyWith(fontSize: 32, letterSpacing: -0.5),
      headlineMedium: display.copyWith(fontSize: 24, letterSpacing: -0.3),
      headlineSmall: display.copyWith(fontSize: 20, letterSpacing: -0.2),
      titleLarge: GoogleFonts.spaceGrotesk(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: body.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: body.copyWith(fontSize: 15, height: 1.4),
      bodyMedium: body.copyWith(fontSize: 14, height: 1.4),
      bodySmall: body.copyWith(
        fontSize: 12.5,
        height: 1.35,
        color: AppColors.textSecondary,
      ),
      labelLarge: body.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelSmall: body.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColors.textSecondary,
      ),
    );
  }

  static TextStyle get clock => GoogleFonts.spaceGrotesk(
        color: AppColors.textPrimary,
        fontSize: 76,
        fontWeight: FontWeight.w500,
        letterSpacing: -1,
      );

  static TextStyle get statusBar => GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );
}
