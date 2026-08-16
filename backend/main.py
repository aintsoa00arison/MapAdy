import uvicorn
import random
import string
from fastapi import FastAPI, Depends, status, Body, Query, HTTPException, APIRouter
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

app = FastAPI(title="mapADy Cyber-Backend", version="3.6.5")

# Configuration CORS pour autoriser le mobile
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

models.Base.metadata.create_all(bind=engine)

# Stockage temporaire des codes
verification_codes = {}

def get_user_use_cases(db: Session = Depends(get_db)):
    return UserUseCases(UserRepository(db))

def get_quiz_use_cases(db: Session = Depends(get_db)):
    return QuizUseCases(QuizRepository(db))

# --- ROUTER API ---
api_router = APIRouter(prefix="/api")

# --- AUTH & USERS ---

@api_router.post("/auth/login", response_model=schemas.UserResponse)
def login(login_data: schemas.UserLogin, service: UserUseCases = Depends(get_user_use_cases)):
    user = service.login_user(login_data)
    if not user:
        raise HTTPException(status_code=401, detail="Échec identification")
    return user

@api_router.post("/users/register", response_model=schemas.UserResponse, status_code=status.HTTP_201_CREATED)
def register(user_data: schemas.UserCreate, service: UserUseCases = Depends(get_user_use_cases)):
    return service.register_user(user_data)

@api_router.get("/users/{user_id}", response_model=schemas.UserResponse)
def get_profile(user_id: int, service: UserUseCases = Depends(get_user_use_cases)):
    user = service.get_user_profile(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="Agent non trouvé")
    return user

@api_router.get("/users/{user_id}/gadgets")
def get_user_gadgets(user_id: int, db: Session = Depends(get_db)):
    all_gadgets = db.query(models.Gadget).all()
    owned_gadgets = db.query(models.UserGadget).filter(models.UserGadget.user_id == user_id).all()
    owned_map = {og.gadget_id: og.quantity for og in owned_gadgets}
    return [{
        "id": g.id, "name": g.name, "description": g.description,
        "image_url": g.image_url, "type": g.type, "quantity": owned_map.get(g.id, 0)
    } for g in all_gadgets]

@api_router.post("/users/{user_id}/update-avatar", response_model=schemas.UserResponse)
def update_avatar(user_id: int, payload: dict = Body(...), db: Session = Depends(get_db)):
    repo = UserRepository(db)
    user = repo.update_avatar(user_id, payload.get("avatar"))
    if not user: raise HTTPException(status_code=404)
    return user

# --- QUIZ & BATTLE ---

@api_router.get("/quiz/next/{user_id}")
def get_next_quiz(user_id: int, base_id: Optional[int] = Query(None), service: QuizUseCases = Depends(get_quiz_use_cases)):
    return service.get_next_question(user_id, base_id)

@api_router.post("/quiz/submit")
def submit_quiz_answer(payload: dict = Body(...), db: Session = Depends(get_db)):
    user_id = payload.get("user_id")
    is_correct = payload.get("is_correct", False)
    base_id = payload.get("base_id")
    is_last = payload.get("is_last", False)
    correct_count = payload.get("correct_count", 0)

    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user: raise HTTPException(status_code=404)

    stop_quiz = False
    status_msg = "OK"
    earned_gold = 0

    if base_id is not None and not is_correct:
        frost_active = db.query(models.ActiveDefense).filter(
            models.ActiveDefense.base_id == base_id,
            models.ActiveDefense.expires_at > datetime.now()
        ).join(models.Gadget).filter(models.Gadget.name == "FrostTrap").first()

        if frost_active or base_id == 0: # Simulation FrostTrap
            penalty = 150
            user.gold = max(0, user.gold - penalty)
            stop_quiz = True
            status_msg = f"GELÉ ! -{penalty} CC"

    if is_last and not stop_quiz:
        earned_gold = correct_count * 10
        if correct_count == 6: earned_gold += 20
        user.gold += earned_gold
        user.quiz_victories += 1

        if base_id and base_id != 0 and correct_count == 6:
            base = db.query(models.GameBase).filter(models.GameBase.id == base_id).first()
            if base:
                base.owner_id = user.id
                user.territories_captured += 1
                status_msg = "SECTEUR CAPTURÉ"

    db.commit()
    return {"gold": user.gold, "stop_quiz": stop_quiz, "status": status_msg, "earned": earned_gold}

# --- BASES & BOUTIQUE ---

@api_router.get("/bases", response_model=List[schemas.GameBaseResponse])
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

@api_router.get("/shop/gadgets")
def get_shop_gadgets(db: Session = Depends(get_db)):
    return db.query(models.Gadget).all()

@api_router.get("/shop/avatars")
def get_shop_avatars(db: Session = Depends(get_db)):
    return db.query(models.AvatarItem).filter(models.AvatarItem.image_url != "avatar_default.jpeg").all()

@api_router.post("/shop/purchase")
def purchase_item(payload: dict = Body(...), db: Session = Depends(get_db)):
    repo = UserRepository(db)
    return repo.purchase_item(payload.get("user_id"), payload.get("item_id"), payload.get("category"))

@api_router.get("/leaderboard", response_model=List[schemas.UserResponse])
def get_leaderboard(service: UserUseCases = Depends(get_user_use_cases)):
    return service.get_leaderboard()

# Inclusion du router dans l'app
app.include_router(api_router)

@app.get("/")
def health():
    return {"status": "ONLINE", "msg": "mapADy OS is running"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
