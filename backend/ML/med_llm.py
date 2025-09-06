import speech_recognition as sr
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
MONGO_URI = "mongodb+srv://meditron_user:meditron_user101@cluster0.2qjbtsd.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
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

def get_voice_input(prompt="Speak now:", retries=2):
    recognizer.dynamic_energy_threshold = True
    for attempt in range(retries):
        with sr.Microphone() as source:
            recognizer.adjust_for_ambient_noise(source, duration=1)
            talk_print(prompt)
            beep(700, 200)
            try:
                audio = recognizer.listen(source, timeout=12, phrase_time_limit=20)
                beep(1000, 150)
                text = recognizer.recognize_google(audio)
                talk_print(f"You said: {text}")
                return text.lower()
            except sr.WaitTimeoutError:
                talk_print(" No speech detected.")
            except sr.UnknownValueError:
                talk_print(" Couldn’t understand audio.")
            except sr.RequestError as e:
                talk_print(f" API error: {e}")
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

# Specialists & Care Tips
# 1️⃣ Base dictionaries
specialists = {d: "General Physician" for d in disease_rules.keys()}  
care_tips = {d: f"Rest, hydrate, consult doctor. More info: https://www.google.com/search?q={d.replace(' ','+')}" 
             for d in disease_rules.keys()} 

# ------------------------------ UPDATED SPECIALISTS & CARE TIPS ------------------------------
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
    "Hypertension": "Monitor BP, reduce salt, exercise, consult cardiologist. More info: https://www.google.com/search?q=Hypertension+management",
    "Appendicitis": "Seek immediate medical attention, avoid food/water until surgery. More info: https://www.google.com/search?q=Appendicitis+care",
    "Allergy": "Avoid allergens, use antihistamines, consult allergist. More info: https://www.google.com/search?q=Allergy+care",
    "Bronchitis": "Rest, hydrate, avoid smoke, follow doctor advice. More info: https://www.google.com/search?q=Bronchitis+care",
    "Anemia": "Consume iron-rich foods, follow supplements, consult hematologist. More info: https://www.google.com/search?q=Anemia+management",
    "Hypothyroidism": "Take thyroid medication, regular check-ups, maintain diet. More info: https://www.google.com/search?q=Hypothyroidism+care",
    "Hyperthyroidism": "Medication compliance, avoid stimulants, regular monitoring. More info: https://www.google.com/search?q=Hyperthyroidism+management",
    "Arthritis": "Physiotherapy, anti-inflammatory meds, joint care. More info: https://www.google.com/search?q=Arthritis+management",
    "Back Pain": "Avoid heavy lifting, gentle exercises, consult orthopedic. More info: https://www.google.com/search?q=Back+Pain+management",
    "Kidney Stones": "Hydrate, pain management, consult urologist. More info: https://www.google.com/search?q=Kidney+Stones+care",
    "Liver Disease": "Avoid alcohol, maintain healthy diet, consult hepatologist. More info: https://www.google.com/search?q=Liver+Disease+care",
    "Sinusitis": "Use saline nasal sprays, rest, consult ENT if severe. More info: https://www.google.com/search?q=Sinusitis+care",
    "Depression": "Maintain routine, talk to a psychiatrist, avoid isolation. More info: https://www.google.com/search?q=Depression+care",
    "Anxiety": "Relaxation techniques, therapy, consult psychiatrist if persistent. More info: https://www.google.com/search?q=Anxiety+management",
    "Insomnia": "Maintain sleep hygiene, avoid caffeine, consult psychiatrist if chronic. More info: https://www.google.com/search?q=Insomnia+care",
    "Obesity": "Balanced diet, exercise, consult nutritionist/endocrinologist. More info: https://www.google.com/search?q=Obesity+management",
    "Osteoporosis": "Calcium & vitamin D intake, weight-bearing exercise, consult doctor. More info: https://www.google.com/search?q=Osteoporosis+care",
    "Heart Failure": "Monitor symptoms, follow cardiologist advice, medication compliance. More info: https://www.google.com/search?q=Heart+Failure+management",
    "COPD": "Avoid smoke, take prescribed inhalers, monitor breathing. More info: https://www.google.com/search?q=COPD+management",
    "Tuberculosis": "Follow antibiotic course strictly, rest, consult pulmonologist. More info: https://www.google.com/search?q=Tuberculosis+management",
    "Malaria": "Hydrate, take prescribed medication, monitor fever. More info: https://www.google.com/search?q=Malaria+care",
    "Chickenpox": "Rest, avoid scratching, maintain hygiene. More info: https://www.google.com/search?q=Chickenpox+care",
    "Measles": "Isolate, hydrate, consult pediatrician. More info: https://www.google.com/search?q=Measles+care",
    "Hepatitis": "Avoid alcohol, maintain diet, consult hepatologist. More info: https://www.google.com/search?q=Hepatitis+care",
    "Ulcer": "Avoid spicy food, follow doctor medication. More info: https://www.google.com/search?q=Ulcer+care",
    "Ear Infection": "Keep ear dry, consult ENT, avoid cotton swabs. More info: https://www.google.com/search?q=Ear+Infection+care",
    "Eye Infection": "Avoid touching eyes, follow ophthalmologist advice. More info: https://www.google.com/search?q=Eye+Infection+care",
    "Cold Sores": "Use antiviral creams, avoid sharing utensils. More info: https://www.google.com/search?q=Cold+Sores+care",
    "Skin Infection": "Keep area clean, consult dermatologist. More info: https://www.google.com/search?q=Skin+Infection+care",
    "Sprain": "Restpython md, ice, compression, elevation, consult orthopedic if severe. More info: https://www.google.com/search?q=Sprain+care",
    "Fracture": "Immobilize, seek orthopedic care immediately. More info: https://www.google.com/search?q=Fracture+care",
    "Burn": "Cool the area, avoid breaking blisters, consult burn specialist. More info: https://www.google.com/search?q=Burn+care",
    "Hypoglycemia": "Consume fast-acting sugar, monitor glucose, consult endocrinologist. More info: https://www.google.com/search?q=Hypoglycemia+care",
    "Hyperglycemia": "Hydrate, monitor glucose, follow medication. More info: https://www.google.com/search?q=Hyperglycemia+management",
    "Panic Attack": "Practice breathing techniques, stay calm, consult psychiatrist if frequent. More info: https://www.google.com/search?q=Panic+Attack+care"
})

