import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/aqi_widgets.dart';
import 'widget_preview_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final district = state.myDistrict;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          const Text('Ещё', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          const _SectionTitle('НАСТРОЙКИ'),
          _Group(
            children: [
              _SettingsRow(
                icon: Icons.location_on_outlined,
                color: AppColors.iconPurple,
                title: 'Мой район',
                value: district?.name ?? '',
                onTap: () => _pickDistrict(context),
              ),
              _SettingsRow(
                icon: Icons.notifications_none,
                color: AppColors.iconRed,
                title: 'Уведомления',
                trailing: Switch(
                  value: state.notifications,
                  onChanged: state.setNotifications,
                ),
                onTap: () => state.setNotifications(!state.notifications),
              ),
              _SettingsRow(
                icon: Icons.widgets_outlined,
                color: AppColors.iconBlue,
                title: 'Виджет на экран',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const WidgetPreviewScreen()),
                ),
              ),
              _SettingsRow(
                icon: Icons.language,
                color: AppColors.iconGreen,
                title: 'Язык',
                value: state.language.label,
                onTap: () => _pickLanguage(context),
              ),
              _SettingsRow(
                icon: Icons.straighten,
                color: AppColors.iconOrange,
                title: 'Единицы',
                value: state.units == AirUnits.usAqi ? 'US AQI' : 'PM2.5',
                onTap: () => _pickUnits(context),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionTitle('О ПРИЛОЖЕНИИ'),
          _Group(
            children: [
              _SettingsRow(
                icon: Icons.storage_outlined,
                color: AppColors.iconGray,
                title: 'Источники данных',
                value: state.snapshot?.source ?? 'IQAir',
                onTap: () => _info(
                  context,
                  'Источники данных',
                  'Показатели качества воздуха предоставляет IQAir. '
                      'В этом прототипе используются демонстрационные данные.',
                ),
              ),
              _SettingsRow(
                icon: Icons.info_outline,
                color: AppColors.iconBlue,
                title: 'О проекте',
                onTap: () => _info(
                  context,
                  'О проекте',
                  'Air Almaty помогает жителям Алматы следить за качеством воздуха '
                      'по районам, планировать прогулки и понимать причины смога.',
                ),
              ),
              _SettingsRow(
                icon: Icons.mail_outline,
                color: AppColors.iconGreen,
                title: 'Связаться с нами',
                onTap: () => _info(
                  context,
                  'Связаться с нами',
                  'Напишите нам: hello@airalmaty.example\n(демонстрационный адрес)',
                ),
              ),
              _SettingsRow(
                icon: Icons.star_rounded,
                color: AppColors.iconYellow,
                title: 'Оценить приложение',
                onTap: () => _rate(context),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Center(
            child: Text(
              'Air Almaty · версия 1.0',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDistrict(BuildContext context) {
    final state = context.read<AppState>();
    final districts = state.snapshot?.districts ?? const [];
    return _showPicker(
      context,
      title: 'Мой район',
      options: [
        for (final d in districts)
          _PickerOption(
            label: d.fullName,
            selected: d.id == state.myDistrictId,
            leading: AqiBadge(
              value: d.aqi,
              color: d.level.color,
              size: AqiBadgeSize.small,
              shadow: false,
            ),
            onSelect: () => state.setMyDistrict(d.id),
          ),
      ],
    );
  }

  Future<void> _pickLanguage(BuildContext context) {
    final state = context.read<AppState>();
    return _showPicker(
      context,
      title: 'Язык',
      options: [
        for (final l in AppLanguage.values)
          _PickerOption(
            label: l.label,
            hint: l.available ? null : 'скоро',
            selected: l == state.language,
            enabled: l.available,
            onSelect: () => state.setLanguage(l),
          ),
      ],
    );
  }

  Future<void> _pickUnits(BuildContext context) {
    final state = context.read<AppState>();
    return _showPicker(
      context,
      title: 'Единицы',
      options: [
        for (final u in AirUnits.values)
          _PickerOption(
            label: u.label,
            selected: u == state.units,
            onSelect: () => state.setUnits(u),
          ),
      ],
    );
  }

  Future<void> _info(BuildContext context, String title, String body) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Text(body, style: const TextStyle(fontSize: 14, height: 1.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Future<void> _rate(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const _RateDialog(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 6, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: AppColors.textMuted,
          ),
        ),
      );
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 66),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.color,
    required this.title,
    this.value,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            IconTile(icon: icon, color: color, size: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  value!,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ),
            trailing ?? const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}

class _PickerOption {
  const _PickerOption({
    required this.label,
    required this.selected,
    required this.onSelect,
    this.hint,
    this.leading,
    this.enabled = true,
  });

  final String label;
  final String? hint;
  final bool selected;
  final bool enabled;
  final Widget? leading;
  final VoidCallback onSelect;
}

Future<void> _showPicker(
  BuildContext context, {
  required String title,
  required List<_PickerOption> options,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    constraints: const BoxConstraints(maxWidth: 420),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            for (final o in options)
              ListTile(
                enabled: o.enabled,
                leading: o.leading,
                title: Text(o.label),
                subtitle: o.hint == null ? null : Text(o.hint!),
                trailing: o.selected
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  o.onSelect();
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    ),
  );
}

class _RateDialog extends StatefulWidget {
  const _RateDialog();

  @override
  State<_RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<_RateDialog> {
  int _stars = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Оценить приложение',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            IconButton(
              tooltip: '$i',
              onPressed: () => setState(() => _stars = i),
              icon: Icon(
                i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: AppColors.iconYellow,
                size: 32,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
        FilledButton(
          onPressed: _stars == 0
              ? null
              : () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Спасибо за оценку: $_stars из 5')),
                  );
                },
          child: const Text('Отправить'),
        ),
      ],
    );
  }
}
