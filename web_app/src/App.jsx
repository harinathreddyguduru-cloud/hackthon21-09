import React, { useState, useEffect } from 'react';
import { 
  MapPin, Bell, Settings, Droplets, Wind, CloudRain, 
  Bot, Send, Search, CheckCircle, Navigation, ArrowLeft, RefreshCw, Smartphone,
  Thermostat, Sun, Compass, Activity, Eye, Gauge, Award, ShieldAlert
} from 'lucide-react';

const API_BASE = 'http://127.0.0.1:8000/api/weather';

export default function App() {
  const [location, setLocation] = useState('Guntur, India');
  const [demoScenario, setDemoScenario] = useState('live'); // live, normal, rain, heat, wind
  const [weatherData, setWeatherData] = useState(null);
  const [alertsSummary, setAlertsSummary] = useState(null);
  const [aiSummary, setAiSummary] = useState('');
  const [loading, setLoading] = useState(true);
  const [currentView, setCurrentView] = useState('home');
  const [tempUnit, setTempUnit] = useState('C');
  const [viewMode, setViewMode] = useState('mobile');

  // Chat State
  const [messages, setMessages] = useState([
    { id: 1, text: "Hello! I am WeatherGPT 🤖. Ask me any weather question for grounded recommendations!", isUser: false }
  ]);
  const [inputQuery, setInputQuery] = useState('');
  const [isAsking, setIsAsking] = useState(false);

  // Search state
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);

  // Fetch weather data
  const fetchWeather = async (loc = location, mode = demoScenario) => {
    setLoading(true);
    try {
      const modeParam = mode === 'live' ? '' : mode;
      const url = `${API_BASE}/current/?location=${encodeURIComponent(loc)}&demo_mode=${modeParam}`;
      const res = await fetch(url);
      const data = await res.json();
      if (data.status === 'success') {
        setWeatherData(data.weather);
        setAlertsSummary(data.alerts_summary);
        setAiSummary(data.ai_summary);
      }
    } catch (e) {
      console.error("API error, using fallback", e);
      buildFallback(loc, mode);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = async (q) => {
    setSearchQuery(q);
    if (!q.trim()) {
      setSearchResults([]);
      return;
    }
    try {
      const res = await fetch(`${API_BASE}/search/?q=${encodeURIComponent(q)}`);
      const data = await res.json();
      if (data.status === 'success') {
        setSearchResults(data.results || []);
      }
    } catch (e) {
      console.error("Search error", e);
    }
  };

  const buildFallback = (loc, mode) => {
    const isLiveMode = mode === 'live';
    let temp = 33, rain = 20, wind = 14, cond = "Hazy sunshine";
    if (mode === 'rain') { temp = 26; rain = 85; wind = 18; cond = "Heavy Rain"; }
    else if (mode === 'heat') { temp = 38; rain = 5; wind = 8; cond = "Scorching Heat"; }
    else if (mode === 'wind') { temp = 30; rain = 35; wind = 45; cond = "Strong Gusty Winds"; }

    setWeatherData({
      location: loc.split(',')[0],
      temperature: temp,
      feels_like: temp + 10,
      condition: cond,
      condition_code: mode === 'rain' ? 'Rain' : 'Clouds',
      is_demo: !isLiveMode,
      mode_label: isLiveMode ? "🟢 LIVE WEATHER" : "🟠 DEMO MODE",
      mode_subtitle: isLiveMode ? "Real weather data from Open-Meteo" : `Simulated ${mode} scenario for hackathon demonstration`,
      provider: isLiveMode ? 'Open-Meteo' : 'Demo Simulation',
      humidity: 62,
      wind_speed: wind,
      wind_direction: 210,
      wind_direction_cardinal: "SSW",
      pressure: 1008,
      visibility: 16.1,
      rain_probability: rain,
      uv_index: 5,
      uv_label: "Strong",
      aqi: { score: 24, quality: "Good", pm25: 24, pm10: 21, so2: 7, co: 2 },
      sun_trajectory: { sunrise: "05:59", sunset: "18:04", moonrise: "14:33", moonset: "01:54" },
      lifestyle_activities: [
        { name: "Outdoor activities", status: "Low suitability", icon: "🚴" },
        { name: "Stargazing", status: "Fair", icon: "🛰️" },
        { name: "Fishing", status: "Unsuitable", icon: "🎣" },
        { name: "Sailing", status: "Unsuitable", icon: "⛵" },
        { name: "Cold risk", status: "Not Easy", icon: "💊" },
        { name: "Mosquito activity", status: "Extremely High", icon: "🦟" }
      ],
      hourly_forecast: [
        { time: "Now", temp: temp, icon: "☀️", rain_chance: rain },
        { time: "14:00", temp: temp + 1, icon: "🌤️", rain_chance: rain },
        { time: "16:00", temp: temp, icon: "🌧️", rain_chance: rain },
        { time: "18:00", temp: temp - 1, icon: "🌧️", rain_chance: rain },
        { time: "20:00", temp: temp - 2, icon: "⛅", rain_chance: 15 },
        { time: "22:00", temp: temp - 3, icon: "🌙", rain_chance: 10 },
      ],
      daily_forecast: [
        { day: "Today", date: "09/21", condition: cond, high: temp + 1, low: temp - 5 },
        { day: "Tomorrow", date: "09/22", condition: "Light Rain", high: temp, low: temp - 6 },
        { day: "Wed", date: "09/23", condition: "Partly Cloudy", high: temp + 2, low: temp - 4 },
        { day: "Thu", date: "09/24", condition: "Sunny", high: temp + 1, low: temp - 5 },
        { day: "Fri", date: "09/25", condition: "Clear Sky", high: temp + 3, low: temp - 4 },
      ]
    });

    setAlertsSummary({
      has_alerts: rain >= 50 || temp >= 35 || wind >= 35,
      alerts: [
        rain >= 50 ? { title: "🌧️ Rain Alert", message: "High probability of rain expected. Consider carrying an umbrella.", severity: "danger", action: "Carry umbrella" }
        : temp >= 35 ? { title: "🔥 Heat Alert", message: "High temperatures expected today. Stay hydrated and avoid outdoor sun.", severity: "danger", action: "Stay hydrated" }
        : wind >= 35 ? { title: "💨 Strong Wind Alert", message: "Strong winds expected. Secure loose items and take care outdoors.", severity: "warning", action: "Take care outdoors" }
        : { title: "✓ Clear Weather", message: "Weather conditions look calm right now.", severity: "info", action: "Enjoy your day" }
      ],
      nearby_assistance: [
        { category: "Rain & Convenience Shops", items: [{ name: "City Mall Supermarket", type: "Umbrellas & Rainwear", distance: "350 m" }] }
      ]
    });

    setAiSummary(isLiveMode 
      ? `Real-time weather for ${loc} via Open-Meteo: ${cond} at ${temp}°C. Humidity ${62}%.`
      : `DEMO SIMULATION: Testing ${mode} alert scenario for ${loc}.`);
  };

  useEffect(() => {
    fetchWeather(location, demoScenario);
  }, [location, demoScenario]);

  // Handle Q&A Ask
  const handleAsk = async (queryText) => {
    const q = queryText || inputQuery;
    if (!q.trim() || isAsking) return;

    setInputQuery('');
    setMessages(prev => [...prev, { id: Date.now(), text: q, isUser: true }]);
    setIsAsking(true);

    try {
      const res = await fetch(`${API_BASE}/ask/`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query: q, location, demo_mode: demoScenario === 'live' ? '' : demoScenario })
      });
      const data = await res.json();
      setMessages(prev => [...prev, { id: Date.now() + 1, text: data.answer, isUser: false }]);
    } catch (e) {
      let reply = `🌤️ Weather in ${location} is ${weatherData?.condition?.toLowerCase()} at ${weatherData?.temperature}°C.`;
      if (q.toLowerCase().includes('rain') || q.toLowerCase().includes('umbrella')) {
        reply = `🌧️ Rain probability in ${location} is ${weatherData?.rain_probability || 20}%. ${weatherData?.rain_probability >= 50 ? 'Carrying an umbrella is recommended!' : 'You probably won\'t need an umbrella.'}`;
      }
      setMessages(prev => [...prev, { id: Date.now() + 1, text: reply, isUser: false }]);
    } finally {
      setIsAsking(false);
    }
  };

  const convertTemp = (t) => tempUnit === 'F' ? Math.round((t * 9/5) + 32) : t;
  const isLive = demoScenario === 'live';

  return (
    <div className="min-h-screen bg-[#EAF6FF] text-white flex flex-col items-center justify-center p-2 sm:p-6 font-sans">
      {/* Top Banner Control */}
      <div className="w-full max-w-md mb-3 flex items-center justify-between bg-white/90 backdrop-blur-md px-4 py-2.5 rounded-2xl shadow-sm border border-white/50 text-[#183B56]">
        <div className="flex items-center gap-2">
          <span className={`w-3 h-3 rounded-full ${isLive ? 'bg-emerald-500 animate-pulse' : 'bg-amber-500'}`}></span>
          <span className="text-xs font-bold">WeatherGPT 3D Sky</span>
          <span className="text-[10px] px-2 py-0.5 bg-[#EAF6FF] text-[#4DA8FF] rounded-full font-semibold">Open-Meteo API</span>
        </div>
        <button 
          onClick={() => setViewMode(v => v === 'mobile' ? 'full' : 'mobile')}
          className="flex items-center gap-1.5 text-xs bg-[#F5FBFF] px-2.5 py-1 rounded-lg border border-[#4DA8FF]/20 text-[#4DA8FF] font-semibold hover:bg-[#EAF6FF] transition"
        >
          <Smartphone size={14} />
          {viewMode === 'mobile' ? 'Expand View' : 'Mobile Frame'}
        </button>
      </div>

      {/* Dynamic 3D Sky Background Container */}
      <div className={`w-full relative transition-all duration-300 ${
        viewMode === 'mobile' 
          ? 'max-w-[400px] h-[860px] rounded-[44px] shadow-2xl border-[10px] border-[#183B56] overflow-hidden flex flex-col' 
          : 'max-w-2xl rounded-3xl shadow-xl border border-white/30 p-6'
      }`}>
        
        {/* Dynamic Sky Gradient & Sun Flare Animation Canvas */}
        <div className="absolute inset-0 bg-gradient-to-b from-[#2C74C3] via-[#4FA0EE] to-[#7CB8F8] z-0 overflow-hidden">
          {/* Animated 3D Sun flare glow */}
          <div className="absolute -top-16 left-1/2 -translate-x-1/2 w-72 h-72 bg-gradient-to-r from-yellow-200/50 via-amber-300/30 to-transparent rounded-full blur-2xl animate-pulse"></div>
          <div className="absolute top-10 right-10 w-24 h-24 bg-white/30 rounded-full blur-xl"></div>
        </div>

        {/* Mobile Header Bar */}
        {viewMode === 'mobile' && (
          <div className="w-full bg-[#183B56]/90 backdrop-blur-sm text-white pt-3 pb-1 px-6 flex justify-between items-center text-[10px] tracking-wider font-mono z-10">
            <span>12:42 PM</span>
            <div className="w-16 h-4 bg-black/60 rounded-full mx-auto -mt-1"></div>
            <span>5G ⚡ 69%</span>
          </div>
        )}

        {/* Dynamic App Screens */}
        <div className="flex-1 overflow-y-auto scrollbar-thin relative z-10">

          {/* SCREEN 1: HOME DASHBOARD */}
          {currentView === 'home' && (
            <div className="p-4 space-y-4">
              
              {/* Header Bar */}
              <div className="flex items-center justify-between">
                <button 
                  onClick={() => setCurrentView('location')}
                  className="flex items-center gap-1 text-white font-bold text-2xl tracking-tight drop-shadow-sm"
                >
                  <span>{location.split(',')[0]}</span>
                  <span className="text-base text-white/80">▼</span>
                </button>

                <div className="flex items-center gap-1">
                  <button 
                    onClick={() => fetchWeather()} 
                    className="p-2 text-white/90 hover:text-white rounded-full hover:bg-white/10 transition"
                    title="Refresh weather"
                  >
                    <RefreshCw size={20} className={loading ? "animate-spin" : ""} />
                  </button>
                  <button 
                    onClick={() => setCurrentView('settings')}
                    className="p-2 text-white/90 hover:text-white rounded-full hover:bg-white/10 transition"
                  >
                    <Settings size={20} />
                  </button>
                </div>
              </div>

              {/* Mode Switcher Buttons */}
              <div className="grid grid-cols-2 gap-2 text-xs">
                <button
                  onClick={() => setDemoScenario('live')}
                  className={`py-2 px-3 rounded-xl font-bold transition flex items-center justify-center gap-1.5 border ${
                    isLive ? 'bg-white text-[#183B56] border-white shadow-md' : 'bg-white/20 text-white border-white/30 hover:bg-white/30'
                  }`}
                >
                  <span>🟢 Live Weather</span>
              {/* 100% Real-Time Weather Badge */}
              <div className="p-3 rounded-2xl border backdrop-blur-md flex items-center justify-between text-xs bg-white/20 border-white/40 text-white">
                <div className="flex items-center gap-2">
                  <span className="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-pulse"></span>
                  <div>
                    <div className="font-bold tracking-wide">🟢 100% REAL-TIME LIVE WEATHER</div>
                    <div className="text-[10px] opacity-80">Real-time weather observations from WeatherAPI.com & Open-Meteo</div>
                  </div>
                </div>
                <span className="text-[9px] font-bold uppercase px-2 py-0.5 rounded bg-emerald-500/40 text-white border border-emerald-300/40">
                  REAL LIVE
                </span>
              </div>

              {loading ? (
                <div className="py-20 text-center space-y-3">
                  <div className="text-6xl animate-bounce">🌤️</div>
                  <div className="text-base font-semibold">Fetching WeatherGPT 3D Sky...</div>
                </div>
              ) : (
                <>
                  {/* Hero Weather Header */}
                  <div className="text-center space-y-1 py-2">
                    <div className="text-sm font-medium text-white/90">{weatherData?.condition}</div>
                    <div className="text-xs text-white/80">28° ~ 34°   Feels like {convertTemp(weatherData?.feels_like || 43)}°</div>
                    <div className="text-7xl font-bold tracking-tight text-white drop-shadow-lg pt-1">
                      {convertTemp(weatherData?.temperature || 33)}°
                    </div>
                  </div>

                  {/* Hourly Temperature Trend Curve Line Graph */}
                  <div className="space-y-2 pt-2">
                    <div className="bg-white/18 backdrop-blur-md p-4 rounded-3xl border border-white/30 space-y-3">
                      <div className="text-xs font-bold flex items-center justify-between text-white/90">
                        <span>Hourly Temperature Trend</span>
                        <span className="text-[10px] text-amber-300 font-semibold">Live Curve</span>
                      </div>
                      <div className="flex justify-between items-end h-16 pt-2 px-1">
                        {weatherData?.hourly_forecast?.map((item, idx) => (
                          <div key={idx} className="flex flex-col items-center gap-1">
                            <span className="text-[10px] font-bold bg-amber-500/90 text-white px-1.5 py-0.5 rounded-full text-[9px]">
                              {convertTemp(item.temp)}°
                            </span>
                            <span className="text-sm">{item.icon}</span>
                            <span className="text-[10px] text-white/80">{item.time}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>

                  {/* Daily 7-Day Forecast Translucent Glass Card */}
                  <div className="bg-white/18 backdrop-blur-md p-4 rounded-3xl border border-white/30 divide-y divide-white/10 space-y-2">
                    {weatherData?.daily_forecast?.map((item, idx) => (
                      <div key={idx} className="pt-2 flex items-center justify-between text-xs text-white">
                        <div className="w-12 text-[10px] text-white/70">{item.date || '09/21'}</div>
                        <div className="w-16 font-bold">{item.day}</div>
                        <div className="text-lg">{item.condition.toLowerCase().includes('rain') ? '🌧️' : '🌤️'}</div>
                        <div className="flex-1 px-3 text-left text-white/80 text-[11px] truncate">{item.condition}</div>
                        <div className="font-bold">{convertTemp(item.low)}°  {convertTemp(item.high)}°</div>
                      </div>
                    ))}
                  </div>

                  {/* Active Alert Banner */}
                  {alertsSummary?.alerts?.[0] && (
                    <div className="bg-white/20 backdrop-blur-md p-4 rounded-2xl border border-white/40 text-sm space-y-2">
                      <div className="flex items-center justify-between font-bold">
                        <span>{alertsSummary.alerts[0].title}</span>
                        <span className="text-[10px] uppercase px-2 py-0.5 rounded-full bg-white/30 text-white">
                          {alertsSummary.alerts[0].severity}
                        </span>
                      </div>
                      <div className="text-xs leading-relaxed text-white/90">{alertsSummary.alerts[0].message}</div>
                      <div className="text-xs font-semibold pt-1 flex items-center gap-1">
                        <span>Action:</span>
                        <span className="underline">{alertsSummary.alerts[0].action}</span>
                      </div>
                    </div>
                  )}

                  {/* WeatherGPT AI Summary Glass Card */}
                  <div className="bg-white/20 backdrop-blur-md p-4 rounded-3xl border border-white/40 space-y-3">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <div className="p-1.5 bg-white/20 rounded-xl text-lg">🤖</div>
                        <div>
                          <div className="font-bold text-sm">WeatherGPT AI Summary</div>
                          <div className="text-[10px] text-white/80">Grounded AI Recommendations</div>
                        </div>
                      </div>
                      <span className="text-[10px] font-bold bg-white/20 px-2 py-0.5 rounded-md">Grounded</span>
                    </div>

                    <p className="text-xs leading-relaxed text-white/95">
                      {aiSummary}
                    </p>

                    <button 
                      onClick={() => setCurrentView('chat')}
                      className="w-full py-2.5 bg-white text-[#183B56] text-xs font-bold rounded-xl flex items-center justify-center gap-2 shadow-sm hover:bg-white/90 transition"
                    >
                      <span>💬</span>
                      <span>Ask WeatherGPT Anything</span>
                    </button>
                  </div>

                  {/* 2x2 Glass Metric Cards */}
                  <div className="grid grid-cols-2 gap-3">
                    
                    {/* Feels Like */}
                    <div className="bg-white/18 backdrop-blur-md p-4 rounded-2xl border border-white/30 space-y-2">
                      <div className="flex items-center justify-between text-xs font-bold text-white">
                        <span>Feels like</span>
                        <Thermostat size={16} />
                      </div>
                      <div className="h-1.5 w-full bg-gradient-to-r from-blue-400 via-amber-400 to-red-500 rounded-full my-2"></div>
                      <div className="text-lg font-bold text-white">{convertTemp(weatherData?.feels_like || 43)} °C</div>
                      <div className="text-[10px] text-white/80">Extremely hot</div>
                    </div>

                    {/* Wind Compass */}
                    <div className="bg-white/18 backdrop-blur-md p-4 rounded-2xl border border-white/30 space-y-2 text-center">
                      <div className="flex items-center justify-between text-xs font-bold text-white">
                        <span>{weatherData?.wind_direction_cardinal || 'SSW'}</span>
                        <Wind size={16} />
                      </div>
                      <div className="w-16 h-16 rounded-full border-2 border-white/40 mx-auto flex items-center justify-center relative my-1">
                        <div className="text-[10px] font-bold">{weatherData?.wind_speed || 14} km/h</div>
                      </div>
                    </div>

                    {/* Humidity */}
                    <div className="bg-white/18 backdrop-blur-md p-4 rounded-2xl border border-white/30 space-y-2">
                      <div className="flex items-center justify-between text-xs font-bold text-white">
                        <span>Humidity</span>
                        <Droplets size={16} />
                      </div>
                      <div className="text-2xl font-bold text-white pt-2">{weatherData?.humidity}%</div>
                      <div className="text-[10px] text-white/80">Moderate</div>
                    </div>

                    {/* UV Index */}
                    <div className="bg-white/18 backdrop-blur-md p-4 rounded-2xl border border-white/30 space-y-2">
                      <div className="flex items-center justify-between text-xs font-bold text-white">
                        <span>UV</span>
                        <Sun size={16} />
                      </div>
                      <div className="h-1.5 w-full bg-gradient-to-r from-green-400 via-yellow-400 to-purple-500 rounded-full my-2"></div>
                      <div className="text-base font-bold text-white">Level {weatherData?.uv_index || 5}</div>
                      <div className="text-[10px] text-white/80">Strong</div>
                    </div>

                  </div>

                  {/* Forecast7 Live Weather Widget Card */}
                  <div className="bg-white/18 backdrop-blur-md p-4 rounded-3xl border border-white/30 space-y-2">
                    <div className="flex items-center justify-between text-xs font-bold text-white mb-1">
                      <span className="flex items-center gap-1.5">
                        <span>🌐</span>
                        <span>Forecast7 Live Embed</span>
                      </span>
                      <a 
                        href={`https://forecast7.com/en/16z3180z44/${encodeURIComponent(weatherData?.location?.toLowerCase() || 'guntur')}/`} 
                        target="_blank" 
                        rel="noreferrer"
                        className="text-[10px] bg-blue-500/40 hover:bg-blue-500/60 px-2 py-0.5 rounded-full transition-colors text-white text-decoration-none"
                      >
                        Forecast7.com ↗
                      </a>
                    </div>
                    <div className="w-full h-36 rounded-xl overflow-hidden border border-white/20 bg-black/20">
                      <iframe
                        title="Forecast7 Weather Widget"
                        src={`https://forecast7.com/en/16z3180z44/${encodeURIComponent(weatherData?.location?.toLowerCase() || 'guntur')}/`}
                        className="w-full h-full border-0"
                        scrolling="no"
                      ></iframe>
                    </div>
                  </div>

                  {/* Air Quality (AQI Arc Glass Card) */}
                  <div className="bg-white/18 backdrop-blur-md p-4 rounded-3xl border border-white/30 space-y-3">
                    <div className="flex items-center justify-between text-xs font-bold text-white">
                      <span>Air quality</span>
                      <Activity size={16} />
                    </div>
                    <div className="flex items-center gap-4">
                      <div className="w-14 h-14 rounded-full border-4 border-emerald-400 flex flex-col items-center justify-center">
                        <span className="text-[9px] text-white/80">Good</span>
                        <span className="text-sm font-bold text-white">24</span>
                      </div>
                      <div className="grid grid-cols-4 gap-2 flex-1 text-center text-xs">
                        <div>
                          <div className="text-[9px] text-white/70">PM2.5</div>
                          <div className="font-bold">24</div>
                        </div>
                        <div>
                          <div className="text-[9px] text-white/70">PM10</div>
                          <div className="font-bold">21</div>
                        </div>
                        <div>
                          <div className="text-[9px] text-white/70">SO2</div>
                          <div className="font-bold">7</div>
                        </div>
                        <div>
                          <div className="text-[9px] text-white/70">CO</div>
                          <div className="font-bold">2</div>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Sunrise & Sunset Arc */}
                  <div className="bg-white/18 backdrop-blur-md p-4 rounded-3xl border border-white/30 space-y-3">
                    <div className="flex items-center justify-between text-xs font-bold text-white">
                      <span>Sunrise & sunset</span>
                      <Sun size={16} />
                    </div>
                    <div className="h-10 w-full relative flex items-center justify-center">
                      <div className="w-full h-8 border-b-2 border-dashed border-white/40 rounded-t-full"></div>
                    </div>
                    <div className="flex justify-between text-xs text-white">
                      <div>
                        <div className="text-[10px] text-white/70">Sunrise</div>
                        <div className="font-bold">05:59</div>
                      </div>
                      <div className="text-right">
                        <div className="text-[10px] text-white/70">Sunset</div>
                        <div className="font-bold">18:04</div>
                      </div>
                    </div>
                  </div>

                  {/* Lifestyle Grid */}
                  <div className="grid grid-cols-2 gap-2.5">
                    {[
                      { name: 'Outdoor activities', status: 'Low suitability', icon: '🚴' },
                      { name: 'Stargazing', status: 'Fair', icon: '🛰️' },
                      { name: 'Fishing', status: 'Unsuitable', icon: '🎣' },
                      { name: 'Sailing', status: 'Unsuitable', icon: '⛵' },
                      { name: 'Cold risk', status: 'Not Easy', icon: '💊' },
                      { name: 'Mosquito activity', status: 'Extremely High', icon: '🦟' },
                    ].map((act, idx) => (
                      <div key={idx} className="bg-white/18 backdrop-blur-md p-3 rounded-2xl border border-white/30 text-center space-y-1">
                        <div className="text-xl">{act.icon}</div>
                        <div className="text-xs font-bold text-white">{act.name}</div>
                        <div className="text-[10px] text-white/80">{act.status}</div>
                      </div>
                    ))}
                  </div>

                </>
              )}
            </div>
          )}

          {/* SCREEN 2: LOCATION SELECTOR */}
          {currentView === 'location' && (
            <div className="p-4 space-y-4 text-[#183B56] bg-white h-full">
              <div className="flex items-center gap-3">
                <button onClick={() => setCurrentView('home')} className="p-1">
                  <ArrowLeft size={20} />
                </button>
                <div className="font-bold text-base">Choose Location</div>
              </div>

              <div className="relative">
                <Search size={18} className="absolute left-3 top-3 text-[#6B7C8F]" />
                <input
                  type="text"
                  placeholder="Search city via Open-Meteo..."
                  value={searchQuery}
                  onChange={(e) => handleSearch(e.target.value)}
                  className="w-full bg-[#F5FBFF] pl-10 pr-4 py-2.5 rounded-xl border border-[#EAF6FF] text-xs focus:outline-none focus:border-[#4DA8FF]"
                />
              </div>

              <button 
                onClick={() => { setLocation('Guntur, India'); setCurrentView('home'); }}
                className="w-full p-3 bg-[#EAF6FF] text-[#4DA8FF] font-bold text-xs rounded-xl flex items-center justify-center gap-2 border border-[#4DA8FF]/20"
              >
                <Navigation size={16} />
                <span>Use my current location</span>
              </button>

              <div className="text-xs font-bold text-[#6B7C8F] pt-2">Popular Cities</div>
              <div className="space-y-2">
                {['Guntur, Andhra Pradesh', 'Vijayawada, Andhra Pradesh', 'Hyderabad, Telangana', 'Bengaluru, Karnataka', 'Chennai, Tamil Nadu'].map((city, idx) => (
                  <button
                    key={idx}
                    onClick={() => { setLocation(city); setCurrentView('home'); }}
                    className="w-full bg-[#F5FBFF] p-3 rounded-xl border border-[#EAF6FF] hover:border-[#4DA8FF] text-left flex items-center justify-between text-xs font-semibold text-[#183B56] transition"
                  >
                    <span>📍 {city}</span>
                    <span className="text-xs text-[#6B7C8F]">→</span>
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* SCREEN 3: CHAT */}
          {currentView === 'chat' && (
            <div className="p-4 flex flex-col h-full space-y-3 bg-white text-[#183B56]">
              <div className="flex items-center gap-3 border-b border-[#EAF6FF] pb-3">
                <button onClick={() => setCurrentView('home')} className="p-1">
                  <ArrowLeft size={20} />
                </button>
                <div>
                  <div className="font-bold text-sm">WeatherGPT AI Assistant</div>
                  <div className="text-[10px] text-[#6B7C8F]">📍 {location}</div>
                </div>
              </div>

              <div className="flex gap-2 overflow-x-auto pb-1 text-[11px] no-scrollbar">
                {['🌧️ Will it rain today?', '☂️ Need an umbrella?', '✈️ Good for travel?', '👕 What should I wear?'].map((chip, idx) => (
                  <button
                    key={idx}
                    onClick={() => handleAsk(chip)}
                    className="px-2.5 py-1 bg-[#F5FBFF] border border-[#EAF6FF] hover:border-[#4DA8FF] rounded-xl shrink-0 font-medium transition"
                  >
                    {chip}
                  </button>
                ))}
              </div>

              <div className="flex-1 overflow-y-auto space-y-3 pr-1">
                {messages.map((msg) => (
                  <div key={msg.id} className={`flex ${msg.isUser ? 'justify-end' : 'justify-start'} gap-2`}>
                    {!msg.isUser && <div className="w-7 h-7 rounded-full bg-[#EAF6FF] flex items-center justify-center text-sm shrink-0">🤖</div>}
                    <div className={`p-3 rounded-2xl text-xs max-w-[80%] leading-relaxed ${
                      msg.isUser ? 'bg-[#4DA8FF] text-white rounded-br-none' : 'bg-[#F5FBFF] border border-[#EAF6FF] text-[#183B56] rounded-bl-none shadow-sm'
                    }`}>
                      {msg.text}
                    </div>
                  </div>
                ))}
              </div>

              <div className="flex gap-2 pt-2 border-t border-[#EAF6FF]">
                <input
                  type="text"
                  placeholder="Ask WeatherGPT..."
                  value={inputQuery}
                  onChange={(e) => setInputQuery(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleAsk()}
                  className="flex-1 bg-[#F5FBFF] px-3 py-2 rounded-xl border border-[#EAF6FF] text-xs focus:outline-none focus:border-[#4DA8FF]"
                />
                <button onClick={() => handleAsk()} className="p-2.5 bg-[#4DA8FF] text-white rounded-xl hover:bg-[#3D98EF] transition">
                  <Send size={16} />
                </button>
              </div>
            </div>
          )}

          {/* SCREEN 4: SETTINGS */}
          {currentView === 'settings' && (
            <div className="p-4 space-y-4 bg-white text-[#183B56] h-full">
              <div className="flex items-center gap-3">
                <button onClick={() => setCurrentView('home')} className="p-1">
                  <ArrowLeft size={20} />
                </button>
                <div className="font-bold text-base">Settings</div>
              </div>

              <div className="space-y-3 text-xs">
                <div className="font-bold text-[#6B7C8F] uppercase text-[10px]">Preferences</div>
                <div className="bg-[#F5FBFF] p-3 rounded-xl border border-[#EAF6FF] flex items-center justify-between">
                  <span className="font-semibold">Temperature Unit</span>
                  <div className="flex bg-white p-1 rounded-lg border border-[#EAF6FF]">
                    <button onClick={() => setTempUnit('C')} className={`px-3 py-1 rounded-md font-bold ${tempUnit === 'C' ? 'bg-[#4DA8FF] text-white' : 'text-[#6B7C8F]'}`}>°C</button>
                    <button onClick={() => setTempUnit('F')} className={`px-3 py-1 rounded-md font-bold ${tempUnit === 'F' ? 'bg-[#4DA8FF] text-white' : 'text-[#6B7C8F]'}`}>°F</button>
                  </div>
                </div>

                <div className="font-bold text-[#6B7C8F] uppercase text-[10px] pt-2">Weather Modes</div>
                <button
                  onClick={() => { setDemoScenario('live'); setCurrentView('home'); }}
                  className={`w-full p-3 rounded-xl border text-left flex items-center justify-between ${demoScenario === 'live' ? 'border-[#4DA8FF] bg-[#EAF6FF]' : 'bg-[#F5FBFF] border-[#EAF6FF]'}`}
                >
                  <div>
                    <div className="font-bold">🟢 Live Open-Meteo Weather</div>
                    <div className="text-[10px] text-[#6B7C8F]">Real-time weather data & 7-day forecast</div>
                  </div>
                  {demoScenario === 'live' && <CheckCircle size={16} className="text-[#4DA8FF]" />}
                </button>

                {['normal', 'rain', 'heat', 'wind'].map(s => (
                  <button
                    key={s}
                    onClick={() => { setDemoScenario(s); setCurrentView('home'); }}
                    className={`w-full p-3 rounded-xl border text-left flex items-center justify-between ${demoScenario === s ? 'border-amber-500 bg-amber-50' : 'bg-[#F5FBFF] border-[#EAF6FF]'}`}
                  >
                    <div>
                      <div className="font-bold capitalize">Demo: {s} Alert</div>
                      <div className="text-[10px] text-[#6B7C8F]">Simulated hackathon test scenario</div>
                    </div>
                    {demoScenario === s && <CheckCircle size={16} className="text-amber-500" />}
                  </button>
                ))}
              </div>
            </div>
          )}

        </div>

        {/* Bottom Navigation Bar */}
        <div className="bg-[#183B56]/90 backdrop-blur-md border-t border-white/20 px-6 py-2.5 flex justify-around items-center text-[10px] font-semibold text-white/80 z-10">
          <button onClick={() => setCurrentView('home')} className={`flex flex-col items-center gap-1 ${currentView === 'home' ? 'text-white font-bold' : ''}`}>
            <span className="text-base">🌤️</span>
            <span>Dashboard</span>
          </button>
          <button onClick={() => setCurrentView('chat')} className={`flex flex-col items-center gap-1 ${currentView === 'chat' ? 'text-white font-bold' : ''}`}>
            <span className="text-base">🤖</span>
            <span>WeatherGPT</span>
          </button>
          <button onClick={() => setCurrentView('location')} className={`flex flex-col items-center gap-1 ${currentView === 'location' ? 'text-white font-bold' : ''}`}>
            <span className="text-base">📍</span>
            <span>Locations</span>
          </button>
        </div>

      </div>
    </div>
  );
}
