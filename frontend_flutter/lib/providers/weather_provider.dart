import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

class WeatherProvider extends ChangeNotifier {
  String _currentLocation = 'Guntur, India';
  double? _currentLat = 16.3067;
  double? _currentLon = 80.4365;

  WeatherData? _weatherData;
  AlertsSummary? _alertsSummary;
  String _aiSummary = '';
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _demoScenario = 'live'; // 'live', 'normal', 'rain', 'heat', 'wind'
  String _temperatureUnit = 'C';
  bool _locationPermissionGranted = true;

  // Getters
  String get currentLocation => _currentLocation;
  double? get currentLat => _currentLat;
  double? get currentLon => _currentLon;
  WeatherData? get weatherData => _weatherData;
  AlertsSummary? get alertsSummary => _alertsSummary;
  String get aiSummary => _aiSummary;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String get demoScenario => _demoScenario;
  String get temperatureUnit => _temperatureUnit;
  bool get locationPermissionGranted => _locationPermissionGranted;

  WeatherProvider() {
    initWeather();
  }

  Future<void> initWeather() async {
    _isLoading = true;
    notifyListeners();

    // Check location permission and fetch GPS coordinates
    final locResult = await LocationService.getCurrentLocation();
    _locationPermissionGranted = locResult['granted'] ?? true;
    
    if (locResult['lat'] != null && locResult['lon'] != null) {
      _currentLat = (locResult['lat'] as num).toDouble();
      _currentLon = (locResult['lon'] as num).toDouble();
    }
    if (locResult['location'] != null && locResult['location'] != 'Current Location') {
      _currentLocation = locResult['location'];
    }

    await loadWeather();
  }

  Future<void> loadWeather({String? targetLocation, double? lat, double? lon}) async {
    if (targetLocation != null) {
      _currentLocation = targetLocation;
    }
    if (lat != null && lon != null) {
      _currentLat = lat;
      _currentLon = lon;
    }

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final data = await ApiService.fetchCurrentWeather(
        location: _currentLocation,
        lat: _currentLat,
        lon: _currentLon,
        demoMode: _demoScenario,
      );

      if (data['status'] == 'success' && data['weather'] != null) {
        _weatherData = WeatherData.fromJson(data['weather']);
        if (data['alerts_summary'] != null) {
          _alertsSummary = AlertsSummary.fromJson(data['alerts_summary']);
        }
        _aiSummary = data['ai_summary'] ?? '';

        if (_alertsSummary != null && _alertsSummary!.hasAlerts && _alertsSummary!.alerts.isNotEmpty) {
          final firstAlert = _alertsSummary!.alerts.firstWhere(
            (a) => a.type != 'normal',
            orElse: () => _alertsSummary!.alerts.first,
          );
          NotificationService.triggerAlertNotification(firstAlert, _currentLocation);
        }
      } else {
        final fallback = ApiService._buildLocalFallbackResponse(_currentLocation, _demoScenario);
        _weatherData = WeatherData.fromJson(fallback['weather']);
        _alertsSummary = AlertsSummary.fromJson(fallback['alerts_summary']);
        _aiSummary = fallback['ai_summary'] ?? '';
      }
    } catch (e) {
      print('Weather loading note ($e). Using local fallback model.');
      final fallback = ApiService._buildLocalFallbackResponse(_currentLocation, _demoScenario);
      _weatherData = WeatherData.fromJson(fallback['weather']);
      _alertsSummary = AlertsSummary.fromJson(fallback['alerts_summary']);
      _aiSummary = fallback['ai_summary'] ?? '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDemoScenario(String scenario) async {
    _demoScenario = scenario;
    await loadWeather();
  }

  void setTemperatureUnit(String unit) {
    _temperatureUnit = unit;
    notifyListeners();
  }

  Future<String> askQuestion(String query) async {
    return await ApiService.askWeatherGPT(
      query: query,
      location: _currentLocation,
      lat: _currentLat,
      lon: _currentLon,
      demoMode: _demoScenario,
    );
  }

  int convertTemp(int tempC) {
    if (_temperatureUnit == 'F') {
      return ((tempC * 9 / 5) + 32).round();
    }
    return tempC;
  }
}
