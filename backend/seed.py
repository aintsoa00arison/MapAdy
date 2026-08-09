from database import SessionLocal, engine, Base
import models
from models import AvatarItem, Gadget, QuizQuestion

def seed_database():
    print("--- RÉINITIALISATION DE LA BASE DE DONNÉES ---")
    # Force la suppression et la recréation des tables pour appliquer le nouveau schéma (colonnes hints, etc.)
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()

    try:
        print("Début du peuplement de la base de données...")

        # 1. Insertion de l'avatar par défaut
        db.add(AvatarItem(
            name="Agent Standard",
            description="L'avatar de base du réseau MapAdy. Aucune influence spéciale.",
            image_url="avatar_default.jpeg",
            price=0
        ))

        # 2. Insertion des 10 Avatars avec influences
        avatars = [
            AvatarItem(name="Neon Scavenger", description="Influence : +2s durée GlitchScreen.", image_url="avatar_1.jpeg", price=500),
            AvatarItem(name="Glitch Vision", description="Influence : Révèle niveau défense IntelScan.", image_url="avatar_2.jpeg", price=750),
            AvatarItem(name="Midnight Slice", description="Influence : 50% remboursement SafeDrop.", image_url="avatar_3.jpeg", price=400),
            AvatarItem(name="Rain Stalker", description="Influence : 100% esquive GhostKey.", image_url="avatar_4.jpeg", price=900),
            AvatarItem(name="Convenience Hacker", description="Influence : +20% gold DrainCash.", image_url="avatar_5.jpeg", price=600),
            AvatarItem(name="Insomnia Netrunner", description="Influence : -50% cooldown Overheat.", image_url="avatar_6.jpeg", price=850),
            AvatarItem(name="Chain-Skull", description="Influence : 3ème barrière IronTwin.", image_url="avatar_7.jpeg", price=1500),
            AvatarItem(name="Matrix Puppet", description="Influence : +2s immobilisation IceLock.", image_url="avatar_8.jpeg", price=1100),
            AvatarItem(name="Sicko Flex", description="Influence : -15% prix gadgets attaque.", image_url="avatar_9.jpeg", price=2000),
            AvatarItem(name="Shadow Anonymous", description="Influence : Pièges invisibles (Stealth).", image_url="avatar_10.jpeg", price=1250),
        ]
        db.add_all(avatars)

        # 3. Insertion des Gadgets
        gadgets = [
            Gadget(name="GlitchScreen", description="Brouille le texte pendant 3s.", price=300, image_url="GlitchScreen.jpeg"),
            Gadget(name="IronTwin", description="Double barrière de protection.", price=450, image_url="IronTwin.jpeg"),
            Gadget(name="DrainCash", description="Vole les points en cas d'erreur.", price=400, image_url="DrainCash.jpeg"),
            Gadget(name="FrostTrap", description="Gèle l'adversaire.", price=350, image_url="FrostTrap.jpeg"),
            Gadget(name="GhostKey", description="Traverse les barrières.", price=500, image_url="GhostKey.jpeg"),
            Gadget(name="SafeDrop", description="Bouclier anti-échec.", price=600, image_url="SafeDrop.jpeg"),
            Gadget(name="Overheat", description="Accélère le chrono ennemi.", price=550, image_url="Overheat.jpeg"),
            Gadget(name="Cyberspy", description="Scanne le type de question.", price=250, image_url="Cyberspy.jpeg"),
            Gadget(name="Floral", description="Bonus mystère urbain.", price=200, image_url="floral.jpeg"),
        ]
        db.add_all(gadgets)

        # 4. Insertion des Questions de Quiz Techniques
        questions = [
            QuizQuestion(
                theme="Réseau & Système",
                text="Une machine a l'IP 192.168.10.45/27. Quelle est l'adresse de diffusion (broadcast) de ce sous-réseau ?",
                answers=[
                    {"text": "192.168.10.31", "is_correct": False},
                    {"text": "192.168.10.63", "is_correct": True},
                    {"text": "192.168.10.47", "is_correct": False},
                    {"text": "192.168.10.255", "is_correct": False}
                ],
                hints=["Le masque /27 divise les réseaux par blocs de 32.", "L'adresse de broadcast est toujours l'adresse juste avant le prochain sous-réseau."],
                difficulty="difficile"
            ),
            QuizQuestion(
                theme="Algorithme & Complexité",
                text="Quelle est la complexité temporelle dans le pire des cas d'une recherche binaire sur un tableau trié de taille n ?",
                answers=[
                    {"text": "O(n)", "is_correct": False},
                    {"text": "O(log n)", "is_correct": True},
                    {"text": "O(n log n)", "is_correct": False},
                    {"text": "O(1)", "is_correct": False}
                ],
                hints=["Chaque étape divise l'espace de recherche par deux.", "Pense à la profondeur d'un arbre binaire équilibré."],
                difficulty="moyen"
            ),
            QuizQuestion(
                theme="Code & Programmation",
                text="En Dart (Flutter), quel mot-clé est utilisé pour déclarer une variable qui ne peut être définie qu'une seule fois et dont la valeur est connue à la compilation ?",
                answers=[
                    {"text": "final", "is_correct": False},
                    {"text": "const", "is_correct": True},
                    {"text": "static", "is_correct": False},
                    {"text": "immutable", "is_correct": False}
                ],
                hints=["Ce mot-clé rend la variable profondément immuable.", "con... est plus restrictif que fin... car il est vérifié au build."],
                difficulty="facile"
            )
        ]
        db.add_all(questions)

        db.commit()
        print("Base de données réinitialisée et peuplée avec succès !")

    except Exception as e:
        db.rollback()
        print(f"Erreur lors du seeding : {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
