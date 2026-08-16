import enum
from sqlalchemy import Column, Integer, String, ForeignKey, Boolean, Enum as SQLEnum, JSON, DateTime, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base
from datetime import datetime, timedelta

class RankTitleEnum(str, enum.Enum):
    ROOKIE = "ROOKIE"
    RUNNER = "RUNNER"
    HACKER = "HACKER"
    ELITE = "ELITE"
    COMMANDER = "COMMANDER"
    CYBER_GOD = "CYBER_GOD"

class PalierTopographique(str, enum.Enum):
    HAUTE = "HAUTE"
    MOYENNE = "MOYENNE"
    BASSE = "BASSE"

class GadgetTypeEnum(str, enum.Enum):
    DEFENSE = "DEFENSE"
    ATTAQUE = "ATTAQUE"

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, nullable=False)
    email = Column(String, unique=True, nullable=False)
    avatar = Column(String, nullable=False, default="avatar_default.jpeg")
    gold = Column(Integer, default=100)

    quiz_victories = Column(Integer, default=0)
    territories_captured = Column(Integer, default=0)

    rank_title = Column(SQLEnum(RankTitleEnum), default=RankTitleEnum.ROOKIE)
    rank_position = Column(Integer, default=0)
    joined_date = Column(String, default="Oct 2024")

    gadgets = relationship("UserGadget", back_populates="user")
    avatars = relationship("UserAvatar", back_populates="user")
    quiz_history = relationship("QuizHistory", back_populates="user")

class Gadget(Base):
    __tablename__ = "gadgets"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String)
    price = Column(Integer, nullable=False)
    image_url = Column(String)
    type = Column(SQLEnum(GadgetTypeEnum), default=GadgetTypeEnum.DEFENSE)

class AvatarItem(Base):
    __tablename__ = "avatar_items"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String)
    image_url = Column(String, nullable=False)
    price = Column(Integer, nullable=False)

class UserGadget(Base):
    __tablename__ = "user_gadgets"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    gadget_id = Column(Integer, ForeignKey("gadgets.id"))
    quantity = Column(Integer, default=1)

    user = relationship("User", back_populates="gadgets")
    gadget = relationship("Gadget")

class UserAvatar(Base):
    __tablename__ = "user_avatars"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    avatar_item_id = Column(Integer, ForeignKey("avatar_items.id"))
    is_equipped = Column(Boolean, default=False)

    user = relationship("User", back_populates="avatars")
    avatar_item = relationship("AvatarItem")

class QuizQuestion(Base):
    __tablename__ = "quiz_questions"

    id = Column(Integer, primary_key=True, index=True)
    theme = Column(String, nullable=False)
    text = Column(String, nullable=False)
    answers = Column(JSON, nullable=False)
    hints = Column(JSON, nullable=True)
    difficulty = Column(String, default="medium")

class QuizHistory(Base):
    __tablename__ = "quiz_history"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    question_id = Column(Integer, ForeignKey("quiz_questions.id"), nullable=True)
    generated_text = Column(String, nullable=True)
    is_correct = Column(Boolean, nullable=False)
    answered_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="quiz_history")

class GameBase(Base):
    __tablename__ = "game_bases"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    palier = Column(SQLEnum(PalierTopographique), nullable=False)
    description = Column(String)
    conquest_radius_m = Column(Float, default=15.0)
    points_value = Column(Integer, default=150)

    owner_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    owner = relationship("User")

    # Lien vers les défenses actives
    active_defenses = relationship("ActiveDefense", back_populates="base")

class ActiveDefense(Base):
    __tablename__ = "active_defenses"

    id = Column(Integer, primary_key=True, index=True)
    base_id = Column(Integer, ForeignKey("game_bases.id"))
    gadget_id = Column(Integer, ForeignKey("gadgets.id"))

    activated_at = Column(DateTime, default=func.now())
    # Par défaut, une défense dure 24 heures
    expires_at = Column(DateTime, default=lambda: datetime.now() + timedelta(hours=24))

    base = relationship("GameBase", back_populates="active_defenses")
    gadget = relationship("Gadget")

class ActiveAgent(Base):
    __tablename__ = "active_agents"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    base_id = Column(Integer, ForeignKey("game_bases.id"))
    last_seen = Column(DateTime, default=func.now(), onupdate=func.now())
