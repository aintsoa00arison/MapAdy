from pydantic import BaseModel, EmailStr
from models import RankTitleEnum

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
