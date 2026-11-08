import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/app_theme.dart';
import 'aqi_widgets.dart';

/// Stylised city map with a tappable AQI badge per district.
class DistrictMap extends StatelessWidget {
  const DistrictMap({
    super.key,
    required this.districts,
    required this.valueOf,
    required this.onSelected,
    this.highlightedId,
  });

  final List<District> districts;
  final int Function(District) valueOf;
  final ValueChanged<District> onSelected;
  final String? highlightedId;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8CFD3), Color(0xFFFBE3B0), Color(0xFFFFF3DA)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: AspectRatio(
          aspectRatio: 1.1,
          child: LayoutBuilder(
            builder: (context, box) {
              return Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _StreetsPainter())),
                  const Positioned(
                    right: 12,
                    bottom: 10,
                    child: Text(
                      '▲▲▲ горы (юг)',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  for (final d in districts)
                    Positioned(
                      left: d.mapX * box.maxWidth,
                      top: d.mapY * box.maxHeight,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, 0),
                        child: _DistrictMarker(
                          district: d,
                          value: valueOf(d),
                          highlighted: d.id == highlightedId,
                          onTap: () => onSelected(d),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DistrictMarker extends StatelessWidget {
  const _DistrictMarker({
    required this.district,
    required this.value,
    required this.highlighted,
    required this.onTap,
  });

  final District district;
  final int value;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${district.fullName}, AQI ${district.aqi}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: highlighted ? const EdgeInsets.all(2) : EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  border: highlighted
                      ? Border.all(color: AppColors.text, width: 1.5)
                      : null,
                ),
                child: AqiBadge(value: value, color: district.level.color),
              ),
              const SizedBox(height: 3),
              Text(
                district.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreetsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    // Grid of "streets" with a couple of diagonals, purely decorative.
    for (final fy in [0.22, 0.52, 0.78]) {
      canvas.drawLine(Offset(0, h * fy), Offset(w, h * fy), paint);
    }
    for (final fx in [0.33, 0.67]) {
      canvas.drawLine(Offset(w * fx, 0), Offset(w * fx, h), paint);
    }
    canvas.drawLine(Offset(0, h * 0.95), Offset(w * 0.9, h * 0.1), paint);
    canvas.drawLine(Offset(w * 0.1, 0), Offset(w, h * 0.7), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
