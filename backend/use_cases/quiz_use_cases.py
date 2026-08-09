import random
from repositories.quiz_repository import QuizRepository
from logic.quiz_generator import QuizGenerator

class QuizUseCases:
    def __init__(self, quiz_repo: QuizRepository):
        self.quiz_repo = quiz_repo

    def get_next_question(self, user_id: int):
        # 1. Try to get a fixed question from DB
        question = self.quiz_repo.get_random_question_not_in_history(user_id)

        if question:
            return {
                "id": question.id,
                "theme": question.theme,
                "text": question.text,
                "answers": question.answers,
                "hints": question.hints or ["Indice indisponible.", "Indice indisponible."],
                "difficulty": question.difficulty,
                "is_dynamic": False
            }

        # 2. Dynamic generation
        generators = [
            QuizGenerator.generate_network_question,
            QuizGenerator.generate_logic_question
        ]
        return random.choice(generators)()

    def submit_answer(self, user_id: int, question_id: int, is_correct: bool, generated_text: str = None):
        return self.quiz_repo.add_to_history(
            user_id=user_id,
            question_id=question_id if question_id != -1 else None,
            generated_text=generated_text,
            is_correct=is_correct
        )
