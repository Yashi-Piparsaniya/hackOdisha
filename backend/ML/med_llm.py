import json
import datetime
import requests
from collections import Counter
import pandas as pd
import matplotlib.pyplot as plt
import os

# ------------------------------
# CONFIGURATION
# ------------------------------
DEFAULT_LOCATION = "Rourkela"

# ------------------------------
# EXPANDED DISEASE DATABASE (~50)
# ------------------------------
disease_rules = {
    "Flu": ["fever", "cough", "body ache", "fatigue", "chills"],
    "Common Cold": ["cough", "sore throat", "runny nose", "sneezing", "mild fever"],
    "Migraine": ["headache", "migraine", "nausea", "light sensitivity", "vomiting"],
    "Measles": ["fever", "rash", "cough", "runny nose", "red eyes"],
    "Meningitis": ["fever", "headache", "stiff neck", "nausea", "vomiting"],
    "Bronchitis": ["cough", "shortness of breath", "chest discomfort", "fatigue", "wheezing"],
    "Food Poisoning": ["nausea", "vomiting", "diarrhea", "abdominal pain", "fever"],
    "Gastritis": ["abdominal pain", "bloating", "nausea", "indigestion", "heartburn"],
    "Arthritis": ["joint pain", "swelling", "stiffness", "redness", "tenderness"],
    "Heart Attack": ["chest pain", "shortness of breath", "nausea", "sweating", "dizziness"],
    "Allergy": ["rash", "itching", "sneezing", "watery eyes", "swelling"],
    "Skin Infection": ["skin infection", "pimples", "redness", "pus", "swelling"],
    "Diabetes": ["frequent urination", "increased thirst", "fatigue", "blurred vision", "slow healing"],
    "Hypertension": ["headache", "dizziness", "blurred vision", "chest pain", "nosebleed"],
    "Asthma": ["shortness of breath", "wheezing", "chest tightness", "coughing", "fatigue"],
    "Pneumonia": ["fever", "cough", "shortness of breath", "chest pain", "fatigue"],
    "Tuberculosis": ["persistent cough", "fever", "night sweats", "weight loss", "fatigue"],
    "Urinary Tract Infection": ["painful urination", "frequent urination", "urgency", "lower abdominal pain", "cloudy urine"],
    "Hepatitis": ["fatigue", "nausea", "jaundice", "abdominal pain", "loss of appetite"],
    "Chickenpox": ["fever", "rash", "itching", "fatigue", "loss of appetite"],
    "Dengue": ["fever", "headache", "joint pain", "rash", "nausea"],
    "Typhoid": ["fever", "abdominal pain", "diarrhea", "headache", "weakness"],
    "Anemia": ["fatigue", "weakness", "pale skin", "dizziness", "shortness of breath"],
    "Bronchial Asthma": ["wheezing", "shortness of breath", "cough", "chest tightness"],
    "Thyroid Disorder": ["fatigue", "weight change", "hair loss", "dry skin", "mood changes"],
    "Gout": ["joint pain", "redness", "swelling", "warmth", "limited movement"],
    "Epilepsy": ["seizures", "loss of consciousness", "confusion", "staring spells", "falling"],
    "Depression": ["persistent sadness", "loss of interest", "fatigue", "sleep changes", "concentration problems"],
    "Anxiety": ["restlessness", "rapid heartbeat", "nervousness", "sweating", "trembling"],
    "Cystitis": ["frequent urination", "burning sensation", "urgency", "lower abdominal pain", "blood in urine"],
    "Sinusitis": ["facial pain", "nasal congestion", "headache", "runny nose", "fever"],
    "Ear Infection": ["ear pain", "hearing loss", "fluid discharge", "fever", "dizziness"],
    "Conjunctivitis": ["red eyes", "itching", "tearing", "discharge", "swelling"],
    "Psoriasis": ["red patches", "scaly skin", "itching", "dryness", "thickened skin"],
    "Eczema": ["itching", "redness", "dry skin", "rash", "inflammation"],
    "Bronchiectasis": ["chronic cough", "mucus", "shortness of breath", "recurrent infections"],
    "COPD": ["shortness of breath", "chronic cough", "fatigue", "wheezing"],
    "Osteoporosis": ["bone pain", "fractures", "loss of height", "stooped posture"],
    "Polio": ["fever", "fatigue", "muscle weakness", "paralysis", "stiffness"],
    "Rabies": ["fever", "headache", "agitation", "salivation", "fear of water"],
    "Malaria": ["fever", "chills", "sweating", "headache", "vomiting"],
    "Cholera": ["severe diarrhea", "dehydration", "vomiting", "abdominal cramps"],
    "Zika Virus": ["fever", "rash", "joint pain", "red eyes", "headache"],
    "Leprosy": ["skin lesions", "numbness", "weakness", "ulcers", "thickened skin"],
    "HIV/AIDS": ["fatigue", "weight loss", "fever", "night sweats", "swollen lymph nodes"],
    "COVID-19": ["fever", "cough", "shortness of breath", "fatigue", "loss of taste or smell"],
    "Mononucleosis": ["fatigue", "fever", "sore throat", "swollen lymph nodes", "headache"]
}