# ------------------------------ DISEASE PREDICTION ------------------------------
def predict_disease(symptoms):
    best_match, max_count = None, 0
    for disease, keywords in disease_rules.items():
        match_count = sum(1 for s in symptoms if any(word in s for word in keywords) or difflib.get_close_matches(s, keywords, cutoff=0.7))
        if match_count > max_count:
            max_count, best_match = match_count, disease
    confidence = min((max_count / len(symptoms) * 100), 100) if symptoms else 0  # capped at 100%
    severity = "High" if best_match in ["Heart Attack","Stroke","Hypoglycemia"] else "Moderate" if confidence>50 else "Low"
    return best_match, round(confidence,2), severity


# ------------------------------ GRAPH ------------------------------
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

# ------------------------------ MAIN CHATBOT LOOP ------------------------------
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
        mode = input("You (type 'speak' or 'type'): ").strip().lower()
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
    predicted, confidence, severity = predict_disease(symptoms)

    if predicted:
        specialist = specialists.get(predicted, "General Physician")
        hospitals = get_osm_hospitals(city)

        record = {
            "Timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "Symptoms": symptoms,
            "Disease": predicted,
            "Confidence": confidence,
            "Severity": severity,
            "Specialist": specialist,
            "Care_Tips": care_tips.get(predicted),
            "Nearby_Hospitals": hospitals,
            "City": city
        }
        chat_collection.insert_one(record)
        history.append(record)

        talk_print(f"Based on your symptoms, you might have {predicted}.")
        talk_print(f"My confidence level is {confidence} percent.")
        talk_print(f"The severity appears to be {severity}.")
        talk_print(f"You should consult a {specialist}.")
        talk_print(f"Care Tips: {care_tips.get(predicted)}")

    
    talk_print("Opening Google Maps links for nearby hospitals...")
