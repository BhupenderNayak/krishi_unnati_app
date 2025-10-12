import { useState } from 'react';
import { useLanguage } from '../../contexts/LanguageContext';
import { useAuth } from '../../contexts/AuthContext';
import { supabase } from '../../lib/supabase';
import { Sprout, Sparkles } from 'lucide-react';

type RecommendedCrop = {
  name: string;
  name_hi: string;
  score: number;
  reason: string;
  reason_hi: string;
};

export function CropRecommendation() {
  const { t, language } = useLanguage();
  const { user } = useAuth();
  const [region, setRegion] = useState('');
  const [soilType, setSoilType] = useState('');
  const [season, setSeason] = useState('');
  const [loading, setLoading] = useState(false);
  const [recommendations, setRecommendations] = useState<RecommendedCrop[]>([]);

  const soilTypes = [
    'Alluvial',
    'Black (Regur)',
    'Red',
    'Laterite',
    'Desert',
    'Mountain',
    'Loamy',
    'Clay',
    'Sandy',
  ];

  const seasons = ['kharif', 'rabi', 'zaid', 'perennial'];

  const getRecommendations = async () => {
    if (!region || !soilType || !season) return;

    setLoading(true);
    try {
      const mockRecommendations: RecommendedCrop[] = [];

      if (season === 'kharif') {
        mockRecommendations.push(
          {
            name: 'Rice',
            name_hi: 'धान',
            score: 95,
            reason: 'Excellent for monsoon season, high water availability',
            reason_hi: 'मानसून के मौसम के लिए उत्तम, उच्च जल उपलब्धता',
          },
          {
            name: 'Cotton',
            name_hi: 'कपास',
            score: 88,
            reason: 'Suitable for black soil, good market demand',
            reason_hi: 'काली मिट्टी के लिए उपयुक्त, अच्छी बाजार मांग',
          },
          {
            name: 'Maize',
            name_hi: 'मक्का',
            score: 82,
            reason: 'Versatile crop, moderate water requirement',
            reason_hi: 'बहुमुखी फसल, मध्यम जल आवश्यकता',
          }
        );
      } else if (season === 'rabi') {
        mockRecommendations.push(
          {
            name: 'Wheat',
            name_hi: 'गेहूं',
            score: 93,
            reason: 'Perfect for winter season, loamy soil',
            reason_hi: 'सर्दियों के मौसम के लिए बिल्कुल सही, दोमट मिट्टी',
          },
          {
            name: 'Chickpea',
            name_hi: 'चना',
            score: 87,
            reason: 'Low water requirement, good protein source',
            reason_hi: 'कम पानी की आवश्यकता, अच्छा प्रोटीन स्रोत',
          },
          {
            name: 'Mustard',
            name_hi: 'सरसों',
            score: 80,
            reason: 'Short duration crop, oil production',
            reason_hi: 'कम अवधि की फसल, तेल उत्पादन',
          }
        );
      } else if (season === 'zaid') {
        mockRecommendations.push(
          {
            name: 'Watermelon',
            name_hi: 'तरबूज',
            score: 90,
            reason: 'Summer crop, high profitability',
            reason_hi: 'गर्मी की फसल, उच्च लाभप्रदता',
          },
          {
            name: 'Cucumber',
            name_hi: 'खीरा',
            score: 85,
            reason: 'Quick harvest, good demand',
            reason_hi: 'त्वरित कटाई, अच्छी मांग',
          },
          {
            name: 'Muskmelon',
            name_hi: 'खरबूजा',
            score: 78,
            reason: 'Suitable for sandy soil, summer season',
            reason_hi: 'रेतीली मिट्टी के लिए उपयुक्त, गर्मी का मौसम',
          }
        );
      }

      setRecommendations(mockRecommendations);

      if (user) {
        await supabase.from('crop_recommendations').insert({
          user_id: user.id,
          region,
          soil_type: soilType,
          season,
          recommended_crops: mockRecommendations,
        });
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-3 mb-6">
        <Sprout className="w-8 h-8 text-green-700" />
        <div>
          <h2 className="text-3xl font-bold text-gray-800">{t('cropRecommendation')}</h2>
          <p className="text-gray-600">Get AI-powered crop suggestions for your farm</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {t('region')}
            </label>
            <input
              type="text"
              value={region}
              onChange={(e) => setRegion(e.target.value)}
              placeholder="e.g., Punjab, Maharashtra"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {t('soilType')}
            </label>
            <select
              value={soilType}
              onChange={(e) => setSoilType(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
            >
              <option value="">Select Soil Type</option>
              {soilTypes.map((type) => (
                <option key={type} value={type}>
                  {type}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {t('season')}
            </label>
            <select
              value={season}
              onChange={(e) => setSeason(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
            >
              <option value="">Select Season</option>
              {seasons.map((s) => (
                <option key={s} value={s}>
                  {s.charAt(0).toUpperCase() + s.slice(1)}
                </option>
              ))}
            </select>
          </div>
        </div>

        <button
          onClick={getRecommendations}
          disabled={loading || !region || !soilType || !season}
          className="w-full bg-green-700 text-white px-6 py-3 rounded-lg font-medium hover:bg-green-800 transition-colors flex items-center justify-center space-x-2 disabled:bg-gray-400 disabled:cursor-not-allowed"
        >
          <Sparkles className="w-5 h-5" />
          <span>Get Recommendations</span>
        </button>

        {loading ? (
          <div className="text-center py-12 mt-6">
            <div className="inline-block animate-spin rounded-full h-12 w-12 border-4 border-green-700 border-t-transparent"></div>
          </div>
        ) : recommendations.length > 0 ? (
          <div className="mt-6 space-y-4">
            <h3 className="text-xl font-bold text-gray-800 flex items-center space-x-2">
              <Sparkles className="w-6 h-6 text-yellow-500" />
              <span>{t('recommended')}</span>
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {recommendations.map((crop, index) => (
                <div
                  key={index}
                  className="bg-gradient-to-br from-green-50 to-green-100 rounded-lg p-6 border-2 border-green-200 hover:shadow-lg transition-shadow"
                >
                  <div className="flex items-center justify-between mb-3">
                    <h4 className="text-xl font-bold text-gray-800">
                      {language === 'hi' ? crop.name_hi : crop.name}
                    </h4>
                    <div className="bg-green-700 text-white px-3 py-1 rounded-full text-sm font-bold">
                      {crop.score}%
                    </div>
                  </div>
                  <p className="text-sm text-gray-600">
                    {language === 'hi' ? crop.reason_hi : crop.reason}
                  </p>
                  <div className="mt-4 pt-4 border-t border-green-200">
                    <div className="flex justify-between text-xs text-gray-500">
                      <span>Confidence Score</span>
                      <span className="font-semibold">{crop.score}/100</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2 mt-2">
                      <div
                        className="bg-green-600 h-2 rounded-full transition-all"
                        style={{ width: `${crop.score}%` }}
                      ></div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ) : null}
      </div>
    </div>
  );
}
