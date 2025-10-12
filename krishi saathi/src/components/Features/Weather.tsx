import { useState } from 'react';
import { useLanguage } from '../../contexts/LanguageContext';
import { Cloud, Droplets, Wind, Thermometer, Search } from 'lucide-react';

type WeatherForecast = {
  date: string;
  temp: number;
  humidity: number;
  rainfall: number;
  description: string;
};

export function Weather() {
  const { t } = useLanguage();
  const [city, setCity] = useState('');
  const [loading, setLoading] = useState(false);
  const [weatherData, setWeatherData] = useState<any>(null);
  const [forecast, setForecast] = useState<WeatherForecast[]>([]);

  const searchWeather = async () => {
    if (!city) return;

    setLoading(true);
    try {
      const mockWeatherData = {
        city: city,
        temperature: 28 + Math.random() * 10,
        humidity: 60 + Math.random() * 30,
        rainfall: Math.random() * 10,
        windSpeed: 10 + Math.random() * 20,
      };

      const mockForecast: WeatherForecast[] = Array.from({ length: 5 }, (_, i) => ({
        date: new Date(Date.now() + i * 24 * 60 * 60 * 1000).toLocaleDateString(),
        temp: 25 + Math.random() * 10,
        humidity: 60 + Math.random() * 30,
        rainfall: Math.random() * 15,
        description: ['Sunny', 'Partly Cloudy', 'Cloudy', 'Rainy'][Math.floor(Math.random() * 4)],
      }));

      setWeatherData(mockWeatherData);
      setForecast(mockForecast);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-3 mb-6">
        <Cloud className="w-8 h-8 text-green-700" />
        <div>
          <h2 className="text-3xl font-bold text-gray-800">{t('weather')}</h2>
          <p className="text-gray-600">Weather forecast and conditions</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="flex gap-4 mb-6">
          <input
            type="text"
            value={city}
            onChange={(e) => setCity(e.target.value)}
            placeholder={t('searchCity')}
            className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
          />
          <button
            onClick={searchWeather}
            disabled={loading}
            className="bg-green-700 text-white px-6 py-2 rounded-lg font-medium hover:bg-green-800 transition-colors flex items-center space-x-2 disabled:bg-gray-400"
          >
            <Search className="w-5 h-5" />
            <span>{t('search')}</span>
          </button>
        </div>

        {loading ? (
          <div className="text-center py-12">
            <div className="inline-block animate-spin rounded-full h-12 w-12 border-4 border-green-700 border-t-transparent"></div>
          </div>
        ) : weatherData ? (
          <div className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div className="bg-gradient-to-br from-orange-50 to-orange-100 rounded-lg p-4">
                <div className="flex items-center space-x-3">
                  <Thermometer className="w-8 h-8 text-orange-600" />
                  <div>
                    <p className="text-sm text-gray-600">{t('temperature')}</p>
                    <p className="text-2xl font-bold text-gray-800">
                      {weatherData.temperature.toFixed(1)}°C
                    </p>
                  </div>
                </div>
              </div>

              <div className="bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg p-4">
                <div className="flex items-center space-x-3">
                  <Droplets className="w-8 h-8 text-blue-600" />
                  <div>
                    <p className="text-sm text-gray-600">{t('humidity')}</p>
                    <p className="text-2xl font-bold text-gray-800">
                      {weatherData.humidity.toFixed(0)}%
                    </p>
                  </div>
                </div>
              </div>

              <div className="bg-gradient-to-br from-cyan-50 to-cyan-100 rounded-lg p-4">
                <div className="flex items-center space-x-3">
                  <Cloud className="w-8 h-8 text-cyan-600" />
                  <div>
                    <p className="text-sm text-gray-600">{t('rainfall')}</p>
                    <p className="text-2xl font-bold text-gray-800">
                      {weatherData.rainfall.toFixed(1)}mm
                    </p>
                  </div>
                </div>
              </div>

              <div className="bg-gradient-to-br from-teal-50 to-teal-100 rounded-lg p-4">
                <div className="flex items-center space-x-3">
                  <Wind className="w-8 h-8 text-teal-600" />
                  <div>
                    <p className="text-sm text-gray-600">{t('windSpeed')}</p>
                    <p className="text-2xl font-bold text-gray-800">
                      {weatherData.windSpeed.toFixed(1)} km/h
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <div>
              <h3 className="text-xl font-bold text-gray-800 mb-4">
                5-Day {t('forecast')}
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
                {forecast.map((day, index) => (
                  <div key={index} className="bg-gray-50 rounded-lg p-4 text-center">
                    <p className="text-sm font-medium text-gray-600 mb-2">{day.date}</p>
                    <p className="text-2xl font-bold text-gray-800 mb-2">
                      {day.temp.toFixed(1)}°C
                    </p>
                    <p className="text-sm text-gray-600 mb-1">{day.description}</p>
                    <div className="flex justify-center space-x-4 text-xs text-gray-500">
                      <span>💧 {day.humidity.toFixed(0)}%</span>
                      <span>🌧️ {day.rainfall.toFixed(1)}mm</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        ) : (
          <div className="text-center py-12">
            <Cloud className="w-16 h-16 text-gray-300 mx-auto mb-4" />
            <p className="text-gray-500">{t('noData')}</p>
            <p className="text-sm text-gray-400 mt-2">Enter a city name to get weather information</p>
          </div>
        )}
      </div>
    </div>
  );
}
