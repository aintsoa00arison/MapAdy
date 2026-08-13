import enum
from sqlalchemy.orm import Session
from database import SessionLocal, engine, Base
from models import GameBase, PalierTopographique

def seed_fianarantsoa_bases(db: Session):
    # Liste complète des bases géolocalisées à Fianarantsoa
    bases_data = [
        # --- VILLE HAUTE (Antanambony / Historique) ---
        {
            "name": "Cathédrale Ambozontany",
            "latitude": -21.4580638,
            "longitude": 47.0760217,
            "palier": PalierTopographique.HAUTE,
            "description": "Edifice historique dominant la ville haute."
        },
        {
            "name": "Rova Tanana Ambony",
            "latitude": -21.4597375,
            "longitude": 47.0768906,
            "palier": PalierTopographique.HAUTE,
            "description": "L'ancien palais royal et ses points stratégiques."
        },
        {
            "name": "Point de vue",
            "latitude": -21.4455408,
            "longitude": 47.0782979,
            "palier": PalierTopographique.HAUTE,
            "description": "Panorama global sur les collines environnantes."
        },
        {
            "name": "La Rizière",
            "latitude": -21.4581028,
            "longitude": 47.0785398,
            "palier": PalierTopographique.HAUTE,
            "description": "Zone agricole en terrasse intégrée au tissu urbain."
        },

        # --- VILLE MOYENNE / ADMINISTRATIVE ---
        {
            "name": "Parc Anosy",
            "latitude": -21.4520000,
            "longitude": 47.0850000,
            "palier": PalierTopographique.MOYENNE,
            "description": "Zone verte de détente et de transit au cœur de la ville."
        },
        {
            "name": "La Gare",
            "latitude": -21.4530000,
            "longitude": 47.0870000,
            "palier": PalierTopographique.MOYENNE,
            "description": "Gare historique du FCE, nœud de communication clé."
        },
        {
            "name": "Hôtel Pietra",
            "latitude": -21.4525000,
            "longitude": 47.0865000,
            "palier": PalierTopographique.MOYENNE,
            "description": "Repère urbain et centre névralgique de la ville moyenne."
        },
        {
            "name": "Stade Ampasambazaha",
            "latitude": -21.4491096,
            "longitude": 47.0880535,
            "palier": PalierTopographique.MOYENNE,
            "description": "Arène sportive historique du quartier."
        },
        {
            "name": "Saint François Xavier",
            "latitude": -21.4510000,
            "longitude": 47.0890000,
            "palier": PalierTopographique.MOYENNE,
            "description": "Établissement et repère institutionnel."
        },
        {
            "name": "Hôpital Tambohobe",
            "latitude": -21.4470000,
            "longitude": 47.0920000,
            "palier": PalierTopographique.MOYENNE,
            "description": "Centre de soin majeur de la zone."
        },
        {
            "name": "Hôpital Universitaire",
            "latitude": -21.4500000,
            "longitude": 47.0905000,
            "palier": PalierTopographique.MOYENNE,
            "description": "Pôle médical stratégique et technologique."
        },

        # --- VILLE BASSE & COMMERCIALE ---
        {
            "name": "Marché Anjoma",
            "latitude": -21.4546147,
            "longitude": 47.0875045,
            "palier": PalierTopographique.BASSE,
            "description": "Le grand marché bouillonnant, plaque tournante du commerce."
        },
        {
            "name": "ENI",
            "latitude": -21.4551875,
            "longitude": 47.0934375,
            "palier": PalierTopographique.BASSE,
            "description": "Ecole Nationale d'Informatique, le temple des hackers locaux."
        },
        {
            "name": "Coliseum",
            "latitude": -21.4535000,
            "longitude": 47.0895000,
            "palier": PalierTopographique.BASSE,
            "description": "Lieu de rassemblement et d'événements."
        },
        {
            "name": "Petite Bouffe",
            "latitude": -21.4515000,
            "longitude": 47.0860000,
            "palier": PalierTopographique.BASSE,
            "description": "QG informel des netrunners et étudiants."
        },
        {
            "name": "Chez Nini",
            "latitude": -21.4508124,
            "longitude": 47.0858120,
            "palier": PalierTopographique.BASSE,
            "description": "Point de deal de data et de ravitaillement."
        },
        {
            "name": "RDI",
            "latitude": -21.4540000,
            "longitude": 47.0910000,
            "palier": PalierTopographique.BASSE,
            "description": "Centre de diffusion et de relais réseau."
        },
        {
            "name": "SMIPI",
            "latitude": -21.4548000,
            "longitude": 47.0925000,
            "palier": PalierTopographique.BASSE,
            "description": "Nœud de infrastructure technique locale."
        },

        # --- PÉRIPHÉRIE / ANDRAINJATO ---
        {
            "name": "Université d'Andrainjato",
            "latitude": -21.4617858,
            "longitude": 47.1118573,
            "palier": PalierTopographique.BASSE,
            "description": "Le campus universitaire principal, zone de haute concentration de savoir."
        },
        {
            "name": "L'Aéroport",
            "latitude": -21.4350000,
            "longitude": 47.0700000,
            "palier": PalierTopographique.BASSE,
            "description": "Porte d'entrée aérienne et zone de transit externe."
        }
    ]

    print("Insertion des territoires de Fianarantsoa...")
    for data in bases_data:
        # Vérifie si la base existe déjà pour éviter les doublons lors des relances du script
        existing = db.query(GameBase).filter(GameBase.name == data["name"]).first()
        if not existing:
            new_base = GameBase(
                name=data["name"],
                latitude=data["latitude"],
                longitude=data["longitude"],
                palier=data["palier"],
                description=data["description"],
                conquest_radius_m=15.0,
                points_value=150
            )
            db.add(new_base)

    db.commit()
    print("Seed des territoires terminé avec succès !")

if __name__ == "__main__":
    db = SessionLocal()
    try:
        seed_fianarantsoa_bases(db)
    finally:
        db.close()
