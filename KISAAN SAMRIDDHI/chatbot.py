# chatbot.py

# Pichle code se apne analysis function ko import karein
# Isko abhi comment rakha hai, jab aap dono files ko jodenge tab ise uncomment karein
# from app import run_crop_analysis 

def kisan_chatbot():
    """Ye Kisan Samriddhi project ke liye ek simple rule-based chatbot hai."""

    # 1. Chatbot shuru hone par welcome message
    print("="*50)
    print("🤖 Namaskar! Main Kisan Samriddhi Bot hoon.")
    print("Aap fasal ka bhav (price), upaj (yield), ya FPI ke baare me pooch sakte hain.")
    print("Baat-cheet khatm karne ke liye 'exit' ya 'bye' type karein.")
    print("="*50)

    # 2. Hamesha chalne wala loop taki chatbot aapse baar baar sawaal le sake
    while True:
        # 3. User se input lena
        user_input = input("👨 Aap: ").lower() # .lower() se input ko chhote letters me badal dete hain

        # 4. User ke input ko check karke jawab dena (Rules)
        
        # Rule: Baat-cheet khatm karne ke liye
        if user_input in ['exit', 'quit', 'bye', 'alvida']:
            print("🤖 Bot: Theek hai! Phir milenge. Aapka din shubh ho.")
            break # Loop ko todkar program band kar dega

        # Rule: Bhav (Price) ke liye
        elif 'bhav' in user_input or 'price' in user_input or 'rate' in user_input:
            print("🤖 Bot: Zaroor! Aap kis fasal aur mandi ka bhav janna chahte hain?")
            # TODO: Yahan par aap apne app.py wale price prediction model ko call karenge.
            # Example: run_crop_analysis()
            print("   (Abhi ke liye, ye feature development me hai.)")

        # Rule: Upaj (Yield) ke liye
        elif 'upaj' in user_input or 'yield' in user_input or 'paidawar' in user_input:
            print("🤖 Bot: Main aapki location aur fasal ke hisaab se upaj ka anuman laga sakta hoon.")
            # TODO: Yahan par aap apne Yield Prediction model ko call karenge.
            print("   (Abhi ke liye, ye feature development me hai.)")
        
        # Rule: FPI ke liye
        elif 'fpi' in user_input or 'fair price' in user_input:
            print("🤖 Bot: Fair Price Index (FPI) aapko batata hai ki bhav MSP ke mukabale kitna accha hai.")
            # TODO: FPI calculation wala function yahan call hoga.
            print("   (Abhi ke liye, ye feature development me hai.)")

        # Rule: Fasal sujhav (Crop Suggestion) ke liye
        elif 'fasal' in user_input or 'crop' in user_input or 'ugana' in user_input:
            print("🤖 Bot: Main aapki mitti (soil) aur location ke hisaab se sabse faydemand fasal ka sujhav de sakta hoon.")
            # TODO: Yahan par aap apne Crop Recommendation model ko call karenge.
            print("   (Abhi ke liye, ye feature development me hai.)")
        
        # Rule: Greeting ke liye
        elif 'namaste' in user_input or 'hello' in user_input or 'hi' in user_input:
            print("🤖 Bot: Namaste! Main aapki kaise sahayata kar sakta hoon?")

        # 5. Agar koi rule match na ho
        else:
            print("🤖 Bot: Maaf kijiye, main aapka sawaal samajh nahi paya. Aap 'price', 'yield', ya 'fasal' jaise keywords ka istemal kar sakte hain.")

# Program ko shuru karne ke liye function ko call karein
if __name__ == "__main__":
    kisan_chatbot()