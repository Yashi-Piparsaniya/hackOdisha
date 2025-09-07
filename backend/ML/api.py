from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional

import med_llm  # Your existing ML logic
import datetime
from pymongo import MongoClient

# Mongo setup
MONGO_URI = "mongodb+srv://aditiguptachp20_db_user:HUImlQMeh0ReZqN6@swasthai.k8a9puu.mongodb.net/?retryWrites=true&w=majority&appName=SwasthAI"
client = MongoClient(MONGO_URI)
db = client["swasth_ai_db"]
chat_collection = db["chat_history_large"]

app = FastAPI(title="Swasth AI API")

# ------------------------------ REQUEST & RESPONSE MODELS ------------------------------
class PredictRequest(BaseModel):
    symptoms: List[str]
    city: Optional[str] = "Rourkela"

class PredictResponse(BaseModel):
    disease: Optional[str]
    confidence: float
    severity: str
    specialist: str
    care_tips: str
    nearby_hospitals: List[str]

# ------------------------------ API ENDPOINT ------------------------------
@app.post("/predict", response_model=PredictResponse)
def predict(request: PredictRequest):
    symptoms = [s.lower() for s in request.symptoms]
    predicted, confidence, severity = med_llm.predict_disease(symptoms)
    
    specialist = med_llm.specialists.get(predicted, "General Physician")
    care_tips = med_llm.care_tips.get(predicted, "No tips available")
    hospitals = med_llm.get_osm_hospitals(request.city)
    
    # Save record in MongoDB
    record = {
        "Timestamp": med_llm.datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "Symptoms": symptoms,
        "Disease": predicted,
        "Confidence": confidence,
        "Severity": severity,
        "Specialist": specialist,
        "Care_Tips": care_tips,
        "Nearby_Hospitals": hospitals,
        "City": request.city
    }
    med_llm.chat_collection.insert_one(record)

    return PredictResponse(
        disease=predicted,
        confidence=confidence,
        severity=severity,
        specialist=specialist,
        care_tips=care_tips,
        nearby_hospitals=hospitals
    )

# ------------------------------ HEALTH CHECK ------------------------------
@app.get("/health")
def health_check():
    return {"status": "API is running!"}


