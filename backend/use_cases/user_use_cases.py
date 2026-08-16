from repositories.user_repository import UserRepository
import schemas, models

class UserUseCases:
    def __init__(self, user_repo: UserRepository):
        self.user_repo = user_repo

    def register_user(self, user_data: schemas.UserCreate):
        return self.user_repo.create_user(user_data)

    def get_user_profile(self, user_id: int):
        user = self.user_repo.get_user(user_id)
        if not user:
            # Fallback debug: retourner le premier utilisateur si l'ID 1 n'existe pas
            return self.user_repo.db.query(models.User).first()
        return user

    def login_user(self, login_data: schemas.UserLogin):
        user = self.user_repo.get_user_by_email(login_data.email)
        if not user:
            # AUTO-REGISTER : Si l'utilisateur n'existe pas, on le crée
            # (Très utile pour le développement après un reset de DB)
            new_user = schemas.UserCreate(
                email=login_data.email,
                username=login_data.email.split('@')[0].upper()
            )
            return self.user_repo.create_user(new_user)
        return user

    def get_leaderboard(self):
        return self.user_repo.get_leaderboard()
