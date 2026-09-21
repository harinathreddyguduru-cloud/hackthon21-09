import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/weather_card.dart';
import '../widgets/alert_banner.dart';
import '../widgets/ai_summary_card.dart';
import '../widgets/forecast_list.dart';
import '../widgets/nearby_assistance_widget.dart';
import '../widgets/mode_indicator.dart';
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
              return _buildLoadingState(provider);
            }

            if (provider.hasError) {
              return _buildErrorState(context, provider);
            }

            final weather = provider.weatherData;
            final alerts = provider.alertsSummary;

            if (weather == null) {
              return _buildLoadingState(provider);
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
                    // Top Bar: Location + Notifications + Settings
                    _buildTopAppBar(context, provider),

                    const SizedBox(height: 16),

                    // Separate Live vs Demo Mode Switcher Bar
                    _buildModeSwitcherSection(context, provider),

                    const SizedBox(height: 16),

                    // Clear Mode Indicator (🟢 LIVE WEATHER vs 🟠 DEMO MODE)
                    ModeIndicator(
                      isDemo: weather.isDemo,
                      label: weather.modeLabel,
                      subtitle: weather.modeSubtitle,
                    ),

                    const SizedBox(height: 16),

                    // 1. Weather Card (Temperature, Condition, Metrics)
                    WeatherCard(weather: weather),

                    const SizedBox(height: 18),

                    // 2. Smart Weather Alerts Banner
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

  Widget _buildModeSwitcherSection(BuildContext context, WeatherProvider provider) {
    final isLive = provider.demoScenario == 'live';

    final demoScenarios = [
      {'id': 'normal', 'label': 'Normal'},
      {'id': 'rain', 'label': '🌧️ Rain Alert'},
      {'id': 'heat', 'label': '🔥 Heat Alert'},
      {'id': 'wind', 'label': '💨 Wind Alert'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Weather Button (Primary)
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => provider.setDemoScenario('live'),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isLive ? AppColors.primarySkyBlue : AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isLive ? AppColors.primarySkyBlue : AppColors.lightSkyBlue,
                    ),
                    boxShadow: isLive ? [
                      BoxShadow(color: AppColors.primarySkyBlue.withOpacity(0.3), blurRadius: 6)
                    ] : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '🟢 Live Weather',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isLive ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(Open-Meteo)',
                        style: TextStyle(
                          fontSize: 11,
                          color: isLive ? Colors.white.withOpacity(0.85) : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Grouped Demo Simulations section
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightSkyBlue),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: Text(
                  '🎬 HACKATHON DEMO SIMULATIONS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: demoScenarios.map((item) {
                    final isSelected = provider.demoScenario == item['id'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(item['label']!),
                        selected: isSelected,
                        onSelected: (_) => provider.setDemoScenario(item['id']!),
                        selectedColor: AppColors.warning,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textDark,
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: AppColors.veryLightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? AppColors.warning : AppColors.lightSkyBlue,
                          ),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(WeatherProvider provider) {
    final isLive = provider.demoScenario == 'live';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌤️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const CircularProgressIndicator(color: AppColors.primarySkyBlue),
          const SizedBox(height: 16),
          Text(
            isLive ? 'Fetching live Open-Meteo weather...' : 'Preparing demo simulation...',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isLive ? '📍 Open-Meteo API  •  ☁️ Real Coordinates' : '🎬 Hackathon Demo Scenario Engine',
            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
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
