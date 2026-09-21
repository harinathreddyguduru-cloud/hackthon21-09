from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics

from .models import SavedLocation, UserPreference, WeatherQueryLog
from .serializers import SavedLocationSerializer, UserPreferenceSerializer, WeatherQueryLogSerializer
from .services.weather_api import WeatherAPIService
from .services.alert_engine import AlertEngineService
from .services.ai_service import AIService

class CurrentWeatherView(APIView):
    """
    Returns complete current weather from Open-Meteo (or Demo Mode),
    smart alerts, executive AI summary, and forecast data.
    """
    def get(self, request):
        location = request.query_params.get('location', 'Guntur, India')
        demo_mode = request.query_params.get('demo_mode', None)

        lat = request.query_params.get('lat')
        lon = request.query_params.get('lon')

        try:
            lat = float(lat) if lat is not None else None
            lon = float(lon) if lon is not None else None
        except ValueError:
            lat, lon = None, None

        weather_data = WeatherAPIService.get_weather(
            location_name=location,
            lat=lat,
            lon=lon,
            demo_mode=demo_mode
        )
        
        alert_data = AlertEngineService.analyze_alerts(weather_data)
        ai_summary = AIService.generate_summary(weather_data)
        
        return Response({
            "status": "success",
            "weather": weather_data,
            "alerts_summary": alert_data,
            "ai_summary": ai_summary,
        })


class AskWeatherGPTView(APIView):
    """
    Processes natural-language weather questions and returns grounded AI answers.
    """
    def post(self, request):
        query = request.data.get('query', '')
        location = request.data.get('location', 'Guntur, India')
        demo_mode = request.data.get('demo_mode', None)
        lat = request.data.get('lat')
        lon = request.data.get('lon')
        
        if not query:
            return Response({"error": "Query field is required."}, status=status.HTTP_400_BAD_REQUEST)
            
        weather_data = WeatherAPIService.get_weather(
            location_name=location,
            lat=lat,
            lon=lon,
            demo_mode=demo_mode
        )
        
        ai_answer = AIService.answer_question(query, weather_data)
        
        # Log query to database
        try:
            WeatherQueryLog.objects.create(
                location_name=weather_data.get('location', location),
                user_query=query,
                ai_response=ai_answer
            )
        except Exception as e:
            print(f"Log save error: {e}")
            
        return Response({
            "status": "success",
            "location": weather_data.get('location', location),
            "query": query,
            "answer": ai_answer,
            "weather_context": {
                "temperature": weather_data.get('temperature'),
                "condition": weather_data.get('condition'),
                "rain_probability": weather_data.get('rain_probability')
            }
        })


class WeatherSearchView(APIView):
    """
    City search endpoint using Open-Meteo Geocoding API.
    """
    def get(self, request):
        q = request.query_params.get('q', '').strip()
        
        if not q:
            # Popular defaults
            results = [
                {"name": "Guntur", "state": "Andhra Pradesh", "country": "India", "lat": 16.3067, "lon": 80.4365},
                {"name": "Vijayawada", "state": "Andhra Pradesh", "country": "India", "lat": 16.5062, "lon": 80.6480},
                {"name": "Hyderabad", "state": "Telangana", "country": "India", "lat": 17.3850, "lon": 78.4867},
                {"name": "Bengaluru", "state": "Karnataka", "country": "India", "lat": 12.9716, "lon": 77.5946},
                {"name": "Chennai", "state": "Tamil Nadu", "country": "India", "lat": 13.0827, "lon": 80.2707},
            ]
        else:
            # Query Open-Meteo Geocoding API
            results = WeatherAPIService.geocode_city(q)
            if not results:
                results = [{"name": q.capitalize(), "state": "", "country": "India", "lat": 16.3067, "lon": 80.4365}]
                
        return Response({"status": "success", "results": results})


class SavedLocationListCreateView(generics.ListCreateAPIView):
    queryset = SavedLocation.objects.all()
    serializer_class = SavedLocationSerializer


class UserPreferenceView(APIView):
    def get(self, request):
        pref, _ = UserPreference.objects.get_or_create(id=1)
        serializer = UserPreferenceSerializer(pref)
        return Response(serializer.data)

    def post(self, request):
        pref, _ = UserPreference.objects.get_or_create(id=1)
        serializer = UserPreferenceSerializer(pref, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
