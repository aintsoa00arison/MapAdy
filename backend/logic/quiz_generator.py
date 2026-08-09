import random

class QuizGenerator:
    @staticmethod
    def generate_network_question():
        """Génère une question dynamique sur les sous-réseaux IP."""
        base_ip = f"192.168.{random.randint(1, 254)}"
        cidrs = [24, 25, 26, 27, 28]
        cidr = random.choice(cidrs)

        hosts = (2 ** (32 - cidr)) - 2

        question_text = f"Dans un sous-réseau avec un masque /{cidr}, quel est le nombre maximum d'hôtes utilisables ?"

        correct_answer = hosts
        wrong_answers = [hosts + 2, hosts + 1, hosts - 10, hosts * 2]
        random.shuffle(wrong_answers)
        wrong_answers = wrong_answers[:3]

        answers = [{"text": str(correct_answer), "is_correct": True}]
        for wa in wrong_answers:
            answers.append({"text": str(wa), "is_correct": False})

        random.shuffle(answers)

        return {
            "theme": "Réseau & Système",
            "text": question_text,
            "answers": answers,
            "hints": [
                f"La formule est 2^(32 - masque) - 2.",
                f"Ici, 32 - {cidr} = {32 - cidr} bits pour les hôtes."
            ],
            "difficulty": "moyen",
            "is_dynamic": True
        }

    @staticmethod
    def generate_logic_question():
        """Génère une question de logique (suite binaire)."""
        start = random.randint(1, 10)
        step = random.choice([2, 4, 8])
        sequence = [start * (step ** i) for i in range(4)]

        question_text = f"Quelle est la valeur suivante dans cette suite logique : {', '.join(map(str, sequence))} ?"

        correct_answer = sequence[-1] * step
        wrong_answers = [correct_answer + step, correct_answer - step, correct_answer * 2, correct_answer + 10]

        answers = [{"text": str(correct_answer), "is_correct": True}]
        for wa in random.sample(wrong_answers, 3):
            answers.append({"text": str(wa), "is_correct": False})

        random.shuffle(answers)

        return {
            "theme": "Logique & Raisonnement",
            "text": question_text,
            "answers": answers,
            "hints": [
                f"Regarde le rapport entre {sequence[1]} et {sequence[0]}.",
                f"Il s'agit d'une progression géométrique de raison {step}."
            ],
            "difficulty": "difficile",
            "is_dynamic": True
        }
