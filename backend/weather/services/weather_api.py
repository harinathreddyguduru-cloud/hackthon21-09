import os
import requests
from django.conf import settings

class WeatherAPIService:
    """
    Open-Meteo Real Weather & Geocoding Service with Hackathon Demo Engine.
    
    Provides real weather observations and 7-day forecasts from Open-Meteo API
    for Live Weather mode, and simulated demo scenarios for Hackathon presentations.
    Both modes pass through the exact same Django Alert Engine.
    """

    WMO_CODES = {
        0: {"condition": "Clear sky", "code": "Clear", "icon": "☀️"},
        1: {"condition": "Mainly clear", "code": "Clouds", "icon": "🌤️"},
        2: {"condition": "Partly cloudy", "code": "Clouds", "icon": "⛅"},
        3: {"condition": "Overcast", "code": "Clouds", "icon": "☁️"},
        45: {"condition": "Fog", "code": "Clouds", "icon": "🌫️"},
        48: {"condition": "Depositing rime fog", "code": "Clouds", "icon": "🌫️"},
        51: {"condition": "Light drizzle", "code": "Rain", "icon": "🌧️"},
        53: {"condition": "Moderate drizzle", "code": "Rain", "icon": "🌧️"},
        55: {"condition": "Dense drizzle", "code": "Rain", "icon": "🌧️"},
        56: {"condition": "Light freezing drizzle", "code": "Rain", "icon": "🌧️"},
        57: {"condition": "Dense freezing drizzle", "code": "Rain", "icon": "🌧️"},
        61: {"condition": "Slight rain", "code": "Rain", "icon": "🌧️"},
        63: {"condition": "Moderate rain", "code": "Rain", "icon": "🌧️"},
        65: {"condition": "Heavy rain", "code": "Rain", "icon": "🌧️"},
        66: {"condition": "Light freezing rain", "code": "Rain", "icon": "🌧️"},
        67: {"condition": "Heavy freezing rain", "code": "Rain", "icon": "🌧️"},
        71: {"condition": "Slight snow fall", "code": "Snow", "icon": "❄️"},
        73: {"condition": "Moderate snow fall", "code": "Snow", "icon": "❄️"},
        75: {"condition": "Heavy snow fall", "code": "Snow", "icon": "❄️"},
        77: {"condition": "Snow grains", "code": "Snow", "icon": "❄️"},
        80: {"condition": "Slight rain showers", "code": "Rain", "icon": "🌧️"},
        81: {"condition": "Moderate rain showers", "code": "Rain", "icon": "🌧️"},
        82: {"condition": "Violent rain showers", "code": "Rain", "icon": "🌧️"},
        85: {"condition": "Slight snow showers", "code": "Snow", "icon": "❄️"},
        86: {"condition": "Heavy snow showers", "code": "Snow", "icon": "❄️"},
        95: {"condition": "Thunderstorm", "code": "Rain", "icon": "⛈️"},
        96: {"condition": "Thunderstorm with slight hail", "code": "Rain", "icon": "🌩️"},
        99: {"condition": "Thunderstorm with heavy hail", "code": "Rain", "icon": "🌩️"},
    }

    @staticmethod
    def get_weather(location_name="Guntur, India", lat=None, lon=None, demo_mode=None):
        """
        Main entry point for weather retrieval.
        - If demo_mode is 'normal', 'rain', 'heat', or 'wind': returns simulated demo data.
        - Otherwise (demo_mode is None or 'live'): fetches real weather data from Open-Meteo API.
        """
        demo = (demo_mode or '').lower()
        if demo in ['normal', 'rain', 'heat', 'wind']:
            return WeatherAPIService._get_mock_weather(location_name, demo)

        # Default fallback coordinates for Guntur if not supplied
        if lat is None or lon is None:
            geo = WeatherAPIService.geocode_city(location_name)
            if geo:
                lat = geo[0]['lat']
                lon = geo[0]['lon']
                location_name = geo[0]['name']
            else:
                lat, lon = 16.3067, 80.4365

        try:
            return WeatherAPIService.fetch_open_meteo_weather(lat, lon, location_name)
        except Exception as e:
            print(f"Open-Meteo API fetch failed ({e}). Returning live fallback.")
            return WeatherAPIService.fetch_open_meteo_weather(16.3067, 80.4365, "Guntur")

    @staticmethod
    def fetch_open_meteo_weather(lat, lon, location_name):
        base_url = settings.OPEN_METEO_BASE_URL
        url = f"{base_url}/forecast"
        
        params = {
            "latitude": lat,
            "longitude": lon,
            "current": "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,weather_code,wind_speed_10m,wind_direction_10m",
            "hourly": "temperature_2m,relative_humidity_2m,precipitation_probability,precipitation,rain,weather_code,wind_speed_10m,wind_direction_10m",
            "daily": "weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,precipitation_probability_max,precipitation_sum,rain_sum,wind_speed_10m_max,sunrise,sunset",
            "timezone": "auto",
            "forecast_days": 7
        }
        
        resp = requests.get(url, params=params, timeout=5)
        if resp.status_code != 200:
            raise ValueError(f"Open-Meteo error status code {resp.status_code}")

        data = resp.json()
        return WeatherAPIService._normalize_open_meteo(data, location_name, lat, lon)

    @staticmethod
    def geocode_city(query):
        """
        Geocodes a city query using Open-Meteo Geocoding API.
        """
        if not query or len(query.strip()) == 0:
            return []

        base_url = settings.OPEN_METEO_GEOCODING_URL
        url = f"{base_url}/search"
        clean_q = query.split(',')[0].strip()

        params = {
            "name": clean_q,
            "count": 8,
            "language": "en",
            "format": "json"
        }

        try:
            resp = requests.get(url, params=params, timeout=4)
            if resp.status_code == 200:
                raw_results = resp.json().get('results', [])
                results = []
                for r in raw_results:
                    name = r.get('name', clean_q)
                    admin1 = r.get('admin1', '')
                    country = r.get('country', '')
                    results.append({
                        "name": name,
                        "state": admin1,
                        "country": country,
                        "lat": r.get('latitude'),
                        "lon": r.get('longitude'),
                    })
                return results
        except Exception as e:
            print(f"Open-Meteo Geocoding error: {e}")

        return []

    @staticmethod
    def _normalize_open_meteo(data, location_name, lat, lon):
        current = data.get('current', {})
        hourly_data = data.get('hourly', {})
        daily_data = data.get('daily', {})

        temp = round(current.get('temperature_2m', 28))
        feels_like = round(current.get('apparent_temperature', temp))
        humidity = round(current.get('relative_humidity_2m', 70))
        wind_speed = round(current.get('wind_speed_10m', 10))
        wind_direction = round(current.get('wind_direction_10m', 180))
        precipitation = current.get('precipitation', 0)
        weather_code = current.get('weather_code', 0)

        wmo_info = WeatherAPIService._convert_wmo_code(weather_code)
        condition = wmo_info['condition']
        condition_code = wmo_info['code']

        hourly_probs = hourly_data.get('precipitation_probability', [])
        rain_prob = hourly_probs[0] if hourly_probs else (80 if precipitation > 0 else 20)

        # Build 6-period hourly forecast
        hourly_times = hourly_data.get('time', [])
        hourly_temps = hourly_data.get('temperature_2m', [])
        hourly_codes = hourly_data.get('weather_code', [])
        
        hourly_forecast = []
        for i in range(min(6, len(hourly_times))):
            h_time_str = hourly_times[i]
            time_part = h_time_str.split('T')[-1][:5] if 'T' in h_time_str else h_time_str
            try:
                hour = int(time_part.split(':')[0])
                am_pm = "AM" if hour < 12 else "PM"
                disp_hour = hour % 12
                disp_hour = 12 if disp_hour == 0 else disp_hour
                formatted_time = f"{disp_hour} {am_pm}"
            except Exception:
                formatted_time = time_part

            code_i = hourly_codes[i] if i < len(hourly_codes) else 0
            wmo_i = WeatherAPIService._convert_wmo_code(code_i)
            prob_i = hourly_probs[i] if i < len(hourly_probs) else 10

            hourly_forecast.append({
                "time": formatted_time,
                "temp": round(hourly_temps[i]) if i < len(hourly_temps) else temp,
                "icon": wmo_i['icon'],
                "rain_chance": prob_i
            })

        # Build 5-day daily forecast
        daily_times = daily_data.get('time', [])
        daily_max = daily_data.get('temperature_2m_max', [])
        daily_min = daily_data.get('temperature_2m_min', [])
        daily_codes = daily_data.get('weather_code', [])
        daily_probs = daily_data.get('precipitation_probability_max', [])

        days_labels = ["Today", "Tomorrow", "Day 3", "Day 4", "Day 5"]
        daily_forecast = []
        for i in range(min(5, len(daily_times))):
            d_code = daily_codes[i] if i < len(daily_codes) else 0
            d_wmo = WeatherAPIService._convert_wmo_code(d_code)
            d_prob = daily_probs[i] if i < len(daily_probs) else 15

            daily_forecast.append({
                "day": days_labels[i] if i < len(days_labels) else daily_times[i],
                "condition": d_wmo['condition'],
                "high": round(daily_max[i]) if i < len(daily_max) else temp + 2,
                "low": round(daily_min[i]) if i < len(daily_min) else temp - 4,
                "rain_chance": d_prob
            })

        clean_location = location_name.split(',')[0].strip()

        return {
            "location": clean_location if clean_location else "Current Location",
            "country": "IN",
            "latitude": lat,
            "longitude": lon,
            "temperature": temp,
            "feels_like": feels_like,
            "condition": condition,
            "condition_code": condition_code,
            "humidity": humidity,
            "wind_speed": wind_speed,
            "wind_direction": wind_direction,
            "rain_probability": rain_prob,
            "precipitation": precipitation,
            "weather_code": weather_code,
            "uv_index": 5,
            "is_demo": False,
            "weather_source": "open_meteo",
            "mode_label": "🟢 LIVE WEATHER",
            "mode_subtitle": "Real weather data from Open-Meteo",
            "provider": "Open-Meteo",
            "hourly_forecast": hourly_forecast,
            "daily_forecast": daily_forecast
        }

    @staticmethod
    def _convert_wmo_code(code):
        return WeatherAPIService.WMO_CODES.get(
            code,
            {"condition": "Partly cloudy", "code": "Clouds", "icon": "🌤️"}
        )

    @staticmethod
    def _get_mock_weather(location_name, mode="normal"):
        mode = (mode or "normal").lower()
        scenarios = {
            "normal": {
                "temperature": 29, "feels_like": 31, "condition": "Partly Cloudy",
                "condition_code": "Clouds", "humidity": 72, "wind_speed": 14,
                "rain_probability": 20, "uv_index": 6,
                "label": "Demo: Normal Weather",
                "subtitle": "Simulated normal weather scenario"
            },
            "rain": {
                "temperature": 26, "feels_like": 27, "condition": "Heavy Rain",
                "condition_code": "Rain", "humidity": 92, "wind_speed": 18,
                "rain_probability": 85, "uv_index": 2,
                "label": "Demo: Rain Alert",
                "subtitle": "Simulated rain alert for hackathon demonstration"
            },
            "heat": {
                "temperature": 38, "feels_like": 42, "condition": "Hot / Scorching Sun",
                "condition_code": "Clear", "humidity": 40, "wind_speed": 8,
                "rain_probability": 5, "uv_index": 10,
                "label": "Demo: Heat Alert",
                "subtitle": "Simulated heat alert for hackathon demonstration"
            },
            "wind": {
                "temperature": 30, "feels_like": 32, "condition": "Strong Gusty Winds",
                "condition_code": "Wind", "humidity": 65, "wind_speed": 45,
                "rain_probability": 35, "uv_index": 5,
                "label": "Demo: Strong Wind Alert",
                "subtitle": "Simulated wind alert for hackathon demonstration"
            }
        }
        
        data = scenarios.get(mode, scenarios["normal"])
        clean_name = location_name.split(',')[0].strip()
        
        return {
            "location": clean_name if clean_name else "Guntur",
            "country": "IN",
            "latitude": 16.3067,
            "longitude": 80.4365,
            "temperature": data["temperature"],
            "feels_like": data["feels_like"],
            "condition": data["condition"],
            "condition_code": data["condition_code"],
            "humidity": data["humidity"],
            "wind_speed": data["wind_speed"],
            "wind_direction": 180,
            "rain_probability": data["rain_probability"],
            "precipitation": 5.0 if mode == "rain" else 0.0,
            "weather_code": 63 if mode == "rain" else 0,
            "uv_index": data["uv_index"],
            "is_demo": True,
            "demo_scenario": mode,
            "weather_source": "demo",
            "mode_label": "🟠 DEMO MODE",
            "mode_subtitle": data["subtitle"],
            "provider": f"Simulated ({data['label']})",
            "hourly_forecast": WeatherAPIService._generate_hourly_forecast(data["temperature"], data["condition_code"]),
            "daily_forecast": WeatherAPIService._generate_daily_forecast(data["temperature"], data["condition_code"])
        }

    @staticmethod
    def _generate_hourly_forecast(base_temp, condition):
        hours = ["10 AM", "12 PM", "2 PM", "4 PM", "6 PM", "8 PM"]
        icons = ["☀️", "🌤️", "🌧️", "🌧️", "⛅", "🌙"] if "Rain" in condition else ["☀️", "☀️", "🌤️", "🌤️", "⛅", "🌙"]
        probs = [15, 30, 75, 80, 45, 20] if "Rain" in condition else [5, 10, 15, 20, 10, 5]
        return [
            {"time": hours[i], "temp": base_temp + (i % 3) - 1, "icon": icons[i], "rain_chance": probs[i]}
            for i in range(len(hours))
        ]

    @staticmethod
    def _generate_daily_forecast(base_temp, condition):
        days = ["Today", "Tomorrow", "Wednesday", "Thursday", "Friday"]
        conditions = [condition, "Light Rain", "Partly Cloudy", "Sunny", "Clear Sky"]
        return [
            {"day": days[i], "condition": conditions[i], "high": base_temp + i - 1, "low": base_temp - 5, "rain_chance": 80 if "Rain" in conditions[i] else 15}
            for i in range(5)
        ]
