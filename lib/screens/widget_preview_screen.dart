import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/aqi_widgets.dart';

/// Illustrates how the Air Almaty widgets look on a phone home screen
/// ("F · Виджет (домашний экран)" in the design).
class WidgetPreviewScreen extends StatelessWidget {
  const WidgetPreviewScreen({super.key});

  static const _appIcons = <List<Color>>[
    [Color(0xFF4CD964), Color(0xFF34C759)],
    [Color(0xFF1E90FF), Color(0xFF0A74F0)],
    [Color(0xFFFFA928), Color(0xFFFF9500)],
    [Color(0xFFFF3B6B), Color(0xFFFF2D55)],
    [Color(0xFF7A7AEB), Color(0xFF5856D6)],
    [Color(0xFFC46BF0), Color(0xFFAF52DE)],
    [Color(0xFF6FD8FF), Color(0xFF5AC8FA)],
    [Color(0xFFFFE01A), Color(0xFFFFCC00)],
    [Color(0xFFA0A0A6), Color(0xFF8E8E93)],
    [Color(0xFFFF5C4D), Color(0xFFFF3B30)],
    [Color(0xFF44C8D8), Color(0xFF30B0C7)],
    [Color(0xFFB08D68), Color(0xFFA2845E)],
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cityAqi = state.snapshot?.cityAqi ?? 156;
    final level = AqiLevel.of(cityAqi);
    final updatedAt = state.snapshot?.updatedAt ?? '10:00';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.text,
        title: const Text(
          'Виджет на экран',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB9D7EE), Color(0xFFCFCBEE), Color(0xFFF0CCD3)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _WidgetCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _WidgetTitle('Air Almaty'),
                            const SizedBox(height: 4),
                            Text(
                              '$cityAqi',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: level.color,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: level.color,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              // Wraps tightly around the label, never wider than the card.
                              child: Text(
                                level.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Алматы · $updatedAt',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _WidgetCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _WidgetTitle('Прогноз на сегодня'),
                            const SizedBox(height: 8),
                            for (final (hour, aqi) in const [(13, 98), (16, 120), (20, 200)])
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$hour:00',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    AqiBadge(
                                      value: aqi,
                                      color: AqiLevel.of(aqi).color,
                                      size: AqiBadgeSize.small,
                                      shadow: false,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final colors in _appIcons)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: colors,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.last.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const Text(
                  'Так виджеты Air Almaty выглядят на домашнем экране',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WidgetTitle extends StatelessWidget {
  const _WidgetTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      );
}

class _WidgetCard extends StatelessWidget {
  const _WidgetCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
