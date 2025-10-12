import { useAuth } from '../../contexts/AuthContext';
import { useLanguage } from '../../contexts/LanguageContext';
import { Sprout, LogOut, Globe } from 'lucide-react';

export function Header() {
  const { profile, signOut } = useAuth();
  const { t, language, setLanguage } = useLanguage();

  const toggleLanguage = () => {
    setLanguage(language === 'en' ? 'hi' : 'en');
  };

  return (
    <header className="bg-gradient-to-r from-green-800 to-green-700 text-white shadow-lg">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <Sprout className="w-10 h-10" />
            <div>
              <h1 className="text-2xl font-bold">{t('appName')}</h1>
              <p className="text-sm text-green-100">Agriculture Intelligence Platform</p>
            </div>
          </div>

          <div className="flex items-center space-x-4">
            <button
              onClick={toggleLanguage}
              className="flex items-center space-x-2 px-4 py-2 bg-green-600 hover:bg-green-500 rounded-lg transition-colors"
            >
              <Globe className="w-4 h-4" />
              <span className="text-sm font-medium">
                {language === 'en' ? t('hindi') : t('english')}
              </span>
            </button>

            {profile && (
              <div className="flex items-center space-x-4">
                <div className="text-right">
                  <p className="font-medium">{profile.full_name}</p>
                  <p className="text-xs text-green-100">{t(profile.role)}</p>
                </div>
                <button
                  onClick={() => signOut()}
                  className="flex items-center space-x-2 px-4 py-2 bg-green-600 hover:bg-green-500 rounded-lg transition-colors"
                >
                  <LogOut className="w-4 h-4" />
                  <span className="text-sm font-medium">{t('logout')}</span>
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </header>
  );
}
