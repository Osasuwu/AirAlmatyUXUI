import 'package:flutter/material.dart';

/// Design tokens taken from the "Air Almaty · Mockup + prototype" Figma frames.
class AppColors {
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF0F4F7);
  static const border = Color(0xFFE3E9EE);
  static const text = Color(0xFF172230);
  static const textSecondary = Color(0xFF5E6B7A);
  static const textMuted = Color(0xFF8A96A3);
  static const primary = Color(0xFF0B66A6);
  static const primarySoft = Color(0xFFE3F0FA);

  // Settings row icon tiles.
  static const iconPurple = Color(0xFF8E3FB3);
  static const iconRed = Color(0xFFD0343F);
  static const iconBlue = Color(0xFF0B66A6);
  static const iconGreen = Color(0xFF2E9E5B);
  static const iconOrange = Color(0xFFE8772E);
  static const iconGray = Color(0xFF4A5560);
  static const iconYellow = Color(0xFFE8B923);

  // Tips.
  static const tipGreenBg = Color(0xFFE6F5EC);
  static const tipGreenFg = Color(0xFF1F7A45);
}

/// AQI categories (US EPA breakpoints, as shown in the legend: 0 / 51 / 101 / 151 / 201+).
enum AqiLevel {
  good(
    label: 'Хорошо',
    advice: 'Воздух чистый — можно гулять и заниматься спортом на улице.',
    color: Color(0xFF2E9E5B),
    tint: Color(0xFFE6F5EC),
    min: 0,
  ),
  moderate(
    label: 'Умеренно',
    advice: 'Необычно чувствительным людям стоит сократить длительные нагрузки на улице.',
    color: Color(0xFFE8B923),
    tint: Color(0xFFFFF6D6),
    min: 51,
  ),
  sensitive(
    label: 'Вредно для чувствительных',
    advice:
        'Чувствительным группам — ограничить длительное пребывание на улице и физическую активность.',
    color: Color(0xFFE8772E),
    tint: Color(0xFFFDEBDD),
    min: 101,
  ),
  unhealthy(
    label: 'Вредно',
    advice:
        'Всем стоит сократить время на улице. Чувствительным группам — остаться дома.',
    color: Color(0xFFD0343F),
    tint: Color(0xFFFDE3E3),
    min: 151,
  ),
  veryUnhealthy(
    label: 'Очень вредно',
    advice:
        'Здоровым людям ограничить длительное пребывание на улице. Чувствительным группам — избегать физической активности.',
    color: Color(0xFF8E3FB3),
    tint: Color(0xFFF1E6F6),
    min: 201,
  );

  const AqiLevel({
    required this.label,
    required this.advice,
    required this.color,
    required this.tint,
    required this.min,
  });

  final String label;
  final String advice;
  final Color color;
  final Color tint;
  final int min;

  static AqiLevel of(int aqi) {
    var result = AqiLevel.good;
    for (final level in AqiLevel.values) {
      if (aqi >= level.min) result = level;
    }
    return result;
  }

  /// One-line hint shown on the "Мой район" card.
  String get shortAdvice => switch (this) {
        AqiLevel.good => 'Отличный день для прогулки',
        AqiLevel.moderate => 'Можно гулять, без долгих нагрузок',
        AqiLevel.sensitive => 'Чувствительным — ограничить прогулки',
        AqiLevel.unhealthy => 'Лучше сократить время на улице',
        AqiLevel.veryUnhealthy => 'Лучше остаться дома',
      };
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    surface: AppColors.background,
    onSurface: AppColors.text,
    outline: AppColors.border,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.background,
    splashFactory: InkSparkle.splashFactory,
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Inter',
          bodyColor: AppColors.text,
          displayColor: AppColors.text,
        ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.primary
            : const Color(0xFFCBD3DB),
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, space: 1, thickness: 1),
  );
}
