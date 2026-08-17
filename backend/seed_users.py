from database import SessionLocal
import models
from models import User, RankTitleEnum
import random

def seed_users():
    print("--- DÉPLOIEMENT DES AGENTS D'ÉLITE (SEED USERS) ---")
    db = SessionLocal()

    target_users = [
        {"email": "arisonchristina@gmail.com", "username": "CHRIS_CYBER", "gold": 1500, "wins": 15, "zones": 5, "avatar": "avatar_1.jpeg"},
        {"email": "tovosoamichele@gmail.com", "username": "MICH_RUNNER", "gold": 2500, "wins": 30, "zones": 12, "avatar": "avatar_5.jpeg"},
        {"email": "ratovoarizaka@gmail.com", "username": "RIZAKA_NET", "gold": 1200, "wins": 12, "zones": 4, "avatar": "avatar_3.jpeg"},
    ]

    try:
        # 1. Traitement des 3 emails cibles
        for u_data in target_users:
            user = db.query(User).filter(User.email == u_data["email"]).first()
            if not user:
                print(f"Création de l'agent : {u_data['username']}")
                user = User(
                    email=u_data["email"],
                    username=u_data["username"],
                    avatar=u_data["avatar"],
                    joined_date="Jan 2024"
                )
                db.add(user)

            # Mise à jour des stats (toujours plus de 1000 gold)
            user.gold = u_data["gold"]
            user.quiz_victories = u_data["wins"]
            user.territories_captured = u_data["zones"]
            db.flush()

        # 2. Mise à jour des autres agents déjà présents (s'il y en a)
        others = db.query(User).filter(~User.email.in_([u["email"] for u in target_users])).all()
        for other in others:
            print(f"Mise à jour des stats de l'agent existant : {other.username}")
            other.gold = random.randint(1100, 3000)
            other.quiz_victories = random.randint(5, 20)
            other.territories_captured = random.randint(1, 6)

        db.commit()

        # 3. Recalcul des rangs et titres pour tout le monde
        print("Recalcul de la hiérarchie mondiale...")
        all_users = db.query(User).all()
        # On trie par score : (Victoires * 10) + (Zones * 25)
        all_users.sort(key=lambda x: (x.quiz_victories * 10 + x.territories_captured * 25), reverse=True)

        for index, user in enumerate(all_users):
            user.rank_position = index + 1
            score = (user.quiz_victories * 10) + (user.territories_captured * 25)

            if score > 500:
                user.rank_title = RankTitleEnum.CYBER_GOD
            elif score > 300:
                user.rank_title = RankTitleEnum.COMMANDER
            elif score > 200:
                user.rank_title = RankTitleEnum.ELITE
            elif score > 100:
                user.rank_title = RankTitleEnum.HACKER
            elif score > 50:
                user.rank_title = RankTitleEnum.RUNNER
            else:
                user.rank_title = RankTitleEnum.ROOKIE

        db.commit()
        print(f"TERMINÉ : {len(all_users)} agents sont maintenant actifs dans le classement.")

    except Exception as e:
        db.rollback()
        print(f"Erreur lors du seeding users : {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_users()
