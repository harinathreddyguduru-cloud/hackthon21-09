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
  final bool isMock;
  final String? demoScenario;
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
    required this.isMock,
    this.demoScenario,
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
      isMock: json['is_mock'] ?? false,
      demoScenario: json['demo_scenario'],
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
  final String day;
  final String condition;
  final int high;
  final int low;
  final int rainChance;

  DailyForecast({
    required this.day,
    required this.condition,
    required this.high,
    required this.low,
    required this.rainChance,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      day: json['day'] ?? '',
      condition: json['condition'] ?? '',
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
