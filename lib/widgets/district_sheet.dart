import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'aqi_widgets.dart';

/// Bottom sheet with the details of one district ("Карточка района").
Future<void> showDistrictSheet(BuildContext context, District district) {
  final state = context.read<AppState>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    constraints: const BoxConstraints(maxWidth: 420),
    builder: (sheetContext) => _DistrictSheet(
      district: district,
      source: state.snapshot?.source ?? 'IQAir',
      updatedAt: state.snapshot?.updatedAt ?? '',
      onForecast: () {
        Navigator.of(sheetContext).pop();
        state.showForecastFor(district.id);
      },
      onCauses: () {
        Navigator.of(sheetContext).pop();
        state.selectTab(AppTab.causes);
      },
    ),
  );
}

class _DistrictSheet extends StatelessWidget {
  const _DistrictSheet({
    required this.district,
    required this.source,
    required this.updatedAt,
    required this.onForecast,
    required this.onCauses,
  });

  final District district;
  final String source;
  final String updatedAt;
  final VoidCallback onForecast;
  final VoidCallback onCauses;

  @override
  Widget build(BuildContext context) {
    final level = district.level;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      district.fullName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Material(
                    color: AppColors.surface,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textSecondary,
                          semanticLabel: 'Закрыть',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${district.aqi}',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: level.color,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AQI (US EPA)',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      LevelPill(level: level, fontSize: 13),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _MetricChip(label: 'PM2.5', value: '${district.pm25}', unit: 'мкг/м³'),
                  const SizedBox(width: 8),
                  _MetricChip(label: 'PM10', value: '${district.pm10}', unit: 'мкг/м³'),
                  const SizedBox(width: 8),
                  _MetricChip(label: 'NO₂', value: '${district.no2}', unit: 'ppb'),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: level.tint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: level.color, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        level.advice,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Источник: $source · обновлено $updatedAt',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: onForecast,
                      style: _buttonStyle(AppColors.primary, Colors.white),
                      child: const Text('Прогноз →'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: onCauses,
                      style: _buttonStyle(AppColors.primarySoft, AppColors.primary),
                      child: const Text('Почему грязно? →'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(Color bg, Color fg) => FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      );
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value, required this.unit});

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text(unit, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