if hospitals:
    talk_print("Nearby Hospitals (clickable links):")
    for i, h in enumerate(hospitals, 1):
        query = h.replace(" ", "+") + "+" + city.replace(" ", "+")
        maps_url = f"https://www.google.com/maps/search/?api=1&query={query}"
        talk_print(f"{i}. {h} → {maps_url}")  # clickable link in console


        #if hospitals:
           # talk_print("Nearby Hospitals:")
            #for h in hospitals:
            #    talk_print(f" - {h}")
            #talk_print(f"Google Maps: https://www.google.com/maps/search/hospitals+near+{city}")

        if severity == "High":
            talk_print("This seems serious. Please call emergency services immediately!")
            talk_print(f"EMERGENCY ALERT! Call {emergency_numbers.get(city,'108')} or your local emergency number.")

    #else:
       # talk_print("I couldn’t match your symptoms to a known disease. Please provide more details.")

# ------------------------------ SAVE GRAPH ------------------------------
def save_graph_to_mongo(history):
    if not history:
        return
    df = pd.DataFrame(history)
    df["Timestamp"] = pd.to_datetime(df["Timestamp"])
    colors = {"High":"#FF4C4C","Moderate":"#FFA500","Low":"#4CAF50"}
    plt.style.use('ggplot')  # default style, avoids seaborn errors
    fig, ax = plt.subplots(figsize=(12,6))
    ax.plot(df["Timestamp"], df["Confidence"], color="#0077CC", linewidth=2, marker='o')
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

    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=150)
    buf.seek(0)
    graph_collection.insert_one({
        "Timestamp": datetime.datetime.now(),
        "Graph_Image": buf.getvalue()
    })
    buf.close()
    plt.close(fig)

save_graph_to_mongo(history)

# ------------------------------ INTERACTIVE GRAPH ------------------------------
def save_interactive_graph_to_mongo(history):
    if not history:
        return
    df = pd.DataFrame(history)
    df["Timestamp"] = pd.to_datetime(df["Timestamp"])
    severity_colors = {"High": "#FF4C4C", "Moderate": "#FFA500", "Low": "#4CAF50"}
    traces = []
    for sev in ["High", "Moderate", "Low"]:
        subset = df[df["Severity"] == sev]
        if subset.empty:
            continue
        trace = go.Scatter(
            x=subset["Timestamp"],
            y=subset["Confidence"],
            mode='markers+lines',
            name=f"{sev} Severity",
            marker=dict(color=severity_colors[sev], size=12, line=dict(color='black', width=1)),
            line=dict(color='#0077CC', width=2),
            text=[f"Disease: {r['Disease']}<br>Symptoms: {', '.join(r['Symptoms'])}<br>Specialist: {r['Specialist']}" 
                  for i, r in subset.iterrows()],
            hoverinfo='text+y+x'
        )
        traces.append(trace)
    layout = go.Layout(
        title="Confidence & Severity Over Time",
        xaxis=dict(title="Timestamp"),
        yaxis=dict(title="Confidence %", range=[0, 110]),
        plot_bgcolor="#E6F2FF",
        paper_bgcolor="#FFFFFF",
        hovermode='closest'
    )
    fig = go.Figure(data=traces, layout=layout)
    html_buf = pio.to_html(fig, full_html=True, include_plotlyjs='cdn')
    graph_collection.insert_one({
        "Timestamp": datetime.datetime.now(),
        "Graph_HTML": html_buf.encode('utf-8')
    })
    #print("Interactive graph saved to MongoDB.")
    print("Thankyou! Your hitory is now saved.")

save_interactive_graph_to_mongo(history)
