import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgBase,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.bgBase,
        onSurface: AppColors.textMain,
      ),
      fontFamily: 'Pretendard', // Assuming custom font will be added or we can use google_fonts
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textMain, fontSize: 16, height: 1.6),
        bodyMedium: TextStyle(color: AppColors.textMain, fontSize: 14, height: 1.6),
        titleLarge: TextStyle(color: AppColors.textMain, fontSize: 24, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(color: AppColors.textSub, fontSize: 14),
        labelSmall: TextStyle(color: AppColors.textFaint, fontSize: 12),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textMain),
        centerTitle: true,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
