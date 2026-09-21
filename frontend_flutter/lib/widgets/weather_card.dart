import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData weather;

  const WeatherCard({Key? key, required this.weather}) : super(key: key);

  String _getWeatherEmoji(String conditionCode, int temp) {
    final code = conditionCode.toLowerCase();
    if (code.contains('rain')) return '🌧️';
    if (code.contains('cloud')) return '🌤️';
    if (code.contains('clear') || code.contains('sun')) return temp >= 35 ? '☀️' : '🌤️';
    if (code.contains('wind')) return '💨';
    return '☀️';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);
    final tempDisplay = provider.convertTemp(weather.temperature);
    final feelsDisplay = provider.convertTemp(weather.feelsLike);
    final unit = provider.temperatureUnit;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white,
            AppColors.lightSkyBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightSkyBlue, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // Weather emoji icon
          Text(
            _getWeatherEmoji(weather.conditionCode, weather.temperature),
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 8),

          // Main Temperature display
          Text(
            '$tempDisplay°$unit',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),

          // Condition text
          Text(
            weather.condition,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),

          // Feels like text
          Text(
            'Feels like $feelsDisplay°$unit',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),

          // Metrics row (Humidity, Wind Speed, Rain Chance)
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: '💧',
                  value: '${weather.humidity}%',
                  label: 'Humidity',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: '💨',
                  value: '${weather.windSpeed} km/h',
                  label: 'Wind',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: '🌧️',
                  value: '${weather.rainProbability}%',
                  label: 'Rain Chance',
                  highlight: weather.rainProbability >= 50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String icon,
    required String value,
    required String label,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: highlight ? AppColors.rainBlue.withOpacity(0.15) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? AppColors.rainBlue.withOpacity(0.4) : AppColors.softBlue,
        ),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: highlight ? AppColors.rainBlue : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
