from sqlalchemy.orm import Session
from sqlalchemy import not_
from models import QuizQuestion, QuizHistory

class QuizRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_random_question_not_in_history(self, user_id: int):
        # Get IDs of questions already answered by this user
        answered_ids = self.db.query(QuizHistory.question_id).filter(
            QuizHistory.user_id == user_id,
            QuizHistory.question_id.isnot(None)
        ).all()
        answered_ids = [r[0] for r in answered_ids]

        # Get a random question not in the list
        from sqlalchemy.sql.expression import func
        return self.db.query(QuizQuestion).filter(
            not_(QuizQuestion.id.in_(answered_ids))
        ).order_by(func.random()).first()

    def add_to_history(self, user_id: int, question_id: int = None, generated_text: str = None, is_correct: bool = False):
        history = QuizHistory(
            user_id=user_id,
            question_id=question_id,
            generated_text=generated_text,
            is_correct=is_correct
        )
        self.db.add(history)
        self.db.commit()
        return history
