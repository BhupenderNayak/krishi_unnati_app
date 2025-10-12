import { useState, useEffect } from 'react';
import { supabase, MandiPrice, Crop, Mandi } from '../../lib/supabase';
import { useLanguage } from '../../contexts/LanguageContext';
import { Search, TrendingUp, Calendar } from 'lucide-react';

export function MandiPrices() {
  const { t, language } = useLanguage();
  const [crops, setCrops] = useState<Crop[]>([]);
  const [mandis, setMandis] = useState<Mandi[]>([]);
  const [prices, setPrices] = useState<MandiPrice[]>([]);
  const [selectedCrop, setSelectedCrop] = useState('');
  const [selectedCity, setSelectedCity] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadCrops();
    loadMandis();
  }, []);

  async function loadCrops() {
    const { data } = await supabase.from('crops').select('*').order('name_en');
    if (data) setCrops(data);
  }

  async function loadMandis() {
    const { data } = await supabase.from('mandis').select('*').order('city');
    if (data) setMandis(data);
  }

  async function searchPrices() {
    if (!selectedCrop && !selectedCity) return;

    setLoading(true);
    try {
      let query = supabase
        .from('mandi_prices')
        .select(`
          *,
          crop:crops(*),
          mandi:mandis(*)
        `)
        .order('date', { ascending: false })
        .limit(20);

      if (selectedCrop) {
        query = query.eq('crop_id', selectedCrop);
      }

      if (selectedCity) {
        const cityMandis = mandis.filter(m =>
          m.city.toLowerCase().includes(selectedCity.toLowerCase())
        );
        if (cityMandis.length > 0) {
          const mandiIds = cityMandis.map(m => m.id);
          query = query.in('mandi_id', mandiIds);
        }
      }

      const { data } = await query;
      if (data) setPrices(data as any);
    } finally {
      setLoading(false);
    }
  }

  const uniqueCities = Array.from(new Set(mandis.map(m => m.city))).sort();

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-3 mb-6">
        <TrendingUp className="w-8 h-8 text-green-700" />
        <div>
          <h2 className="text-3xl font-bold text-gray-800">{t('mandiPrices')}</h2>
          <p className="text-gray-600">Live market prices from mandis across India</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {t('searchCrop')}
            </label>
            <select
              value={selectedCrop}
              onChange={(e) => setSelectedCrop(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
            >
              <option value="">All Crops</option>
              {crops.map((crop) => (
                <option key={crop.id} value={crop.id}>
                  {language === 'hi' ? crop.name_hi : crop.name_en}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {t('searchCity')}
            </label>
            <select
              value={selectedCity}
              onChange={(e) => setSelectedCity(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
            >
              <option value="">All Cities</option>
              {uniqueCities.map((city) => (
                <option key={city} value={city}>
                  {city}
                </option>
              ))}
            </select>
          </div>

          <div className="flex items-end">
            <button
              onClick={searchPrices}
              disabled={loading}
              className="w-full bg-green-700 text-white px-6 py-2 rounded-lg font-medium hover:bg-green-800 transition-colors flex items-center justify-center space-x-2 disabled:bg-gray-400"
            >
              <Search className="w-5 h-5" />
              <span>{t('search')}</span>
            </button>
          </div>
        </div>

        {loading ? (
          <div className="text-center py-12">
            <div className="inline-block animate-spin rounded-full h-12 w-12 border-4 border-green-700 border-t-transparent"></div>
            <p className="mt-4 text-gray-600">{t('loading')}</p>
          </div>
        ) : prices.length > 0 ? (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-green-50">
                <tr>
                  <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Crop</th>
                  <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Mandi</th>
                  <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">{t('modalPrice')}</th>
                  <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">{t('minPrice')}</th>
                  <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">{t('maxPrice')}</th>
                  <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">{t('arrivals')}</th>
                  <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Date</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {prices.map((price) => (
                  <tr key={price.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3 text-sm text-gray-800 font-medium">
                      {language === 'hi' && price.crop ? price.crop.name_hi : price.crop?.name_en}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600">
                      {price.mandi?.name}, {price.mandi?.city}
                    </td>
                    <td className="px-4 py-3 text-sm font-semibold text-green-700">
                      ₹{price.modal_price.toFixed(2)}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600">
                      ₹{price.min_price.toFixed(2)}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600">
                      ₹{price.max_price.toFixed(2)}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600">
                      {price.arrivals_tonnes} {t('tonnes')}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-500">
                      <div className="flex items-center space-x-1">
                        <Calendar className="w-4 h-4" />
                        <span>{new Date(price.date).toLocaleDateString()}</span>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="text-center py-12">
            <TrendingUp className="w-16 h-16 text-gray-300 mx-auto mb-4" />
            <p className="text-gray-500">{t('noData')}</p>
            <p className="text-sm text-gray-400 mt-2">Select crop and city, then click search</p>
          </div>
        )}
      </div>
    </div>
  );
}