# ------------------------------
# Disease Info Links
# ------------------------------
disease_links = {
    "Flu": "https://www.cdc.gov/flu/",
    "Common Cold": "https://www.mayoclinic.org/diseases-conditions/common-cold/",
    "Migraine": "https://www.mayoclinic.org/diseases-conditions/migraine/",
    "Measles": "https://www.who.int/news-room/fact-sheets/detail/measles",
    "Meningitis": "https://www.cdc.gov/meningitis/",
    "Bronchitis": "https://www.nhs.uk/conditions/bronchitis/",
    "Food Poisoning": "https://www.mayoclinic.org/diseases-conditions/food-poisoning/",
    "Gastritis": "https://www.mayoclinic.org/diseases-conditions/gastritis/",
    "Arthritis": "https://www.cdc.gov/arthritis/",
    "Heart Attack": "https://www.heart.org/en/health-topics/heart-attack",
    "Allergy": "https://www.aaaai.org/conditions-and-treatments/allergies",
    "Skin Infection": "https://www.mayoclinic.org/diseases-conditions/skin-infections/",
    "Diabetes": "https://www.who.int/news-room/fact-sheets/detail/diabetes",
    "Hypertension": "https://www.cdc.gov/bloodpressure/",
    "Asthma": "https://www.nhs.uk/conditions/asthma/",
    "Pneumonia": "https://www.cdc.gov/pneumonia/",
    "Tuberculosis": "https://www.who.int/health-topics/tuberculosis",
    "Urinary Tract Infection": "https://www.mayoclinic.org/diseases-conditions/urinary-tract-infection/",
    "Hepatitis": "https://www.cdc.gov/hepatitis/",
    "Chickenpox": "https://www.cdc.gov/chickenpox/",
    "Dengue": "https://www.who.int/news-room/fact-sheets/detail/dengue-and-severe-dengue",
    "Typhoid": "https://www.who.int/news-room/fact-sheets/detail/typhoid",
    "Anemia": "https://www.mayoclinic.org/diseases-conditions/anemia/",
    "Bronchial Asthma": "https://www.nhs.uk/conditions/asthma/",
    "Thyroid Disorder": "https://www.mayoclinic.org/diseases-conditions/hypothyroidism/",
    "Gout": "https://www.mayoclinic.org/diseases-conditions/gout/",
    "Epilepsy": "https://www.who.int/news-room/fact-sheets/detail/epilepsy",
    "Depression": "https://www.nimh.nih.gov/health/topics/depression",
    "Anxiety": "https://www.nimh.nih.gov/health/topics/anxiety-disorders",
    "Cystitis": "https://www.nhs.uk/conditions/cystitis/",
    "Sinusitis": "https://www.mayoclinic.org/diseases-conditions/sinusitis/",
    "Ear Infection": "https://www.nhs.uk/conditions/ear-infections/",
    "Conjunctivitis": "https://www.nhs.uk/conditions/conjunctivitis/",
    "Psoriasis": "https://www.nhs.uk/conditions/psoriasis/",
    "Eczema": "https://www.nhs.uk/conditions/eczema/",
    "Bronchiectasis": "https://www.nhs.uk/conditions/bronchiectasis/",
    "COPD": "https://www.nhs.uk/conditions/chronic-obstructive-pulmonary-disease-copd/",
    "Osteoporosis": "https://www.nhs.uk/conditions/osteoporosis/",
    "Polio": "https://www.who.int/news-room/fact-sheets/detail/poliomyelitis",
    "Rabies": "https://www.who.int/news-room/fact-sheets/detail/rabies",
    "Malaria": "https://www.who.int/news-room/fact-sheets/detail/malaria",
    "Cholera": "https://www.who.int/news-room/fact-sheets/detail/cholera",
    "Zika Virus": "https://www.cdc.gov/zika/",
    "Leprosy": "https://www.who.int/news-room/fact-sheets/detail/leprosy",
    "HIV/AIDS": "https://www.who.int/health-topics/hiv-aids",
    "COVID-19": "https://www.who.int/health-topics/coronavirus",
    "Mononucleosis": "https://www.mayoclinic.org/diseases-conditions/mononucleosis/"
}

