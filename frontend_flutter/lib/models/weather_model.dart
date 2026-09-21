class WeatherData {
  final String location;
  final String country;
  final int temperature;
  final int feelsLike;
  final String condition;
  final String conditionCode;
  final int humidity;
  final int windSpeed;
  final int rainProbability;
  final int uvIndex;
  final bool isDemo;
  final String weatherSource;
  final String modeLabel;
  final String modeSubtitle;
  final String? demoScenario;
  final String provider;
  final int windDirection;
  final String windDirectionCardinal;
  final String uvLabel;
  final Map<String, dynamic> aqi;
  final Map<String, String> sunTrajectory;
  final List<Map<String, dynamic>> lifestyleActivities;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  WeatherData({
    required this.location,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.conditionCode,
    required this.humidity,
    required this.windSpeed,
    required this.rainProbability,
    required this.uvIndex,
    required this.isDemo,
    required this.weatherSource,
    required this.modeLabel,
    required this.modeSubtitle,
    this.demoScenario,
    required this.provider,
    required this.windDirection,
    required this.windDirectionCardinal,
    required this.uvLabel,
    required this.aqi,
    required this.sunTrajectory,
    required this.lifestyleActivities,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['location'] ?? 'Guntur',
      country: json['country'] ?? 'IN',
      temperature: (json['temperature'] as num).toInt(),
      feelsLike: (json['feels_like'] as num).toInt(),
      condition: json['condition'] ?? 'Clear',
      conditionCode: json['condition_code'] ?? 'Clear',
      humidity: (json['humidity'] as num).toInt(),
      windSpeed: (json['wind_speed'] as num).toInt(),
      rainProbability: (json['rain_probability'] as num).toInt(),
      uvIndex: (json['uv_index'] as num).toInt(),
      isDemo: json['is_demo'] ?? (json['is_mock'] ?? false),
      weatherSource: json['weather_source'] ?? (json['is_mock'] == true ? 'demo' : 'open_meteo'),
      modeLabel: json['mode_label'] ?? (json['is_mock'] == true ? '🟠 DEMO MODE' : '🟢 LIVE WEATHER'),
      modeSubtitle: json['mode_subtitle'] ?? (json['is_mock'] == true ? 'Simulated weather scenario' : 'Real weather data from Open-Meteo'),
      demoScenario: json['demo_scenario'],
      provider: json['provider'] ?? 'Open-Meteo',
      windDirection: ((json['wind_direction'] ?? 210) as num).toInt(),
      windDirectionCardinal: json['wind_direction_cardinal'] ?? json['wind_dir'] ?? 'SSW',
      uvLabel: json['uv_label'] ?? 'Strong',
      aqi: json['aqi'] is Map ? Map<String, dynamic>.from(json['aqi']) : {"score": 24, "quality": "Good", "pm25": 24, "pm10": 21, "so2": 7, "co": 2},
      sunTrajectory: json['sun_trajectory'] is Map
          ? (json['sun_trajectory'] as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
          : {"sunrise": "05:59", "sunset": "18:04", "moonrise": "14:33", "moonset": "01:54"},
      lifestyleActivities: json['lifestyle_activities'] is List
          ? (json['lifestyle_activities'] as List).map((i) => Map<String, dynamic>.from(i as Map)).toList()
          : [],
      hourlyForecast: (json['hourly_forecast'] as List? ?? [])
          .map((item) => HourlyForecast.fromJson(item))
          .toList(),
      dailyForecast: (json['daily_forecast'] as List? ?? [])
          .map((item) => DailyForecast.fromJson(item))
          .toList(),
    );
  }
}

class HourlyForecast {
  final String time;
  final int temp;
  final String icon;
  final int rainChance;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.icon,
    required this.rainChance,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'] ?? '',
      temp: (json['temp'] as num).toInt(),
      icon: json['icon'] ?? '☀️',
      rainChance: (json['rain_chance'] as num).toInt(),
    );
  }
}

class DailyForecast {
  final String date;
  final String day;
  final String condition;
  final String icon;
  final int high;
  final int low;
  final int rainChance;

  DailyForecast({
    required this.date,
    required this.day,
    required this.condition,
    required this.icon,
    required this.high,
    required this.low,
    required this.rainChance,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'] ?? json['day'] ?? '09/21',
      day: json['day'] ?? '',
      condition: json['condition'] ?? '',
      icon: json['icon'] ?? '🌤️',
      high: (json['high'] as num).toInt(),
      low: (json['low'] as num).toInt(),
      rainChance: (json['rain_chance'] as num).toInt(),
    );
  }
}

class AlertItem {
  final String id;
  final String type;
  final String severity;
  final String title;
  final String message;
  final String action;
  final String icon;

  AlertItem({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.action,
    required this.icon,
  });

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    return AlertItem(
      id: json['id'] ?? '',
      type: json['type'] ?? 'normal',
      severity: json['severity'] ?? 'info',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      action: json['action'] ?? '',
      icon: json['icon'] ?? 'check',
    );
  }
}

class AlertsSummary {
  final bool hasAlerts;
  final int alertsCount;
  final List<AlertItem> alerts;
  final List<NearbyCategory> nearbyAssistance;

  AlertsSummary({
    required this.hasAlerts,
    required this.alertsCount,
    required this.alerts,
    required this.nearbyAssistance,
  });

  factory AlertsSummary.fromJson(Map<String, dynamic> json) {
    return AlertsSummary(
      hasAlerts: json['has_alerts'] ?? false,
      alertsCount: (json['alerts_count'] as num? ?? 0).toInt(),
      alerts: (json['alerts'] as List? ?? [])
          .map((a) => AlertItem.fromJson(a))
          .toList(),
      nearbyAssistance: (json['nearby_assistance'] as List? ?? [])
          .map((n) => NearbyCategory.fromJson(n))
          .toList(),
    );
  }
}

class NearbyCategory {
  final String category;
  final List<NearbyItem> items;

  NearbyCategory({required this.category, required this.items});

  factory NearbyCategory.fromJson(Map<String, dynamic> json) {
    return NearbyCategory(
      category: json['category'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((i) => NearbyItem.fromJson(i))
          .toList(),
    );
  }
}

class NearbyItem {
  final String name;
  final String type;
  final String distance;

  NearbyItem({required this.name, required this.type, required this.distance});

  factory NearbyItem.fromJson(Map<String, dynamic> json) {
    return NearbyItem(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      distance: json['distance'] ?? '',
    );
  }
}
