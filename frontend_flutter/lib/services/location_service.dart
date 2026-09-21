import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    const defaultLocation = {
      'granted': true,
      'message': 'Using default location (Guntur, India).',
      'location': 'Guntur, India',
      'lat': 16.3067,
      'lon': 80.4365,
    };

    if (kIsWeb) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 2),
        );
        return {
          'granted': true,
          'message': 'Current location detected.',
          'location': 'Current Location',
          'lat': position.latitude,
          'lon': position.longitude,
        };
      } catch (_) {
        return defaultLocation;
      }
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(const Duration(seconds: 2));
      if (!serviceEnabled) return defaultLocation;

      LocationPermission permission = await Geolocator.checkPermission().timeout(const Duration(seconds: 2));
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(const Duration(seconds: 2));
        if (permission == LocationPermission.denied) return defaultLocation;
      }
      if (permission == LocationPermission.deniedForever) return defaultLocation;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 2),
      );
      return {
        'granted': true,
        'message': 'Current location detected.',
        'location': 'Current Location',
        'lat': position.latitude,
        'lon': position.longitude,
      };
    } catch (_) {
      return defaultLocation;
    }
  }
}
