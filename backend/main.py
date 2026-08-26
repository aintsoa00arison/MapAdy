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

app = FastAPI(title="mapADy Cyber-Backend", version="3.6.11")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

models.Base.metadata.create_all(bind=engine)

# --- DEPENDENCIES ---

def get_user_use_cases(db: Session = Depends(get_db)):
    return UserUseCases(UserRepository(db))

def get_quiz_use_cases(db: Session = Depends(get_db)):
    return QuizUseCases(QuizRepository(db))

api_router = APIRouter()

# --- AUTH & USERS ---

@api_router.post("/auth/login", response_model=schemas.UserResponse)
def login(login_data: schemas.UserLogin, service: UserUseCases = Depends(get_user_use_cases)):
    user = service.login_user(login_data)
    if not user:
        raise HTTPException(status_code=401, detail="Agent non trouvé")
    return user

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
    return [{"id": g.id, "name": g.name, "description": g.description, "image_url": g.image_url, "type": g.type, "quantity": owned_map.get(g.id, 0)} for g in all_gadgets]

@api_router.get("/users/{user_id}/owned-avatars")
def get_owned_avatars(user_id: int, db: Session = Depends(get_db)):
    repo = UserRepository(db)
    return repo.get_owned_avatars(user_id)

@api_router.post("/users/{user_id}/update-avatar", response_model=schemas.UserResponse)
def update_avatar(user_id: int, payload: dict = Body(...), db: Session = Depends(get_db)):
    repo = UserRepository(db)
    user = repo.update_avatar(user_id, payload.get("avatar"))
    if not user: raise HTTPException(status_code=404)
    return user

# --- QUIZ & TACTICAL ---

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
    total_questions = payload.get("total_questions", 6)
    debug_gadget = payload.get("debug_gadget")

    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user: raise HTTPException(status_code=404)

    stop_quiz = False
    status_msg = "OK"
    earned_gold = 0

    if not is_correct:
        trigger_freeze = False
        if base_id == 0 and debug_gadget == "FROSTTRAP":
            trigger_freeze = True
        elif base_id and base_id != 0:
            frost_active = db.query(models.ActiveDefense).filter(
                models.ActiveDefense.base_id == base_id,
                models.ActiveDefense.expires_at > datetime.now()
            ).join(models.Gadget).filter(models.Gadget.name == "FrostTrap").first()
            if frost_active: trigger_freeze = True

        if trigger_freeze:
            penalty = 150
            user.gold = max(0, user.gold - penalty)
            stop_quiz = True
            status_msg = f"SYSTÈME GELÉ ! -{penalty} CC."

    if is_last and not stop_quiz:
        earned_gold = correct_count * 10
        gold_multiplier = 1.2 if user.avatar == "avatar_5.jpeg" else 1.0
        earned_gold = int(earned_gold * gold_multiplier)
        if correct_count == total_questions: earned_gold += 20

        trigger_drain = False
        if base_id == 0 and debug_gadget == "DRAINCASH":
            trigger_drain = True
        elif base_id and base_id != 0:
            drain_active = db.query(models.ActiveDefense).filter(
                models.ActiveDefense.base_id == base_id,
                models.ActiveDefense.expires_at > datetime.now()
            ).join(models.Gadget).filter(models.Gadget.name == "DrainCash").first()
            if drain_active: trigger_drain = True

        if trigger_drain and correct_count < total_questions:
            earned_gold = 0
            status_msg = "DRAINCASH : GAINS NEUTRALISÉS"

        user.gold += earned_gold
        user.quiz_victories += 1
        if base_id and base_id != 0 and correct_count == total_questions:
            base = db.query(models.GameBase).filter(models.GameBase.id == base_id).first()
            if base:
                base.owner_id = user.id
                user.territories_captured += 1
                status_msg = "SECTEUR CAPTURÉ"

    db.commit()
    return {"gold": user.gold, "stop_quiz": stop_quiz, "status": status_msg, "earned": earned_gold}

# --- WORLD & SHOP ---

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

@api_router.post("/bases/{base_id}/activate-defense")
def activate_defense(base_id: int, payload: dict = Body(...), db: Session = Depends(get_db)):
    user_id = payload.get("user_id")
    gadget_id = payload.get("gadget_id")

    # 1. Vérification du gadget
    user_gadget = db.query(models.UserGadget).filter(
        models.UserGadget.user_id == user_id,
        models.UserGadget.gadget_id == gadget_id
    ).first()

    if not user_gadget or user_gadget.quantity <= 0:
        raise HTTPException(status_code=400, detail="Gadget non possédé")

    # 2. Vérification de la propriété de la base
    base = db.query(models.GameBase).filter(models.GameBase.id == base_id).first()
    if not base or base.owner_id != user_id:
        raise HTTPException(status_code=403, detail="Vous ne contrôlez pas ce secteur")

    # 3. Consommation et Activation
    user_gadget.quantity -= 1
    db.add(models.ActiveDefense(base_id=base_id, gadget_id=gadget_id))
    db.commit()
    return {"status": "SUCCESS", "message": "Défense activée"}

@api_router.get("/shop/gadgets")
def get_shop_gadgets(db: Session = Depends(get_db)):
    return db.query(models.Gadget).all()

@api_router.get("/shop/avatars")
def get_shop_avatars(db: Session = Depends(get_db)):
    return db.query(models.AvatarItem).filter(models.AvatarItem.image_url != "avatar_default.jpeg").all()

@api_router.post("/shop/purchase", response_model=schemas.UserResponse)
def purchase_item(payload: dict = Body(...), db: Session = Depends(get_db)):
    repo = UserRepository(db)
    user_id = payload.get("user_id")
    item_id = payload.get("item_id")
    category = payload.get("category")
    if category == "AVATARS":
        already = db.query(models.UserAvatar).filter(models.UserAvatar.user_id == user_id, models.UserAvatar.avatar_item_id == item_id).first()
        if already: raise HTTPException(status_code=400, detail="Vous possédez déjà cet avatar.")
    return repo.purchase_item(user_id, item_id, category)

@api_router.get("/leaderboard", response_model=List[schemas.UserResponse])
def get_leaderboard(service: UserUseCases = Depends(get_user_use_cases)):
    return service.get_leaderboard()

app.include_router(api_router, prefix="/api")

@app.get("/")
def health():
    return {"status": "ONLINE", "version": "3.6.11"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
