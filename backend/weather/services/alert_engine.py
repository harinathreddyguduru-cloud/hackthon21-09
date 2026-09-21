class AlertEngineService:
    """
    Analyzes normalized weather data and returns active smart alerts
    and recommended safety/prep actions.
    """
    
    @staticmethod
    def analyze_alerts(weather_data):
        alerts = []
        temp = weather_data.get('temperature', 0)
        rain_prob = weather_data.get('rain_probability', 0)
        wind_speed = weather_data.get('wind_speed', 0)
        condition = weather_data.get('condition', '').lower()
        
        # 1. Rain Alert
        if rain_prob >= 50 or 'rain' in condition:
            alerts.append({
                "id": "rain_alert",
                "type": "rain",
                "severity": "warning" if rain_prob < 75 else "danger",
                "title": "🌧️ Rain Alert",
                "message": f"Rain is expected soon ({rain_prob}% chance). Carry an umbrella and plan travel accordingly.",
                "action": "Carry umbrella",
                "icon": "rain"
            })
            
        # 2. Heat Alert
        if temp >= 35:
            severity = "danger" if temp >= 40 else "warning"
            alerts.append({
                "id": "heat_alert",
                "type": "heat",
                "severity": severity,
                "title": "🔥 Heat Alert",
                "message": f"High temperature of {temp}°C expected today. Stay hydrated and limit outdoor activity.",
                "action": "Stay hydrated",
                "icon": "heat"
            })
            
        # 3. Wind Alert
        if wind_speed >= 35:
            alerts.append({
                "id": "wind_alert",
                "type": "wind",
                "severity": "warning" if wind_speed < 55 else "danger",
                "title": "💨 Strong Wind Alert",
                "message": f"Strong winds of {wind_speed} km/h expected. Secure loose items and take care outdoors.",
                "action": "Take care outdoors",
                "icon": "wind"
            })

        # 4. Severe Weather (extreme condition check)
        if temp >= 42 or wind_speed >= 65:
            alerts.append({
                "id": "severe_alert",
                "type": "severe",
                "severity": "danger",
                "title": "⚠️ Severe Weather Warning",
                "message": "Extreme weather conditions detected. Follow local weather advisory instructions.",
                "action": "Seek safe shelter",
                "icon": "severe"
            })

        # Default normal status if no alerts
        if not alerts:
            alerts.append({
                "id": "normal_status",
                "type": "normal",
                "severity": "info",
                "title": "✓ Clear Weather",
                "message": "Weather conditions look calm and normal right now. Have a pleasant day!",
                "action": "Enjoy your day",
                "icon": "check"
            })

        return {
            "has_alerts": any(a['type'] != 'normal' for a in alerts),
            "alerts_count": len([a for a in alerts if a['type'] != 'normal']),
            "alerts": alerts,
            "nearby_assistance": AlertEngineService._get_nearby_assistance(alerts)
        }

    @staticmethod
    def _get_nearby_assistance(alerts):
        """
        Returns relevant nearby places/services based on active weather alerts.
        """
        types = [a['type'] for a in alerts]
        assistance = []
        
        if 'rain' in types:
            assistance.append({
                "category": "Rain Protection & Conveniences",
                "items": [
                    {"name": "City Mall & Supermarket", "type": "Umbrellas & Raincoats", "distance": "400 m"},
                    {"name": "Metro Transit Station", "type": "Covered Transit Shelter", "distance": "650 m"}
                ]
            })
            
        if 'heat' in types:
            assistance.append({
                "category": "Cooling & Hydration Stations",
                "items": [
                    {"name": "Community Health Center", "type": "Hydration Station & First Aid", "distance": "300 m"},
                    {"name": "Central Park Shaded Pavilion", "type": "Public Cooling Shelter", "distance": "500 m"}
                ]
            })

        if 'wind' in types or 'severe' in types:
            assistance.append({
                "category": "Safe Emergency Shelters",
                "items": [
                    {"name": "Civic Auditorium Shelter", "type": "Reinforced Indoor Shelter", "distance": "800 m"}
                ]
            })

        if not assistance:
            assistance.append({
                "category": "Nearby Amenities",
                "items": [
                    {"name": "Local Coffee Shop", "type": "Outdoor & Indoor Seating", "distance": "250 m"}
                ]
            })

        return assistance
