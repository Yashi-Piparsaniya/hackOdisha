from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional

import med_llm  # Your existing ML logic
import datetime
from pymongo import MongoClient

# ------------------------------ MONGO SETUP ------------------------------
MONGO_URI = "mongodb+srv://aditiguptachp20_db_user:HUImlQMeh0ReZqN6@swasthai.k8a9puu.mongodb.net/?retryWrites=true&w=majority&appName=SwasthAI"
client = MongoClient(MONGO_URI)
db = client["swasth_ai_db"]
chat_collection = db["chat_history_large"]

# ------------------------------ FASTAPI APP ------------------------------
app = FastAPI(title="Swasth AI API")

# ------------------------------ CORS MIDDLEWARE ------------------------------
origins = [
    "http://localhost",
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    # Add any frontend URLs that will call this API
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Use ["*"] to allow all origins or specify frontend URLs
    allow_credentials=True,
    allow_methods=["*"],  # GET, POST, OPTIONS, etc.
    allow_headers=["*"],
)

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
    
    # ML prediction
    predicted, confidence, severity = med_llm.predict_disease(symptoms)
    
    specialist = med_llm.specialists.get(predicted, "General Physician")
    care_tips = med_llm.care_tips.get(predicted, "No tips available")
    hospitals = med_llm.get_osm_hospitals(request.city)
    
    # Save record in MongoDB
    record = {
        "Timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "Symptoms": symptoms,
        "Disease": predicted,
        "Confidence": confidence,
        "Severity": severity,
        "Specialist": specialist,
        "Care_Tips": care_tips,
        "Nearby_Hospitals": hospitals,
        "City": request.city
    }
    chat_collection.insert_one(record)

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

from fastapi.responses import JSONResponse

# ------------------------------ HISTORY ENDPOINT ------------------------------
@app.get("/history")
def get_history():
    records = chat_collection.find().sort("Timestamp", -1).limit(20)  # Get last 20 entries
    history = []
    for record in records:
        history.append({
            "Disease": record.get("Disease"),
            "Confidence": record.get("Confidence"),
            "Severity": record.get("Severity"),
            "Specialist": record.get("Specialist"),
            "Care_Tips": record.get("Care_Tips"),
            "Timestamp": record.get("Timestamp"),
        })
    return JSONResponse(content=history)
