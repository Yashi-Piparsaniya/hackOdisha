import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextFieldTheme {
  static final InputDecorationTheme theme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle: const TextStyle(
      color: AppColors.textLight,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: const TextStyle(
      color: AppColors.textLight,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    prefixIconColor: AppColors.textLight,
    suffixIconColor: AppColors.textLight,
  );
}
