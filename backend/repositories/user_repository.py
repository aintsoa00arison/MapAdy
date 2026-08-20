from sqlalchemy.orm import Session
from models import User, RankTitleEnum, Gadget, AvatarItem, UserGadget, UserAvatar
from schemas import UserCreate
from datetime import datetime
from fastapi import HTTPException

class UserRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_user(self, user_id: int):
        return self.db.query(User).filter(User.id == user_id).first()

    def get_user_by_email(self, email: str):
        return self.db.query(User).filter(User.email == email).first()

    def create_user(self, user_data: UserCreate):
        current_date = datetime.now().strftime("%b %Y")
        # Calculer le nombre actuel d'utilisateurs pour donner le rang le plus bas
        user_count = self.db.query(User).count()

        new_user = User(
            username=user_data.username,
            email=user_data.email,
            avatar="avatar_default.jpeg",
            gold=100,
            rank_title=RankTitleEnum.ROOKIE,
            rank_position=user_count + 1,
            joined_date=current_date
        )
        self.db.add(new_user)
        self.db.commit()
        self.db.refresh(new_user)
        return new_user

    def update_email(self, user_id: int, new_email: str):
        user = self.get_user(user_id)
        if user:
            user.email = new_email
            self.db.commit()
            self.db.refresh(user)
        return user

    def update_avatar(self, user_id: int, avatar_url: str):
        user = self.get_user(user_id)
        if not user:
            return None

        user.avatar = avatar_url
        avatar_item = self.db.query(AvatarItem).filter(AvatarItem.image_url == avatar_url).first()
        if avatar_item:
            self.db.query(UserAvatar).filter(UserAvatar.user_id == user_id).update({"is_equipped": False})
            user_avatar = self.db.query(UserAvatar).filter(
                UserAvatar.user_id == user_id,
                UserAvatar.avatar_item_id == avatar_item.id
            ).first()
            if user_avatar:
                user_avatar.is_equipped = True

        self.db.commit()
        self.db.refresh(user)
        return user

    def get_owned_avatars(self, user_id: int):
        owned = self.db.query(UserAvatar).filter(UserAvatar.user_id == user_id).all()
        return [ua.avatar_item.image_url for ua in owned]

    def purchase_item(self, user_id: int, item_id: int, category: str):
        user = self.get_user(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur non trouvé")

        if category == "GADGETS":
            item = self.db.query(Gadget).filter(Gadget.id == item_id).first()
            if not item:
                raise HTTPException(status_code=404, detail="Gadget non trouvé")

            if user.gold < item.price:
                raise HTTPException(status_code=400, detail="Crédits Cyber insuffisants")

            user.gold -= item.price
            user_gadget = self.db.query(UserGadget).filter(
                UserGadget.user_id == user_id,
                UserGadget.gadget_id == item_id
            ).first()

            if user_gadget:
                user_gadget.quantity += 1
            else:
                new_gadget = UserGadget(user_id=user_id, gadget_id=item_id, quantity=1)
                self.db.add(new_gadget)

        elif category == "AVATARS":
            item = self.db.query(AvatarItem).filter(AvatarItem.id == item_id).first()
            if not item:
                raise HTTPException(status_code=404, detail="Avatar non trouvé")

            already_owned = self.db.query(UserAvatar).filter(
                UserAvatar.user_id == user_id,
                UserAvatar.avatar_item_id == item_id
            ).first()

            if already_owned:
                raise HTTPException(status_code=400, detail="Avatar déjà possédé")

            if user.gold < item.price:
                raise HTTPException(status_code=400, detail="Crédits Cyber insuffisants")

            user.gold -= item.price
            new_avatar = UserAvatar(user_id=user_id, avatar_item_id=item_id, is_equipped=False)
            self.db.add(new_avatar)

        self.db.commit()
        self.db.refresh(user)
        return user

    def get_leaderboard(self, limit: int = 50):
        return (
            self.db.query(User)
            .order_by((User.quiz_victories * 10 + User.territories_captured * 25).desc())
            .limit(limit)
            .all()
        )

    def update_user_ranks(self):
        users = (
            self.db.query(User)
            .order_by((User.quiz_victories * 10 + User.territories_captured * 25).desc())
            .all()
        )

        for index, user in enumerate(users):
            user.rank_position = index + 1
            score = (user.quiz_victories * 10) + (user.territories_captured * 25)

            if score > 2000:
                user.rank_title = RankTitleEnum.CYBER_GOD
            elif score > 1000:
                user.rank_title = RankTitleEnum.COMMANDER
            elif score > 600:
                user.rank_title = RankTitleEnum.ELITE
            elif score > 300:
                user.rank_title = RankTitleEnum.HACKER
            elif score > 100:
                user.rank_title = RankTitleEnum.RUNNER
            else:
                user.rank_title = RankTitleEnum.ROOKIE

        self.db.commit()
