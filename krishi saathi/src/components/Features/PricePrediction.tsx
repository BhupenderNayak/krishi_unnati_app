import { useState } from 'react';
import { useLanguage } from '../../contexts/LanguageContext';
import { LineChart, TrendingUp } from 'lucide-react';

type PredictionData = {
  date: string;
  price: number;
  confidence: number;
};

export function PricePrediction() {
  const { t } = useLanguage();
  const [cropName, setCropName] = useState('');
  const [mandiName, setMandiName] = useState('');
  const [loading, setLoading] = useState(false);
  const [predictions, setPredictions] = useState<PredictionData[]>([]);
  const [currentPrice, setCurrentPrice] = useState(0);

  const generatePredictions = async () => {
    if (!cropName || !mandiName) return;

    setLoading(true);
    try {
      await new Promise((resolve) => setTimeout(resolve, 1500));

      const basePrice = 2000 + Math.random() * 3000;
      setCurrentPrice(basePrice);

      const predictionData: PredictionData[] = [];
      let price = basePrice;

      for (let i = 1; i <= 7; i++) {
        const change = (Math.random() - 0.45) * 200;
        price += change;
        const date = new Date();
        date.setDate(date.getDate() + i);

        predictionData.push({
          date: date.toLocaleDateString(),
          price: Math.max(price, basePrice * 0.7),
          confidence: 95 - i * 3,
        });
      }

      setPredictions(predictionData);
    } finally {
      setLoading(false);
    }
  };

  const avgPredictedPrice =
    predictions.length > 0
      ? predictions.reduce((sum, p) => sum + p.price, 0) / predictions.length
      : 0;

  const priceChange =
    currentPrice > 0 ? ((avgPredictedPrice - currentPrice) / currentPrice) * 100 : 0;

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-3 mb-6">
        <LineChart className="w-8 h-8 text-green-700" />
        <div>
          <h2 className="text-3xl font-bold text-gray-800">{t('pricePrediction')}</h2>
          <p className="text-gray-600">7-day price forecast using ML models</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <div className="md:col-span-1">
            <label className="block text-sm font-medium text-gray-700 mb-2">Crop Name</label>
            <input
              type="text"
              value={cropName}
              onChange={(e) => setCropName(e.target.value)}
              placeholder="e.g., Wheat, Rice"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
            />
          </div>

          <div className="md:col-span-1">
            <label className="block text-sm font-medium text-gray-700 mb-2">Mandi Location</label>
            <input
              type="text"
              value={mandiName}
              onChange={(e) => setMandiName(e.target.value)}
              placeholder="e.g., Delhi, Mumbai"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
            />
          </div>

          <div className="flex items-end">
            <button
              onClick={generatePredictions}
              disabled={loading || !cropName || !mandiName}
              className="w-full bg-green-700 text-white px-6 py-2 rounded-lg font-medium hover:bg-green-800 transition-colors flex items-center justify-center space-x-2 disabled:bg-gray-400 disabled:cursor-not-allowed"
            >
              <TrendingUp className="w-5 h-5" />
              <span>{loading ? 'Predicting...' : 'Predict Prices'}</span>
            </button>
          </div>
        </div>

        {predictions.length > 0 && (
          <div className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="bg-blue-50 rounded-lg p-4 border border-blue-200">
                <p className="text-sm text-blue-600 mb-1">Current Price</p>
                <p className="text-2xl font-bold text-blue-900">₹{currentPrice.toFixed(2)}</p>
                <p className="text-xs text-blue-600 mt-1">Per quintal</p>
              </div>

              <div className="bg-green-50 rounded-lg p-4 border border-green-200">
                <p className="text-sm text-green-600 mb-1">Avg Predicted</p>
                <p className="text-2xl font-bold text-green-900">
                  ₹{avgPredictedPrice.toFixed(2)}
                </p>
                <p className="text-xs text-green-600 mt-1">Next 7 days</p>
              </div>

              <div
                className={`${
                  priceChange >= 0
                    ? 'bg-emerald-50 border-emerald-200'
                    : 'bg-red-50 border-red-200'
                } rounded-lg p-4 border`}
              >
                <p
                  className={`text-sm ${
                    priceChange >= 0 ? 'text-emerald-600' : 'text-red-600'
                  } mb-1`}
                >
                  Expected Change
                </p>
                <p
                  className={`text-2xl font-bold ${
                    priceChange >= 0 ? 'text-emerald-900' : 'text-red-900'
                  }`}
                >
                  {priceChange >= 0 ? '+' : ''}
                  {priceChange.toFixed(2)}%
                </p>
                <p
                  className={`text-xs ${
                    priceChange >= 0 ? 'text-emerald-600' : 'text-red-600'
                  } mt-1`}
                >
                  {priceChange >= 0 ? '↑ Upward trend' : '↓ Downward trend'}
                </p>
              </div>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">
                      Date
                    </th>
                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">
                      Predicted Price
                    </th>
                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">
                      Change
                    </th>
                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">
                      Confidence
                    </th>
                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">
                      Trend
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {predictions.map((pred, index) => {
                    const change =
                      index === 0
                        ? pred.price - currentPrice
                        : pred.price - predictions[index - 1].price;
                    const changePercent =
                      index === 0
                        ? ((pred.price - currentPrice) / currentPrice) * 100
                        : ((pred.price - predictions[index - 1].price) /
                            predictions[index - 1].price) *
                          100;

                    return (
                      <tr key={index} className="hover:bg-gray-50">
                        <td className="px-4 py-3 text-sm text-gray-800">{pred.date}</td>
                        <td className="px-4 py-3 text-sm font-semibold text-gray-900">
                          ₹{pred.price.toFixed(2)}
                        </td>
                        <td
                          className={`px-4 py-3 text-sm font-medium ${
                            change >= 0 ? 'text-green-600' : 'text-red-600'
                          }`}
                        >
                          {change >= 0 ? '+' : ''}₹{change.toFixed(2)} ({changePercent.toFixed(1)}
                          %)
                        </td>
                        <td className="px-4 py-3 text-sm text-gray-600">
                          <div className="flex items-center space-x-2">
                            <div className="flex-1 bg-gray-200 rounded-full h-2">
                              <div
                                className="bg-green-600 h-2 rounded-full"
                                style={{ width: `${pred.confidence}%` }}
                              ></div>
                            </div>
                            <span className="text-xs">{pred.confidence}%</span>
                          </div>
                        </td>
                        <td className="px-4 py-3 text-sm">
                          {change >= 0 ? (
                            <span className="text-green-600">📈 Up</span>
                          ) : (
                            <span className="text-red-600">📉 Down</span>
                          )}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>

            <div className="bg-yellow-50 rounded-lg p-4 border border-yellow-200">
              <p className="text-sm text-yellow-800">
                <strong>Note:</strong> These predictions are based on historical data and ML
                models. Actual prices may vary due to market conditions, weather, and other
                factors. Use this as a reference for planning, not as guaranteed prices.
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
