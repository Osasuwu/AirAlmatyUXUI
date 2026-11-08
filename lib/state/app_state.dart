import 'package:flutter/foundation.dart';

import '../data/air_repository.dart';
import '../data/models.dart';

enum AppTab { map, forecast, causes, more }

enum AirUnits {
  usAqi('US AQI'),
  pm25('PM2.5, мкг/м³');

  const AirUnits(this.label);
  final String label;
}

enum AppLanguage {
  ru('Русский', available: true),
  kk('Қазақша', available: false),
  en('English', available: false);

  const AppLanguage(this.label, {required this.available});
  final String label;
  final bool available;
}

class AppState extends ChangeNotifier {
  AppState(this._repo) {
    refresh();
    _loadForecast();
    _loadCauses();
  }

  final AirRepository _repo;

  AppTab tab = AppTab.map;

  AirSnapshot? snapshot;
  bool loading = true;

  List<Cause> causes = const [];

  String myDistrictId = 'auezov';
  bool notifications = true;
  AirUnits units = AirUnits.usAqi;
  AppLanguage language = AppLanguage.ru;

  ForecastRange forecastRange = ForecastRange.today;

  /// `null` means the whole city.
  String? forecastDistrictId;
  Forecast? forecast;
  bool forecastLoading = true;
  int _forecastRequest = 0;

  District? get myDistrict => snapshot?.districtById(myDistrictId);

  /// Value shown on badges, honouring the selected units.
  int displayValue(District d) => units == AirUnits.usAqi ? d.aqi : d.pm25;

  String get unitsCaption => units == AirUnits.usAqi ? 'AQI' : 'PM2.5';

  void selectTab(AppTab value) {
    if (tab == value) return;
    tab = value;
    notifyListeners();
  }

  Future<void> refresh() async {
    loading = snapshot == null;
    notifyListeners();
    snapshot = await _repo.loadSnapshot();
    loading = false;
    notifyListeners();
  }

  Future<void> _loadCauses() async {
    causes = await _repo.loadCauses();
    notifyListeners();
  }

  Future<void> _loadForecast() async {
    final request = ++_forecastRequest;
    forecastLoading = true;
    notifyListeners();
    final result = await _repo.loadForecast(
      forecastRange,
      districtId: forecastDistrictId,
    );
    // Ignore stale responses when the user switched filters quickly.
    if (request != _forecastRequest) return;
    forecast = result;
    forecastLoading = false;
    notifyListeners();
  }

  void setForecastRange(ForecastRange range) {
    if (range == forecastRange) return;
    forecastRange = range;
    _loadForecast();
  }

  void setForecastDistrict(String? id) {
    if (id == forecastDistrictId) return;
    forecastDistrictId = id;
    _loadForecast();
  }

  /// Opens the forecast tab pre-filtered to a district ("Прогноз →" in the sheet).
  void showForecastFor(String districtId) {
    forecastDistrictId = districtId;
    forecastRange = ForecastRange.today;
    tab = AppTab.forecast;
    _loadForecast();
  }

  void setMyDistrict(String id) {
    if (id == myDistrictId) return;
    myDistrictId = id;
    notifyListeners();
  }

  void setNotifications(bool value) {
    notifications = value;
    notifyListeners();
  }

  void setUnits(AirUnits value) {
    units = value;
    notifyListeners();
  }

  void setLanguage(AppLanguage value) {
    if (!value.available) return;
    language = value;
    notifyListeners();
  }
}
