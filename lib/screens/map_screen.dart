import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/aqi_widgets.dart';
import '../widgets/district_map.dart';
import '../widgets/district_sheet.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final snapshot = state.snapshot;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: state.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            const _Header(),
            const SizedBox(height: 16),
            if (snapshot == null)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              _CitySummary(snapshot: snapshot, units: state.unitsCaption),
              const SizedBox(height: 14),
              DistrictMap(
                districts: snapshot.districts,
                valueOf: state.displayValue,
                highlightedId: state.myDistrictId,
                onSelected: (d) => showDistrictSheet(context, d),
              ),
              const SizedBox(height: 12),
              const AqiLegend(),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Нажмите на район на карте, чтобы увидеть подробности',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 14),
              if (state.myDistrict case final mine?) _MyDistrictCard(district: mine),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.air, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        const Text('Air Almaty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(99),
          ),
          child: const Text(
            'RU',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CitySummary extends StatelessWidget {
  const _CitySummary({required this.snapshot, required this.units});

  final AirSnapshot snapshot;
  final String units;

  @override
  Widget build(BuildContext context) {
    final level = AqiLevel.of(snapshot.cityAqi);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: level.tint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: level.color.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Алматы · среднее по городу · ${snapshot.updatedAt}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('AQI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text(
                '${snapshot.cityAqi}',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: level.color,
                  height: 1,
                ),
              ),
              const Spacer(),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: level.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                level.label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyDistrictCard extends StatelessWidget {
  const _MyDistrictCard({required this.district});

  final District district;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => showDistrictSheet(context, district),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              AqiBadge(
                value: state.displayValue(district),
                color: district.level.color,
                size: AqiBadgeSize.large,
                shadow: false,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Мой район · ${district.name}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${district.level.label} — ${district.level.shortAdvice.toLowerCase()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
