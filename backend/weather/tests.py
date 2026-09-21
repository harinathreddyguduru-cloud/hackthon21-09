from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from weather.services.weather_api import WeatherAPIService
from weather.services.alert_engine import AlertEngineService

class WeatherAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_wmo_code_conversion(self):
        clear = WeatherAPIService._convert_wmo_code(0)
        self.assertEqual(clear["condition"], "Clear sky")
        self.assertEqual(clear["icon"], "☀️")

        rain = WeatherAPIService._convert_wmo_code(63)
        self.assertEqual(rain["condition"], "Moderate rain")
        self.assertEqual(rain["icon"], "🌧️")

    def test_open_meteo_live_fetch(self):
        # Fetch real weather for Guntur lat/lon
        weather = WeatherAPIService.get_weather("Guntur", lat=16.3067, lon=80.4365, demo_mode="live")
        self.assertIn("temperature", weather)
        self.assertIn("humidity", weather)
        self.assertEqual(weather["provider"], "Open-Meteo")

    def test_geocoding_city_search(self):
        results = WeatherAPIService.geocode_city("Hyderabad")
        self.assertTrue(len(results) > 0)
        self.assertEqual(results[0]["name"], "Hyderabad")
        self.assertIn("lat", results[0])

    def test_alert_engine_with_real_data(self):
        weather = WeatherAPIService.get_weather("Guntur", lat=16.3067, lon=80.4365, demo_mode="live")
        alerts = AlertEngineService.analyze_alerts(weather)
        self.assertIn("has_alerts", alerts)
        self.assertIn("alerts", alerts)

    def test_ask_endpoint_with_real_data(self):
        url = reverse('weather-ask')
        data = {'location': 'Guntur', 'query': 'Will it rain today?', 'lat': 16.3067, 'lon': 80.4365, 'demo_mode': 'live'}
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('answer', response.data)
