import { useLanguage } from '../../contexts/LanguageContext';
import { useAuth } from '../../contexts/AuthContext';
import {
  LayoutDashboard,
  TrendingUp,
  Cloud,
  MessageSquare,
  Sprout,
  LineChart,
  MapPin,
  BarChart3,
  User,
  Activity,
  Settings,
} from 'lucide-react';

type NavItem = {
  id: string;
  icon: React.ReactNode;
  adminOnly?: boolean;
};

const navItems: NavItem[] = [
  { id: 'dashboard', icon: <LayoutDashboard className="w-5 h-5" /> },
  { id: 'mandiPrices', icon: <TrendingUp className="w-5 h-5" /> },
  { id: 'weather', icon: <Cloud className="w-5 h-5" /> },
  { id: 'cropRecommendation', icon: <Sprout className="w-5 h-5" /> },
  { id: 'pricePrediction', icon: <LineChart className="w-5 h-5" /> },
  { id: 'mandiLocator', icon: <MapPin className="w-5 h-5" /> },
  { id: 'analytics', icon: <BarChart3 className="w-5 h-5" /> },
  { id: 'farmerPortal', icon: <User className="w-5 h-5" /> },
  { id: 'diseaseDetection', icon: <Activity className="w-5 h-5" /> },
  { id: 'adminPanel', icon: <Settings className="w-5 h-5" />, adminOnly: true },
];

type SidebarProps = {
  activeSection: string;
  onSectionChange: (section: string) => void;
};

export function Sidebar({ activeSection, onSectionChange }: SidebarProps) {
  const { t } = useLanguage();
  const { profile } = useAuth();

  const filteredNavItems = navItems.filter(
    item => !item.adminOnly || profile?.role === 'admin'
  );

  return (
    <aside className="w-64 bg-white shadow-lg h-[calc(100vh-88px)] sticky top-0 overflow-y-auto">
      <nav className="p-4 space-y-2">
        {filteredNavItems.map((item) => (
          <button
            key={item.id}
            onClick={() => onSectionChange(item.id)}
            className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg transition-all duration-200 ${
              activeSection === item.id
                ? 'bg-green-700 text-white shadow-md'
                : 'text-gray-700 hover:bg-green-50 hover:text-green-700'
            }`}
          >
            {item.icon}
            <span className="font-medium">{t(item.id)}</span>
          </button>
        ))}
      </nav>
    </aside>
  );
}
