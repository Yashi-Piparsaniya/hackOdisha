import speech_recognition as sr
import sounddevice as sd
import wavio
import pyttsx3
import datetime
import pandas as pd
import matplotlib.pyplot as plt
import difflib
import requests
import webbrowser
import winsound
from pymongo import MongoClient
import time
import io
import plotly.graph_objs as go
import plotly.io as pio

# ------------------------------ MONGO SETUP ------------------------------
MONGO_URI = "mongodb+srv://aditiguptachp20_db_user:HUImlQMeh0ReZqN6@swasthai.k8a9puu.mongodb.net/?retryWrites=true&w=majority&appName=SwasthAI"
client = MongoClient(MONGO_URI)
db = client["swasth_ai_db"]
chat_collection = db["chat_history_large"]   # Chat records
graph_collection = db["graphs"]              # Graph records

# ------------------------------ SPEECH + TTS ------------------------------
recognizer = sr.Recognizer()
engine = pyttsx3.init()
engine.setProperty('rate', 165)
engine.setProperty('volume', 1.0)
voices = engine.getProperty('voices')
engine.setProperty('voice', voices[0].id)

def speak(text):
    engine.stop()
    engine.say(text)
    engine.runAndWait()
    time.sleep(0.2)

def talk_print(text):
    print(text)
    speak(text)

def beep(freq=800, duration=200):
    try:
        winsound.Beep(freq, duration)
    except:
        pass

def get_voice_input(prompt="Speak now:", duration=5, retries=2, fs=44100):
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

# ------------------------------ HOSPITAL FETCH ------------------------------
hospital_cache = {}
emergency_numbers = {"Rourkela": "108", "Delhi": "102", "Mumbai": "108"}

def get_osm_hospitals(city="Rourkela"):
    if city in hospital_cache:
        return hospital_cache[city]
    try:
        url = f"https://nominatim.openstreetmap.org/search?city={city}&format=json"
        res = requests.get(url, headers={"User-Agent": "Mozilla/5.0"}).json()
        if not res:
            return []
        lat, lon = res[0]["lat"], res[0]["lon"]

        overpass_url = "http://overpass-api.de/api/interpreter"
        query = f"""
        [out:json];
        node
          ["amenity"="hospital"]
          (around:5000,{lat},{lon});
        out;
        """
        response = requests.get(overpass_url, params={'data': query}, headers={"User-Agent": "Mozilla/5.0"}).json()
        hospitals = [e["tags"].get("name", "Unnamed Hospital") for e in response["elements"]][:4]
        hospital_cache[city] = hospitals
        return hospitals
    except Exception as e:
        print(f" Hospital fetch error: {e}")
        return []

