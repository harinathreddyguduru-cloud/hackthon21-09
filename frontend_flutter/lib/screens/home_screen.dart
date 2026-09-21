import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/sky_background.dart';
import '../widgets/temp_trend_chart.dart';
import '../widgets/compass_dial.dart';
import '../widgets/sun_arc_widget.dart';
import '../widgets/lifestyle_grid.dart';
import '../widgets/alert_banner.dart';
import '../widgets/ai_summary_card.dart';
import '../widgets/mode_indicator.dart';
import 'location_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final weather = provider.weatherData;
        final conditionCode = weather?.conditionCode ?? 'Clouds';

        return Scaffold(
          body: SkyBackground(
            conditionCode: conditionCode,
            child: SafeArea(
              child: provider.isLoading || weather == null
                  ? _buildLoadingState(provider)
                  : RefreshIndicator(
                      onRefresh: () => provider.loadWeather(),
                      color: Colors.white,
                      backgroundColor: const Color(0xFF327FD2),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 1. Header Bar: Location Title + Menu
                            _buildHeaderBar(context, provider),

                            const SizedBox(height: 12),

                            // Mode Switcher Bar (🟢 LIVE WEATHER vs 🎬 DEMO MODE)
                            _buildModeSwitcherSection(context, provider),

                            const SizedBox(height: 12),

                            // Clear Mode Indicator Banner
                            ModeIndicator(
                              isDemo: weather.isDemo,
                              label: weather.modeLabel,
                              subtitle: weather.modeSubtitle,
                            ),

                            const SizedBox(height: 16),

                            // 2. Hero Weather Header (33°C, Hazy sunshine, Feels like 43°)
                            Text(
                              weather.condition,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '28° ~ 34°   Feels like ${provider.convertTemp(weather.feelsLike)}°',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${provider.convertTemp(weather.temperature)}°',
                              style: const TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.0,
                                shadows: [
                                  Shadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4)),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 3. Hourly Temperature Trend Curve Graph
                            TempTrendChart(hourly: weather.hourlyForecast),

                            const SizedBox(height: 20),

                            // 4. Daily 7-Day Forecast Translucent Glass Card
                            _buildDailyForecastGlassCard(provider, weather.dailyForecast),

                            const SizedBox(height: 20),

                            // 5. Active Smart Weather Alerts Banner
                            if (provider.alertsSummary != null && provider.alertsSummary!.alerts.isNotEmpty)
                              AlertBanner(alert: provider.alertsSummary!.alerts.first),

                            const SizedBox(height: 20),

                            // 6. AI WeatherGPT Insight Card
                            AISummaryCard(
                              summary: provider.aiSummary,
                              onAskTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            // 7. 2x2 Glass Metric Cards (Feels like, Wind Compass, Humidity, UV Index)
                            _buildMetricGlassGrid(provider, weather),

                            const SizedBox(height: 20),

                            // 8. Air Quality (AQI Arc Gauge Glass Card)
                            _buildAQIGlassCard(weather),

                            const SizedBox(height: 20),

                            // 9. Sunrise & Sunset Trajectory Curve
                            SunArcWidget(
                              sunrise: weather.sunTrajectory['sunrise'] ?? '05:59',
                              sunset: weather.sunTrajectory['sunset'] ?? '18:04',
                              moonrise: weather.sunTrajectory['moonrise'] ?? '14:33',
                              moonset: weather.sunTrajectory['moonset'] ?? '01:54',
                            ),

                            const SizedBox(height: 20),

                            // 10. Lifestyle Activity Index Grid
                            LifestyleGrid(activities: weather.lifestyleActivities),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderBar(BuildContext context, WeatherProvider provider) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationScreen()));
          },
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Text(
                provider.currentLocation.split(',')[0],
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 22),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.tune, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildModeSwitcherSection(BuildContext context, WeatherProvider provider) {
    final isLive = provider.demoScenario == 'live';

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => provider.setDemoScenario('live'),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isLive ? Colors.white : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🟢 Live Weather',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isLive ? const Color(0xFF183B56) : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: () => provider.setDemoScenario('rain'),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: !isLive ? const Color(0xFFFFB74D) : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🎬 Demo Mode',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: !isLive ? const Color(0xFF183B56) : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecastGlassCard(WeatherProvider provider, dynamic dailyForecast) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: dailyForecast.map<Widget>((d) {
          final isToday = d.day == "Today";
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 55,
                  child: Text(
                    d.date,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                  ),
                ),
                SizedBox(
                  width: 75,
                  child: Text(
                    d.day,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Text(d.icon.isNotEmpty ? d.icon : (d.condition.contains('Rain') ? '🌧️' : '🌤️'), style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                if (d.rainChance > 40)
                  Text('${d.rainChance}%', style: const TextStyle(color: Color(0xFF80C3FF), fontSize: 11, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  '${provider.convertTemp(d.low)}°  ${provider.convertTemp(d.high)}°',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricGlassGrid(WeatherProvider provider, dynamic weather) {
    return Column(
      children: [
        Row(
          children: [
            // Feels Like
            Expanded(
              child: _buildGlassBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Feels like', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        Icon(Icons.thermostat_outlined, color: Colors.white, size: 16),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: const LinearGradient(colors: [Color(0xFF4DA8FF), Color(0xFFFFB74D), Color(0xFFEF5350)]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('${provider.convertTemp(weather.feelsLike)} °C', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(weather.feelsLike >= 38 ? 'Extremely hot' : 'Pleasant', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Wind Compass Dial
            Expanded(
              child: _buildGlassBox(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(weather.windDirectionCardinal ?? 'SSW', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        const Icon(Icons.air, color: Colors.white, size: 16),
                      ],
                    ),
                    const SizedBox(height: 6),
                    CompassDial(
                      degrees: weather.windDirection ?? 210,
                      cardinal: weather.windDirectionCardinal ?? 'SSW',
                      speed: weather.windSpeed ?? 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Humidity
            Expanded(
              child: _buildGlassBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Humidity', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        Icon(Icons.water_drop_outlined, color: Colors.white, size: 16),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('${weather.humidity} %', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Moderate', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // UV Index
            Expanded(
              child: _buildGlassBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('UV', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 16),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: const LinearGradient(colors: [Colors.green, Colors.yellow, Colors.orange, Colors.purple]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Level ${weather.uvIndex}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(weather.uvLabel ?? 'Strong', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAQIGlassCard(dynamic weather) {
    final aqi = weather.aqi ?? {"score": 24, "quality": "Good", "pm25": 24, "pm10": 21, "so2": 7, "co": 2};

    return _buildGlassBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Air quality', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              Icon(Icons.nature_outlined, color: Colors.white, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // AQI Arc score
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.greenAccent, width: 3),
                ),
                child: Column(
                  children: [
                    Text('Good', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                    Text('${aqi['score']}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Pollutants breakdown
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPollutant('PM2.5', aqi['pm25']),
                    _buildPollutant('PM10', aqi['pm10']),
                    _buildPollutant('SO2', aqi['so2']),
                    _buildPollutant('CO', aqi['co']),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollutant(String label, dynamic val) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
        const SizedBox(height: 2),
        Text('$val', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGlassBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: child,
    );
  }

  Widget _buildLoadingState(WeatherProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('🌤️', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Fetching WeatherGPT 3D Sky environment...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
