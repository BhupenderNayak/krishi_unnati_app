import { useState } from 'react';
import { useLanguage } from '../../contexts/LanguageContext';
import { MapPin, Navigation, Phone } from 'lucide-react';

type MandiLocation = {
  id: string;
  name: string;
  city: string;
  state: string;
  distance: number;
  contact: string;
  latitude: number;
  longitude: number;
};

export function MandiLocator() {
  const { t } = useLanguage();
  const [userLocation, setUserLocation] = useState('');
  const [loading, setLoading] = useState(false);
  const [mandis, setMandis] = useState<MandiLocation[]>([]);
  const [selectedMandi, setSelectedMandi] = useState<MandiLocation | null>(null);

  const findNearbyMandis = async () => {
    if (!userLocation) return;

    setLoading(true);
    try {
      await new Promise((resolve) => setTimeout(resolve, 1000));

      const mockMandis: MandiLocation[] = [
        {
          id: '1',
          name: 'Central Mandi',
          city: userLocation,
          state: 'State',
          distance: 5.2,
          contact: '+91 98765 43210',
          latitude: 28.6139,
          longitude: 77.209,
        },
        {
          id: '2',
          name: 'Agricultural Market',
          city: userLocation,
          state: 'State',
          distance: 12.8,
          contact: '+91 98765 43211',
          latitude: 28.7041,
          longitude: 77.1025,
        },
        {
          id: '3',
          name: 'Farmers Market',
          city: userLocation,
          state: 'State',
          distance: 18.5,
          contact: '+91 98765 43212',
          latitude: 28.5355,
          longitude: 77.391,
        },
        {
          id: '4',
          name: 'Grain Market',
          city: userLocation,
          state: 'State',
          distance: 25.3,
          contact: '+91 98765 43213',
          latitude: 28.4595,
          longitude: 77.0266,
        },
        {
          id: '5',
          name: 'Vegetable Mandi',
          city: userLocation,
          state: 'State',
          distance: 32.1,
          contact: '+91 98765 43214',
          latitude: 28.6692,
          longitude: 77.4538,
        },
      ].sort((a, b) => a.distance - b.distance);

      setMandis(mockMandis);
      if (mockMandis.length > 0) {
        setSelectedMandi(mockMandis[0]);
      }
    } finally {
      setLoading(false);
    }
  };

  const getDirections = (mandi: MandiLocation) => {
    const url = `https://www.google.com/maps/dir/?api=1&destination=${mandi.latitude},${mandi.longitude}`;
    window.open(url, '_blank');
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-3 mb-6">
        <MapPin className="w-8 h-8 text-green-700" />
        <div>
          <h2 className="text-3xl font-bold text-gray-800">{t('mandiLocator')}</h2>
          <p className="text-gray-600">Find nearest mandis with directions</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="flex gap-4 mb-6">
          <input
            type="text"
            value={userLocation}
            onChange={(e) => setUserLocation(e.target.value)}
            placeholder="Enter your city or location"
            className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
          />
          <button
            onClick={findNearbyMandis}
            disabled={loading || !userLocation}
            className="bg-green-700 text-white px-6 py-2 rounded-lg font-medium hover:bg-green-800 transition-colors flex items-center space-x-2 disabled:bg-gray-400 disabled:cursor-not-allowed"
          >
            <Navigation className="w-5 h-5" />
            <span>{loading ? 'Searching...' : 'Find Mandis'}</span>
          </button>
        </div>

        {mandis.length > 0 ? (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="space-y-4">
              <h3 className="text-lg font-bold text-gray-800">
                Nearby Mandis ({mandis.length})
              </h3>
              <div className="space-y-3 max-h-[600px] overflow-y-auto pr-2">
                {mandis.map((mandi) => (
                  <div
                    key={mandi.id}
                    onClick={() => setSelectedMandi(mandi)}
                    className={`p-4 rounded-lg border-2 cursor-pointer transition-all ${
                      selectedMandi?.id === mandi.id
                        ? 'border-green-600 bg-green-50 shadow-md'
                        : 'border-gray-200 hover:border-green-300 hover:bg-gray-50'
                    }`}
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <h4 className="font-bold text-gray-800 mb-1">{mandi.name}</h4>
                        <p className="text-sm text-gray-600">
                          {mandi.city}, {mandi.state}
                        </p>
                        <div className="flex items-center space-x-4 mt-2">
                          <div className="flex items-center space-x-1 text-sm text-green-700">
                            <Navigation className="w-4 h-4" />
                            <span className="font-semibold">{mandi.distance} km</span>
                          </div>
                          <div className="flex items-center space-x-1 text-sm text-gray-600">
                            <Phone className="w-4 h-4" />
                            <span>{mandi.contact}</span>
                          </div>
                        </div>
                      </div>
                      <div className="ml-3">
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            getDirections(mandi);
                          }}
                          className="bg-green-700 text-white p-2 rounded-lg hover:bg-green-800 transition-colors"
                        >
                          <Navigation className="w-5 h-5" />
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div>
              <h3 className="text-lg font-bold text-gray-800 mb-4">Map View</h3>
              <div className="bg-gray-100 rounded-lg p-8 h-[600px] flex flex-col items-center justify-center border-2 border-gray-300">
                <MapPin className="w-16 h-16 text-gray-400 mb-4" />
                <p className="text-gray-600 text-center mb-4">
                  Interactive map would display here
                </p>
                {selectedMandi && (
                  <div className="bg-white rounded-lg p-6 shadow-md max-w-sm w-full">
                    <h4 className="font-bold text-gray-800 mb-3 text-center">
                      {selectedMandi.name}
                    </h4>
                    <div className="space-y-2 text-sm">
                      <div className="flex items-center space-x-2">
                        <MapPin className="w-4 h-4 text-green-700" />
                        <span className="text-gray-600">
                          {selectedMandi.city}, {selectedMandi.state}
                        </span>
                      </div>
                      <div className="flex items-center space-x-2">
                        <Navigation className="w-4 h-4 text-green-700" />
                        <span className="text-gray-600">
                          {selectedMandi.distance} km away
                        </span>
                      </div>
                      <div className="flex items-center space-x-2">
                        <Phone className="w-4 h-4 text-green-700" />
                        <span className="text-gray-600">{selectedMandi.contact}</span>
                      </div>
                    </div>
                    <button
                      onClick={() => getDirections(selectedMandi)}
                      className="w-full mt-4 bg-green-700 text-white px-4 py-2 rounded-lg hover:bg-green-800 transition-colors flex items-center justify-center space-x-2"
                    >
                      <Navigation className="w-5 h-5" />
                      <span>Get Directions</span>
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        ) : (
          <div className="text-center py-16">
            <MapPin className="w-16 h-16 text-gray-300 mx-auto mb-4" />
            <p className="text-gray-500">{t('noData')}</p>
            <p className="text-sm text-gray-400 mt-2">
              Enter your location to find nearby mandis
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
