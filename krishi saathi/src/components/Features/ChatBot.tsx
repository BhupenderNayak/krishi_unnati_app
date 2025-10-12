import { useState, useRef, useEffect } from 'react';
import { useLanguage } from '../../contexts/LanguageContext';
import { useAuth } from '../../contexts/AuthContext';
import { MessageSquare, Send, X, Minimize2 } from 'lucide-react';

type Message = {
  role: 'user' | 'assistant';
  content: string;
  timestamp: Date;
};

export function ChatBot() {
  const { t } = useLanguage();
  const { user } = useAuth();
  const [isOpen, setIsOpen] = useState(false);
  const [messages, setMessages] = useState<Message[]>([
    {
      role: 'assistant',
      content: t('language') === 'Hindi'
        ? 'नमस्ते! मैं कृषि सहायक हूं। मैं फसल, मौसम और खेती के बारे में आपके सवालों का जवाब दे सकता हूं।'
        : 'Hello! I am Krishi Assistant. I can help answer your questions about crops, weather, and farming.',
      timestamp: new Date(),
    },
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const getAIResponse = async (userMessage: string): Promise<string> => {
    const lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.includes('wheat') || lowerMessage.includes('गेहूं')) {
      return t('language') === 'Hindi'
        ? 'गेहूं रबी की फसल है। इसे अक्टूबर-नवंबर में बोया जाता है और मार्च-अप्रैल में काटा जाता है। इसे दोमट मिट्टी और 15-25°C तापमान की आवश्यकता होती है।'
        : 'Wheat is a rabi crop. It is sown in October-November and harvested in March-April. It requires loamy soil and 15-25°C temperature.';
    }

    if (lowerMessage.includes('rice') || lowerMessage.includes('धान')) {
      return t('language') === 'Hindi'
        ? 'धान खरीफ की फसल है। इसे जून-जुलाई में बोया जाता है। इसे बहुत पानी और 20-35°C तापमान की आवश्यकता होती है।'
        : 'Rice is a kharif crop. It is sown in June-July. It requires high water availability and 20-35°C temperature.';
    }

    if (lowerMessage.includes('price') || lowerMessage.includes('मूल्य')) {
      return t('language') === 'Hindi'
        ? 'कृपया मंडी मूल्य अनुभाग देखें। वहां आप विभिन्न फसलों और मंडियों के लिए नवीनतम मूल्य पा सकते हैं।'
        : 'Please check the Mandi Prices section. You can find the latest prices for various crops and mandis there.';
    }

    if (lowerMessage.includes('weather') || lowerMessage.includes('मौसम')) {
      return t('language') === 'Hindi'
        ? 'मौसम अनुभाग में जाएं और अपने शहर के लिए 5 दिन का पूर्वानुमान प्राप्त करें।'
        : 'Go to the Weather section and get a 5-day forecast for your city.';
    }

    if (lowerMessage.includes('fertilizer') || lowerMessage.includes('उर्वरक')) {
      return t('language') === 'Hindi'
        ? 'उर्वरक मिट्टी परीक्षण के परिणामों के आधार पर लगाएं। NPK (नाइट्रोजन, फास्फोरस, पोटेशियम) मुख्य पोषक तत्व हैं।'
        : 'Apply fertilizers based on soil test results. NPK (Nitrogen, Phosphorus, Potassium) are the main nutrients.';
    }

    return t('language') === 'Hindi'
      ? 'मैं आपकी मदद करने की कोशिश कर रहा हूं। कृपया फसल, मौसम, मूल्य या खेती के बारे में अधिक विशिष्ट प्रश्न पूछें।'
      : 'I am trying to help you. Please ask more specific questions about crops, weather, prices, or farming.';
  };

  const handleSend = async () => {
    if (!input.trim() || loading) return;

    const userMessage: Message = {
      role: 'user',
      content: input,
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInput('');
    setLoading(true);

    try {
      const response = await getAIResponse(input);
      const aiMessage: Message = {
        role: 'assistant',
        content: response,
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, aiMessage]);
    } catch (error) {
      const errorMessage: Message = {
        role: 'assistant',
        content: 'Sorry, I encountered an error. Please try again.',
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setLoading(false);
    }
  };

  if (!isOpen) {
    return (
      <button
        onClick={() => setIsOpen(true)}
        className="fixed bottom-6 right-6 bg-green-700 text-white p-4 rounded-full shadow-lg hover:bg-green-800 transition-all hover:scale-110 z-50"
      >
        <MessageSquare className="w-6 h-6" />
      </button>
    );
  }

  return (
    <div className="fixed bottom-6 right-6 w-96 h-[600px] bg-white rounded-lg shadow-2xl flex flex-col z-50">
      <div className="bg-gradient-to-r from-green-700 to-green-600 text-white p-4 rounded-t-lg flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <MessageSquare className="w-5 h-5" />
          <span className="font-semibold">{t('chatbot')}</span>
        </div>
        <div className="flex items-center space-x-2">
          <button
            onClick={() => setIsOpen(false)}
            className="hover:bg-green-600 p-1 rounded transition-colors"
          >
            <Minimize2 className="w-5 h-5" />
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-gray-50">
        {messages.map((message, index) => (
          <div
            key={index}
            className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[80%] rounded-lg p-3 ${
                message.role === 'user'
                  ? 'bg-green-700 text-white'
                  : 'bg-white text-gray-800 shadow-sm'
              }`}
            >
              <p className="text-sm whitespace-pre-wrap">{message.content}</p>
              <p
                className={`text-xs mt-1 ${
                  message.role === 'user' ? 'text-green-100' : 'text-gray-400'
                }`}
              >
                {message.timestamp.toLocaleTimeString()}
              </p>
            </div>
          </div>
        ))}
        {loading && (
          <div className="flex justify-start">
            <div className="bg-white text-gray-800 rounded-lg p-3 shadow-sm">
              <div className="flex space-x-2">
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce delay-100"></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce delay-200"></div>
              </div>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      <div className="p-4 border-t border-gray-200">
        <div className="flex space-x-2">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSend()}
            placeholder="Type your question..."
            className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-600 focus:border-transparent"
          />
          <button
            onClick={handleSend}
            disabled={loading || !input.trim()}
            className="bg-green-700 text-white p-2 rounded-lg hover:bg-green-800 transition-colors disabled:bg-gray-400 disabled:cursor-not-allowed"
          >
            <Send className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
}
