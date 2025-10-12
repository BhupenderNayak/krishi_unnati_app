import { useLanguage } from '../../contexts/LanguageContext';
import { useAuth } from '../../contexts/AuthContext';
import {
  TrendingUp,
  Cloud,
  Sprout,
  MapPin,
  Activity,
  BarChart3,
} from 'lucide-react';

type DashboardCardProps = {
  icon: React.ReactNode;
  title: string;
  value: string;
  subtitle: string;
  color: string;
};

function DashboardCard({ icon, title, value, subtitle, color }: DashboardCardProps) {
  return (
    <div className={`bg-gradient-to-br ${color} rounded-lg p-6 shadow-md hover:shadow-lg transition-shadow`}>
      <div className="flex items-start justify-between mb-4">
        <div className="bg-white bg-opacity-30 p-3 rounded-lg">{icon}</div>
      </div>
      <h3 className="text-white text-lg font-semibold mb-1">{title}</h3>
      <p className="text-white text-3xl font-bold mb-2">{value}</p>
      <p className="text-white text-sm opacity-90">{subtitle}</p>
    </div>
  );
}

export function Dashboard() {
  const { t } = useLanguage();
  const { profile } = useAuth();

  return (
    <div className="space-y-6">
      <div className="mb-6">
        <h2 className="text-3xl font-bold text-gray-800">
          {t('welcome')}, {profile?.full_name}!
        </h2>
        <p className="text-gray-600 mt-2">
          Your agriculture intelligence dashboard
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <DashboardCard
          icon={<TrendingUp className="w-8 h-8 text-white" />}
          title={t('mandiPrices')}
          value="1,250+"
          subtitle="Live price updates from mandis"
          color="from-green-600 to-green-700"
        />

        <DashboardCard
          icon={<Cloud className="w-8 h-8 text-white" />}
          title={t('weather')}
          value="28°C"
          subtitle="Current weather conditions"
          color="from-blue-600 to-blue-700"
        />

        <DashboardCard
          icon={<Sprout className="w-8 h-8 text-white" />}
          title="Crop Health"
          value="Excellent"
          subtitle="Based on recent analysis"
          color="from-emerald-600 to-emerald-700"
        />

        <DashboardCard
          icon={<MapPin className="w-8 h-8 text-white" />}
          title="Nearby Mandis"
          value="12"
          subtitle="Within 50km radius"
          color="from-orange-600 to-orange-700"
        />

        <DashboardCard
          icon={<Activity className="w-8 h-8 text-white" />}
          title="Active Alerts"
          value="3"
          subtitle="Weather & price alerts"
          color="from-red-600 to-red-700"
        />

        <DashboardCard
          icon={<BarChart3 className="w-8 h-8 text-white" />}
          title="Market Trend"
          subtitle="7-day prediction available"
          value="↑ 12%"
          color="from-teal-600 to-teal-700"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-8">
        <div className="bg-white rounded-lg shadow-md p-6">
          <h3 className="text-xl font-bold text-gray-800 mb-4">
            Recent Activities
          </h3>
          <div className="space-y-4">
            {[
              { action: 'Checked mandi prices', time: '2 hours ago', color: 'bg-green-100 text-green-700' },
              { action: 'Weather forecast viewed', time: '5 hours ago', color: 'bg-blue-100 text-blue-700' },
              { action: 'Crop recommendation taken', time: '1 day ago', color: 'bg-emerald-100 text-emerald-700' },
              { action: 'Disease detection performed', time: '2 days ago', color: 'bg-orange-100 text-orange-700' },
            ].map((activity, index) => (
              <div key={index} className="flex items-center justify-between py-3 border-b border-gray-100 last:border-0">
                <div className="flex items-center space-x-3">
                  <div className={`w-2 h-2 rounded-full ${activity.color}`}></div>
                  <span className="text-gray-700">{activity.action}</span>
                </div>
                <span className="text-sm text-gray-500">{activity.time}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <h3 className="text-xl font-bold text-gray-800 mb-4">
            Quick Tips
          </h3>
          <div className="space-y-4">
            {[
              {
                tip: 'Check weather forecast before planning irrigation',
                icon: '💧',
              },
              {
                tip: 'Monitor mandi prices regularly for better selling decisions',
                icon: '💰',
              },
              {
                tip: 'Use crop recommendation for seasonal planning',
                icon: '🌱',
              },
              {
                tip: 'Early disease detection saves crops and money',
                icon: '🔍',
              },
            ].map((item, index) => (
              <div key={index} className="flex items-start space-x-3 p-3 bg-gray-50 rounded-lg">
                <span className="text-2xl">{item.icon}</span>
                <p className="text-gray-700 text-sm">{item.tip}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
