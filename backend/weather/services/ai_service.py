import os
from django.conf import settings

class AIService:
    """
    AI Weather Assistant using Gemini API with strict grounding
    on actual weather API data provided by Django.
    """

    @staticmethod
    def generate_summary(weather_data):
        api_key = settings.GEMINI_API_KEY
        location = weather_data.get('location', 'your area')
        temp = weather_data.get('temperature', 29)
        condition = weather_data.get('condition', 'Partly Cloudy')
        rain_prob = weather_data.get('rain_probability', 20)
        wind_speed = weather_data.get('wind_speed', 10)
        
        prompt = f"""
        You are WeatherGPT, a helpful AI weather assistant.
        Given this ACTUAL weather data for {location}:
        - Temperature: {temp}°C (Feels like {weather_data.get('feels_like', temp)}°C)
        - Condition: {condition}
        - Rain probability: {rain_prob}%
        - Wind speed: {wind_speed} km/h
        - Humidity: {weather_data.get('humidity', 70)}%

        Write a concise, 2-sentence executive summary for the user explaining what to expect today and what action to take (e.g. carry umbrella, wear light clothes, stay hydrated, drive safely).
        Do NOT invent any weather data. Use only the provided numbers.
        """

        if api_key:
            try:
                from google import genai
                client = genai.Client(api_key=api_key)
                response = client.models.generate_content(
                    model='gemini-2.5-flash',
                    contents=prompt
                )
                if response and response.text:
                    return response.text.strip()
            except Exception as e:
                print(f"Gemini API error: {e}. Using fallback AI summary.")

        # Grounded fallback summary logic
        if rain_prob >= 50:
            return f"Rain is likely in {location} today with a {rain_prob}% probability. Carrying an umbrella is highly recommended if heading outside."
        elif temp >= 35:
            return f"It is very hot in {location} today at {temp}°C. Keep hydrated and minimize prolonged sun exposure."
        elif wind_speed >= 35:
            return f"Strong winds of {wind_speed} km/h expected in {location}. Take extra care when traveling or participating in outdoor activities."
        else:
            return f"Weather in {location} is currently {condition.lower()} at {temp}°C. Conditions are pleasant for routine daily activities."

    @staticmethod
    def answer_question(user_query, weather_data):
        api_key = settings.GEMINI_API_KEY
        location = weather_data.get('location', 'your location')
        temp = weather_data.get('temperature', 29)
        condition = weather_data.get('condition', 'Partly Cloudy')
        rain_prob = weather_data.get('rain_probability', 20)
        wind_speed = weather_data.get('wind_speed', 10)
        humidity = weather_data.get('humidity', 70)
        forecast = weather_data.get('daily_forecast', [])

        prompt = f"""
        You are WeatherGPT, a smart, friendly weather assistant.
        Answer the user's question accurately using ONLY this official weather data:
        - Location: {location}
        - Temperature: {temp}°C (Feels like: {weather_data.get('feels_like', temp)}°C)
        - Condition: {condition}
        - Rain Probability: {rain_prob}%
        - Humidity: {humidity}%
        - Wind Speed: {wind_speed} km/h
        - Forecast summary: {forecast}

        User Question: "{user_query}"

        Rules:
        1. Keep answer friendly, direct and short (2 to 3 sentences maximum).
        2. Use relevant weather emoji.
        3. Give practical advice (e.g. umbrella, clothing, travel safety).
        4. NEVER invent temperatures, rain chances or weather conditions.
        """

        if api_key:
            try:
                from google import genai
                client = genai.Client(api_key=api_key)
                response = client.models.generate_content(
                    model='gemini-2.5-flash',
                    contents=prompt
                )
                if response and response.text:
                    return response.text.strip()
            except Exception as e:
                print(f"Gemini API Q&A error: {e}. Using fallback Q&A.")

        # Grounded fallback Q&A logic based on query intent
        query_lower = user_query.lower()

        if "rain" in query_lower or "umbrella" in query_lower:
            if rain_prob >= 50:
                return f"🌧️ Yes, there is a high {rain_prob}% chance of rain in {location} today. Carrying an umbrella is definitely recommended!"
            else:
                return f"🌤️ Rain is unlikely in {location} right now ({rain_prob}% chance). You probably won't need an umbrella today."
        
        elif "wear" in query_lower or "dress" in query_lower or "clothes" in query_lower:
            if temp >= 32:
                return f"☀️ It's warm at {temp}°C! Wear light, breathable cotton clothing and consider sunglasses or a hat."
            elif rain_prob >= 50:
                return f"🌧️ Waterproof footwear and a light jacket are advisable today due to the {rain_prob}% chance of rain."
            else:
                return f"👕 Comfortable casual wear is ideal for today's {temp}°C {condition.lower()} weather."

        elif "travel" in query_lower or "drive" in query_lower or "out" in query_lower:
            if wind_speed >= 35 or rain_prob >= 75:
                return f"⚠️ Take caution while traveling! Winds of {wind_speed} km/h and high rain probability ({rain_prob}%) may slow down traffic."
            else:
                return f"✈️ Travel conditions look good in {location}! The weather is {condition.lower()} with moderate winds of {wind_speed} km/h."

        elif "wind" in query_lower:
            return f"💨 Wind speed in {location} is currently {wind_speed} km/h. {'Caution advised outdoors.' if wind_speed >= 35 else 'Winds are calm.'}"

        else:
            return f"🌡️ Currently in {location} it is {temp}°C and {condition.lower()} with {rain_prob}% rain chance and {humidity}% humidity. Let me know if you need specific travel or clothing tips!"
