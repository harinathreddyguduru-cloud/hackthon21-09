from django.db import models

class SavedLocation(models.Model):
    name = models.CharField(max_length=100)
    state = models.CharField(max_length=100, blank=True, default='')
    country = models.CharField(max_length=100, default='India')
    latitude = models.FloatField()
    longitude = models.FloatField()
    is_favorite = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.name}, {self.country}"


class UserPreference(models.Model):
    temperature_unit = models.CharField(max_length=2, choices=[('C', 'Celsius'), ('F', 'Fahrenheit')], default='C')
    notifications_enabled = models.BooleanField(default=True)
    alert_rain = models.BooleanField(default=True)
    alert_heat = models.BooleanField(default=True)
    alert_wind = models.BooleanField(default=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Preferences ({self.temperature_unit})"


class WeatherQueryLog(models.Model):
    location_name = models.CharField(max_length=100)
    user_query = models.TextField()
    ai_response = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"[{self.location_name}] {self.user_query[:30]}..."