# ------------------------------ DISEASE DATABASE (~50 DISEASES) ------------------------------
disease_rules = {
    "Flu": ["fever", "cough", "body ache", "fatigue", "chills"],
    "Common Cold": ["cough", "sore throat", "runny nose", "sneezing", "mild fever"],
    "Migraine": ["headache", "migraine", "nausea", "light sensitivity", "vomiting"],
    "Heart Attack": ["chest pain", "shortness of breath", "nausea", "sweating", "dizziness"],
    "Stroke": ["face drooping", "arm weakness", "speech difficulty", "sudden confusion"],
    "Diabetes": ["frequent urination", "increased thirst", "fatigue", "blurred vision", "slow healing"],
    "COVID-19": ["fever", "cough", "shortness of breath", "fatigue", "loss of taste", "loss of smell"],
    "Dengue": ["fever", "headache", "joint pain", "rash", "nausea"],
    "Typhoid": ["fever", "abdominal pain", "diarrhea", "headache", "weakness"],
    "Pneumonia": ["fever", "cough", "shortness of breath", "chest pain", "fatigue"],
    "Asthma": ["wheezing", "shortness of breath", "chest tightness", "coughing"],
    "Hypertension": ["headache", "dizziness", "blurred vision", "chest discomfort"],
    "Appendicitis": ["abdominal pain", "nausea", "vomiting", "loss of appetite", "fever"],
    "Allergy": ["sneezing", "itchy eyes", "runny nose", "rash"],
    "Bronchitis": ["cough", "mucus", "fatigue", "shortness of breath", "mild fever"],
    "Anemia": ["fatigue", "pale skin", "shortness of breath", "dizziness"],
    "Hypothyroidism": ["fatigue", "weight gain", "cold intolerance", "dry skin"],
    "Hyperthyroidism": ["weight loss", "heat intolerance", "palpitations", "nervousness"],
    "Arthritis": ["joint pain", "stiffness", "swelling", "reduced motion"],
    "Back Pain": ["lower back pain", "stiffness", "muscle ache"],
    "Kidney Stones": ["severe back pain", "nausea", "vomiting", "blood in urine"],
    "Liver Disease": ["jaundice", "abdominal pain", "fatigue", "nausea"],
    "Gastroenteritis": ["diarrhea", "vomiting", "abdominal cramps", "fever"],
    "Food Poisoning": ["nausea", "vomiting", "diarrhea", "abdominal pain"],
    "Sinusitis": ["headache", "facial pain", "congestion", "runny nose"],
    "Depression": ["sadness", "loss of interest", "fatigue", "sleep changes"],
    "Anxiety": ["nervousness", "worry", "restlessness", "difficulty concentrating"],
    "Insomnia": ["difficulty sleeping", "fatigue", "irritability"],
    "Obesity": ["weight gain", "fatigue", "shortness of breath"],
    "Osteoporosis": ["bone pain", "fractures", "reduced height"],
    "Heart Failure": ["shortness of breath", "fatigue", "swelling", "coughing"],
    "COPD": ["shortness of breath", "chronic cough", "wheezing", "fatigue"],
    "Tuberculosis": ["cough", "fever", "night sweats", "weight loss"],
    "Malaria": ["fever", "chills", "sweating", "headache", "nausea"],
    "Chickenpox": ["rash", "fever", "fatigue", "itching"],
    "Measles": ["fever", "rash", "cough", "runny nose", "conjunctivitis"],
    "Hepatitis": ["jaundice", "fatigue", "abdominal pain", "nausea"],
    "Ulcer": ["abdominal pain", "bloating", "nausea", "vomiting"],
    "Ear Infection": ["ear pain", "hearing loss", "fluid drainage"],
    "Eye Infection": ["redness", "itching", "discharge", "pain"],
    "Cold Sores": ["painful blisters", "lips", "mouth", "fever"],
    "Skin Infection": ["redness", "swelling", "pain", "pus"],
    "Sprain": ["pain", "swelling", "limited motion", "bruising"],
    "Fracture": ["pain", "swelling", "deformity", "inability to move"],
    "Burn": ["pain", "redness", "blistering", "swelling"],
    "Hypoglycemia": ["shakiness", "sweating", "confusion", "dizziness"],
    "Hyperglycemia": ["increased thirst", "frequent urination", "fatigue", "blurred vision"],
    "Panic Attack": ["shortness of breath", "chest tightness", "rapid heartbeat", "dizziness"]
}

# ------------------------------ SPECIALISTS & CARE TIPS ------------------------------
# ------------------------------ SPECIALISTS & CARE TIPS ------------------------------
specialists = {}
care_tips = {}
specialists.update({
    "Migraine": "Neurologist",
    "Heart Attack": "Cardiologist",
    "Stroke": "Neurologist",
    "Diabetes": "Endocrinologist",
    "COVID-19": "Infectious Disease Specialist",
    "Typhoid": "Gastroenterologist",
    "Pneumonia": "Pulmonologist",
    "Asthma": "Pulmonologist",
    "Hypertension": "Cardiologist",
    "Appendicitis": "Surgeon",
    "Allergy": "Allergist/Immunologist",
    "Bronchitis": "Pulmonologist",
    "Anemia": "Hematologist",
    "Hypothyroidism": "Endocrinologist",
    "Hyperthyroidism": "Endocrinologist",
    "Arthritis": "Rheumatologist",
    "Back Pain": "Orthopedic",
    "Kidney Stones": "Urologist",
    "Liver Disease": "Hepatologist",
    "Gastroenteritis": "Gastroenterologist",
    "Sinusitis": "ENT Specialist",
    "Depression": "Psychiatrist",
    "Anxiety": "Psychiatrist",
    "Insomnia": "Psychiatrist",
    "Obesity": "Nutritionist / Endocrinologist",
    "Osteoporosis": "Endocrinologist / Orthopedic",
    "Heart Failure": "Cardiologist",
    "COPD": "Pulmonologist",
    "Tuberculosis": "Pulmonologist / Infectious Disease Specialist",
    "Malaria": "Infectious Disease Specialist",
    "Chickenpox": "Dermatologist / Pediatrician",
    "Measles": "Pediatrician / Infectious Disease Specialist",
    "Hepatitis": "Hepatologist / Gastroenterologist",
    "Ulcer": "Gastroenterologist",
    "Ear Infection": "ENT Specialist",
    "Eye Infection": "Ophthalmologist",
    "Cold Sores": "Dermatologist",
    "Skin Infection": "Dermatologist",
    "Sprain": "Orthopedic",
    "Fracture": "Orthopedic",
    "Burn": "Dermatologist / Burn Specialist",
    "Hypoglycemia": "Endocrinologist",
    "Hyperglycemia": "Endocrinologist",
    "Panic Attack": "Psychiatrist"
})

