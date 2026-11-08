import 'package:air_almaty/data/air_repository.dart';
import 'package:air_almaty/data/models.dart';
import 'package:air_almaty/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AQI levels switch exactly at the legend breakpoints 51 / 101 / 151 / 201', () {
    // The legend under the map reads 0 / 51 / 101 / 151 / 201+.
    const expected = {
      0: AqiLevel.good,
      50: AqiLevel.good,
      51: AqiLevel.moderate,
      100: AqiLevel.moderate,
      101: AqiLevel.sensitive,
      150: AqiLevel.sensitive,
      151: AqiLevel.unhealthy,
      200: AqiLevel.unhealthy,
      201: AqiLevel.veryUnhealthy,
      500: AqiLevel.veryUnhealthy,
    };
    final wrong = <String>[];
    expected.forEach((aqi, level) {
      if (AqiLevel.of(aqi) != level) wrong.add('$aqi -> ${AqiLevel.of(aqi)}, want $level');
    });
    expect(wrong, isEmpty);
  });

  group('MockAirRepository', () {
    const repo = MockAirRepository(latency: Duration.zero);

    test("today's city forecast has the extremes shown in the design", () async {
      final f = await repo.loadForecast(ForecastRange.today);
      expect(f.points, hasLength(24));
      expect((f.min.label, f.min.aqi), ('13', 98));
      expect((f.max.label, f.max.aqi), ('20', 200));
      expect(f.average, 151);
      expect(f.nowIndex, 10);
      expect(f.points[10].aqi, 151);
    });

    test('a polluted district has a higher forecast than the city, a clean one lower', () async {
      final city = await repo.loadForecast(ForecastRange.today);
      final auezov = await repo.loadForecast(ForecastRange.today, districtId: 'auezov');
      final medeu = await repo.loadForecast(ForecastRange.today, districtId: 'medeu');
      expect(auezov.average, greaterThan(city.average));
      expect(medeu.average, lessThan(city.average));
    });

    test('week forecast has one bar per weekday', () async {
      final f = await repo.loadForecast(ForecastRange.week);
      expect(f.points.map((p) => p.label), ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']);
      expect(f.nowIndex, isNull);
    });

    test('Auezov district carries the values from the district card design', () async {
      final snapshot = await repo.loadSnapshot();
      final d = snapshot.districtById('auezov');
      expect((d.aqi, d.pm25, d.pm10, d.no2), (205, 155, 198, 41));
      expect(d.level, AqiLevel.veryUnhealthy);
      expect(snapshot.districts, hasLength(8));
    });
  });
}
