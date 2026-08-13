import uvicorn
from fastapi import FastAPI, Depends, status, Body
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from database import engine, get_db
import models, schemas
from repositories.user_repository import UserRepository
from repositories.quiz_repository import QuizRepository
from use_cases.user_use_cases import UserUseCases
from use_cases.quiz_use_cases import QuizUseCases
from logic.influence_mapper import get_gadget_modifiers
from typing import List

app = FastAPI(title="mapADy Cyber-Backend", version="3.1.0")

# Création automatique des tables au démarrage
models.Base.metadata.create_all(bind=engine)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Injection de Dépendances ---

def get_user_use_cases(db: Session = Depends(get_db)):
    repository = UserRepository(db)
    return UserUseCases(repository)

def get_quiz_use_cases(db: Session = Depends(get_db)):
    repository = QuizRepository(db)
    return QuizUseCases(repository)

# --- ROUTES UTILISATEURS ---

@app.post("/api/users/register", response_model=schemas.UserResponse, status_code=status.HTTP_201_CREATED)
def register(user_data: schemas.UserCreate, service: UserUseCases = Depends(get_user_use_cases)):
    return service.register_user(user_data)

@app.get("/api/users/{user_id}", response_model=schemas.UserResponse)
def get_profile(user_id: int, service: UserUseCases = Depends(get_user_use_cases)):
    return service.get_user_profile(user_id)

@app.get("/api/users/{user_id}/owned-avatars")
def get_owned_avatars(user_id: int, db: Session = Depends(get_db)):
    repo = UserRepository(db)
    return repo.get_owned_avatars(user_id)

@app.get("/api/users/{user_id}/modifiers")
def get_user_modifiers(user_id: int, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    return get_gadget_modifiers(user.avatar)

# --- ROUTES QUIZ ---

@app.get("/api/quiz/next/{user_id}")
def get_next_quiz(user_id: int, service: QuizUseCases = Depends(get_quiz_use_cases)):
    return service.get_next_question(user_id)

@app.post("/api/quiz/submit")
def submit_quiz_answer(payload: dict = Body(...), service: QuizUseCases = Depends(get_quiz_use_cases)):
    return service.submit_answer(
        user_id=payload.get("user_id"),
        question_id=payload.get("question_id", -1),
        is_correct=payload.get("is_correct", False),
        generated_text=payload.get("generated_text")
    )

# --- ROUTES BOUTIQUE ---

@app.get("/api/shop/gadgets")
def get_shop_gadgets(db: Session = Depends(get_db)):
    return db.query(models.Gadget).all()

@app.get("/api/shop/avatars")
def get_shop_avatars(db: Session = Depends(get_db)):
    return db.query(models.AvatarItem).filter(models.AvatarItem.image_url != "avatar_default.jpeg").all()

@app.post("/api/shop/purchase")
def purchase_item(payload: dict = Body(...), db: Session = Depends(get_db)):
    user_id = payload.get("user_id")
    item_id = payload.get("item_id")
    category = payload.get("category")
    repo = UserRepository(db)
    return repo.purchase_item(user_id, item_id, category)

# --- ROUTES TERRITOIRES (BASES) ---

@app.get("/api/bases", response_model=List[schemas.GameBaseResponse])
def get_all_bases(db: Session = Depends(get_db)):
    return db.query(models.GameBase).all()

# --- AUTRES ROUTES ---

@app.get("/api/leaderboard", response_model=List[schemas.UserResponse])
def get_leaderboard(service: UserUseCases = Depends(get_user_use_cases)):
    return service.get_leaderboard()

@app.post("/api/users/{user_id}/send-verification-code")
def send_code(user_id: int, payload: dict = Body(...), service: UserUseCases = Depends(get_user_use_cases)):
    return service.send_verification_code(payload.get("email"))

@app.post("/api/users/{user_id}/verify-code", response_model=schemas.UserResponse)
def verify_code(user_id: int, payload: dict = Body(...), service: UserUseCases = Depends(get_user_use_cases)):
    return service.verify_code_and_update_email(user_id, payload.get("email"), payload.get("code"))

@app.post("/api/users/{user_id}/update-avatar", response_model=schemas.UserResponse)
def update_avatar(user_id: int, payload: dict = Body(...), db: Session = Depends(get_db)):
    repo = UserRepository(db)
    return repo.update_avatar(user_id, payload.get("avatar"))

@app.post("/api/auth/login", response_model=schemas.UserResponse)
def login(login_data: schemas.UserLogin, service: UserUseCases = Depends(get_user_use_cases)):
    return service.login_user(login_data)

@app.post("/api/auth/logout")
def logout(service: UserUseCases = Depends(get_user_use_cases)):
    return service.logout_user()

@app.get("/")
def health_check():
    return {"status": "ONLINE", "system": "mapADy_OS", "version": "3.1.0"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
