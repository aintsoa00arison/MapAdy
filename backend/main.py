import uvicorn
from fastapi import FastAPI, Depends, status, Body, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from database import engine, get_db
import models, schemas
from repositories.user_repository import UserRepository
from repositories.quiz_repository import QuizRepository
from use_cases.user_use_cases import UserUseCases
from use_cases.quiz_use_cases import QuizUseCases
from typing import List, Optional
from datetime import datetime

app = FastAPI(title="mapADy Cyber-Backend", version="3.5.3")

models.Base.metadata.create_all(bind=engine)

app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

def get_user_use_cases(db: Session = Depends(get_db)):
    return UserUseCases(UserRepository(db))

def get_quiz_use_cases(db: Session = Depends(get_db)):
    return QuizUseCases(QuizRepository(db))

@app.post("/api/quiz/submit")
def submit_quiz_answer(payload: dict = Body(...), db: Session = Depends(get_db)):
    user_id = payload.get("user_id")
    is_correct = payload.get("is_correct", False)
    base_id = payload.get("base_id")
    is_last_question = payload.get("is_last", False)
    correct_count = payload.get("correct_count", 0)
    total_questions = payload.get("total_questions", 6)
    debug_gadget = payload.get("debug_gadget") # Nouveau : pour le simulateur

    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user: return {"error": "User not found"}

    stop_quiz = False
    status_msg = "OK"
    earned_gold = 0

    # LOGIQUE FROSTTRAP (UNIQUEMENT SI ACTIF)
    if base_id is not None and not is_correct:
        # Vérifier si c'est un test local OU une base réelle protégée
        is_frost_trap = False
        if base_id == 0 and debug_gadget == "FROSTTRAP":
            is_frost_trap = True
        elif base_id != 0:
            frost_db = db.query(models.ActiveDefense).filter(
                models.ActiveDefense.base_id == base_id,
                models.ActiveDefense.expires_at > datetime.now()
            ).join(models.Gadget).filter(models.Gadget.name == "FrostTrap").first()
            if frost_db: is_frost_trap = True

        if is_frost_trap:
            penalty = 150
            user.gold = max(0, user.gold - penalty)
            # Donner l'amende au proprio (ou agent 999 pour test)
            owner_id = 999
            if base_id != 0:
                base = db.query(models.GameBase).filter(models.GameBase.id == base_id).first()
                if base: owner_id = base.owner_id

            owner = db.query(models.User).filter(models.User.id == owner_id).first()
            if owner: owner.gold += penalty

            stop_quiz = True
            status_msg = f"SYSTÈME GELÉ ! {penalty} CC VERSÉS AU PROPRIÉTAIRE."

    # GAINS FINAUX & DRAINCASH
    if is_last_question and not stop_quiz:
        earned_gold = correct_count * 10
        if correct_count == total_questions: earned_gold += 20

        # Vérifier DrainCash
        is_drain_cash = False
        if base_id == 0 and debug_gadget == "DRAINCASH":
            is_drain_cash = True
        elif base_id != 0:
            drain_db = db.query(models.ActiveDefense).filter(
                models.ActiveDefense.base_id == base_id,
                models.ActiveDefense.expires_at > datetime.now()
            ).join(models.Gadget).filter(models.Gadget.name == "DrainCash").first()
            if drain_db: is_drain_cash = True

        if is_drain_cash and correct_count < total_questions:
            target_id = 999
            if base_id != 0:
                base = db.query(models.GameBase).filter(models.GameBase.id == base_id).first()
                if base: target_id = base.owner_id

            owner = db.query(models.User).filter(models.User.id == target_id).first()
            if owner: owner.gold += earned_gold
            earned_gold = 0
            status_msg = "DRAINCASH : GAINS DÉVIÉS VERS LE PROPRIÉTAIRE"

        user.gold += earned_gold
        user.quiz_victories += 1

        # Capture réelle
        if base_id and base_id != 0 and correct_count == total_questions:
            base = db.query(models.GameBase).filter(models.GameBase.id == base_id).first()
            if base:
                base.owner_id = user.id
                user.territories_captured += 1

    db.commit()
    return {"gold": user.gold, "stop_quiz": stop_quiz, "status": status_msg, "earned": earned_gold}

# --- RESTE DES ROUTES (Inchangé) ---
@app.get("/api/users/{user_id}", response_model=schemas.UserResponse)
def get_profile(user_id: int, service: UserUseCases = Depends(get_user_use_cases)):
    return service.get_user_profile(user_id)

@app.get("/api/bases", response_model=List[schemas.GameBaseResponse])
def get_all_bases(db: Session = Depends(get_db)):
    return db.query(models.GameBase).all()

@app.get("/api/quiz/next/{user_id}")
def get_next_quiz(user_id: int, base_id: Optional[int] = Query(None), service: QuizUseCases = Depends(get_quiz_use_cases)):
    return service.get_next_question(user_id, base_id)

@app.post("/api/auth/login", response_model=schemas.UserResponse)
def login(login_data: schemas.UserLogin, service: UserUseCases = Depends(get_user_use_cases)):
    return service.login_user(login_data)

@app.get("/")
def health_check():
    return {"status": "ONLINE", "version": "3.5.3"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
