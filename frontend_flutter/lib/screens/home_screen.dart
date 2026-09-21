import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/weather_card.dart';
import '../widgets/alert_banner.dart';
import '../widgets/ai_summary_card.dart';
import '../widgets/forecast_list.dart';
import '../widgets/nearby_assistance_widget.dart';
import 'location_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<WeatherProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return _buildLoadingState();
            }

            if (provider.hasError) {
              return _buildErrorState(context, provider);
            }

            final weather = provider.weatherData;
            final alerts = provider.alertsSummary;

            if (weather == null) {
              return _buildLoadingState();
            }

            return RefreshIndicator(
              onRefresh: () => provider.loadWeather(),
              color: AppColors.primarySkyBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar: Location + Notification Bell + Settings
                    _buildTopAppBar(context, provider),

                    const SizedBox(height: 16),

                    // Demo Mode / Provider Switcher Bar
                    _buildDemoModeChips(context, provider),

                    const SizedBox(height: 16),

                    // 1. Weather Card (Temperature, Condition, Metrics)
                    WeatherCard(weather: weather),

                    const SizedBox(height: 18),

                    // 2. Smart Weather Alerts Banner (if any)
                    if (alerts != null && alerts.alerts.isNotEmpty)
                      AlertBanner(alert: alerts.alerts.first),

                    const SizedBox(height: 18),

                    // 3. AI WeatherGPT Insight Card
                    AISummaryCard(
                      summary: provider.aiSummary,
                      onAskTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // 4. Forecast Section (Hourly & Daily)
                    ForecastList(
                      hourly: weather.hourlyForecast,
                      daily: weather.dailyForecast,
                    ),

                    const SizedBox(height: 24),

                    // 5. Nearby Assistance (Umbrellas, Shelters, Water)
                    if (alerts != null)
                      NearbyAssistanceWidget(categories: alerts.nearbyAssistance),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context, WeatherProvider provider) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LocationScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightSkyBlue),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primarySkyBlue, size: 20),
                const SizedBox(width: 6),
                Text(
                  provider.currentLocation,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.secondaryText, size: 18),
              ],
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Weather alert notifications active 🔔'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.textDark),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDemoModeChips(BuildContext context, WeatherProvider provider) {
    final scenarios = [
      {'id': 'live', 'label': '🌐 Live Open-Meteo'},
      {'id': 'normal', 'label': '☀️ Normal'},
      {'id': 'rain', 'label': '🌧️ Rain Alert'},
      {'id': 'heat', 'label': '🔥 Heat Alert'},
      {'id': 'wind', 'label': '💨 Wind Alert'},
    ];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: scenarios.length,
        itemBuilder: (context, index) {
          final item = scenarios[index];
          final isSelected = provider.demoScenario == item['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(item['label']!),
              selected: isSelected,
              onSelected: (_) => provider.setDemoScenario(item['id']!),
              selectedColor: AppColors.primarySkyBlue,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textDark,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primarySkyBlue : AppColors.lightSkyBlue,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('🌤️', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          CircularProgressIndicator(color: AppColors.primarySkyBlue),
          SizedBox(height: 16),
          Text(
            'Getting your weather...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '📍 Detecting location  •  ☁️ Fetching Open-Meteo forecast',
            style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WeatherProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📡', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              'Unable to connect',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage.isNotEmpty
                  ? provider.errorMessage
                  : 'Please check your internet connection.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.loadWeather(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
