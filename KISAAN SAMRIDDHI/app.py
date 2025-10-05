# ==============================================================================
# FINAL INTERACTIVE API CODE - Live Data Ke Liye (FIXED)
# ==============================================================================
import pandas as pd
from prophet import Prophet
import matplotlib.pyplot as plt
import requests
import warnings

warnings.filterwarnings('ignore')

# ==============================================================================
# API Key Yahan Daalein
# ==============================================================================
API_KEY = "579b464db66ec23bdd000001f862271c9e86424862187ec61661335a"

# ==============================================================================
# API Se Data Fetch Karne Ka Function
# ==============================================================================
def fetch_data_from_api(market, commodity, limit=2000):
    """AGMARKNET API se live data fetch karta hai."""
    print(f"📡 API se '{commodity}' aur '{market}' ka live data fetch kiya ja raha hai...")
    
    api_url = (
        "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"
        f"?api-key={API_KEY}"
        f"&format=json&offset=0&limit={limit}"
        f"&filters[market]={market}"
        f"&filters[commodity]={commodity}"
    )
    
    try:
        response = requests.get(api_url, timeout=30)
        if response.status_code == 200:
            data = response.json().get('records', [])
            if not data:
                return None
            print(f"✅ API se {len(data)} records successfully fetch hue!")
            return pd.DataFrame(data)
        else:
            print(f"❌ ERROR: API request fail hui. Status Code: {response.status_code}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"❌ ERROR: Network me dikkat hai: {e}")
        return None

# ==============================================================================
# Main Analysis Function
# ==============================================================================
def run_crop_analysis():
    print("🚀 Live Crop Analysis Program Shuru Ho Raha Hai...")
    if API_KEY == "579b464db66ec23bdd000001f862271c9e86424862187ec61661335a":
        print("❌ ERROR: Kripya code me apni API Key daalein.")
        return

    # User se fasal aur mandi ka naam poochna
    crop_name_input = input("➡️ Fasal ka naam enter karein (Jaise: Potato, Onion, Wheat): ").strip().title()
    mandi_name_input = input("➡️ Mandi ka naam enter karein (Jaise: Delhi, Mumbai, Lucknow): ").strip().title()

    # API se data fetch karna
    df = fetch_data_from_api(mandi_name_input, crop_name_input)

    if df is None or df.empty:
        print("❌ ERROR: Is combination ke liye API se koi data nahi mila. Kripya koi aur fasal ya mandi try karein.")
        return

    # Data Cleaning and Preparation
    df.rename(columns={'arrival_date': 'ds', 'modal_price': 'y'}, inplace=True)
    df['ds'] = pd.to_datetime(df['ds'], format='%d/%m/%Y', errors='coerce')
    df['y'] = pd.to_numeric(df['y'], errors='coerce')
    model_df = df[['ds', 'y']].dropna()
    
    # ✅ FIX: Sort the data by date before training
    model_df = model_df.sort_values(by='ds')

    if len(model_df) < 50:
        print(f"❌ ERROR: Model train karne ke liye पर्याप्त data nahi hai. Sirf {len(model_df)} data points mile.")
        return

    # Model Training
    print(f"🧠 Model train ho raha hai ({len(model_df)} data points ke saath)...")
    model = Prophet(daily_seasonality=True, yearly_seasonality=True).fit(model_df)

    # Forecasting
    print("📈 Agle 30 din ka bhav predict kiya ja raha hai...")
    future = model.make_future_dataframe(periods=30)
    forecast = model.predict(future)

    # Display Results
    today_predicted_price = forecast['yhat'].iloc[-1]
    print("\n" + "="*40)
    print("       🎉 ANALYSIS RESULT 🎉")
    print("="*40)
    print(f"Fasal (Crop): {crop_name_input}")
    print(f"Mandi: {mandi_name_input}")
    print(f"Agle 30 din ka Anumanit Bhav: ₹{today_predicted_price:.2f} per quintal")
    print("="*40)

    # Visualization
    print("\n📊 Analysis ke charts dikhaye ja rahe hain...")
    fig = model.plot(forecast)
    ax = fig.gca() 
    ax.set_title(f'{crop_name_input} Price Forecast for {mandi_name_input}')
    ax.set_xlabel('Date')
    ax.set_ylabel('Price (per Quintal)')
    
    fig2 = model.plot_components(forecast)
    
    plt.show()

if __name__ == "__main__":
    run_crop_analysis()