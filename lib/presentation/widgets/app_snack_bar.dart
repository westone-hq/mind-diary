import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppSnackBar {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.only(bottom: 64, left: 100, right: 100),
        backgroundColor: AppColors.textMain,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }
}
