import 'models.dart';

/// Data source for the app. The prototype only ships [MockAirRepository];
/// a real implementation (IQAir API) would implement the same interface.
abstract class AirRepository {
  Future<AirSnapshot> loadSnapshot();
  Future<Forecast> loadForecast(ForecastRange range, {String? districtId});
  Future<List<Cause>> loadCauses();
}

/// Fake backend: static data from the Figma prototype behind a short delay,
/// so loading and refresh states are visible in the UI.
class MockAirRepository implements AirRepository {
  const MockAirRepository({this.latency = const Duration(milliseconds: 450)});

  final Duration latency;

  static const _districts = <District>[
    District(
      id: 'alatau', name: 'Алатауский', aqi: 172, pm25: 96, pm10: 140, no2: 38,
      mapX: 0.17, mapY: 0.10,
    ),
    District(
      id: 'zhetysu', name: 'Жетысуский', aqi: 165, pm25: 86, pm10: 128, no2: 36,
      mapX: 0.50, mapY: 0.10,
    ),
    District(
      id: 'turksib', name: 'Турксибский', aqi: 148, pm25: 54, pm10: 102, no2: 33,
      mapX: 0.83, mapY: 0.10,
    ),
    District(
      id: 'auezov', name: 'Ауэзовский', aqi: 205, pm25: 155, pm10: 198, no2: 41,
      mapX: 0.17, mapY: 0.40,
    ),
    District(
      id: 'almaly', name: 'Алмалинский', aqi: 139, pm25: 51, pm10: 96, no2: 35,
      mapX: 0.50, mapY: 0.45,
    ),
    District(
      id: 'medeu', name: 'Медеуский', aqi: 72, pm25: 22, pm10: 48, no2: 18,
      mapX: 0.84, mapY: 0.45,
    ),
    District(
      id: 'bostandyk', name: 'Бостандыкский', aqi: 95, pm25: 33, pm10: 62, no2: 24,
      mapX: 0.55, mapY: 0.74,
    ),
    District(
      id: 'nauryzbay', name: 'Наурызбайский', aqi: 88, pm25: 30, pm10: 58, no2: 21,
      mapX: 0.20, mapY: 0.80,
    ),
  ];

  /// City-wide hourly AQI for today. Chosen so that min = 98 (13:00),
  /// max = 200 (20:00), average = 151, "now" (10:00) = 151, as in the design.
  static const todayHourly = <int>[
    160, 162, 164, 162, 158, 156, 154, 152, 150, 150, 151, 128, //
    108, 98, 100, 104, 120, 140, 162, 184, 200, 196, 188, 177,
  ];

  static const _weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  static const _weekCity = <int>[151, 138, 122, 96, 84, 110, 143];

  @override
  Future<AirSnapshot> loadSnapshot() async {
    await Future<void>.delayed(latency);
    return const AirSnapshot(
      districts: _districts,
      cityAqi: 156,
      updatedAt: '10:00',
      source: 'IQAir',
    );
  }

  @override
  Future<Forecast> loadForecast(ForecastRange range, {String? districtId}) async {
    await Future<void>.delayed(latency ~/ 3);
    final district =
        districtId == null ? null : _districts.firstWhere((d) => d.id == districtId);
    // A district follows the city curve, scaled by how it compares to the city average.
    final factor = district == null ? 1.0 : district.aqi / 156;
    int scale(int v) => (v * factor).round().clamp(0, 500);

    switch (range) {
      case ForecastRange.today:
        return Forecast(
          points: [
            for (var h = 0; h < 24; h++)
              ForecastPoint(h.toString().padLeft(2, '0'), scale(todayHourly[h])),
          ],
          nowIndex: 10,
        );
      case ForecastRange.tomorrow:
        return Forecast(
          points: [
            for (var h = 0; h < 24; h++)
              ForecastPoint(
                h.toString().padLeft(2, '0'),
                scale((todayHourly[(h + 5) % 24] * 0.86).round()),
              ),
          ],
        );
      case ForecastRange.week:
        return Forecast(
          points: [
            for (var d = 0; d < 7; d++) ForecastPoint(_weekDays[d], scale(_weekCity[d])),
          ],
        );
    }
  }

  @override
  Future<List<Cause>> loadCauses() async {
    await Future<void>.delayed(latency ~/ 3);
    return const [
      Cause(
        title: 'Отопительный сезон',
        description: 'ТЭЦ и частный сектор топят углём — главный источник зимой.',
        kind: CauseKind.heating,
        primary: true,
      ),
      Cause(
        title: 'Безветрие и инверсия',
        description: 'Город в котловине: холодный воздух запирает смог у земли.',
        kind: CauseKind.inversion,
      ),
      Cause(
        title: 'Транспорт',
        description: 'Около 600 тыс. машин, много старых, пробки в час пик.',
        kind: CauseKind.traffic,
      ),
      Cause(
        title: 'Застройка',
        description: 'Высотки на юге перекрывают горный ветер («роза ветров»).',
        kind: CauseKind.buildings,
      ),
      Cause(
        title: 'Пыль и стройки',
        description: 'Открытые стройплощадки и грунт поднимают PM10.',
        kind: CauseKind.dust,
      ),
    ];
  }
}
