from flask import Flask, render_template, request, jsonify
import pandas as pd
import requests

app = Flask(__name__)

# --------------------------------------------
# CSV Load Safe + Clean Columns
# --------------------------------------------
try:
    data = pd.read_csv("mandi_data_full.csv", encoding='utf-8-sig')
    data.columns = data.columns.str.strip().str.replace('\ufeff','')
except Exception as e:
    print("⚠️ CSV load failed:", e)
    data = pd.DataFrame(columns=["Crop", "Market", "Variety", "Modal Price"])

# Dropdown options
crops = sorted(data["Crop"].dropna().unique())
mandis = sorted(data["Market"].dropna().unique())

# --------------------------------------------
# OpenWeather API Key
# --------------------------------------------
WEATHER_API_KEY = "e24e4a977f4f53ab1fce52f5d54f27fa"  # replace this

# --------------------------------------------
# Home route
# --------------------------------------------
@app.route("/")
def home():
    return render_template("index.html", crops=crops, mandis=mandis)

# --------------------------------------------
# Chat / Weather / Price API
# --------------------------------------------
@app.route("/get", methods=["POST"])
def get_reply():
    msg = (request.form.get("msg") or "").strip().lower()
    crop = (request.form.get("crop") or "").strip().title()
    mandi = (request.form.get("mandi") or "").strip().title()

    # Crop price logic
    if crop and mandi:
        result = data[
            (data["Crop"].str.lower() == crop.lower()) &
            (data["Market"].str.lower() == mandi.lower())
        ]
        if not result.empty:
            price = result.iloc[0]["Modal Price"]
            variety = result.iloc[0]["Variety"]
            return jsonify({"type": "price", "reply": f"📊 {crop} price in {mandi} mandi:\n💰 ₹{price}/quintal ({variety})"})
        else:
            return jsonify({"type": "price", "reply": "❌ Data not found for that crop or mandi."})

    # Weather logic
    if "weather" in msg:
        try:
            city = msg.split("in")[-1].strip().title()
            if not city:
                return jsonify({"type": "weather", "reply": "⚠️ Please mention a city name."})

            url = f"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={WEATHER_API_KEY}&units=metric"
            res = requests.get(url).json()

            if res.get("cod") != 200:
                return jsonify({"type": "weather", "reply": f"❌ Weather not found for {city}."})

            temp = res["main"]["temp"]
            cond = res["weather"][0]["description"].capitalize()
            return jsonify({"type": "weather", "reply": f"🌤 Weather in {city}: {temp}°C, {cond}."})
        except Exception as e:
            return jsonify({"type": "weather", "reply": f"⚠️ Error fetching weather: {e}"})

    # Default chatbot
    reply = "💬 Type 'weather in Delhi' or select crop & mandi to get rates."
    return jsonify({"type": "chat", "reply": reply})

# --------------------------------------------
# Run server
# --------------------------------------------
if __name__ == "__main__":
    app.run(debug=True)
