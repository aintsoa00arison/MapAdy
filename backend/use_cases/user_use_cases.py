from fastapi import HTTPException, status
from repositories.user_repository import UserRepository
from schemas import UserCreate, UserLogin
import random

# Simuler un stockage de codes en mémoire (Email -> Code)
verification_codes = {}

class UserUseCases:
    def __init__(self, user_repo: UserRepository):
        self.user_repo = user_repo

    def register_user(self, user_data: UserCreate):
        if self.user_repo.get_by_email(user_data.email):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cet email est déjà enregistré sur le réseau."
            )
        return self.user_repo.create(user_data)

    def get_user_profile(self, user_id: int):
        user = self.user_repo.get_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Utilisateur introuvable."
            )
        return user

    def send_verification_code(self, email: str):
        code = str(random.randint(100000, 999999))
        verification_codes[email] = code
        print(f"--- [SYSTÈME] CODE POUR {email} : {code} ---")
        return {"status": "SUCCESS", "message": "Code envoyé."}

    def verify_code_and_update_email(self, user_id: int, email: str, code: str):
        if verification_codes.get(email) != code:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Code de vérification invalide."
            )
        del verification_codes[email]
        return self.user_repo.update_email(user_id, email)

    def get_leaderboard(self):
        # Recalculer les rangs avant de renvoyer le classement
        self.user_repo.update_user_ranks()
        return self.user_repo.get_leaderboard()

    def login_user(self, login_data: UserLogin):
        user = self.user_repo.get_by_email(login_data.email)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Accès refusé : Identifiants incorrects."
            )
        return user

    def logout_user(self):
        return {"status": "OFFLINE", "message": "Déconnexion du système réussie."}
