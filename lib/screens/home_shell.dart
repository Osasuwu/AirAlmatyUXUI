import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'causes_screen.dart';
import 'forecast_screen.dart';
import 'map_screen.dart';
import 'more_screen.dart';

/// Phone-width frame with the four main tabs. On wide windows (web/desktop)
/// the app is centred in a phone-sized column.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static const maxWidth = 420.0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ColoredBox(
      color: AppColors.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: Scaffold(
            body: IndexedStack(
              index: state.tab.index,
              children: const [
                MapScreen(),
                ForecastScreen(),
                CausesScreen(),
                MoreScreen(),
              ],
            ),
            bottomNavigationBar: _BottomBar(
              current: state.tab,
              onSelected: state.selectTab,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.current, required this.onSelected});

  final AppTab current;
  final ValueChanged<AppTab> onSelected;

  static const _items = <(AppTab, String, IconData)>[
    (AppTab.map, 'Карта', Icons.map_outlined),
    (AppTab.forecast, 'Прогноз', Icons.bar_chart_rounded),
    (AppTab.causes, 'Причины', Icons.help_outline),
    (AppTab.more, 'Ещё', Icons.menu),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          child: Row(
            children: [
              for (final (tab, label, icon) in _items)
                Expanded(
                  child: _NavItem(
                    label: label,
                    icon: icon,
                    selected: tab == current,
                    onTap: () => onSelected(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 56,
              height: 30,
              decoration: BoxDecoration(
                color: selected ? AppColors.primarySoft : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
