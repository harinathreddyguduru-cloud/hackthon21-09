import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/weather';

  static Future<Map<String, dynamic>> fetchCurrentWeather({
    String location = 'Guntur, India',
    double? lat,
    double? lon,
    String? demoMode,
  }) async {
    final queryParams = <String, String>{
      'location': location,
    };
    if (lat != null && lon != null) {
      queryParams['lat'] = lat.toString();
      queryParams['lon'] = lon.toString();
    }
    if (demoMode != null && demoMode.isNotEmpty && demoMode != 'live') {
      queryParams['demo_mode'] = demoMode;
    }

    final uri = Uri.parse('$baseUrl/current/').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('API fetch error ($e). Using local fallback response.');
    }

    // Local fallback if server unreachable
    return _buildLocalFallbackResponse(location, demoMode);
  }

  static Future<String> askWeatherGPT({
    required String query,
    required String location,
    double? lat,
    double? lon,
    String? demoMode,
  }) async {
    final uri = Uri.parse('$baseUrl/ask/');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'query': query,
          'location': location,
          'lat': lat,
          'lon': lon,
          'demo_mode': demoMode,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['answer'] ?? 'WeatherGPT answer generated successfully.';
      }
    } catch (e) {
      print('API Ask error: $e');
    }

    // Local fallback AI answer
    if (query.toLowerCase().contains('rain') || query.toLowerCase().contains('umbrella')) {
      return "🌧️ Rain is possible in $location later today. Carrying an umbrella is a wise idea if heading outdoors!";
    }
    return "🌤️ Currently in $location, weather conditions are manageable. Stay prepared and check forecasts before traveling!";
  }

  static Future<List<Map<String, dynamic>>> searchCities(String query) async {
    final uri = Uri.parse('$baseUrl/search/').replace(queryParameters: {'q': query});
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      }
    } catch (_) {}

    return [
      {"name": "Guntur", "state": "Andhra Pradesh", "country": "India", "lat": 16.3067, "lon": 80.4365},
      {"name": "Vijayawada", "state": "Andhra Pradesh", "country": "India", "lat": 16.5062, "lon": 80.6480},
      {"name": "Hyderabad", "state": "Telangana", "country": "India", "lat": 17.3850, "lon": 78.4867},
      {"name": "Bengaluru", "state": "Karnataka", "country": "India", "lat": 12.9716, "lon": 77.5946},
      {"name": "Chennai", "state": "Tamil Nadu", "country": "India", "lat": 13.0827, "lon": 80.2707},
    ];
  }

  static Map<String, dynamic> _buildLocalFallbackResponse(String location, String? demoMode) {
    final mode = demoMode ?? 'normal';
    int temp = 29;
    int rain = 20;
    int wind = 14;
    String cond = "Partly Cloudy";

    if (mode == 'rain') {
      temp = 27; rain = 85; wind = 18; cond = "Heavy Rain";
    } else if (mode == 'heat') {
      temp = 38; rain = 5; wind = 8; cond = "Scorching Sun";
    } else if (mode == 'wind') {
      temp = 30; rain = 35; wind = 48; cond = "Strong Winds";
    }

    return {
      "status": "success",
      "weather": {
        "location": location.split(',')[0],
        "country": "IN",
        "temperature": temp,
        "feels_like": temp + 2,
        "condition": cond,
        "condition_code": "Clouds",
        "humidity": 72,
        "wind_speed": wind,
        "rain_probability": rain,
        "uv_index": 6,
        "is_mock": true,
        "provider": "Mock Demo",
        "wind_direction": 210,
        "wind_direction_cardinal": "SSW",
        "uv_label": "Strong",
        "aqi": {"score": 24, "quality": "Good", "pm25": 24, "pm10": 21, "so2": 7, "co": 2},
        "sun_trajectory": {"sunrise": "05:59", "sunset": "18:04", "moonrise": "14:33", "moonset": "01:54"},
        "lifestyle_activities": [
          {"name": "Outdoor activities", "status": "Low suitability", "icon": "biking"},
          {"name": "Stargazing", "status": "Fair", "icon": "satellite"},
          {"name": "Fishing", "status": "Unsuitable", "icon": "fishing"},
          {"name": "Sailing", "status": "Unsuitable", "icon": "sailing"},
          {"name": "Cold risk", "status": "Not Easy", "icon": "pill"},
          {"name": "Mosquito activity", "status": "Extremely High", "icon": "bug"}
        ],
        "hourly_forecast": [
          {"time": "Now", "temp": temp, "icon": "☀️", "rain_chance": rain},
          {"time": "12 PM", "temp": temp + 1, "icon": "🌤️", "rain_chance": rain},
          {"time": "2 PM", "temp": temp, "icon": "🌧️", "rain_chance": rain},
          {"time": "4 PM", "temp": temp - 1, "icon": "🌧️", "rain_chance": rain},
        ],
        "daily_forecast": [
          {"day": "Today", "date": "09/21", "condition": cond, "icon": "🌤️", "high": temp + 2, "low": temp - 4, "rain_chance": rain},
          {"day": "Tomorrow", "date": "09/22", "condition": "Light Rain", "icon": "🌧️", "high": temp, "low": temp - 5, "rain_chance": 60},
          {"day": "Wednesday", "date": "09/23", "condition": "Partly Cloudy", "icon": "⛅", "high": temp + 3, "low": temp - 3, "rain_chance": 15},
        ]
      },
      "alerts_summary": {
        "has_alerts": rain >= 50 || temp >= 35 || wind >= 35,
        "alerts_count": (rain >= 50 ? 1 : 0) + (temp >= 35 ? 1 : 0) + (wind >= 35 ? 1 : 0),
        "alerts": [
          if (rain >= 50)
            {
              "id": "rain_alert",
              "type": "rain",
              "severity": "warning",
              "title": "🌧️ Rain Alert",
              "message": "Rain expected soon ($rain% chance). Carry an umbrella.",
              "action": "Carry umbrella",
              "icon": "rain"
            }
          else if (temp >= 35)
            {
              "id": "heat_alert",
              "type": "heat",
              "severity": "danger",
              "title": "🔥 Heat Alert",
              "message": "High temperature of $temp°C expected today. Stay hydrated.",
              "action": "Stay hydrated",
              "icon": "heat"
            }
          else if (wind >= 35)
            {
              "id": "wind_alert",
              "type": "wind",
              "severity": "warning",
              "title": "💨 Strong Wind Alert",
              "message": "Strong winds of $wind km/h expected. Take care outdoors.",
              "action": "Take care outdoors",
              "icon": "wind"
            }
          else
            {
              "id": "normal",
              "type": "normal",
              "severity": "info",
              "title": "✓ Clear Weather",
              "message": "Weather looks normal right now. Have a pleasant day!",
              "action": "Enjoy your day",
              "icon": "check"
            }
        ],
        "nearby_assistance": [
          {
            "category": "Rain Protection & Convenience",
            "items": [
              {"name": "City Center Supermarket", "type": "Umbrellas & Rainwear", "distance": "350 m"},
              {"name": "Central Metro Station", "type": "Sheltered Transit", "distance": "600 m"}
            ]
          }
        ]
      },
      "ai_summary": rain >= 50
          ? "Rain is expected in $location today ($rain% chance). Remember your umbrella if heading outside!"
          : "Weather in $location is $cond at $temp°C. Conditions are pleasant for routine outdoor plans."
    };
  }
}
