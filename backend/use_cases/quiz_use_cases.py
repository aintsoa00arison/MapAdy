import random
from datetime import datetime
from repositories.quiz_repository import QuizRepository
from logic.quiz_generator import QuizGenerator
import models

class QuizUseCases:
    def __init__(self, quiz_repo: QuizRepository):
        self.quiz_repo = quiz_repo

    def get_next_question(self, user_id: int, base_id: int = None):
        active_effects = []
        total_needed = 6 # Valeur par défaut

        if base_id and base_id != 0:
            now = datetime.now()
            defenses = self.quiz_repo.db.query(models.ActiveDefense).filter(
                models.ActiveDefense.base_id == base_id,
                models.ActiveDefense.expires_at > now
            ).all()

            for d in defenses:
                name = d.gadget.name.upper()
                active_effects.append(name)
                # Effet IRON_TWIN : Ajoute 4 questions (Total 10)
                if name == "IRON_TWIN":
                    total_needed = 10

        question = self.quiz_repo.get_random_question_not_in_history(user_id)

        if question:
            response = {
                "id": question.id,
                "theme": question.theme,
                "text": question.text,
                "answers": question.answers,
                "hints": question.hints or ["Indice indisponible.", "Indice indisponible."],
                "difficulty": question.difficulty,
                "is_dynamic": False,
                "active_effects": active_effects,
                "total_needed": total_needed
            }
        else:
            generators = [
                QuizGenerator.generate_network_question,
                QuizGenerator.generate_logic_question
            ]
            response = random.choice(generators)()
            response["active_effects"] = active_effects
            response["total_needed"] = total_needed

        return response

    def submit_answer(self, user_id: int, question_id: int, is_correct: bool, generated_text: str = None):
        return self.quiz_repo.add_to_history(
            user_id=user_id,
            question_id=question_id if question_id != -1 else None,
            generated_text=generated_text,
            is_correct=is_correct
        )
