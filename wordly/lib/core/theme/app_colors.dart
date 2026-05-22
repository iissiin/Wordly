import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary — основной акцентный цвет
  static const Color primary = Color(0xFF6C63FF); // фиолетовый
  static const Color primaryLight = Color(0xFFEDECFF); // светлый фон акцента
  static const Color primaryDark = Color(0xFF4B44CC); // тёмный акцент

  // Secondary — второй акцент
  static const Color secondary = Color(0xFFFF6584); // розовый
  static const Color secondaryLight = Color(0xFFFFECF0);

  // Success / Warning / Error
  static const Color success = Color(0xFF43D39E);
  static const Color successLight = Color(0xFFE8FBF5);
  static const Color warning = Color(0xFFFFB84C);
  static const Color warningLight = Color(0xFFFFF4E3);
  static const Color error = Color(0xFFFF5C7A);
  static const Color errorLight = Color(0xFFFFECF0);

  // Neutrals
  static const Color background = Color(0xFFF8F9FF); // фон приложения
  static const Color surface = Color(0xFFFFFFFF); // карточки
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocus = Color(0xFF6C63FF);

  // Градиенты для карточек паков (разные цвета для разных паков)
  static const List<List<Color>> packGradients = [
    [Color(0xFF6C63FF), Color(0xFF9C8FFF)],
    [Color(0xFFFF6584), Color(0xFFFF9BAB)],
    [Color(0xFF43D39E), Color(0xFF7EEAC4)],
    [Color(0xFFFFB84C), Color(0xFFFFD68A)],
    [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
    [Color(0xFFBA68C8), Color(0xFFCE93D8)],
  ];
}
