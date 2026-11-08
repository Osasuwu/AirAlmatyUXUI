import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/air_repository.dart';
import 'screens/home_shell.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AirAlmatyApp());
}

class AirAlmatyApp extends StatelessWidget {
  const AirAlmatyApp({super.key, this.repository = const MockAirRepository()});

  final AirRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(repository),
      child: MaterialApp(
        title: 'Air Almaty',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeShell(),
      ),
    );
  }
}
