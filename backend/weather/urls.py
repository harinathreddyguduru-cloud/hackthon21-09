from django.urls import path
from .views import (
    CurrentWeatherView,
    AskWeatherGPTView,
    WeatherSearchView,
    SavedLocationListCreateView,
    UserPreferenceView
)

urlpatterns = [
    path('current/', CurrentWeatherView.as_view(), name='weather-current'),
    path('ask/', AskWeatherGPTView.as_view(), name='weather-ask'),
    path('search/', WeatherSearchView.as_view(), name='weather-search'),
    path('locations/', SavedLocationListCreateView.as_view(), name='weather-locations'),
    path('preferences/', UserPreferenceView.as_view(), name='weather-preferences'),
]
