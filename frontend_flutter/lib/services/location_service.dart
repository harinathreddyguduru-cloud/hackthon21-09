import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        'granted': false,
        'message': 'Location access is off. Search for a city to continue.',
        'location': 'Guntur, India',
        'lat': 16.3067,
        'lon': 80.4365,
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          'granted': false,
          'message': 'Location access is off. Search for a city to continue.',
          'location': 'Guntur, India',
          'lat': 16.3067,
          'lon': 80.4365,
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {
        'granted': false,
        'message': 'Location permission permanently denied. Search for a city to continue.',
        'location': 'Guntur, India',
        'lat': 16.3067,
        'lon': 80.4365,
      };
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
      return {
        'granted': true,
        'message': 'Current location detected successfully.',
        'location': 'Current Location',
        'lat': position.latitude,
        'lon': position.longitude,
      };
    } catch (e) {
      return {
        'granted': true,
        'message': 'Using default location (Guntur, India).',
        'location': 'Guntur, India',
        'lat': 16.3067,
        'lon': 80.4365,
      };
    }
  }
}
