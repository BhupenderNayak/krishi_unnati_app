import { useState } from 'react';
import { useLanguage } from '../../contexts/LanguageContext';
import { Settings, Database, Users, FileText } from 'lucide-react';

export function AdminPanel() {
  const { t } = useLanguage();
  const [activeTab, setActiveTab] = useState<'overview' | 'users' | 'data'>('overview');

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-3 mb-6">
        <Settings className="w-8 h-8 text-green-700" />
        <div>
          <h2 className="text-3xl font-bold text-gray-800">{t('adminPanel')}</h2>
          <p className="text-gray-600">System administration and management</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-md">
        <div className="flex border-b border-gray-200">
          <button
            onClick={() => setActiveTab('overview')}
            className={`flex-1 py-4 px-6 font-medium transition-colors ${
              activeTab === 'overview'
                ? 'text-green-700 border-b-2 border-green-700 bg-green-50'
                : 'text-gray-600 hover:text-gray-800 hover:bg-gray-50'
            }`}
          >
            <div className="flex items-center justify-center space-x-2">
              <Database className="w-5 h-5" />
              <span>Overview</span>
            </div>
          </button>
          <button
            onClick={() => setActiveTab('users')}
            className={`flex-1 py-4 px-6 font-medium transition-colors ${
              activeTab === 'users'
                ? 'text-green-700 border-b-2 border-green-700 bg-green-50'
                : 'text-gray-600 hover:text-gray-800 hover:bg-gray-50'
            }`}
          >
            <div className="flex items-center justify-center space-x-2">
              <Users className="w-5 h-5" />
              <span>Users</span>
            </div>
          </button>
          <button
            onClick={() => setActiveTab('data')}
            className={`flex-1 py-4 px-6 font-medium transition-colors ${
              activeTab === 'data'
                ? 'text-green-700 border-b-2 border-green-700 bg-green-50'
                : 'text-gray-600 hover:text-gray-800 hover:bg-gray-50'
            }`}
          >
            <div className="flex items-center justify-center space-x-2">
              <FileText className="w-5 h-5" />
              <span>Data Management</span>
            </div>
          </button>
        </div>

        <div className="p-6">
          {activeTab === 'overview' && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg p-6 border border-blue-200">
                  <Database className="w-8 h-8 text-blue-600 mb-3" />
                  <p className="text-sm text-blue-600 mb-1">Database Size</p>
                  <p className="text-3xl font-bold text-blue-900">2.4 GB</p>
                </div>

                <div className="bg-gradient-to-br from-green-50 to-green-100 rounded-lg p-6 border border-green-200">
                  <Users className="w-8 h-8 text-green-600 mb-3" />
                  <p className="text-sm text-green-600 mb-1">Total Users</p>
                  <p className="text-3xl font-bold text-green-900">12,456</p>
                </div>

                <div className="bg-gradient-to-br from-purple-50 to-purple-100 rounded-lg p-6 border border-purple-200">
                  <FileText className="w-8 h-8 text-purple-600 mb-3" />
                  <p className="text-sm text-purple-600 mb-1">Total Records</p>
                  <p className="text-3xl font-bold text-purple-900">89,234</p>
                </div>
              </div>

              <div className="bg-gray-50 rounded-lg p-6">
                <h3 className="text-lg font-bold text-gray-800 mb-4">System Health</h3>
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-gray-700">API Status</span>
                    <span className="px-3 py-1 bg-green-100 text-green-700 rounded-full text-sm font-medium">
                      Operational
                    </span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-gray-700">Database Connection</span>
                    <span className="px-3 py-1 bg-green-100 text-green-700 rounded-full text-sm font-medium">
                      Connected
                    </span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-gray-700">Cache Status</span>
                    <span className="px-3 py-1 bg-green-100 text-green-700 rounded-full text-sm font-medium">
                      Active
                    </span>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'users' && (
            <div className="space-y-4">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-bold text-gray-800">User Management</h3>
                <button className="bg-green-700 text-white px-4 py-2 rounded-lg hover:bg-green-800 transition-colors">
                  Add User
                </button>
              </div>

              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">
                        Name
                      </th>
                      <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">
                        Email
                      </th>
                      <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">
                        Role
                      </th>
                      <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">
                        Status
                      </th>
                      <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">
                        Actions
                      </th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-200">
                    {[1, 2, 3, 4, 5].map((i) => (
                      <tr key={i} className="hover:bg-gray-50">
                        <td className="px-4 py-3 text-sm text-gray-800">User {i}</td>
                        <td className="px-4 py-3 text-sm text-gray-600">user{i}@example.com</td>
                        <td className="px-4 py-3 text-sm text-gray-600">Farmer</td>
                        <td className="px-4 py-3">
                          <span className="px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-medium">
                            Active
                          </span>
                        </td>
                        <td className="px-4 py-3">
                          <button className="text-green-700 hover:text-green-800 text-sm font-medium">
                            Edit
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {activeTab === 'data' && (
            <div className="space-y-4">
              <h3 className="text-lg font-bold text-gray-800 mb-4">Data Management</h3>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <button className="p-6 bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg border-2 border-blue-200 hover:shadow-md transition-shadow text-left">
                  <Database className="w-8 h-8 text-blue-600 mb-3" />
                  <h4 className="font-bold text-gray-800 mb-1">Manage Crops</h4>
                  <p className="text-sm text-gray-600">Add, edit, or remove crop data</p>
                </button>

                <button className="p-6 bg-gradient-to-br from-green-50 to-green-100 rounded-lg border-2 border-green-200 hover:shadow-md transition-shadow text-left">
                  <Database className="w-8 h-8 text-green-600 mb-3" />
                  <h4 className="font-bold text-gray-800 mb-1">Manage Mandis</h4>
                  <p className="text-sm text-gray-600">Update mandi locations and details</p>
                </button>

                <button className="p-6 bg-gradient-to-br from-purple-50 to-purple-100 rounded-lg border-2 border-purple-200 hover:shadow-md transition-shadow text-left">
                  <Database className="w-8 h-8 text-purple-600 mb-3" />
                  <h4 className="font-bold text-gray-800 mb-1">Price Data</h4>
                  <p className="text-sm text-gray-600">Import and manage price records</p>
                </button>

                <button className="p-6 bg-gradient-to-br from-orange-50 to-orange-100 rounded-lg border-2 border-orange-200 hover:shadow-md transition-shadow text-left">
                  <Database className="w-8 h-8 text-orange-600 mb-3" />
                  <h4 className="font-bold text-gray-800 mb-1">Weather Data</h4>
                  <p className="text-sm text-gray-600">Update weather information</p>
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
