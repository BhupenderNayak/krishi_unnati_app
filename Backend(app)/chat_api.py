import os
from flask import Flask, request, jsonify
from groq import Groq

app = Flask(__name__)

# Yahan apna Groq API Key daalein aur ise uncomment kare
GROQ_API_KEY = "YOUR_GROQ_API_KEY" Put your groq api key here

client = Groq(api_key=GROQ_API_KEY)

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    message = data.get('message', '')
    if not message:
        return jsonify({"reply": "Message is empty."}), 400

    try:
        chat_completion = client.chat.completions.create(
            messages=[
                {
                    "role": "system",
                   
                    "content": "You are a helpful Indian farming assistant named Krishi Mitra. Your most important rule is to reply using the SAME SCRIPT as the user. If the user types in English letters (like 'mumbai ka mausam'), you MUST reply in English letters (Hinglish). If the user types in Hindi script (जैसे 'मुंबई का मौसम'), you MUST reply in Hindi script."
                },
                {
                    "role": "user",
                    "content": message,
                }
            ],
            model="llama-3.1-8b-instant",
            temperature=0.7,
        )
        
        reply = chat_completion.choices[0].message.content
        return jsonify({"reply": reply})

    except Exception as e:
        print(f"Error calling Groq: {e}")
        return jsonify({"reply": "Sorry, AI server mein error aa gaya."}), 500

if __name__ == "__main__":
    print("Naya Chatbot API (Groq) chal raha hai http://127.0.0.1:5001 par")

    app.run(port=5001, debug=True, host='0.0.0.0')
