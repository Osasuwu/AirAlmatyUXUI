import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rounded number pill coloured by AQI level (map badges, widget chips).
class AqiBadge extends StatelessWidget {
  const AqiBadge({
    super.key,
    required this.value,
    required this.color,
    this.size = AqiBadgeSize.medium,
    this.shadow = true,
  });

  final int value;
  final Color color;
  final AqiBadgeSize size;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final (hPad, vPad, fontSize) = switch (size) {
      AqiBadgeSize.small => (10.0, 3.0, 12.0),
      AqiBadgeSize.medium => (13.0, 6.0, 15.0),
      AqiBadgeSize.large => (20.0, 14.0, 26.0),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size == AqiBadgeSize.large ? 18 : 99),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Text(
        '$value',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}

enum AqiBadgeSize { small, medium, large }

/// Small coloured category pill ("Очень вредно").
class LevelPill extends StatelessWidget {
  const LevelPill({super.key, required this.level, this.fontSize = 12});

  final AqiLevel level;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: fontSize > 12 ? 5 : 4),
      decoration: BoxDecoration(
        color: level.color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        level.label,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Five-segment AQI scale with breakpoints underneath.
class AqiLegend extends StatelessWidget {
  const AqiLegend({super.key});

  @override
  Widget build(BuildContext context) {
    const labels = ['0', '51', '101', '151', '201+'];
    return Column(
      children: [
        Row(
          children: [
            for (final level in AqiLevel.values)
              Expanded(
                child: Container(
                  height: 8,
                  margin: EdgeInsets.only(right: level == AqiLevel.veryUnhealthy ? 0 : 3),
                  decoration: BoxDecoration(
                    color: level.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final l in labels)
              Expanded(
                child: Text(
                  l,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Rounded icon tile used on the "Причины" and "Ещё" screens.
class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon, required this.color, this.size = 40});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}
