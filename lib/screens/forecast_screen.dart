import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final forecast = state.forecast;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          const Text('Прогноз', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _DistrictDropdown(state: state),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final range in ForecastRange.values) ...[
                _RangeChip(
                  label: range.label,
                  selected: range == state.forecastRange,
                  onTap: () => state.setForecastRange(range),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (forecast == null || state.forecastLoading && forecast.points.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _ChartCard(forecast: forecast, range: state.forecastRange),
            const SizedBox(height: 12),
            _StatsCard(forecast: forecast),
            const SizedBox(height: 12),
            _TipCard(forecast: forecast, range: state.forecastRange),
          ],
        ],
      ),
    );
  }
}

class _DistrictDropdown extends StatelessWidget {
  const _DistrictDropdown({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final districts = state.snapshot?.districts ?? const <District>[];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: state.forecastDistrictId,
          borderRadius: BorderRadius.circular(14),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.text,
          ),
          selectedItemBuilder: (context) => [
            for (final label in ['Весь город', ...districts.map((d) => d.name)])
              Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Район: ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextSpan(
                        text: label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('Весь город')),
            for (final d in districts)
              DropdownMenuItem<String?>(value: d.id, child: Text(d.name)),
          ],
          onChanged: state.setForecastDistrict,
        ),
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.forecast, required this.range});

  final Forecast forecast;
  final ForecastRange range;

  @override
  Widget build(BuildContext context) {
    final now = forecast.nowIndex;
    final title = range == ForecastRange.week ? 'AQI по дням' : 'AQI по часам';
    final subtitle = now == null ? null : 'Сейчас 10:00 · ${forecast.points[now].aqi}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Text(
                  subtitle,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: BarChart(forecast: forecast, labelEvery: range == ForecastRange.week ? 1 : 6),
          ),
        ],
      ),
    );
  }
}

/// Bars coloured by AQI level. Hours before "now" are drawn pale, the current
/// bar is outlined.
class BarChart extends StatelessWidget {
  const BarChart({super.key, required this.forecast, required this.labelEvery});

  final Forecast forecast;
  final int labelEvery;

  @override
  Widget build(BuildContext context) {
    final points = forecast.points;
    final maxValue = points.map((p) => p.aqi).reduce((a, b) => a > b ? a : b);
    final now = forecast.nowIndex;
    final lastIndex = points.length - 1;

    return LayoutBuilder(
      builder: (context, box) {
        const labelHeight = 18.0;
        final chartHeight = box.maxHeight - labelHeight;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < points.length; i++)
              Expanded(
                child: Semantics(
                  label: '${points[i].label}: AQI ${points[i].aqi}',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: chartHeight * (points[i].aqi / maxValue),
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: _barColor(points[i], i, now),
                          borderRadius: BorderRadius.circular(3),
                          border: i == now
                              ? Border.all(color: AppColors.text, width: 1.5)
                              : null,
                        ),
                      ),
                      SizedBox(
                        height: labelHeight,
                        child: Center(
                          child: OverflowBox(
                            maxWidth: 40,
                            child: Text(
                              _showLabel(i, lastIndex) ? points[i].label : '',
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  bool _showLabel(int i, int last) => labelEvery == 1 || i % labelEvery == 0 || i == last;

  Color _barColor(ForecastPoint p, int i, int? now) {
    final color = AqiLevel.of(p.aqi).color;
    if (now != null && i < now) return Color.lerp(color, Colors.white, 0.65)!;
    return color;
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.forecast});

  final Forecast forecast;

  @override
  Widget build(BuildContext context) {
    final min = forecast.min;
    final max = forecast.max;
    final avg = forecast.average;
    final hourly = forecast.points.length == 24;
    String when(ForecastPoint p) => hourly ? ' · ${p.label}:00' : ' · ${p.label}';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _Stat(
            title: 'Мин',
            value: '${min.aqi}',
            suffix: when(min),
            color: AqiLevel.of(min.aqi).color,
          ),
          _Stat(
            title: 'Макс',
            value: '${max.aqi}',
            suffix: when(max),
            color: AqiLevel.of(max.aqi).color,
          ),
          _Stat(
            title: 'Среднее',
            value: '$avg',
            suffix: '',
            color: AqiLevel.of(avg).color,
          ),
        ],
      ),
    );
  }

}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.title,
    required this.value,
    required this.suffix,
    required this.color,
  });

  final String title;
  final String value;
  final String suffix;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                if (suffix.isNotEmpty)
                  TextSpan(
                    text: suffix,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.forecast, required this.range});

  final Forecast forecast;
  final ForecastRange range;

  @override
  Widget build(BuildContext context) {
    final String title;
    final String body;
    if (range == ForecastRange.week) {
      final best = forecast.min;
      title = 'Лучший день для прогулок';
      body = '${best.label} · AQI около ${_roundTo10(best.aqi)}. '
          'В дни с AQI выше 150 лучше сократить время на улице.';
    } else {
      final window = _bestWindow(forecast.points, 4);
      final start = window.$1;
      final end = start + 3;
      final avg = window.$2;
      var worse = -1;
      for (var i = end + 1; i < forecast.points.length; i++) {
        if (forecast.points[i].aqi > 150) {
          worse = i;
          break;
        }
      }
      final tail = worse == -1
          ? 'Остальное время воздух заметно лучше.'
          : 'Позже станет хуже — после ${forecast.points[worse].label}:00 лучше остаться дома.';
      title = 'Лучшее время для прогулки';
      body = '${_hh(start)}:00–${_hh(end)}:00 · AQI около ${_roundTo10(avg)}. $tail';
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tipGreenBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.eco_outlined, color: AppColors.tipGreenFg, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tipGreenFg,
                  ),
                ),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _hh(int h) => h.toString().padLeft(2, '0');

  int _roundTo10(num v) => ((v / 10).round() * 10);

  /// (start index, average) of the calmest window of [len] consecutive bars.
  (int, double) _bestWindow(List<ForecastPoint> points, int len) {
    var bestStart = 0;
    var bestAvg = double.infinity;
    for (var i = 0; i + len <= points.length; i++) {
      final avg =
          points.sublist(i, i + len).fold<int>(0, (s, p) => s + p.aqi) / len;
      if (avg < bestAvg) {
        bestAvg = avg;
        bestStart = i;
      }
    }
    return (bestStart, bestAvg);
  }
}
