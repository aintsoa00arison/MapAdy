from pydantic import BaseModel, EmailStr
from typing import Optional
from models import RankTitleEnum, PalierTopographique

class UserBase(BaseModel):
    username: str
    email: EmailStr

class UserCreate(UserBase):
    pass

class UserLogin(BaseModel):
    email: EmailStr

class UserResponse(UserBase):
    id: int
    avatar: str
    gold: int
    quiz_victories: int
    territories_captured: int
    rank_title: RankTitleEnum
    rank_position: int
    joined_date: str

    class Config:
        from_attributes = True

class GameBaseResponse(BaseModel):
    id: int
    name: str
    latitude: float
    longitude: float
    palier: PalierTopographique
    description: Optional[str]
    conquest_radius_m: float
    points_value: int
    owner_id: Optional[int]

    class Config:
        from_attributes = True