# ------------------------------
# Tips / Home Remedies
# ------------------------------
tips = {disease: f"Rest, hydrate, and follow medical advice. Learn more: {disease_links.get(disease,'Consult doctor')}" 
        for disease in disease_rules}

# ------------------------------
# Symptom-to-Specialist Mapping
# ------------------------------
specialists = {
    "Flu": "General Physician",
    "Common Cold": "General Physician",
    "Migraine": "Neurologist",
    "Measles": "Pediatrician",
    "Meningitis": "Neurologist",
    "Bronchitis": "Pulmonologist",
    "Food Poisoning": "Gastroenterologist",
    "Gastritis": "Gastroenterologist",
    "Arthritis": "Rheumatologist",
    "Heart Attack": "Cardiologist",
    "Allergy": "Allergist/Immunologist",
    "Skin Infection": "Dermatologist",
    "Diabetes": "Endocrinologist",
    "Hypertension": "Cardiologist",
    "Asthma": "Pulmonologist",
    "Pneumonia": "Pulmonologist",
    "Tuberculosis": "Pulmonologist",
    "Urinary Tract Infection": "Urologist",
    "Hepatitis": "Hepatologist",
    "Chickenpox": "Pediatrician",
    "Dengue": "General Physician",
    "Typhoid": "Infectious Disease Specialist",
    "Anemia": "Hematologist",
    "Bronchial Asthma": "Pulmonologist",
    "Thyroid Disorder": "Endocrinologist",
    "Gout": "Rheumatologist",
    "Epilepsy": "Neurologist",
    "Depression": "Psychiatrist",
    "Anxiety": "Psychiatrist",
    "Cystitis": "Urologist",
    "Sinusitis": "ENT Specialist",
    "Ear Infection": "ENT Specialist",
    "Conjunctivitis": "Ophthalmologist",
    "Psoriasis": "Dermatologist",
    "Eczema": "Dermatologist",
    "Bronchiectasis": "Pulmonologist",
    "COPD": "Pulmonologist",
    "Osteoporosis": "Orthopedic",
    "Polio": "Neurologist",
    "Rabies": "Infectious Disease Specialist",
    "Malaria": "Infectious Disease Specialist",
    "Cholera": "Infectious Disease Specialist",
    "Zika Virus": "Infectious Disease Specialist",
    "Leprosy": "Dermatologist",
    "HIV/AIDS": "Infectious Disease Specialist",
    "COVID-19": "Pulmonologist",
    "Mononucleosis": "General Physician"
}

# ------------------------------
# Emergency Hotlines
# ------------------------------
emergency_hotlines = {"India": "108", "default": "Please contact local emergency services."}

# ------------------------------
# Colors
# ------------------------------
class bcolors:
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

# ------------------------------
# Helper Functions
# ------------------------------
def get_user_city():
    try:
        response = requests.get("https://ipinfo.io/json", timeout=5)
        city = response.json().get("city", DEFAULT_LOCATION)
    except:
        city = DEFAULT_LOCATION
    print(f"Detected location: {city}")
    user_input = input("Press Enter to confirm or type your city: ").strip()
    return user_input if user_input else city

