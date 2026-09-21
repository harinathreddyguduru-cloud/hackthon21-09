from rest_framework import serializers
from .models import SavedLocation, UserPreference, WeatherQueryLog

class SavedLocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = SavedLocation
        fields = '__all__'


class UserPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserPreference
        fields = '__all__'


class WeatherQueryLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = WeatherQueryLog
        fields = '__all__'
