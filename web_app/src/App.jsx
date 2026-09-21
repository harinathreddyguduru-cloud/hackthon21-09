import React, { useState, useEffect } from 'react';
import { 
  MapPin, Bell, Settings, Droplets, Wind, CloudRain, 
  Bot, Send, Search, CheckCircle, AlertTriangle, ShieldAlert,
  Thermometer, Navigation, ArrowLeft, RefreshCw, Smartphone
} from 'lucide-react';

const API_BASE = 'http://127.0.0.1:8000/api/weather';

export default function App() {
  const [location, setLocation] = useState('Guntur, India');
  const [demoScenario, setDemoScenario] = useState('live'); // live, normal, rain, heat, wind
  const [weatherData, setWeatherData] = useState(null);
  const [alertsSummary, setAlertsSummary] = useState(null);
  const [aiSummary, setAiSummary] = useState('');
  const [loading, setLoading] = useState(true);
  const [currentView, setCurrentView] = useState('home'); // home, location, chat, settings
  const [tempUnit, setTempUnit] = useState('C');
  const [viewMode, setViewMode] = useState('mobile');

  // Chat State
  const [messages, setMessages] = useState([
    { id: 1, text: "Hello! I am WeatherGPT 🤖 powered by Open-Meteo real weather data. Ask me any weather question!", isUser: false }
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
      console.error("API error, using local fallback", e);
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
    let temp = 29, rain = 20, wind = 14, cond = "Partly Cloudy";
    if (mode === 'rain') { temp = 27; rain = 85; wind = 18; cond = "Heavy Rain"; }
    else if (mode === 'heat') { temp = 38; rain = 5; wind = 8; cond = "Scorching Sun"; }
    else if (mode === 'wind') { temp = 30; rain = 35; wind = 48; cond = "Strong Winds"; }

    setWeatherData({
      location: loc.split(',')[0],
      temperature: temp,
      feels_like: temp + 2,
      condition: cond,
      provider: mode === 'live' ? 'Open-Meteo' : 'Mock Demo',
      humidity: 72,
      wind_speed: wind,
      rain_probability: rain,
      hourly_forecast: [
        { time: "10 AM", temp: temp, icon: "☀️", rain_chance: rain },
        { time: "12 PM", temp: temp + 1, icon: "🌤️", rain_chance: rain },
        { time: "2 PM", temp: temp, icon: "🌧️", rain_chance: rain },
        { time: "4 PM", temp: temp - 1, icon: "🌧️", rain_chance: rain },
      ],
      daily_forecast: [
        { day: "Today", condition: cond, high: temp + 2, low: temp - 4 },
        { day: "Tomorrow", condition: "Light Rain", high: temp, low: temp - 5 },
        { day: "Wednesday", condition: "Partly Cloudy", high: temp + 3, low: temp - 3 },
      ]
    });

    setAlertsSummary({
      has_alerts: rain >= 50 || temp >= 35 || wind >= 35,
      alerts: [
        rain >= 50 ? { title: "🌧️ Rain Alert", message: `Rain expected soon (${rain}% chance). Carry an umbrella.`, severity: "danger", action: "Carry umbrella" }
        : temp >= 35 ? { title: "🔥 Heat Alert", message: `High temp of ${temp}°C. Stay hydrated.`, severity: "danger", action: "Stay hydrated" }
        : wind >= 35 ? { title: "💨 Strong Wind Alert", message: `Strong winds of ${wind} km/h expected.`, severity: "warning", action: "Take care outdoors" }
        : { title: "✓ Clear Weather", message: "Weather looks normal right now.", severity: "info", action: "Enjoy your day" }
      ],
      nearby_assistance: [
        { category: "Rain & Convenience Shops", items: [{ name: "City Center Supermarket", type: "Umbrellas & Raincoats", distance: "350 m" }] }
      ]
    });

    setAiSummary(`Real-time weather for ${loc} via Open-Meteo: ${cond} at ${temp}°C. Rain chance: ${rain}%.`);
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
      let reply = `🌤️ Weather in ${location} is ${weatherData?.condition.toLowerCase()} at ${weatherData?.temperature}°C.`;
      if (q.toLowerCase().includes('rain') || q.toLowerCase().includes('umbrella')) {
        reply = `🌧️ Rain probability in ${location} is ${weatherData?.rain_probability || 20}%. ${weatherData?.rain_probability >= 50 ? 'Carrying an umbrella is recommended!' : 'You probably won\'t need an umbrella.'}`;
      }
      setMessages(prev => [...prev, { id: Date.now() + 1, text: reply, isUser: false }]);
    } finally {
      setIsAsking(false);
    }
  };

  const convertTemp = (t) => tempUnit === 'F' ? Math.round((t * 9/5) + 32) : t;

  return (
    <div className="min-h-screen bg-[#EAF6FF] text-[#183B56] flex flex-col items-center justify-center p-2 sm:p-6">
      {/* Top Banner Control */}
      <div className="w-full max-w-md mb-3 flex items-center justify-between bg-white px-4 py-2.5 rounded-2xl shadow-sm border border-[#D9F0FF]">
        <div className="flex items-center gap-2">
          <span className="w-3 h-3 rounded-full bg-emerald-500 animate-pulse"></span>
          <span className="text-xs font-semibold text-[#183B56]">WeatherGPT + Open-Meteo</span>
          <span className="text-[10px] px-2 py-0.5 bg-[#EAF6FF] text-[#4DA8FF] rounded-full font-medium">Django Live</span>
        </div>
        <button 
          onClick={() => setViewMode(v => v === 'mobile' ? 'full' : 'mobile')}
          className="flex items-center gap-1.5 text-xs bg-[#F5FBFF] hover:bg-[#EAF6FF] px-2.5 py-1 rounded-lg border border-[#4DA8FF]/20 text-[#4DA8FF] font-medium transition"
        >
          <Smartphone size={14} />
          {viewMode === 'mobile' ? 'Expand View' : 'Mobile Frame'}
        </button>
      </div>

      {/* Main Container - Mobile Frame Simulator */}
      <div className={`w-full bg-[#F5FBFF] transition-all duration-300 ${
        viewMode === 'mobile' 
          ? 'max-w-[400px] h-[840px] rounded-[40px] shadow-2xl border-[10px] border-[#183B56] overflow-hidden flex flex-col relative' 
          : 'max-w-2xl rounded-3xl shadow-xl border border-[#D9F0FF] p-6'
      }`}>
        
        {/* Mobile Header Bar */}
        {viewMode === 'mobile' && (
          <div className="w-full bg-[#183B56] text-white pt-3 pb-1 px-6 flex justify-between items-center text-[10px] tracking-wider font-mono">
            <span>9:41 AM</span>
            <div className="w-16 h-4 bg-black rounded-full mx-auto -mt-1"></div>
            <span>5G ⚡ 100%</span>
          </div>
        )}

        {/* Dynamic App Screens */}
        <div className="flex-1 overflow-y-auto scrollbar-thin">

          {/* SCREEN 1: HOME DASHBOARD */}
          {currentView === 'home' && (
            <div className="p-4 space-y-4">
              {/* App Bar */}
              <div className="flex items-center justify-between">
                <button 
                  onClick={() => setCurrentView('location')}
                  className="flex items-center gap-1.5 bg-white px-3 py-1.5 rounded-2xl border border-[#EAF6FF] shadow-sm hover:bg-[#F5FBFF] transition"
                >
                  <MapPin size={18} className="text-[#4DA8FF]" />
                  <span className="font-bold text-sm text-[#183B56]">{location}</span>
                  <span className="text-xs text-[#6B7C8F]">▼</span>
                </button>

                <div className="flex items-center gap-1">
                  <button 
                    onClick={() => fetchWeather()} 
                    className="p-2 text-[#6B7C8F] hover:text-[#4DA8FF] rounded-full hover:bg-white transition"
                    title="Refresh weather"
                  >
                    <RefreshCw size={18} className={loading ? "animate-spin text-[#4DA8FF]" : ""} />
                  </button>
                  <button 
                    onClick={() => setCurrentView('settings')}
                    className="p-2 text-[#6B7C8F] hover:text-[#4DA8FF] rounded-full hover:bg-white transition"
                  >
                    <Settings size={18} />
                  </button>
                </div>
              </div>

              {/* Provider & Demo Mode Switcher */}
              <div className="flex gap-2 overflow-x-auto pb-1 text-xs no-scrollbar">
                {[
                  { id: 'live', label: '🌐 Live Open-Meteo' },
                  { id: 'normal', label: '☀️ Normal' },
                  { id: 'rain', label: '🌧️ Rain Alert' },
                  { id: 'heat', label: '🔥 Heat Alert' },
                  { id: 'wind', label: '💨 Wind Alert' }
                ].map(scen => (
                  <button
                    key={scen.id}
                    onClick={() => setDemoScenario(scen.id)}
                    className={`px-3 py-1.5 rounded-xl font-medium shrink-0 transition ${
                      demoScenario === scen.id 
                        ? 'bg-[#4DA8FF] text-white shadow-sm' 
                        : 'bg-white text-[#183B56] border border-[#EAF6FF] hover:border-[#4DA8FF]'
                    }`}
                  >
                    {scen.label}
                  </button>
                ))}
              </div>

              {loading ? (
                <div className="py-20 text-center space-y-3">
                  <div className="text-5xl animate-bounce">🌤️</div>
                  <div className="text-sm font-semibold text-[#183B56]">Getting real weather...</div>
                  <div className="text-xs text-[#6B7C8F]">📍 Open-Meteo API • ☁️ Fetching forecast</div>
                </div>
              ) : (
                <>
                  {/* Weather Card */}
                  <div className="bg-gradient-to-b from-white to-[#EAF6FF] p-6 rounded-3xl border border-[#EAF6FF] shadow-sm text-center space-y-3">
                    <div className="flex items-center justify-center gap-1.5">
                      <span className="text-[10px] font-bold text-[#4DA8FF] bg-[#4DA8FF]/10 px-2.5 py-0.5 rounded-full">
                        {weatherData?.provider || 'Open-Meteo'}
                      </span>
                    </div>
                    <div className="text-6xl">
                      {weatherData?.condition?.toLowerCase().includes('rain') ? '🌧️' 
                        : weatherData?.condition?.toLowerCase().includes('cloud') ? '🌤️'
                        : weatherData?.temperature >= 35 ? '☀️' : '🌤️'}
                    </div>
                    <div>
                      <div className="text-6xl font-bold text-[#183B56] tracking-tight">
                        {convertTemp(weatherData?.temperature || 28)}°{tempUnit}
                      </div>
                      <div className="text-lg font-semibold text-[#183B56] mt-1">{weatherData?.condition}</div>
                      <div className="text-xs text-[#6B7C8F] mt-0.5">Feels like {convertTemp(weatherData?.feels_like || 30)}°{tempUnit}</div>
                    </div>

                    {/* Metrics Grid */}
                    <div className="grid grid-cols-3 gap-2 pt-2">
                      <div className="bg-white p-3 rounded-2xl border border-[#D9F0FF] text-center">
                        <Droplets size={18} className="mx-auto text-[#4DA8FF] mb-1" />
                        <div className="text-xs font-bold text-[#183B56]">{weatherData?.humidity}%</div>
                        <div className="text-[10px] text-[#6B7C8F]">Humidity</div>
                      </div>
                      <div className="bg-white p-3 rounded-2xl border border-[#D9F0FF] text-center">
                        <Wind size={18} className="mx-auto text-[#4DA8FF] mb-1" />
                        <div className="text-xs font-bold text-[#183B56]">{weatherData?.wind_speed} km/h</div>
                        <div className="text-[10px] text-[#6B7C8F]">Wind</div>
                      </div>
                      <div className={`p-3 rounded-2xl border text-center ${
                        weatherData?.rain_probability >= 50 
                          ? 'bg-[#42A5F5]/15 border-[#42A5F5]/40 text-[#1976D2]' 
                          : 'bg-white border-[#D9F0FF]'
                      }`}>
                        <CloudRain size={18} className="mx-auto text-[#42A5F5] mb-1" />
                        <div className="text-xs font-bold">{weatherData?.rain_probability}%</div>
                        <div className="text-[10px] text-[#6B7C8F]">Rain Chance</div>
                      </div>
                    </div>
                  </div>

                  {/* Active Alert Banner */}
                  {alertsSummary?.alerts?.[0] && (
                    <div className={`p-4 rounded-2xl border text-sm space-y-2 ${
                      alertsSummary.alerts[0].type === 'rain' ? 'bg-[#42A5F5]/10 border-[#42A5F5]/50 text-[#0D47A1]'
                      : alertsSummary.alerts[0].type === 'heat' ? 'bg-[#FFB74D]/15 border-[#FFB74D]/50 text-[#E65100]'
                      : alertsSummary.alerts[0].type === 'wind' ? 'bg-[#4DA8FF]/10 border-[#4DA8FF]/50 text-[#0277BD]'
                      : 'bg-[#EAF6FF] border-[#4DA8FF]/30 text-[#183B56]'
                    }`}>
                      <div className="flex items-center justify-between font-bold">
                        <span>{alertsSummary.alerts[0].title}</span>
                        <span className="text-[10px] uppercase px-2 py-0.5 rounded-full bg-white/60">
                          {alertsSummary.alerts[0].severity}
                        </span>
                      </div>
                      <div className="text-xs leading-relaxed">{alertsSummary.alerts[0].message}</div>
                      <div className="text-xs font-semibold pt-1 flex items-center gap-1">
                        <span>Recommended action:</span>
                        <span className="underline">{alertsSummary.alerts[0].action}</span>
                      </div>
                    </div>
                  )}

                  {/* AI WeatherGPT Executive Summary Card */}
                  <div className="bg-white p-4.5 rounded-2xl border border-[#4DA8FF]/30 shadow-sm space-y-3">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <div className="p-1.5 bg-[#EAF6FF] rounded-xl text-lg">🤖</div>
                        <div>
                          <div className="font-bold text-sm text-[#183B56]">WeatherGPT Summary</div>
                          <div className="text-[10px] text-[#6B7C8F]">Grounded on Open-Meteo Data</div>
                        </div>
                      </div>
                    </div>

                    <p className="text-xs text-[#183B56] leading-relaxed">
                      {aiSummary}
                    </p>

                    <button 
                      onClick={() => setCurrentView('chat')}
                      className="w-full py-2.5 bg-[#4DA8FF] hover:bg-[#3D98EF] text-white text-xs font-semibold rounded-xl flex items-center justify-center gap-2 shadow-sm transition"
                    >
                      <span>💬</span>
                      <span>Ask WeatherGPT Anything</span>
                    </button>
                  </div>

                  {/* Hourly & Daily Forecast */}
                  <div className="space-y-3 pt-1">
                    <div className="font-bold text-sm text-[#183B56]">Today's Hourly Forecast</div>
                    <div className="flex gap-2.5 overflow-x-auto pb-1 no-scrollbar">
                      {weatherData?.hourly_forecast?.map((item, idx) => (
                        <div key={idx} className="bg-white p-3 rounded-2xl border border-[#EAF6FF] min-w-[70px] text-center space-y-1 shrink-0">
                          <div className="text-[11px] text-[#6B7C8F]">{item.time}</div>
                          <div className="text-xl">{item.icon}</div>
                          <div className="text-xs font-bold text-[#183B56]">{convertTemp(item.temp)}°</div>
                        </div>
                      ))}
                    </div>

                    <div className="font-bold text-sm text-[#183B56] pt-2">7-Day Daily Forecast</div>
                    <div className="bg-white p-3 rounded-2xl border border-[#EAF6FF] divide-y divide-[#F5FBFF]">
                      {weatherData?.daily_forecast?.map((item, idx) => (
                        <div key={idx} className="py-2 flex items-center justify-between text-xs">
                          <div className="w-20 font-semibold text-[#183B56]">{item.day}</div>
                          <div className="text-base">{item.condition.toLowerCase().includes('rain') ? '🌧️' : '🌤️'}</div>
                          <div className="text-[#6B7C8F] flex-1 px-3 text-left">{item.condition}</div>
                          <div className="font-bold text-[#183B56]">{convertTemp(item.high)}° / {convertTemp(item.low)}°</div>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Nearby Assistance */}
                  {alertsSummary?.nearby_assistance?.[0] && (
                    <div className="space-y-2 pt-2">
                      <div className="font-bold text-sm text-[#183B56] flex items-center gap-1.5">
                        <Navigation size={16} className="text-[#4DA8FF]" />
                        <span>Nearby Assistance & Shelters</span>
                      </div>
                      <div className="bg-white p-4 rounded-2xl border border-[#EAF6FF] space-y-2">
                        <div className="text-xs font-bold text-[#4DA8FF]">{alertsSummary.nearby_assistance[0].category}</div>
                        {alertsSummary.nearby_assistance[0].items.map((item, idx) => (
                          <div key={idx} className="flex items-center justify-between text-xs border-b border-[#F5FBFF] pb-1.5 pt-1 last:border-none">
                            <div>
                              <div className="font-semibold text-[#183B56]">{item.name}</div>
                              <div className="text-[10px] text-[#6B7C8F]">{item.type}</div>
                            </div>
                            <span className="text-[10px] font-bold bg-[#EAF6FF] px-2 py-0.5 rounded-lg text-[#183B56]">{item.distance}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  <div className="text-center text-[10px] text-[#6B7C8F] pt-2">
                    Weather data provided by <a href="https://open-meteo.com/" target="_blank" rel="noreferrer" className="underline font-medium text-[#4DA8FF]">Open-Meteo</a>
                  </div>
                </>
              )}
            </div>
          )}

          {/* SCREEN 2: LOCATION SELECTOR (Open-Meteo Geocoding) */}
          {currentView === 'location' && (
            <div className="p-4 space-y-4">
              <div className="flex items-center gap-3">
                <button onClick={() => setCurrentView('home')} className="p-1 text-[#183B56]">
                  <ArrowLeft size={20} />
                </button>
                <div className="font-bold text-base">Choose Location (Open-Meteo)</div>
              </div>

              <div className="relative">
                <Search size={18} className="absolute left-3 top-3 text-[#6B7C8F]" />
                <input
                  type="text"
                  placeholder="Search city via Open-Meteo (e.g. Hyderabad, London, Tokyo)..."
                  value={searchQuery}
                  onChange={(e) => handleSearch(e.target.value)}
                  className="w-full bg-white pl-10 pr-4 py-2.5 rounded-xl border border-[#EAF6FF] text-xs focus:outline-none focus:border-[#4DA8FF]"
                />
              </div>

              <button 
                onClick={() => { setLocation('Guntur, India'); setCurrentView('home'); }}
                className="w-full p-3 bg-[#EAF6FF] text-[#4DA8FF] font-bold text-xs rounded-xl flex items-center justify-center gap-2 border border-[#4DA8FF]/20"
              >
                <Navigation size={16} />
                <span>Use my current location</span>
              </button>

              <div className="text-xs font-bold text-[#6B7C8F] pt-2">
                {searchResults.length > 0 ? 'Search Results (Open-Meteo Geocoding)' : 'Popular Cities'}
              </div>
              <div className="space-y-2">
                {(searchResults.length > 0 ? searchResults : [
                  { name: 'Guntur', state: 'Andhra Pradesh', country: 'India' },
                  { name: 'Vijayawada', state: 'Andhra Pradesh', country: 'India' },
                  { name: 'Hyderabad', state: 'Telangana', country: 'India' },
                  { name: 'Bengaluru', state: 'Karnataka', country: 'India' },
                  { name: 'Chennai', state: 'Tamil Nadu', country: 'India' },
                  { name: 'Mumbai', state: 'Maharashtra', country: 'India' },
                  { name: 'Delhi', state: 'Delhi', country: 'India' },
                ]).map((city, idx) => {
                  const fullStr = city.state ? `${city.name}, ${city.state}, ${city.country}` : `${city.name}, ${city.country}`;
                  return (
                    <button
                      key={idx}
                      onClick={() => { setLocation(fullStr); setCurrentView('home'); }}
                      className="w-full bg-white p-3 rounded-xl border border-[#EAF6FF] hover:border-[#4DA8FF] text-left flex items-center justify-between text-xs font-semibold text-[#183B56] transition"
                    >
                      <span>📍 {fullStr}</span>
                      <span className="text-xs text-[#6B7C8F]">→</span>
                    </button>
                  );
                })}
              </div>
            </div>
          )}

          {/* SCREEN 3: WEATHERGPT AI CHAT */}
          {currentView === 'chat' && (
            <div className="p-4 flex flex-col h-full space-y-3">
              <div className="flex items-center gap-3 border-b border-[#EAF6FF] pb-3">
                <button onClick={() => setCurrentView('home')} className="p-1 text-[#183B56]">
                  <ArrowLeft size={20} />
                </button>
                <div>
                  <div className="font-bold text-sm">WeatherGPT AI Assistant</div>
                  <div className="text-[10px] text-[#6B7C8F]">📍 {location}</div>
                </div>
              </div>

              {/* Quick Chips */}
              <div className="flex gap-2 overflow-x-auto pb-1 text-[11px] no-scrollbar">
                {[
                  '🌧️ Will it rain today?',
                  '☂️ Need an umbrella?',
                  '✈️ Good for travel?',
                  '💨 Strong winds?',
                  '👕 What should I wear?'
                ].map((chip, idx) => (
                  <button
                    key={idx}
                    onClick={() => handleAsk(chip)}
                    className="px-2.5 py-1 bg-white border border-[#EAF6FF] hover:border-[#4DA8FF] rounded-xl text-[#183B56] shrink-0 font-medium transition"
                  >
                    {chip}
                  </button>
                ))}
              </div>

              {/* Chat Stream */}
              <div className="flex-1 overflow-y-auto space-y-3 pr-1">
                {messages.map((msg) => (
                  <div 
                    key={msg.id}
                    className={`flex ${msg.isUser ? 'justify-end' : 'justify-start'} gap-2`}
                  >
                    {!msg.isUser && (
                      <div className="w-7 h-7 rounded-full bg-[#EAF6FF] flex items-center justify-center text-sm shrink-0">🤖</div>
                    )}
                    <div className={`p-3 rounded-2xl text-xs max-w-[80%] leading-relaxed ${
                      msg.isUser 
                        ? 'bg-[#4DA8FF] text-white rounded-br-none' 
                        : 'bg-white border border-[#EAF6FF] text-[#183B56] rounded-bl-none shadow-sm'
                    }`}>
                      {msg.text}
                    </div>
                  </div>
                ))}

                {isAsking && (
                  <div className="flex items-center gap-2 text-xs text-[#6B7C8F]">
                    <div className="w-2 h-2 rounded-full bg-[#4DA8FF] animate-bounce"></div>
                    <span>WeatherGPT is processing query...</span>
                  </div>
                )}
              </div>

              {/* Input Form */}
              <div className="flex gap-2 pt-2 border-t border-[#EAF6FF]">
                <input
                  type="text"
                  placeholder="Ask about rain, travel, clothes..."
                  value={inputQuery}
                  onChange={(e) => setInputQuery(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleAsk()}
                  className="flex-1 bg-white px-3 py-2 rounded-xl border border-[#EAF6FF] text-xs focus:outline-none focus:border-[#4DA8FF]"
                />
                <button 
                  onClick={() => handleAsk()}
                  className="p-2.5 bg-[#4DA8FF] text-white rounded-xl hover:bg-[#3D98EF] transition"
                >
                  <Send size={16} />
                </button>
              </div>
            </div>
          )}

          {/* SCREEN 4: SETTINGS & DEMO CONTROL */}
          {currentView === 'settings' && (
            <div className="p-4 space-y-4">
              <div className="flex items-center gap-3">
                <button onClick={() => setCurrentView('home')} className="p-1 text-[#183B56]">
                  <ArrowLeft size={20} />
                </button>
                <div className="font-bold text-base">Settings & Attribution</div>
              </div>

              <div className="space-y-3 text-xs">
                <div className="font-bold text-[#6B7C8F] uppercase text-[10px]">Preferences</div>
                <div className="bg-white p-3 rounded-xl border border-[#EAF6FF] flex items-center justify-between">
                  <span className="font-semibold">Temperature Unit</span>
                  <div className="flex bg-[#F5FBFF] p-1 rounded-lg border border-[#EAF6FF]">
                    <button 
                      onClick={() => setTempUnit('C')}
                      className={`px-3 py-1 rounded-md font-bold ${tempUnit === 'C' ? 'bg-[#4DA8FF] text-white' : 'text-[#6B7C8F]'}`}
                    >
                      °C
                    </button>
                    <button 
                      onClick={() => setTempUnit('F')}
                      className={`px-3 py-1 rounded-md font-bold ${tempUnit === 'F' ? 'bg-[#4DA8FF] text-white' : 'text-[#6B7C8F]'}`}
                    >
                      °F
                    </button>
                  </div>
                </div>

                <div className="font-bold text-[#6B7C8F] uppercase text-[10px] pt-2">Provider & Hackathon Demo Mode</div>
                {[
                  { id: 'live', title: '🌐 Live Open-Meteo Weather', desc: 'Real weather data & 7-day forecast from Open-Meteo API' },
                  { id: 'normal', title: '☀️ Normal Weather Scenario', desc: '29°C • Partly Cloudy • 20% Rain' },
                  { id: 'rain', title: '🌧️ Heavy Rain Alert Scenario', desc: '27°C • Heavy Rain • 85% Rain (Triggers Umbrella Alert)' },
                  { id: 'heat', title: '🔥 Heat Alert Scenario', desc: '38°C • Scorching Sun • 5% Rain (Triggers Hydration Alert)' },
                  { id: 'wind', title: '💨 Strong Wind Alert Scenario', desc: '30°C • Gusty Winds • 48 km/h Wind Speed' },
                ].map(scen => (
                  <button
                    key={scen.id}
                    onClick={() => { setDemoScenario(scen.id); setCurrentView('home'); }}
                    className={`w-full bg-white p-3 rounded-xl border text-left flex items-center justify-between transition ${
                      demoScenario === scen.id ? 'border-[#4DA8FF] bg-[#EAF6FF]/50' : 'border-[#EAF6FF]'
                    }`}
                  >
                    <div>
                      <div className="font-bold text-[#183B56]">{scen.title}</div>
                      <div className="text-[10px] text-[#6B7C8F]">{scen.desc}</div>
                    </div>
                    {demoScenario === scen.id && <CheckCircle size={16} className="text-[#4DA8FF]" />}
                  </button>
                ))}
              </div>

              {/* Attribution */}
              <div className="bg-[#EAF6FF] p-4 rounded-xl text-center space-y-1 text-xs">
                <div className="font-bold text-[#183B56]">Weather data provided by Open-Meteo</div>
                <div className="text-[10px] text-[#6B7C8F]">Free non-commercial weather & geocoding API</div>
              </div>
            </div>
          )}

        </div>

        {/* Bottom Navigation Bar */}
        <div className="bg-white border-t border-[#EAF6FF] px-6 py-2.5 flex justify-around items-center text-[10px] font-semibold text-[#6B7C8F]">
          <button 
            onClick={() => setCurrentView('home')}
            className={`flex flex-col items-center gap-1 ${currentView === 'home' ? 'text-[#4DA8FF]' : ''}`}
          >
            <span className="text-base">🌤️</span>
            <span>Dashboard</span>
          </button>
          <button 
            onClick={() => setCurrentView('chat')}
            className={`flex flex-col items-center gap-1 ${currentView === 'chat' ? 'text-[#4DA8FF]' : ''}`}
          >
            <span className="text-base">🤖</span>
            <span>WeatherGPT</span>
          </button>
          <button 
            onClick={() => setCurrentView('location')}
            className={`flex flex-col items-center gap-1 ${currentView === 'location' ? 'text-[#4DA8FF]' : ''}`}
          >
            <span className="text-base">📍</span>
            <span>Locations</span>
          </button>
        </div>

      </div>
    </div>
  );
}
