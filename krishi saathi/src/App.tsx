import { useState } from 'react';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { LanguageProvider } from './contexts/LanguageContext';
import { LoginForm } from './components/Auth/LoginForm';
import { SignupForm } from './components/Auth/SignupForm';
import { Header } from './components/Layout/Header';
import { Sidebar } from './components/Layout/Sidebar';
import { Dashboard } from './components/Features/Dashboard';
import { MandiPrices } from './components/Features/MandiPrices';
import { Weather } from './components/Features/Weather';
import { ChatBot } from './components/Features/ChatBot';
import { CropRecommendation } from './components/Features/CropRecommendation';
import { PricePrediction } from './components/Features/PricePrediction';
import { MandiLocator } from './components/Features/MandiLocator';
import { Analytics } from './components/Features/Analytics';
import { FarmerPortal } from './components/Features/FarmerPortal';
import { DiseaseDetection } from './components/Features/DiseaseDetection';
import { AdminPanel } from './components/Features/AdminPanel';

function AuthScreen() {
  const [showLogin, setShowLogin] = useState(true);

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-green-100 to-emerald-100 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-[url('https://images.pexels.com/photos/974314/pexels-photo-974314.jpeg?auto=compress&cs=tinysrgb&w=1920')] bg-cover bg-center opacity-10"></div>
      <div className="relative z-10">
        {showLogin ? (
          <LoginForm onToggle={() => setShowLogin(false)} />
        ) : (
          <SignupForm onToggle={() => setShowLogin(true)} />
        )}
      </div>
    </div>
  );
}

function MainApp() {
  const { user, loading } = useAuth();
  const [activeSection, setActiveSection] = useState('dashboard');

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-16 w-16 border-4 border-green-700 border-t-transparent mb-4"></div>
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return <AuthScreen />;
  }

  const renderContent = () => {
    switch (activeSection) {
      case 'dashboard':
        return <Dashboard />;
      case 'mandiPrices':
        return <MandiPrices />;
      case 'weather':
        return <Weather />;
      case 'cropRecommendation':
        return <CropRecommendation />;
      case 'pricePrediction':
        return <PricePrediction />;
      case 'mandiLocator':
        return <MandiLocator />;
      case 'analytics':
        return <Analytics />;
      case 'farmerPortal':
        return <FarmerPortal />;
      case 'diseaseDetection':
        return <DiseaseDetection />;
      case 'adminPanel':
        return <AdminPanel />;
      default:
        return <Dashboard />;
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />
      <div className="flex">
        <Sidebar activeSection={activeSection} onSectionChange={setActiveSection} />
        <main className="flex-1 p-8">
          <div className="max-w-7xl mx-auto">
            {renderContent()}
          </div>
        </main>
      </div>
      <ChatBot />
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <LanguageProvider>
        <MainApp />
      </LanguageProvider>
    </AuthProvider>
  );
}
