import uvicorn
import random
import string
from fastapi import FastAPI, Depends, status, Body, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from database import engine, get_db
import models, schemas
from repositories.user_repository import UserRepository
from repositories.quiz_repository import QuizRepository
from use_cases.user_use_cases import UserUseCases
from use_cases.quiz_use_cases import QuizUseCases
from logic.email_service import EmailService
from typing import List, Optional
from datetime import datetime, timedelta

app = FastAPI(title="mapADy Cyber-Backend", version="3.6.1")

models.Base.metadata.create_all(bind=engine)

app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

# Stockage temporaire des codes (en prod, utiliser Redis ou une table DB)
verification_codes = {}

def get_user_use_cases(db: Session = Depends(get_db)):
    return UserUseCases(UserRepository(db))

def get_quiz_use_cases(db: Session = Depends(get_db)):
    return QuizUseCases(QuizRepository(db))

# --- ROUTES PROFIL & SÉCURITÉ ---

@app.post("/api/users/{user_id}/send-verification-code")
def send_code(user_id: int, payload: dict = Body(...), db: Session = Depends(get_db)):
    email = payload.get("email")
    if not email:
        raise HTTPException(status_code=400, detail="Email requis")

    # Générer un code à 6 chiffres
    code = ''.join(random.choices(string.digits, k=6))
    verification_codes[user_id] = {"code": code, "email": email, "at": datetime.now()}

    success = EmailService.send_verification_code(email, code)
    if success:
        return {"status": "SENT", "message": "Code envoyé par transmission cryptée."}
    raise HTTPException(status_code=500, detail="Échec de l'envoi de l'email")

@app.post("/api/users/{user_id}/verify-code")
def verify_code(user_id: int, payload: dict = Body(...), db: Session = Depends(get_db)):
    code = payload.get("code")
    email = payload.get("email")

    saved = verification_codes.get(user_id)
    if not saved or saved["code"] != code or saved["email"] != email:
        raise HTTPException(status_code=400, detail="Code invalide ou expiré")

    # Vérifier expiration (5 minutes)
    if datetime.now() - saved["at"] > timedelta(minutes=5):
        del verification_codes[user_id]
        raise HTTPException(status_code=400, detail="Code expiré")

    # Mettre à jour l'email dans la DB
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if user:
        user.email = email
        db.commit()
        del verification_codes[user_id]
        return schemas.UserResponse.from_orm(user)

    raise HTTPException(status_code=404, detail="Utilisateur non trouvé")

# --- RESTE DU BACKEND (Check-in, Quiz, Boutique, etc. restauré) ---

@app.post("/api/bases/{base_id}/check-in")
def base_check_in(base_id: int, payload: dict = Body(...), db: Session = Depends(get_db)):
    user_id = payload.get("user_id")
    db.query(models.ActiveAgent).filter(models.ActiveAgent.last_seen < datetime.now() - timedelta(minutes=1)).delete()
    agent = db.query(models.ActiveAgent).filter(models.ActiveAgent.user_id == user_id).first()
    if agent:
        agent.base_id = base_id
        agent.last_seen = datetime.now()
    else:
        db.add(models.ActiveAgent(user_id=user_id, base_id=base_id))
    opponent = db.query(models.ActiveAgent).filter(models.ActiveAgent.base_id == base_id, models.ActiveAgent.user_id != user_id).first()
    db.commit()
    if opponent:
        opp_user = db.query(models.User).filter(models.User.id == opponent.user_id).first()
        return {"status": "OPPONENT_FOUND", "opponent": {"id": opp_user.id, "username": opp_user.username, "avatar": opp_user.avatar}}
    return {"status": "ZONE_EMPTY"}

@app.get("/api/users/{user_id}", response_model=schemas.UserResponse)
def get_profile(user_id: int, service: UserUseCases = Depends(get_user_use_cases)):
    return service.get_user_profile(user_id)

@app.post("/api/quiz/submit")
def submit_quiz_answer(payload: dict = Body(...), db: Session = Depends(get_db)):
    user_id = payload.get("user_id")
    is_correct = payload.get("is_correct", False)
    base_id = payload.get("base_id")
    is_last_question = payload.get("is_last", False)
    correct_count = payload.get("correct_count", 0)
    total_questions = payload.get("total_questions", 6)
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user: return {"error": "User not found"}
    stop_quiz = False
    status_msg = "OK"
    earned_gold = 0
    if base_id is not None and not is_correct:
        owner_id = 999
        if base_id != 0:
            base = db.query(models.GameBase).filter(models.GameBase.id == base_id).first()
            if base: owner_id = base.owner_id
        frost_active = db.query(models.ActiveDefense).filter(models.ActiveDefense.base_id == base_id, models.ActiveDefense.expires_at > datetime.now()).join(models.Gadget).filter(models.Gadget.name == "FrostTrap").first()
        if (frost_active or base_id == 0) and not is_correct:
            owner = db.query(models.User).filter(models.User.id == owner_id).first()
            penalty = 150
            user.gold = max(0, user.gold - penalty)
            if owner: owner.gold += penalty
            stop_quiz = True
            status_msg = f"SYSTÈME GELÉ ! AMENDE DE {penalty} CC PRÉLEVÉE."
    if is_last_question and not stop_quiz:
        earned_gold = correct_count * 10
        if correct_count == total_questions: earned_gold += 20
        user.gold += earned_gold
        user.quiz_victories += 1
        if base_id and base_id != 0 and correct_count == total_questions:
            base = db.query(models.GameBase).filter(models.GameBase.id == base_id).first()
            if base:
                base.owner_id = user.id
                user.territories_captured += 1
    db.commit()
    return {"gold": user.gold, "stop_quiz": stop_quiz, "status": status_msg, "earned": earned_gold}

@app.get("/api/bases", response_model=List[schemas.GameBaseResponse])
def get_all_bases(db: Session = Depends(get_db)):
    bases = db.query(models.GameBase).all()
    results = []
    for b in bases:
        base_dict = schemas.GameBaseResponse.from_orm(b)
        if b.owner_id:
            owner = db.query(models.User).filter(models.User.id == b.owner_id).first()
            if owner:
                base_dict.owner_name = owner.username
                base_dict.owner_avatar = owner.avatar
        results.append(base_dict)
    return results

@app.get("/api/quiz/next/{user_id}")
def get_next_quiz(user_id: int, base_id: Optional[int] = Query(None), service: QuizUseCases = Depends(get_quiz_use_cases)):
    return service.get_next_question(user_id, base_id)

@app.post("/api/auth/login", response_model=schemas.UserResponse)
def login(login_data: schemas.UserLogin, service: UserUseCases = Depends(get_user_use_cases)):
    return service.login_user(login_data)

@app.get("/api/shop/gadgets")
def get_shop_gadgets(db: Session = Depends(get_db)):
    return db.query(models.Gadget).all()

@app.get("/api/shop/avatars")
def get_shop_avatars(db: Session = Depends(get_db)):
    return db.query(models.AvatarItem).filter(models.AvatarItem.image_url != "avatar_default.jpeg").all()

@app.post("/api/shop/purchase")
def purchase_item(payload: dict = Body(...), db: Session = Depends(get_db)):
    repo = UserRepository(db)
    return repo.purchase_item(payload.get("user_id"), payload.get("item_id"), payload.get("category"))

@app.get("/api/leaderboard", response_model=List[schemas.UserResponse])
def get_leaderboard(service: UserUseCases = Depends(get_user_use_cases)):
    return service.get_leaderboard()

@app.get("/")
def health_check():
    return {"status": "ONLINE", "version": "3.6.1"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
