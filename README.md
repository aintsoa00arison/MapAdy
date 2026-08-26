#  MapAdy : Tactical Cyber-Conquest

MapAdy est un jeu de conquête territoriale géolocalisé se déroulant dans un univers **Cyber-Noir**. Les joueurs s'affrontent pour le contrôle des secteurs stratégiques de **Fianarantsoa** à travers des missions de hacking (quiz techniques).

##  État du Projet
- **Backend** : Déployé sur [Render](https://mapady.onrender.com) avec une base de données **PostgreSQL**.
- **Frontend** : Application Flutter en cours de développement (Work In Progress).
- **Cartographie** : Basée sur MapLibre et MapTiler (Vecteur).

##  Installation & Démarrage
1. **Prérequis** : Flutter SDK et un téléphone Android/iOS avec GPS.
2. **Configuration** : Assurez-vous que le fichier `.env` à la racine contient :
   ```env
   BASE_URL=https://mapady.onrender.com/api
   GOOGLE_CLIENT_ID=id_ggogle
   
   ```
3. **Lancement** :
   ```bash
   flutter pub get
   flutter run
   ```

## Fonctionnalités Clés
- **Radar Tactique** : Détection réelle des bases à Fianarantsoa. Le bouton de hack ne s'active qu'à portée.
- **Missions de Hacking** : Quiz de 6 à 10 questions techniques (Algo, Réseau, Logique).
- **Arsenal de Gadgets** :
    - *Défense* : IronTwin (+4 Q), FrostTrap (Gel + Amende), SafeDrop (Bouclier).
    - *Attaque* : GlitchScreen (Brouillage), DrainCash (Vol de gains).
- **Influences d'Avatars** : Chaque avatar acheté en boutique offre des bonus passifs uniques.
- **Mode Duel** : Affrontez un autre agent en temps réel si vous êtes sur le même secteur.
- **Économie** : Gagnez des Cyber-Crédits (CC) pour améliorer votre équipement.

##  Structure du Code
Le code suit une architecture modulaire stricte (< 150 lignes par fichier) :
- `lib/services/` : Centralisation des appels API via `ApiClient`.
- `lib/screens/` : Écrans divisés en sous-widgets spécialisés.
- `lib/logic/` : Gestionnaires d'influences et calculs mathématiques.
- `backend/` : API FastAPI structurée par contrôleurs et dépôts.
