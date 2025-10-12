# Kisan Unnati 🌾

**Digital Empowerment for Indian Farmers**

## 🎯 The Problem

Indian farmers often lack timely access to critical information like accurate market prices, weather forecasts, and modern agricultural practices. This information gap makes it difficult to make informed decisions, leading to potential losses and missed opportunities.

## ✨ Our Solution

Kisan Unnati is an all-in-one mobile application designed to empower farmers with the essential tools and information they need, consolidated into a single, easy-to-use platform.

---

## 🚀 Key Features

1.  **Live Market Price Fetcher:**
    * Fetches real-time (last 7 days) market prices for various commodities across different states, districts, and markets in India using a robust Selenium-based scraper.

2.  **Krishi Mitra - AI Chatbot:**
    * A powerful, multilingual AI assistant that understands queries in **English, Hindi, and Hinglish**.
    * Provides instant answers to farming questions. (Powered by Groq's ultra-fast Llama-3.1 model).

3.  **Farmer Community (Demo):**
    * A beautifully designed UI showcasing a community feed where farmers can connect and share knowledge. The "Create Post" button opens a functional UI, ready for backend integration.

4.  **Marketplace:**
    * A grid-view marketplace displaying various agricultural products like fertilizers, seeds, and equipment with images stored locally within the app for fast and reliable loading.

---

## 🔧 How to Run the App

### Prerequisites
* Flutter SDK
* Python 3.x
* Google Chrome Browser (Updated)

### 1. Backend Setup (Python APIs)

The app requires two separate Python Flask servers.

1.  **Activate the Virtual Environment:**
    * Open a terminal in the project's root folder.
    * Run: `venv\Scripts\activate`

2.  **Install Python Dependencies:**
    * (Make sure you are inside the activated `venv`)
    * Run: `pip install -r requirements.txt`

3.  **Start the Servers:**
    * Open **two separate terminals**, and activate the `venv` in both.
    * **Terminal 1 (Price API):**
        ```bash
        python price_api.py
        ```
        *(This will run on `http://0.0.0.0:5000`)*
    * **Terminal 2 (Chat API):**
        ```bash
        python chat_api.py
        ```
        *(This will run on `http://0.0.0.0:5001`)*

### 2. Frontend Setup (Flutter App)

1.  **Install Flutter Dependencies:**
    ```bash
    flutter pub get
    ```

2.  **Configure API Host IP (CRUCIAL for Real Device):**
    * Open `lib/services/api_service.dart`.
    * Find the `_priceApiBaseUrl` and `_chatApiBaseUrl` variables.
    * Replace the IP address with your computer's actual Wi-Fi IP address.
        * To find your IP: Open Command Prompt and type `ipconfig`. Look for "IPv4 Address".
    * **Example:**
    * Note i made some comments in the file from where you can put your ip address
        ```dart
        
        final String _priceApiBaseUrl = '[http://192.168.1.5:5000](http://192.168.1.5:5000)'; // YOUR IP
        final String _chatApiBaseUrl = '[http://192.168.1.5:5001](http://192.168.1.5:5001)';   // YOUR IP
        ```

3.  **Run the Flutter App:**
    ```bash
    flutter run
    ```
    * Make sure your phone and computer are on the **same Wi-Fi network**.
    * Ensure your **Windows Firewall** allows Python to communicate on ports 5000 and 5001.

---

## 💡 Future Plans

* **Live Dashboard:** Integrate live weather and price data onto the main dashboard.
* **Functional Community:** Connect the community feature to Firebase for real-time posts and likes.
* **Voice Commands:** Add a speech-to-text feature to the AI Chatbot.
* **Image Recognition:** Allow farmers to upload photos of diseased crops to the chatbot for instant advice.
