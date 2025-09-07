import time
import datetime
import speech_recognition as sr
import pyttsx3
import sounddevice as sd
import wavio
import med_llm  
from pymongo import MongoClient

# -------------------- MONGO SETUP --------------------
MONGO_URI = "your_mongo_uri_here"  # use same as in med_llm.py
client = MongoClient(MONGO_URI)
db = client["swasth_ai_db"]
chat_collection = db["chat_history_large"]

# -------------------- SPEECH & TTS --------------------
engine = pyttsx3.init()
engine.setProperty('rate', 165)
engine.setProperty('volume', 1.0)
voices = engine.getProperty('voices')
engine.setProperty('voice', voices[0].id)

recognizer = sr.Recognizer()

def speak(text):
    engine.say(text)
    engine.runAndWait()
    time.sleep(0.2)

def talk_print(text):
    print(text)
    speak(text)

def beep(freq=800, duration=200):
    try:
        import winsound
        winsound.Beep(freq, duration)
    except:
        pass

def get_voice_input(prompt="Speak now:", duration=5, retries=2, fs=44100):
    """
    Record audio using sounddevice and recognize speech using Google API.
    """
    r = sr.Recognizer()
    for attempt in range(retries):
        talk_print(prompt)
        print(f"Recording for {duration} seconds...")
        try:
            recording = sd.rec(int(duration * fs), samplerate=fs, channels=1, dtype='int16')
            sd.wait()
            wavio.write("temp.wav", recording, fs, sampwidth=2)

            with sr.AudioFile("temp.wav") as source:
                audio = r.record(source)
            text = r.recognize_google(audio)
            talk_print(f"You said: {text}")
            return text.lower()
        except sr.UnknownValueError:
            talk_print("Couldn’t understand audio.")
        except sr.RequestError as e:
            talk_print(f"API error: {e}")
        except Exception as e:
            talk_print(f"Recording error: {e}")

    talk_print("I couldn’t catch that. Please type your response.")
    return None

# -------------------- EMERGENCY --------------------
emergency_numbers = {"Rourkela": "108", "Delhi": "102", "Mumbai": "108"}

# -------------------- CHATBOT LOOP --------------------
history = []

talk_print("Welcome to Swasth AI, your intelligent voice-enabled medical assistant!")

DEFAULT_LOCATION = "Rourkela"
city = input(f"Detected location: {DEFAULT_LOCATION}\nPress Enter to confirm or type your city: ").strip()
if not city:
    city = DEFAULT_LOCATION

while True:
    talk_print("Would you like to speak or type your symptoms? Say 'exit' to quit.")
    mode = get_voice_input("Say 'speak' or 'type':")
    if not mode:
        mode = input("Type 'speak' or 'type': ").strip().lower()
    else:
        mode = mode.lower()

    if "exit" in mode:
        talk_print("Chatbot session ended. Stay healthy!")
        break

    if "speak" in mode:
        user_input = get_voice_input("Please describe your symptoms:")
        if not user_input:
            talk_print("Sorry, I didn’t catch that. Please try typing instead.")
            continue
    elif "type" in mode:
        user_input = input("Enter your symptoms separated by commas: ").strip()
    else:
        talk_print("I didn’t understand. Please say or type 'speak' or 'type'.")
        continue

    symptoms = [s.strip().lower() for s in user_input.split(",")]
    predicted, confidence, severity = med_llm.predict_disease(symptoms)

    if predicted:
        specialist = med_llm.specialists.get(predicted, "General Physician")
        hospitals = med_llm.get_osm_hospitals(city)

        record = {
            "Timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "Symptoms": symptoms,
            "Disease": predicted,
            "Confidence": confidence,
            "Severity": severity,
            "Specialist": specialist,
            "Care_Tips": med_llm.care_tips.get(predicted),
            "Nearby_Hospitals": hospitals,
            "City": city
        }
        chat_collection.insert_one(record)
        history.append(record)

        talk_print(f"Based on your symptoms, you might have {predicted}.")
        talk_print(f"My confidence level is {confidence} percent.")
        talk_print(f"The severity appears to be {severity}.")
        talk_print(f"You should consult a {specialist}.")
        talk_print(f"Care Tips: {med_llm.care_tips.get(predicted)}")

        talk_print("Nearby Hospitals:")
        for i, h in enumerate(hospitals, 1):
            query = h.replace(" ", "+") + "+" + city.replace(" ", "+")
            maps_url = f"https://www.google.com/maps/search/?api=1&query={query}"
            talk_print(f"{i}. {h} → {maps_url}")

        if severity == "High":
            talk_print("This seems serious. Please call emergency services immediately!")
            talk_print(f"EMERGENCY ALERT! Call {emergency_numbers.get(city,'108')} or your local emergency number.")

    else:
        talk_print("I couldn’t match your symptoms. Please provide more details or consult a doctor.")

talk_print("Thank you! Your session is now saved.")
