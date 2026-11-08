import 'package:air_almaty/data/air_repository.dart';
import 'package:air_almaty/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(900, 1800);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    const AirAlmatyApp(repository: MockAirRepository(latency: Duration.zero)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('map shows city summary, every district and my district', (tester) async {
    await pumpApp(tester);

    expect(find.text('Алматы · среднее по городу · 10:00'), findsOneWidget);
    for (final name in [
      'Алатауский', 'Жетысуский', 'Турксибский', 'Ауэзовский',
      'Алмалинский', 'Медеуский', 'Бостандыкский', 'Наурызбайский', //
    ]) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
    expect(find.text('Мой район · Ауэзовский'), findsOneWidget);
  });

  testWidgets('tapping a district opens its card with PM values and advice', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Медеуский'));
    await tester.pumpAndSettle();

    expect(find.text('Медеуский район'), findsOneWidget);
    expect(find.text('AQI (US EPA)'), findsOneWidget);
    expect(find.text('22'), findsOneWidget); // PM2.5 of Medeu
    expect(find.text('Источник: IQAir · обновлено 10:00'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Медеуский район'), findsNothing);
  });

  testWidgets('"Прогноз →" opens the forecast filtered to that district', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Алатауский'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Прогноз →'));
    await tester.pumpAndSettle();

    expect(find.text('AQI по часам'), findsOneWidget);
    // The dropdown shows the district we came from, not "Весь город".
    expect(find.textContaining('Алатауский', findRichText: true), findsOneWidget);
    expect(find.textContaining('Весь город', findRichText: true), findsNothing);
  });

  testWidgets('"Почему грязно? →" opens the causes tab', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Ауэзовский').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Почему грязно? →'));
    await tester.pumpAndSettle();

    expect(find.text('5 главных причин зимнего смога'), findsOneWidget);
    expect(find.text('Отопительный сезон'), findsOneWidget);
    expect(find.text('Главный'), findsOneWidget);
  });

  testWidgets('forecast tabs recompute chart, stats and the walk tip', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Прогноз').last);
    await tester.pumpAndSettle();

    // Today, whole city: numbers from the design.
    expect(find.text('Сейчас 10:00 · 151'), findsOneWidget);
    expect(find.textContaining('12:00–15:00 · AQI около 100'), findsOneWidget);
    expect(find.textContaining('после 18:00 лучше остаться дома'), findsOneWidget);

    await tester.tap(find.text('7 дней'));
    await tester.pumpAndSettle();
    expect(find.text('AQI по дням'), findsOneWidget);
    expect(find.text('Лучший день для прогулок'), findsOneWidget);
    expect(find.text('Сейчас 10:00 · 151'), findsNothing);
  });

  testWidgets('changing "Мой район" updates the map card', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Ещё'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Мой район'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Медеуский район'));
    await tester.pumpAndSettle();
    expect(find.text('Медеуский'), findsOneWidget); // value of the settings row

    await tester.tap(find.text('Карта'));
    await tester.pumpAndSettle();
    expect(find.text('Мой район · Медеуский'), findsOneWidget);
    expect(find.text('Мой район · Ауэзовский'), findsNothing);
  });

  testWidgets('units setting switches the map badges to PM2.5', (tester) async {
    await pumpApp(tester);
    expect(find.text('205'), findsWidgets); // map badge + "Мой район" card

    await tester.tap(find.text('Ещё'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Единицы'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PM2.5, мкг/м³'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Карта'));
    await tester.pumpAndSettle();
    expect(find.text('205'), findsNothing);
    expect(find.text('155'), findsWidgets); // Auezov PM2.5 on the badge
  });

  testWidgets('notification toggle flips and the widget preview opens', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Ещё'));
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await tester.tap(find.text('Виджет на экран'));
    await tester.pumpAndSettle();
    expect(find.text('Прогноз на сегодня'), findsOneWidget);
    expect(find.text('156'), findsOneWidget);
  });
}
