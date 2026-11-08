import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/aqi_widgets.dart';

class CausesScreen extends StatelessWidget {
  const CausesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final causes = context.watch<AppState>().causes;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          const Text('Причины', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            '${causes.isEmpty ? 5 : causes.length} главных причин зимнего смога',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          for (final cause in causes) ...[
            _CauseCard(cause: cause),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          const _ProtectCard(),
        ],
      ),
    );
  }
}

({IconData icon, Color color}) _style(CauseKind kind) => switch (kind) {
      CauseKind.heating => (icon: Icons.local_fire_department_outlined, color: AppColors.iconRed),
      CauseKind.inversion => (icon: Icons.cloud_outlined, color: AppColors.iconBlue),
      CauseKind.traffic => (icon: Icons.directions_car_outlined, color: AppColors.iconOrange),
      CauseKind.buildings => (icon: Icons.apartment, color: AppColors.iconPurple),
      CauseKind.dust => (icon: Icons.grain, color: AppColors.iconYellow),
    };

class _CauseCard extends StatelessWidget {
  const _CauseCard({required this.cause});

  final Cause cause;

  @override
  Widget build(BuildContext context) {
    final style = _style(cause.kind);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: style.icon, color: style.color, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        cause.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (cause.primary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.iconRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          'Главный',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.iconRed,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  cause.description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectCard extends StatelessWidget {
  const _ProtectCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Как защититься',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Маска FFP2 на улице, очиститель воздуха дома, проветривание — днём, когда AQI ниже.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
