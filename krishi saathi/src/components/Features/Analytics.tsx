import { useLanguage } from '../../contexts/LanguageContext';
import { BarChart3, TrendingUp, Users, Activity } from 'lucide-react';

export function Analytics() {
  const { t } = useLanguage();

  const platformStats = [
    { label: 'Total Users', value: '12,456', change: '+18%', icon: Users, color: 'text-blue-600' },
    {
      label: 'Price Queries',
      value: '45,789',
      change: '+24%',
      icon: TrendingUp,
      color: 'text-green-600',
    },
    {
      label: 'Crop Recommendations',
      value: '8,234',
      change: '+12%',
      icon: Activity,
      color: 'text-purple-600',
    },
    {
      label: 'Disease Detections',
      value: '3,456',
      change: '+32%',
      icon: BarChart3,
      color: 'text-orange-600',
    },
  ];

  const topCrops = [
    { name: 'Wheat', queries: 8543, percentage: 28 },
    { name: 'Rice', queries: 7234, percentage: 24 },
    { name: 'Cotton', queries: 5432, percentage: 18 },
    { name: 'Sugarcane', queries: 4321, percentage: 14 },
    { name: 'Maize', queries: 3210, percentage: 11 },
  ];

  const regionalData = [
    { region: 'North India', users: 3456, growth: 15 },
    { region: 'South India', users: 2890, growth: 22 },
    { region: 'West India', users: 2345, growth: 18 },
    { region: 'East India', users: 1987, growth: 12 },
    { region: 'Central India', users: 1778, growth: 20 },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-3 mb-6">
        <BarChart3 className="w-8 h-8 text-green-700" />
        <div>
          <h2 className="text-3xl font-bold text-gray-800">{t('analytics')}</h2>
          <p className="text-gray-600">Platform insights and statistics</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {platformStats.map((stat, index) => (
          <div key={index} className="bg-white rounded-lg shadow-md p-6">
            <div className="flex items-center justify-between mb-4">
              <stat.icon className={`w-8 h-8 ${stat.color}`} />
              <span className="text-green-600 text-sm font-semibold bg-green-50 px-2 py-1 rounded">
                {stat.change}
              </span>
            </div>
            <p className="text-gray-600 text-sm mb-1">{stat.label}</p>
            <p className="text-3xl font-bold text-gray-800">{stat.value}</p>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg shadow-md p-6">
          <h3 className="text-xl font-bold text-gray-800 mb-6">Top Searched Crops</h3>
          <div className="space-y-4">
            {topCrops.map((crop, index) => (
              <div key={index}>
                <div className="flex items-center justify-between mb-2">
                  <span className="font-medium text-gray-700">{crop.name}</span>
                  <div className="flex items-center space-x-3">
                    <span className="text-sm text-gray-600">{crop.queries} queries</span>
                    <span className="text-sm font-semibold text-green-700">
                      {crop.percentage}%
                    </span>
                  </div>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-3">
                  <div
                    className="bg-gradient-to-r from-green-500 to-green-600 h-3 rounded-full transition-all"
                    style={{ width: `${crop.percentage * 3.5}%` }}
                  ></div>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <h3 className="text-xl font-bold text-gray-800 mb-6">Regional Distribution</h3>
          <div className="space-y-4">
            {regionalData.map((region, index) => (
              <div
                key={index}
                className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <div className="flex-1">
                  <p className="font-semibold text-gray-800">{region.region}</p>
                  <p className="text-sm text-gray-600">{region.users.toLocaleString()} users</p>
                </div>
                <div className="text-right">
                  <p className="text-green-600 font-semibold">+{region.growth}%</p>
                  <p className="text-xs text-gray-500">growth</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-md p-6">
        <h3 className="text-xl font-bold text-gray-800 mb-6">Usage Trends</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="text-center p-6 bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg">
            <p className="text-blue-600 text-sm font-medium mb-2">Peak Usage Time</p>
            <p className="text-3xl font-bold text-blue-900">9 AM - 12 PM</p>
            <p className="text-xs text-blue-600 mt-2">Morning hours</p>
          </div>

          <div className="text-center p-6 bg-gradient-to-br from-green-50 to-green-100 rounded-lg">
            <p className="text-green-600 text-sm font-medium mb-2">Avg Session Duration</p>
            <p className="text-3xl font-bold text-green-900">8.5 min</p>
            <p className="text-xs text-green-600 mt-2">Per user session</p>
          </div>

          <div className="text-center p-6 bg-gradient-to-br from-purple-50 to-purple-100 rounded-lg">
            <p className="text-purple-600 text-sm font-medium mb-2">Return Rate</p>
            <p className="text-3xl font-bold text-purple-900">78%</p>
            <p className="text-xs text-purple-600 mt-2">Weekly active users</p>
          </div>
        </div>
      </div>
    </div>
  );
}
