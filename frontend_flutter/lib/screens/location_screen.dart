import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  final List<Map<String, String>> _popularCities = [
    {'name': 'Guntur', 'state': 'Andhra Pradesh', 'country': 'India'},
    {'name': 'Vijayawada', 'state': 'Andhra Pradesh', 'country': 'India'},
    {'name': 'Hyderabad', 'state': 'Telangana', 'country': 'India'},
    {'name': 'Bengaluru', 'state': 'Karnataka', 'country': 'India'},
    {'name': 'Chennai', 'state': 'Tamil Nadu', 'country': 'India'},
    {'name': 'Mumbai', 'state': 'Maharashtra', 'country': 'India'},
    {'name': 'Delhi', 'state': 'Delhi', 'country': 'India'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchSuggestions('');
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() => _isSearching = true);
    final results = await ApiService.searchCities(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _selectLocation(String locationName) {
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    provider.loadWeather(targetLocation: locationName);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Box
            TextField(
              controller: _searchController,
              onChanged: (val) => _fetchSuggestions(val),
              decoration: InputDecoration(
                hintText: '🔍 Search city...',
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.lightSkyBlue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.lightSkyBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primarySkyBlue, width: 1.5),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _fetchSuggestions('');
                        },
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 16),

            // Use Current Location Button
            InkWell(
              onTap: () {
                final provider = Provider.of<WeatherProvider>(context, listen: false);
                provider.initWeather();
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightSkyBlue,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primarySkyBlue.withOpacity(0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.my_location, color: AppColors.primarySkyBlue, size: 22),
                    SizedBox(width: 12),
                    Text(
                      'Use my current location',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primarySkyBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Popular Cities',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText,
              ),
            ),

            const SizedBox(height: 10),

            // Suggestions List
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primarySkyBlue))
                  : ListView.builder(
                      itemCount: _searchResults.isNotEmpty
                          ? _searchResults.length
                          : _popularCities.length,
                      itemBuilder: (context, index) {
                        final city = _searchResults.isNotEmpty
                            ? _searchResults[index]
                            : _popularCities[index];

                        final name = city['name'] ?? '';
                        final state = city['state'] ?? '';
                        final country = city['country'] ?? 'India';
                        final fullString = state.isNotEmpty ? '$name, $state' : '$name, $country';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.lightSkyBlue.withOpacity(0.8)),
                          ),
                          child: ListTile(
                            leading: const Text('📍', style: TextStyle(fontSize: 18)),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.textDark,
                              ),
                            ),
                            subtitle: Text(
                              fullString,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppColors.secondaryText,
                            ),
                            onTap: () => _selectLocation(fullString),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