def get_nearby_hospitals(location):
    try:
        url = "https://nominatim.openstreetmap.org/search"
        params = {"q": f"hospitals in {location}", "format": "json", "limit": 5}
        headers = {"User-Agent": "MeditronBot/1.0"}
        response = requests.get(url, params=params, headers=headers, timeout=5)
        data = response.json()
        hospitals = []
        for place in data:
            name = place.get("display_name", "")
            lat = place.get("lat")
            lon = place.get("lon")
            parts = name.split(",")
            hospital_name = f"{parts[0].strip()} - {parts[1].strip()}" if len(parts) >= 2 else parts[0].strip()
            if lat and lon:
                link = f"https://www.google.com/maps/search/?api=1&query={lat},{lon}"
                hospitals.append(f"{hospital_name} ({link})")
            else:
                hospitals.append(hospital_name)
        return hospitals if hospitals else ["No hospitals found"]
    except Exception as e:
        return [f"Error fetching hospitals: {e}"]

# ------------------------------
# Disease Prediction
# ------------------------------
def predict_disease(symptoms):
    symptoms = [s.strip().lower() for s in symptoms.split(",")]
    scores = {}
    for disease, keywords in disease_rules.items():
        match_count = sum(1 for word in keywords if word.lower() in symptoms)
        if match_count > 0:
            confidence = match_count / len(keywords)
            severe_diseases = ["HIV/AIDS", "Rabies", "Polio", "Heart Attack", "Meningitis"]
            if disease in severe_diseases and match_count < 2:
                continue
            scores[disease] = confidence

    if not scores:
        return [("Unknown", 0)]
    sorted_diseases = sorted(scores.items(), key=lambda x: x[1], reverse=True)[:3]
    return sorted_diseases

# ------------------------------
# Severity Calculation
# ------------------------------
def get_severity(symptoms):
    severity_score = 1
    symptoms = symptoms.lower()
    if any(word in symptoms for word in ["chest pain", "shortness of breath", "stiff neck", "severe"]):
        severity_score = 10
        color = bcolors.FAIL
        alert = True
    elif any(word in symptoms for word in ["fever", "pain", "vomiting", "rash", "cough"]):
        severity_score = 7
        color = bcolors.WARNING
        alert = False
    else:
        severity_score = 3
        color = bcolors.OKGREEN
        alert = False

    if severity_score <= 3:
        level = "Low"
    elif severity_score <= 7:
        level = "Medium"
    else:
        level = "High"
    return level, color, alert

# ------------------------------
# Display Response
# ------------------------------
# ------------------------------
# Display Response with Personality
# ------------------------------
def display_response(predictexions, severity_level, color, emergency_alert, hospitals):
    print("\n" + "="*60)
    
    # Emergency alert
    if emergency_alert:
        print(f"{bcolors.FAIL}{bcolors.BOLD}!!! EMERGENCY ALERT: Seek immediate medical attention !!!{bcolors.ENDC}")
        print(f"{bcolors.FAIL}Emergency Hotline: {emergency_hotlines.get('India','108')}{bcolors.ENDC}")
        print("-"*60)
    
    # Intro message
    if not emergency_alert:
        print(f"{bcolors.BOLD}Hello! Here's what I found based on your symptoms:{bcolors.ENDC}")
    
    print(f"{bcolors.BOLD}Disease Predictions (Top 3):{bcolors.ENDC}")
    for disease, confidence in predictexions:  # <-- fixed here
        tip = tips.get(disease, "Consult a doctor for advice.")
        specialist = specialists.get(disease, "General Physician")
        link = disease_links.get(disease, "")
        
        # Professional-light personality messaging
        if confidence >= 0.7:
            tone = "It seems quite likely that you may have"
        elif confidence >= 0.4:
            tone = "There’s a chance of"
        else:
            tone = "Possibly"
        
        print(f"  {bcolors.WARNING}• {disease} ({confidence*100:.0f}% match){bcolors.ENDC}")
        print(f"    {tone} {disease}.")
        print(f"    Tip: {tip}")
        print(f"    Specialist: {specialist}")
        if link:
            print(f"    More info: {link}")
    
    # Severity message
    if severity_level == "High":
        print(f"{bcolors.BOLD}Severity Level:{bcolors.ENDC} {color}{severity_level} - Please act promptly!{bcolors.ENDC}")
    elif severity_level == "Medium":
        print(f"{bcolors.BOLD}Severity Level:{bcolors.ENDC} {color}{severity_level} - Keep monitoring and stay cautious.{bcolors.ENDC}")
    else:
        print(f"{bcolors.BOLD}Severity Level:{bcolors.ENDC} {color}{severity_level} - No major concern. Take care!{bcolors.ENDC}")
    
    # Nearby hospitals
    print(f"{bcolors.BOLD}Nearby Hospitals:{bcolors.ENDC}")
    for idx, hospital in enumerate(hospitals, 1):
        print(f"  {idx}. {hospital}")
    
    # Closing friendly note
    if not emergency_alert:
        print("\nRemember to rest, stay hydrated, and don’t hesitate to consult a doctor if things worsen!")
    
    print("="*60 + "\n")



