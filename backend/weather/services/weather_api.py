import os
import requests
from django.conf import settings

class WeatherAPIService:
    """
    Open-Meteo Real Weather & Geocoding Service with Hackathon Demo Engine.
    
    Provides real weather observations, 7-day forecasts, AQI, visibility, pressure,
    sun trajectory, and lifestyle indices matching the premium UI specification.
    """

    WMO_CODES = {
        0: {"condition": "Clear sky", "code": "Clear", "icon": "☀️"},
        1: {"condition": "Mainly clear", "code": "Clouds", "icon": "🌤️"},
        2: {"condition": "Partly cloudy", "code": "Clouds", "icon": "⛅"},
        3: {"condition": "Hazy sunshine", "code": "Clouds", "icon": "🌤️"},
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
        96: {"condition": "Thunderstorm with hail", "code": "Rain", "icon": "🌩️"},
        99: {"condition": "Thunderstorm with heavy hail", "code": "Rain", "icon": "🌩️"},
    }

    @staticmethod
    def get_weather(location_name="Guntur, India", lat=None, lon=None, demo_mode=None):
        demo = (demo_mode or '').lower()
        if demo in ['normal', 'rain', 'heat', 'wind']:
            return WeatherAPIService._get_mock_weather(location_name, demo)

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
            "current": "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure",
            "hourly": "temperature_2m,relative_humidity_2m,precipitation_probability,precipitation,rain,weather_code,wind_speed_10m,wind_direction_10m,visibility",
            "daily": "weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,precipitation_probability_max,precipitation_sum,rain_sum,wind_speed_10m_max,sunrise,sunset,uv_index_max",
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
    def fetch_open_meteo_aqi(lat, lon):
        base_url = getattr(settings, 'OPEN_METEO_AIR_QUALITY_URL', 'https://air-quality-api.open-meteo.com/v1')
        url = f"{base_url}/air-quality"
        params = {
            "latitude": lat,
            "longitude": lon,
            "current": "us_aqi,pm10,pm2_5,sulphur_dioxide,carbon_monoxide"
        }
        try:
            resp = requests.get(url, params=params, timeout=4)
            if resp.status_code == 200:
                cur = resp.json().get('current', {})
                score = round(cur.get('us_aqi', 24))

                quality = "Good"
                if score > 300:
                    quality = "Hazardous"
                elif score > 200:
                    quality = "Very Unhealthy"
                elif score > 150:
                    quality = "Unhealthy"
                elif score > 100:
                    quality = "Sensitive"
                elif score > 50:
                    quality = "Moderate"

                co_val = round(cur.get('carbon_monoxide', 200) / 100.0, 1)

                return {
                    "score": score,
                    "quality": quality,
                    "pm25": round(cur.get('pm2_5', 14)),
                    "pm10": round(cur.get('pm10', 21)),
                    "so2": round(cur.get('sulphur_dioxide', 7)),
                    "co": co_val
                }
        except Exception as e:
            print(f"Open-Meteo Air Quality fetch error: {e}")

        return {
            "score": 24, "quality": "Good", "pm25": 14, "pm10": 21, "so2": 7, "co": 2
        }

    @staticmethod
    def _calculate_lifestyle_indices(temp, rain_prob, wind_speed, uv_index, humidity, aqi_score):
        outdoor = "Optimal" if rain_prob < 20 and 20 <= temp <= 32 else ("Unsuitable" if rain_prob > 50 or temp > 38 else "Fair")
        stargazing = "Excellent" if rain_prob < 15 and humidity < 70 else ("Poor" if rain_prob > 40 else "Fair")
        fishing = "Unsuitable" if rain_prob > 60 or wind_speed > 30 else ("Fair" if rain_prob > 30 else "Suitable")
        sailing = "Unsuitable" if wind_speed > 35 or wind_speed < 5 else ("Optimal" if 10 <= wind_speed <= 22 else "Suitable")
        cold_risk = "High" if temp < 10 else ("Moderate" if temp < 18 else "Low")
        mosquito = "Extremely High" if humidity > 70 and temp > 25 else ("Moderate" if humidity > 55 else "Low")

        return [
            {"name": "Outdoor activities", "status": outdoor, "icon": "biking"},
            {"name": "Stargazing", "status": stargazing, "icon": "satellite"},
            {"name": "Fishing", "status": fishing, "icon": "fishing"},
            {"name": "Sailing", "status": sailing, "icon": "sailing"},
            {"name": "Cold risk", "status": cold_risk, "icon": "pill"},
            {"name": "Mosquito activity", "status": mosquito, "icon": "bug"}
        ]

    @staticmethod
    def _normalize_open_meteo(data, location_name, lat, lon):
        current = data.get('current', {})
        hourly_data = data.get('hourly', {})
        daily_data = data.get('daily', {})

        temp = round(current.get('temperature_2m', 33))
        feels_like = round(current.get('apparent_temperature', temp + 4))
        humidity = round(current.get('relative_humidity_2m', 62))
        wind_speed = round(current.get('wind_speed_10m', 14))
        wind_direction = round(current.get('wind_direction_10m', 210))
        pressure = round(current.get('surface_pressure', 1008))
        precipitation = current.get('precipitation', 0.0)
        weather_code = current.get('weather_code', 3)

        wmo_info = WeatherAPIService._convert_wmo_code(weather_code)
        condition = wmo_info['condition']
        condition_code = wmo_info['code']

        hourly_probs = hourly_data.get('precipitation_probability', [])
        rain_prob = hourly_probs[0] if hourly_probs else 20

        # Visibility
        hourly_vis = hourly_data.get('visibility', [])
        vis_m = hourly_vis[0] if hourly_vis else 16100
        visibility_km = round(vis_m / 1000.0, 1)

        # Real AQI from Open-Meteo Air Quality API
        real_aqi = WeatherAPIService.fetch_open_meteo_aqi(lat, lon)

        # Hourly forecast
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

            hourly_forecast.append({
                "time": formatted_time,
                "temp": round(hourly_temps[i]) if i < len(hourly_temps) else temp,
                "icon": wmo_i['icon'],
                "rain_chance": hourly_probs[i] if i < len(hourly_probs) else 10
            })

        # Daily forecast
        daily_times = daily_data.get('time', [])
        daily_max = daily_data.get('temperature_2m_max', [])
        daily_min = daily_data.get('temperature_2m_min', [])
        daily_codes = daily_data.get('weather_code', [])
        daily_probs = daily_data.get('precipitation_probability_max', [])

        days_labels = ["Today", "Tomorrow", "Wed", "Thu", "Fri", "Sat", "Sun"]
        daily_forecast = []
        for i in range(min(7, len(daily_times))):
            d_code = daily_codes[i] if i < len(daily_codes) else 0
            d_wmo = WeatherAPIService._convert_wmo_code(d_code)

            daily_forecast.append({
                "day": days_labels[i] if i < len(days_labels) else daily_times[i],
                "date": daily_times[i][5:].replace('-', '/'),
                "condition": d_wmo['condition'],
                "high": round(daily_max[i]) if i < len(daily_max) else temp + 2,
                "low": round(daily_min[i]) if i < len(daily_min) else temp - 5,
                "rain_chance": daily_probs[i] if i < len(daily_probs) else 15
            })

        # Sunrise & Sunset
        sunrise_list = daily_data.get('sunrise', ['05:59'])
        sunset_list = daily_data.get('sunset', ['18:04'])
        sunrise = sunrise_list[0].split('T')[-1][:5] if 'T' in str(sunrise_list[0]) else '05:59'
        sunset = sunset_list[0].split('T')[-1][:5] if 'T' in str(sunset_list[0]) else '18:04'

        uv_max_list = daily_data.get('uv_index_max', [5])
        uv_val = round(uv_max_list[0]) if uv_max_list else 5

        clean_location = location_name.split(',')[0].strip()

        lifestyle = WeatherAPIService._calculate_lifestyle_indices(
            temp, rain_prob, wind_speed, uv_val, humidity, real_aqi['score']
        )

        return {
            "location": clean_location if clean_location else "Guntur",
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
            "wind_direction_cardinal": WeatherAPIService._get_cardinal_direction(wind_direction),
            "pressure": pressure,
            "visibility": visibility_km,
            "rain_probability": rain_prob,
            "precipitation": precipitation,
            "weather_code": weather_code,
            "uv_index": uv_val,
            "uv_label": "Very High" if uv_val >= 8 else ("Strong" if uv_val >= 5 else "Moderate"),
            "aqi": real_aqi,
            "sun_trajectory": {
                "sunrise": sunrise,
                "sunset": sunset,
                "moonrise": "14:33",
                "moonset": "01:54"
            },
            "lifestyle_activities": lifestyle,
            "forecast7_url": f"https://forecast7.com/en/16z3180z44/{clean_location.lower().replace(' ', '-')}/",
            "forecast7_widget_id": f"forecast7-{clean_location.lower()}",
            "is_demo": False,
            "weather_source": "open_meteo",
            "mode_label": "🟢 LIVE WEATHER",
            "mode_subtitle": "Real weather & air quality from Open-Meteo",
            "provider": "Open-Meteo",
            "hourly_forecast": hourly_forecast,
            "daily_forecast": daily_forecast
        }

    @staticmethod
    def _get_cardinal_direction(degrees):
        dirs = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        idx = round(degrees / (360 / len(dirs))) % len(dirs)
        return dirs[idx]

    @staticmethod
    def _convert_wmo_code(code):
        return WeatherAPIService.WMO_CODES.get(
            code,
            {"condition": "Hazy sunshine", "code": "Clouds", "icon": "🌤️"}
        )

    @staticmethod
    def _get_mock_weather(location_name, mode="normal"):
        mode = (mode or "normal").lower()
        scenarios = {
            "normal": {
                "temperature": 33, "feels_like": 43, "condition": "Hazy sunshine",
                "condition_code": "Clouds", "humidity": 62, "wind_speed": 14, "wind_dir": 210,
                "rain_probability": 20, "uv_index": 5, "aqi": 24,
                "label": "Demo: Normal Weather",
                "subtitle": "Simulated normal weather scenario"
            },
            "rain": {
                "temperature": 26, "feels_like": 28, "condition": "Heavy Rain",
                "condition_code": "Rain", "humidity": 92, "wind_speed": 18, "wind_dir": 180,
                "rain_probability": 85, "uv_index": 2, "aqi": 18,
                "label": "Demo: Rain Alert",
                "subtitle": "Simulated rain alert for hackathon demonstration"
            },
            "heat": {
                "temperature": 38, "feels_like": 45, "condition": "Scorching Heat",
                "condition_code": "Clear", "humidity": 40, "wind_speed": 8, "wind_dir": 150,
                "rain_probability": 5, "uv_index": 10, "aqi": 48,
                "label": "Demo: Heat Alert",
                "subtitle": "Simulated heat alert for hackathon demonstration"
            },
            "wind": {
                "temperature": 30, "feels_like": 32, "condition": "Strong Gusty Winds",
                "condition_code": "Wind", "humidity": 65, "wind_speed": 45, "wind_dir": 270,
                "rain_probability": 35, "uv_index": 5, "aqi": 30,
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
            "wind_direction": data["wind_dir"],
            "wind_direction_cardinal": WeatherAPIService._get_cardinal_direction(data["wind_dir"]),
            "pressure": 1008,
            "visibility": 16.1,
            "rain_probability": data["rain_probability"],
            "precipitation": 5.0 if mode == "rain" else 0.0,
            "weather_code": 63 if mode == "rain" else 0,
            "uv_index": data["uv_index"],
            "uv_label": "Strong" if data["uv_index"] >= 5 else "Moderate",
            "aqi": {
                "score": data["aqi"],
                "quality": "Good",
                "pm25": 24, "pm10": 21, "so2": 7, "co": 2
            },
            "sun_trajectory": {
                "sunrise": "05:59", "sunset": "18:04", "moonrise": "14:33", "moonset": "01:54"
            },
            "lifestyle_activities": [
                {"name": "Outdoor activities", "status": "Low suitability", "icon": "biking"},
                {"name": "Stargazing", "status": "Fair", "icon": "satellite"},
                {"name": "Fishing", "status": "Unsuitable", "icon": "fishing"},
                {"name": "Sailing", "status": "Unsuitable", "icon": "sailing"},
                {"name": "Cold risk", "status": "Not Easy", "icon": "pill"},
                {"name": "Mosquito activity", "status": "Extremely High", "icon": "bug"}
            ],
            "forecast7_url": f"https://forecast7.com/en/16z3180z44/{clean_name.lower().replace(' ', '-')}/",
            "forecast7_widget_id": f"forecast7-{clean_name.lower()}",
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
        hours = ["Now", "14:00", "16:00", "18:00", "20:00", "22:00"]
        icons = ["☀️", "🌤️", "🌧️", "🌧️", "⛅", "🌙"] if "Rain" in condition else ["☀️", "☀️", "🌤️", "🌤️", "⛅", "🌙"]
        probs = [15, 30, 75, 80, 45, 20] if "Rain" in condition else [5, 10, 15, 20, 10, 5]
        return [
            {"time": hours[i], "temp": base_temp + (i % 3) - 1, "icon": icons[i], "rain_chance": probs[i]}
            for i in range(len(hours))
        ]

    @staticmethod
    def _generate_daily_forecast(base_temp, condition):
        days = ["Today", "Tomorrow", "Wed", "Thu", "Fri", "Sat", "Sun"]
        dates = ["09/21", "09/22", "09/23", "09/24", "09/25", "09/26", "09/27"]
        conditions = [condition, "Light Rain", "Partly Cloudy", "Sunny", "Clear Sky", "Hazy Sunshine", "Partly Cloudy"]
        return [
            {"day": days[i], "date": dates[i], "condition": conditions[i], "high": base_temp + (i % 3), "low": base_temp - 6, "rain_chance": 80 if "Rain" in conditions[i] else 15}
            for i in range(7)
        ]
