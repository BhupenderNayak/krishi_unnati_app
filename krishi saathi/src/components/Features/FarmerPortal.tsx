import { useState } from 'react';
import { useLanguage } from '../../contexts/LanguageContext';
import { useAuth } from '../../contexts/AuthContext';
import { supabase } from '../../lib/supabase';
import { User, Upload, FileText, Save } from 'lucide-react';

export function FarmerPortal() {
  const { t } = useLanguage();
  const { profile, user } = useAuth();
  const [activeTab, setActiveTab] = useState<'profile' | 'soil'>('profile');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const [profileData, setProfileData] = useState({
    full_name: profile?.full_name || '',
    phone: profile?.phone || '',
    location: profile?.location || '',
  });

  const [soilData, setSoilData] = useState({
    location: '',
    ph_level: '',
    nitrogen: '',
    phosphorus: '',
    potassium: '',
    organic_carbon: '',
  });

  const handleProfileUpdate = async () => {
    if (!user) return;

    setLoading(true);
    setMessage('');

    try {
      const { error } = await supabase
        .from('profiles')
        .update({
          full_name: profileData.full_name,
          phone: profileData.phone,
          location: profileData.location,
          updated_at: new Date().toISOString(),
        })
        .eq('id', user.id);

      if (error) throw error;

      setMessage('Profile updated successfully!');
    } catch (error: any) {
      setMessage('Error updating profile: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleSoilTestSubmit = async () => {
    if (!user) return;

    setLoading(true);
    setMessage('');

    try {
      const { error } = await supabase.from('soil_tests').insert({
        user_id: user.id,
        location: soilData.location,
        ph_level: parseFloat(soilData.ph_level) || null,
        nitrogen: parseFloat(soilData.nitrogen) || null,
        phosphorus: parseFloat(soilData.phosphorus) || null,
        potassium: parseFloat(soilData.potassium) || null,
        organic_carbon: parseFloat(soilData.organic_carbon) || null,
      });

      if (error) throw error;

      setMessage('Soil test data saved successfully!');
      setSoilData({
        location: '',
        ph_level: '',
        nitrogen: '',
        phosphorus: '',
        potassium: '',
        organic_carbon: '',
      });
    } catch (error: any) {
      setMessage('Error saving soil test: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-3 mb-6">
        <User className="w-8 h-8 text-green-700" />
        <div>
          <h2 className="text-3xl font-bold text-gray-800">{t('farmerPortal')}</h2>
          <p className="text-gray-600">Manage your profile and farm data</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-md">
        <div className="flex border-b border-gray-200">
          <button
            onClick={() => setActiveTab('profile')}
            className={`flex-1 py-4 px-6 font-medium transition-colors ${
              activeTab === 'profile'
                ? 'text-green-700 border-b-2 border-green-700 bg-green-50'
                : 'text-gray-600 hover:text-gray-800 hover:bg-gray-50'
            }`}
          >
            <div className="flex items-center justify-center space-x-2">
              <User className="w-5 h-5" />
              <span>{t('profile')}</span>
            </div>
          </button>
          <button
            onClick={() => setActiveTab('soil')}
            className={`flex-1 py-4 px-6 font-medium transition-colors ${
              activeTab === 'soil'
                ? 'text-green-700 border-b-2 border-green-700 bg-green-50'
                : 'text-gray-600 hover:text-gray-800 hover:bg-gray-50'
            }`}
          >
            <div className="flex items-center justify-center space-x-2">
              <FileText className="w-5 h-5" />
              <span>Soil Test</span>
            </div>
          </button>
        </div>

        <div className="p-6">
          {message && (
            <div
              className={`mb-4 p-4 rounded-lg ${
                message.includes('Error')
                  ? 'bg-red-50 text-red-700'
                  : 'bg-green-50 text-green-700'
              }`}
            >
              {message}
            </div>
          )}

          {activeTab === 'profile' ? (
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {t('fullName')}
                </label>
                <input
                  type="text"
                  value={profileData.full_name}
                  onChange={(e) =>
                    setProfileData({ ...profileData, full_name: e.target.value })
                  }
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {t('phone')}
                </label>
                <input
                  type="tel"
                  value={profileData.phone}
                  onChange={(e) =>
                    setProfileData({ ...profileData, phone: e.target.value })
                  }
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {t('location')}
                </label>
                <input
                  type="text"
                  value={profileData.location}
                  onChange={(e) =>
                    setProfileData({ ...profileData, location: e.target.value })
                  }
                  placeholder="City, State"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
                />
              </div>

              <button
                onClick={handleProfileUpdate}
                disabled={loading}
                className="w-full bg-green-700 text-white px-6 py-3 rounded-lg font-medium hover:bg-green-800 transition-colors flex items-center justify-center space-x-2 disabled:bg-gray-400 disabled:cursor-not-allowed"
              >
                <Save className="w-5 h-5" />
                <span>{loading ? t('loading') : t('save')}</span>
              </button>
            </div>
          ) : (
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {t('location')}
                </label>
                <input
                  type="text"
                  value={soilData.location}
                  onChange={(e) =>
                    setSoilData({ ...soilData, location: e.target.value })
                  }
                  placeholder="Field location"
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    pH Level
                  </label>
                  <input
                    type="number"
                    step="0.1"
                    value={soilData.ph_level}
                    onChange={(e) =>
                      setSoilData({ ...soilData, ph_level: e.target.value })
                    }
                    placeholder="6.5"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Nitrogen (kg/ha)
                  </label>
                  <input
                    type="number"
                    value={soilData.nitrogen}
                    onChange={(e) =>
                      setSoilData({ ...soilData, nitrogen: e.target.value })
                    }
                    placeholder="280"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Phosphorus (kg/ha)
                  </label>
                  <input
                    type="number"
                    value={soilData.phosphorus}
                    onChange={(e) =>
                      setSoilData({ ...soilData, phosphorus: e.target.value })
                    }
                    placeholder="40"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Potassium (kg/ha)
                  </label>
                  <input
                    type="number"
                    value={soilData.potassium}
                    onChange={(e) =>
                      setSoilData({ ...soilData, potassium: e.target.value })
                    }
                    placeholder="200"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Organic Carbon (%)
                  </label>
                  <input
                    type="number"
                    step="0.01"
                    value={soilData.organic_carbon}
                    onChange={(e) =>
                      setSoilData({ ...soilData, organic_carbon: e.target.value })
                    }
                    placeholder="0.5"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
                  />
                </div>
              </div>

              <button
                onClick={handleSoilTestSubmit}
                disabled={loading || !soilData.location}
                className="w-full bg-green-700 text-white px-6 py-3 rounded-lg font-medium hover:bg-green-800 transition-colors flex items-center justify-center space-x-2 disabled:bg-gray-400 disabled:cursor-not-allowed"
              >
                <Upload className="w-5 h-5" />
                <span>{loading ? t('loading') : t('submit')}</span>
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