care_tips.update({
    "Migraine": "Rest in a dark, quiet room, use cold packs, avoid triggers, consult neurologist. More info: https://www.google.com/search?q=Migraine+care",
    "Heart Attack": "Call emergency services immediately, chew aspirin if not allergic, stay calm. More info: https://www.google.com/search?q=Heart+Attack+first+aid",
    "Stroke": "Call emergency services immediately, note symptom onset time, keep patient safe. More info: https://www.google.com/search?q=Stroke+first+aid",
    "Diabetes": "Monitor blood sugar, maintain diet, stay active, follow medication. More info: https://www.google.com/search?q=Diabetes+management",
    "COVID-19": "Isolate, monitor oxygen, hydrate, rest, consult doctor if worsening. More info: https://www.google.com/search?q=COVID+care",
    "Typhoid": "Take prescribed antibiotics, maintain hydration, avoid street food. More info: https://www.google.com/search?q=Typhoid+care",
    "Pneumonia": "Rest, complete antibiotic course, monitor breathing, drink fluids. More info: https://www.google.com/search?q=Pneumonia+care",
    "Asthma": "Avoid triggers, use inhaler, monitor peak flow, consult pulmonologist. More info: https://www.google.com/search?q=Asthma+management",
    # ... continue for all diseases exactly as in your chatbot.py
})

# ------------------------------ DISEASE PREDICTION ------------------------------
def predict_disease(symptoms):
    best_match, max_count = None, 0
    for disease, keywords in disease_rules.items():
        match_count = 0
        for s in symptoms:
            for keyword in keywords:
                if s == keyword or difflib.get_close_matches(s, [keyword], cutoff=0.8):
                    match_count += 1
                    break
        if match_count > max_count:
            max_count, best_match = match_count, disease
    
    if not symptoms or not best_match:
        return None, 0, "Low"

    # Confidence based on how much of the disease's symptom profile is matched
    confidence = min((max_count / len(disease_rules[best_match]) * 100), 100)
    severity = "High" if best_match in ["Heart Attack","Stroke","Hypoglycemia"] else "Moderate" if confidence > 50 else "Low"
    return best_match, round(confidence,2), severity


# ------------------------------ GRAPH FUNCTIONS ------------------------------
def plot_confidence_severity(history):
    if not history:
        return
    df = pd.DataFrame(history)
    df["Timestamp"] = pd.to_datetime(df["Timestamp"])
    colors = {"High":"#FF4C4C","Moderate":"#FFA500","Low":"#4CAF50"}
    fig, ax = plt.subplots(figsize=(12,6))
    ax.plot(df["Timestamp"], df["Confidence"], color="blue", linewidth=2, marker='o', label="Confidence %")
    for i, row in df.iterrows():
        ax.scatter(row["Timestamp"], row["Confidence"], color=colors[row["Severity"]], s=120, edgecolor='black', zorder=5)
        ax.text(row["Timestamp"], row["Confidence"]+2, row["Severity"], ha='center', fontsize=9, fontweight='bold')
    ax.set_title("Confidence & Severity Over Time", fontsize=16, fontweight='bold')
    ax.set_xlabel("Timestamp")
    ax.set_ylabel("Confidence %")
    ax.set_ylim(0,110)
    ax.grid(True, linestyle='--', alpha=0.6)
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

