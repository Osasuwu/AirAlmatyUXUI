import '../theme/app_theme.dart';

class District {
  const District({
    required this.id,
    required this.name,
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.no2,
    required this.mapX,
    required this.mapY,
  });

  final String id;

  /// Short name as it appears on the map ("Ауэзовский").
  final String name;
  final int aqi;
  final int pm25;
  final int pm10;
  final int no2;

  /// Position on the stylised map, 0..1 of the map card.
  final double mapX;
  final double mapY;

  String get fullName => '$name район';
  AqiLevel get level => AqiLevel.of(aqi);
}

/// A single bar of the forecast chart.
class ForecastPoint {
  const ForecastPoint(this.label, this.aqi);
  final String label;
  final int aqi;
}

enum ForecastRange {
  today('Сегодня'),
  tomorrow('Завтра'),
  week('7 дней');

  const ForecastRange(this.label);
  final String label;
}

class Forecast {
  const Forecast({required this.points, this.nowIndex});

  final List<ForecastPoint> points;

  /// Index of the "current" bar, only for today's hourly chart.
  final int? nowIndex;

  ForecastPoint get min => points.reduce((a, b) => b.aqi < a.aqi ? b : a);
  ForecastPoint get max => points.reduce((a, b) => b.aqi > a.aqi ? b : a);
  int get average =>
      (points.fold<int>(0, (sum, p) => sum + p.aqi) / points.length).round();
}

class Cause {
  const Cause({
    required this.title,
    required this.description,
    required this.kind,
    this.primary = false,
  });

  final String title;
  final String description;
  final CauseKind kind;
  final bool primary;
}

enum CauseKind { heating, inversion, traffic, buildings, dust }

class AirSnapshot {
  const AirSnapshot({
    required this.districts,
    required this.cityAqi,
    required this.updatedAt,
    required this.source,
  });

  final List<District> districts;
  final int cityAqi;
  final String updatedAt;
  final String source;

  District districtById(String id) =>
      districts.firstWhere((d) => d.id == id, orElse: () => districts.first);
}
