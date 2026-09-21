import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';

class ForecastList extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  const ForecastList({
    Key? key,
    required this.hourly,
    required this.daily,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);
    final unit = provider.temperatureUnit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title: Hourly Forecast
        const Text(
          "Today's Hourly Forecast",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),

        // Hourly Horizontal ListView
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourly.length,
            itemBuilder: (context, index) {
              final h = hourly[index];
              final isHighRain = h.rainChance >= 50;

              return Container(
                width: 72,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isHighRain ? AppColors.rainBlue.withOpacity(0.1) : AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isHighRain ? AppColors.rainBlue.withOpacity(0.4) : AppColors.softBlue,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      h.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(h.icon, style: const TextStyle(fontSize: 22)),
                    Text(
                      '${provider.convertTemp(h.temp)}°$unit',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // Section Title: 5-Day Forecast
        const Text(
          '5-Day Daily Forecast',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),

        // Daily Forecast Container
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lightSkyBlue, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: daily.map((d) {
              final high = provider.convertTemp(d.high);
              final low = provider.convertTemp(d.low);
              final isRain = d.condition.toLowerCase().contains('rain');

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        d.day,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      isRain ? '🌧️' : '🌤️',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        d.condition,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                    Text(
                      '$high° / $low°$unit',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
