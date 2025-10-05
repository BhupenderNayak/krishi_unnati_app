# -*- coding: utf-8 -*-
# app.py

import requests

def get_crop_price(crop_name, mandi_name):
    print("\n🔍 Data fetch ho raha hai...")

    # ✅ Tumhara API Key
    API_KEY = "579b464db66ec23bdd000001f862271c9e86424862187ec61661335a"

    # 🌾 API URL (Agmarknet / eNAM)
    url = "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"
    params = {
        "api-key": API_KEY,
        "format": "json",
        "limit": 10000,
        "filters[commodity]": crop_name.title(),
        "filters[market]": mandi_name.title(),
    }

    try:
        response = requests.get(url, params=params)
        response.raise_for_status()
        data = response.json()

        records = data.get("records", [])

        if not records:
            print("❌ Data nahi mila. Crop ya mandi naam galat ho sakta hai.")
            return

        print(f"\n✅ '{crop_name.title()}' ka latest price '{mandi_name.title()}' mandi me:")
        print("-" * 55)
        for rec in records[:5]:  # Sirf latest 5 records dikhaye
            print(f"📅 Date: {rec.get('arrival_date', 'N/A')}")
            print(f"💰 Modal Price: ₹{rec.get('modal_price', 'N/A')}/quintal")
            print(f"🌾 Variety: {rec.get('variety', 'N/A')}")
            print(f"📍 State: {rec.get('state', 'N/A')}")
            print("-" * 55)

    except requests.exceptions.RequestException as e:
        print("⚠️ API Error:", e)


if __name__ == "__main__":
    print("🌿 Kisaan Samriddhi Live Mandi Price Finder 🌾")

    # 🔹 User Input
    crop_name = input("\nEnter Crop Name (e.g. Tomato, Wheat, Cotton): ").strip()
    mandi_name = input("Enter Mandi Name (e.g. Pune, Jaipur, Delhi): ").strip()

    if crop_name and mandi_name:
        get_crop_price(crop_name, mandi_name)
    else:
        print("⚠️ Kripya dono input sahi se dein.")
