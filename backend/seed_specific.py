from database import SessionLocal
import models

def update_game_state():
    print("--- MISE À JOUR SPÉCIFIQUE DU RÉSEAU ---")
    db = SessionLocal()

    try:
        # 1. Attribuer le Campus Andrainjato à Pota
        pota = db.query(models.User).filter(models.User.username == "pota").first()
        campus = db.query(models.GameBase).filter(models.GameBase.name == "CAMPUS ANDRAINJATO").first()

        if pota and campus:
            print(f"Transfert du Campus à l'agent : {pota.username}")
            campus.owner_id = pota.id
            pota.territories_captured = max(pota.territories_captured, 1)
        else:
            print("Alerte : Pota ou Campus introuvable.")

        # 2. Mettre le rang de raRanja à 6
        ranja = db.query(models.User).filter(models.User.username == "raRanja").first()
        if ranja:
            print(f"Mise à jour du rang de raRanja : {ranja.username} -> Rang 6")
            ranja.rank_position = 6
        else:
            print("Alerte : raRanja introuvable.")

        db.commit()
        print("Opération terminée avec succès.")

    except Exception as e:
        db.rollback()
        print(f"Erreur : {e}")
    finally:
        db.close()

if __name__ == "__main__":
    update_game_state()
