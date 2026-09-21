import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Demo Control'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'PREFERENCES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 10),

          // Temperature Unit Selector
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightSkyBlue),
            ),
            child: ListTile(
              title: const Text('Temperature Unit', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                provider.temperatureUnit == 'C' ? 'Celsius (°C)' : 'Fahrenheit (°F)',
                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
              trailing: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'C', label: Text('°C')),
                  ButtonSegment(value: 'F', label: Text('°F')),
                ],
                selected: {provider.temperatureUnit},
                onSelectionChanged: (set) => provider.setTemperatureUnit(set.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? AppColors.primarySkyBlue
                        : AppColors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notifications Toggle
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightSkyBlue),
            ),
            child: SwitchListTile(
              title: const Text('Weather Alert Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text(
                'Receive local alerts for rain, heat, and strong winds',
                style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
              value: true,
              activeColor: AppColors.primarySkyBlue,
              onChanged: (val) {},
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'WEATHER PROVIDER & DEMO MODE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Switch between live real weather data and hackathon alert scenarios:',
            style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 12),

          _buildScenarioTile(
            context: context,
            provider: provider,
            id: 'live',
            title: '🌐 Live Open-Meteo Weather',
            subtitle: 'Fetches real-time weather & 7-day forecast from Open-Meteo API',
          ),
          _buildScenarioTile(
            context: context,
            provider: provider,
            id: 'normal',
            title: '☀️ Normal Weather Scenario',
            subtitle: '29°C • Partly Cloudy • 20% Rain Chance',
          ),
          _buildScenarioTile(
            context: context,
            provider: provider,
            id: 'rain',
            title: '🌧️ Heavy Rain Alert Scenario',
            subtitle: '27°C • Heavy Rain • 85% Rain Chance (Triggers Rain Alert & Umbrella shop assistance)',
          ),
          _buildScenarioTile(
            context: context,
            provider: provider,
            id: 'heat',
            title: '🔥 Heat Alert Scenario',
            subtitle: '38°C • Scorching Sun • 5% Rain Chance (Triggers Heat Alert & Hydration station assistance)',
          ),
          _buildScenarioTile(
            context: context,
            provider: provider,
            id: 'wind',
            title: '💨 Strong Wind Alert Scenario',
            subtitle: '30°C • Gusty Winds • 48 km/h Wind Speed (Triggers Strong Wind Alert)',
          ),

          const SizedBox(height: 28),

          // Backend Connection & Open-Meteo Attribution Badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightSkyBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.dns_outlined, color: AppColors.primarySkyBlue),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Django Backend Active',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Weather data provided by Open-Meteo (Free Non-Commercial API) • Gemini AI • PostgreSQL',
                        style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioTile({
    required BuildContext context,
    required WeatherProvider provider,
    required String id,
    required String title,
    required String subtitle,
  }) {
    final isSelected = provider.demoScenario == id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.lightSkyBlue : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primarySkyBlue : AppColors.lightSkyBlue,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.primarySkyBlue)
            : const Icon(Icons.circle_outlined, color: AppColors.secondaryText),
        onTap: () {
          provider.setDemoScenario(id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to $title'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}
