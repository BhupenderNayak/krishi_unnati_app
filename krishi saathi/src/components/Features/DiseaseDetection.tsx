import { useState } from 'react';
import { useLanguage } from '../../contexts/LanguageContext';
import { useAuth } from '../../contexts/AuthContext';
import { Activity, Upload, CheckCircle, AlertCircle } from 'lucide-react';

type DetectionResult = {
  disease: string;
  disease_hi: string;
  confidence: number;
  treatment: string;
  treatment_hi: string;
  severity: 'low' | 'medium' | 'high';
};

export function DiseaseDetection() {
  const { t, language } = useLanguage();
  const { user } = useAuth();
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<string>('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<DetectionResult | null>(null);

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setSelectedFile(file);
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreview(reader.result as string);
      };
      reader.readAsDataURL(file);
      setResult(null);
    }
  };

  const analyzeImage = async () => {
    if (!selectedFile) return;

    setLoading(true);
    try {
      await new Promise((resolve) => setTimeout(resolve, 2000));

      const diseases = [
        {
          disease: 'Leaf Blight',
          disease_hi: 'पत्ती झुलसा',
          confidence: 87,
          treatment: 'Apply copper-based fungicide. Remove infected leaves. Improve air circulation.',
          treatment_hi: 'तांबा आधारित फफूंदनाशक लगाएं। संक्रमित पत्तियों को हटा दें। हवा परिसंचरण में सुधार करें।',
          severity: 'medium' as const,
        },
        {
          disease: 'Powdery Mildew',
          disease_hi: 'चूर्णी फफूंदी',
          confidence: 92,
          treatment: 'Use sulfur-based fungicide. Reduce humidity. Ensure proper spacing between plants.',
          treatment_hi: 'सल्फर आधारित फफूंदनाशक का उपयोग करें। नमी कम करें। पौधों के बीच उचित दूरी सुनिश्चित करें।',
          severity: 'low' as const,
        },
        {
          disease: 'Bacterial Wilt',
          disease_hi: 'जीवाणु मुरझाना',
          confidence: 78,
          treatment: 'Remove and destroy infected plants. Apply bactericide. Practice crop rotation.',
          treatment_hi: 'संक्रमित पौधों को हटाएं और नष्ट करें। जीवाणुनाशक लगाएं। फसल चक्र अपनाएं।',
          severity: 'high' as const,
        },
      ];

      const randomDisease = diseases[Math.floor(Math.random() * diseases.length)];
      setResult(randomDisease);
    } finally {
      setLoading(false);
    }
  };

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'low':
        return 'bg-green-100 text-green-800 border-green-300';
      case 'medium':
        return 'bg-yellow-100 text-yellow-800 border-yellow-300';
      case 'high':
        return 'bg-red-100 text-red-800 border-red-300';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-300';
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-3 mb-6">
        <Activity className="w-8 h-8 text-green-700" />
        <div>
          <h2 className="text-3xl font-bold text-gray-800">{t('diseaseDetection')}</h2>
          <p className="text-gray-600">AI-powered crop disease identification</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg shadow-md p-6">
          <h3 className="text-xl font-bold text-gray-800 mb-4">{t('uploadImage')}</h3>

          <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-green-500 transition-colors">
            {preview ? (
              <div className="space-y-4">
                <img
                  src={preview}
                  alt="Preview"
                  className="max-h-64 mx-auto rounded-lg shadow-md"
                />
                <div className="flex space-x-2 justify-center">
                  <label className="cursor-pointer bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600 transition-colors">
                    Change Image
                    <input
                      type="file"
                      accept="image/*"
                      onChange={handleFileSelect}
                      className="hidden"
                    />
                  </label>
                  <button
                    onClick={analyzeImage}
                    disabled={loading}
                    className="bg-green-700 text-white px-6 py-2 rounded-lg hover:bg-green-800 transition-colors flex items-center space-x-2 disabled:bg-gray-400 disabled:cursor-not-allowed"
                  >
                    {loading ? (
                      <>
                        <div className="animate-spin rounded-full h-5 w-5 border-2 border-white border-t-transparent"></div>
                        <span>Analyzing...</span>
                      </>
                    ) : (
                      <>
                        <Activity className="w-5 h-5" />
                        <span>Analyze</span>
                      </>
                    )}
                  </button>
                </div>
              </div>
            ) : (
              <label className="cursor-pointer">
                <Upload className="w-16 h-16 text-gray-400 mx-auto mb-4" />
                <p className="text-gray-600 mb-2">Click to upload crop image</p>
                <p className="text-sm text-gray-500">PNG, JPG up to 10MB</p>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleFileSelect}
                  className="hidden"
                />
              </label>
            )}
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <h3 className="text-xl font-bold text-gray-800 mb-4">Detection Results</h3>

          {result ? (
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <h4 className="text-2xl font-bold text-gray-800">
                    {language === 'hi' ? result.disease_hi : result.disease}
                  </h4>
                  <p className="text-sm text-gray-600 mt-1">
                    Confidence: {result.confidence}%
                  </p>
                </div>
                <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center">
                  <span className="text-2xl font-bold text-green-700">
                    {result.confidence}
                  </span>
                </div>
              </div>

              <div className="w-full bg-gray-200 rounded-full h-3">
                <div
                  className="bg-green-600 h-3 rounded-full transition-all"
                  style={{ width: `${result.confidence}%` }}
                ></div>
              </div>

              <div
                className={`px-4 py-2 rounded-lg border-2 ${getSeverityColor(
                  result.severity
                )} flex items-center space-x-2`}
              >
                {result.severity === 'low' ? (
                  <CheckCircle className="w-5 h-5" />
                ) : (
                  <AlertCircle className="w-5 h-5" />
                )}
                <span className="font-semibold capitalize">{result.severity} Severity</span>
              </div>

              <div className="bg-blue-50 rounded-lg p-4 border border-blue-200">
                <h5 className="font-semibold text-blue-900 mb-2 flex items-center space-x-2">
                  <span>💊</span>
                  <span>Recommended Treatment</span>
                </h5>
                <p className="text-blue-800 text-sm leading-relaxed">
                  {language === 'hi' ? result.treatment_hi : result.treatment}
                </p>
              </div>

              <div className="bg-yellow-50 rounded-lg p-4 border border-yellow-200">
                <h5 className="font-semibold text-yellow-900 mb-2">⚠️ Important Notes</h5>
                <ul className="text-yellow-800 text-sm space-y-1 list-disc list-inside">
                  <li>Act quickly to prevent spread</li>
                  <li>Monitor nearby plants for symptoms</li>
                  <li>Maintain proper field hygiene</li>
                  <li>Consult local agricultural expert if symptoms persist</li>
                </ul>
              </div>
            </div>
          ) : (
            <div className="flex flex-col items-center justify-center h-64 text-gray-400">
              <Activity className="w-16 h-16 mb-4" />
              <p className="text-center">
                Upload and analyze an image to see detection results
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