# ------------------------------
# History & Trends
# ------------------------------
def export_history(history):
    df = pd.DataFrame(history)
    df.to_csv("symptom_history.csv", index=False)
    df.to_excel("symptom_history.xlsx", index=False)
    with open("symptom_history.json", "w") as f:
        json.dump(history, f, indent=4)
    print("Session history exported to CSV, Excel, and JSON.")

def frequent_diseases(history):
    all_diseases = []
    for record in history:
        all_diseases.extend([d[0] for d in record["predictions"]])
    common = Counter(all_diseases).most_common(3)
    print("\nMost Frequent Predicted Diseases:")
    for disease, count in common:
        print(f"  {disease} ({count} times)")

def plot_symptom_trends(history):
    all_symptoms = []
    for record in history:
        all_symptoms.extend([s.strip() for s in record["symptoms"].split(",")])
    symptom_counts = Counter(all_symptoms)
    if not symptom_counts:
        print("No symptoms to plot.")
        return
    plt.figure(figsize=(10,5))
    plt.bar(symptom_counts.keys(), symptom_counts.values(), color='skyblue')
    plt.xticks(rotation=45)
    plt.title("Symptom Frequency in Session")
    plt.ylabel("Count")
    plt.tight_layout()
    plt.show()

# ------------------------------
# MAIN CHATBOT
# ------------------------------
def main():
    print(f"{bcolors.BOLD}=== Meditron Multi-Symptom Chatbot (Professional-Light) ==={bcolors.ENDC}\n")
    history = []
    user_city = get_user_city()
    
    try:
        while True:
            user_input = input("\nEnter your symptoms separated by commas (or 'exit' to quit): ").strip()
            if user_input.lower() == "exit":
                break
            if not user_input:  # handle empty input
                print("Please enter at least one symptom to continue.")
                continue

            predictions = predict_disease(user_input)
            severity_level, color, emergency_alert = get_severity(user_input)
            hospitals = get_nearby_hospitals(user_city)

            display_response(predictions, severity_level, color, emergency_alert, hospitals)

            # Add to history
            history.append({
                "time": str(datetime.datetime.now()),
                "symptoms": user_input,
                "predictions": predictions,
                "severity": severity_level
            })

            # Alert Threshold: repeated severe symptoms
            severe_symptoms = ["chest pain", "shortness of breath", "stiff neck", "severe"]
            count = sum(1 for h in history[-5:] if any(word in h["symptoms"].lower() for word in severe_symptoms))
            if count >= 3:
                print(f"{bcolors.FAIL}{bcolors.BOLD}ALERT: Repeated severe symptoms detected. Consider visiting a doctor immediately!{bcolors.ENDC}")

    except KeyboardInterrupt:
        print("\nChatbot interrupted by user.")
    
    finally:
        export_history(history)
        frequent_diseases(history)
        plot_symptom_trends(history)
        print("\nChatbot session ended. History saved.")


# ------------------------------
# RUN
# ------------------------------
if __name__ == "__main__":
    main()
