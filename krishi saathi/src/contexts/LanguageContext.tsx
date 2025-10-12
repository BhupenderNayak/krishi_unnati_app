import { createContext, useContext, useState, ReactNode, useEffect } from 'react';
import { useAuth } from './AuthContext';
import { supabase } from '../lib/supabase';

type Language = 'en' | 'hi';

type Translations = {
  [key: string]: {
    en: string;
    hi: string;
  };
};

const translations: Translations = {
  appName: { en: 'Krishi Saathi', hi: 'कृषि साथी' },
  welcome: { en: 'Welcome', hi: 'स्वागत है' },
  login: { en: 'Login', hi: 'लॉगिन' },
  signup: { en: 'Sign Up', hi: 'साइन अप' },
  logout: { en: 'Logout', hi: 'लॉगआउट' },
  email: { en: 'Email', hi: 'ईमेल' },
  password: { en: 'Password', hi: 'पासवर्ड' },
  fullName: { en: 'Full Name', hi: 'पूरा नाम' },
  role: { en: 'Role', hi: 'भूमिका' },
  farmer: { en: 'Farmer', hi: 'किसान' },
  admin: { en: 'Admin', hi: 'व्यवस्थापक' },
  dashboard: { en: 'Dashboard', hi: 'डैशबोर्ड' },
  mandiPrices: { en: 'Mandi Prices', hi: 'मंडी मूल्य' },
  weather: { en: 'Weather', hi: 'मौसम' },
  chatbot: { en: 'AI Assistant', hi: 'एआई सहायक' },
  cropRecommendation: { en: 'Crop Recommendation', hi: 'फसल सिफारिश' },
  pricePrediction: { en: 'Price Prediction', hi: 'मूल्य भविष्यवाणी' },
  mandiLocator: { en: 'Mandi Locator', hi: 'मंडी लोकेटर' },
  analytics: { en: 'Analytics', hi: 'विश्लेषण' },
  farmerPortal: { en: 'Farmer Portal', hi: 'किसान पोर्टल' },
  diseaseDetection: { en: 'Disease Detection', hi: 'रोग पहचान' },
  adminPanel: { en: 'Admin Panel', hi: 'व्यवस्थापक पैनल' },
  searchCrop: { en: 'Search Crop', hi: 'फसल खोजें' },
  searchCity: { en: 'Search City', hi: 'शहर खोजें' },
  search: { en: 'Search', hi: 'खोजें' },
  modalPrice: { en: 'Modal Price', hi: 'औसत मूल्य' },
  minPrice: { en: 'Min Price', hi: 'न्यूनतम मूल्य' },
  maxPrice: { en: 'Max Price', hi: 'अधिकतम मूल्य' },
  arrivals: { en: 'Arrivals', hi: 'आगमन' },
  tonnes: { en: 'Tonnes', hi: 'टन' },
  temperature: { en: 'Temperature', hi: 'तापमान' },
  humidity: { en: 'Humidity', hi: 'आर्द्रता' },
  rainfall: { en: 'Rainfall', hi: 'वर्षा' },
  windSpeed: { en: 'Wind Speed', hi: 'हवा की गति' },
  forecast: { en: 'Forecast', hi: 'पूर्वानुमान' },
  days: { en: 'Days', hi: 'दिन' },
  uploadImage: { en: 'Upload Image', hi: 'छवि अपलोड करें' },
  submit: { en: 'Submit', hi: 'जमा करें' },
  cancel: { en: 'Cancel', hi: 'रद्द करें' },
  save: { en: 'Save', hi: 'सहेजें' },
  edit: { en: 'Edit', hi: 'संपादित करें' },
  delete: { en: 'Delete', hi: 'हटाएं' },
  close: { en: 'Close', hi: 'बंद करें' },
  loading: { en: 'Loading...', hi: 'लोड हो रहा है...' },
  noData: { en: 'No data available', hi: 'कोई डेटा उपलब्ध नहीं' },
  error: { en: 'Error', hi: 'त्रुटि' },
  success: { en: 'Success', hi: 'सफलता' },
  soilType: { en: 'Soil Type', hi: 'मिट्टी का प्रकार' },
  season: { en: 'Season', hi: 'मौसम' },
  region: { en: 'Region', hi: 'क्षेत्र' },
  recommended: { en: 'Recommended Crops', hi: 'अनुशंसित फसलें' },
  profile: { en: 'Profile', hi: 'प्रोफाइल' },
  location: { en: 'Location', hi: 'स्थान' },
  phone: { en: 'Phone', hi: 'फोन' },
  language: { en: 'Language', hi: 'भाषा' },
  english: { en: 'English', hi: 'अंग्रेज़ी' },
  hindi: { en: 'Hindi', hi: 'हिंदी' },
};

type LanguageContextType = {
  language: Language;
  setLanguage: (lang: Language) => void;
  t: (key: string) => string;
};

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export function LanguageProvider({ children }: { children: ReactNode }) {
  const { profile, user } = useAuth();
  const [language, setLanguageState] = useState<Language>('en');

  useEffect(() => {
    if (profile?.preferred_language) {
      setLanguageState(profile.preferred_language);
    }
  }, [profile]);

  const setLanguage = async (lang: Language) => {
    setLanguageState(lang);

    if (user) {
      try {
        await supabase
          .from('profiles')
          .update({ preferred_language: lang })
          .eq('id', user.id);
      } catch (error) {
        console.error('Error updating language preference:', error);
      }
    }
  };

  const t = (key: string): string => {
    return translations[key]?.[language] || key;
  };

  return (
    <LanguageContext.Provider value={{ language, setLanguage, t }}>
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (context === undefined) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
}
