from database import SessionLocal, engine, Base
import models
from models import AvatarItem, Gadget, QuizQuestion, GameBase, PalierTopographique, GadgetTypeEnum
import random
import math

def seed_database():
    print("--- RÉINITIALISATION COMPLÈTE (V3.5 - 100 QUESTIONS TECHNIQUES + SECTEURS) ---")
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        # 1. Avatars
        db.add(AvatarItem(name="Agent Standard", description="Avatar de base.", image_url="avatar_default.jpeg", price=0))
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

        # 2. Gadgets avec Types
        gadgets = [
            Gadget(name="IronTwin", description="Double barrière de protection.", price=450, image_url="IronTwin.jpeg", type=GadgetTypeEnum.DEFENSE),
            Gadget(name="GhostKey", description="Permet de traverser les barrières.", price=500, image_url="GhostKey.jpeg", type=GadgetTypeEnum.DEFENSE),
            Gadget(name="SafeDrop", description="Bouclier anti-échec.", price=600, image_url="SafeDrop.jpeg", type=GadgetTypeEnum.DEFENSE),
            Gadget(name="Cyberspy", description="Scanne le type de question.", price=250, image_url="Cyberspy.jpeg", type=GadgetTypeEnum.DEFENSE),
            Gadget(name="floral", description="Gadget bonus mystère.", price=200, image_url="floral.jpeg", type=GadgetTypeEnum.DEFENSE),
            Gadget(name="GlitchScreen", description="Brouille le texte pendant 3s.", price=300, image_url="GlitchScreen.jpeg", type=GadgetTypeEnum.ATTAQUE),
            Gadget(name="DrainCash", description="Vole les points en cas d'erreur.", price=400, image_url="DrainCash.jpeg", type=GadgetTypeEnum.ATTAQUE),
            Gadget(name="FrostTrap", description="Gèle l'adversaire.", price=350, image_url="FrostTrap.jpeg", type=GadgetTypeEnum.ATTAQUE),
            Gadget(name="Overheat", description="Accélère le chrono ennemi.", price=550, image_url="Overheat.jpeg", type=GadgetTypeEnum.ATTAQUE),
        ]
        db.add_all(gadgets)

        # 3. Grands Secteurs
        sectors = [
            {"name": "SECTEUR ANJOMA", "lat": -21.4546, "lng": 47.0875, "rad": 150, "p": 300, "palier": PalierTopographique.BASSE, "desc": "Zone commerciale."},
            {"name": "CORE AMPASAMBAZAHA", "lat": -21.4491, "lng": 47.0880, "rad": 200, "p": 450, "palier": PalierTopographique.MOYENNE, "desc": "Centre administratif."},
            {"name": "CAMPUS ANDRAINJATO", "lat": -21.4617, "lng": 47.1118, "rad": 300, "p": 1000, "palier": PalierTopographique.BASSE, "desc": "Pôle technologique."},
            {"name": "CITADELLE AMBOZONTANY", "lat": -21.4580, "lng": 47.0760, "rad": 180, "p": 600, "palier": PalierTopographique.HAUTE, "desc": "Sommet historique."},
            {"name": "RELAIS ANOSY", "lat": -21.4520, "lng": 47.0850, "rad": 120, "p": 250, "palier": PalierTopographique.MOYENNE, "desc": "Nœud de communication."},
            {"name": "BASTION ROVA", "lat": -21.4597, "lng": 47.0768, "rad": 140, "p": 500, "palier": PalierTopographique.HAUTE, "desc": "Ancien palais."},
            {"name": "DATA CENTER ENI", "lat": -21.4551, "lng": 47.0934, "rad": 250, "p": 800, "palier": PalierTopographique.BASSE, "desc": "Temple du code."},
        ]
        for s in sectors:
            db.add(GameBase(
                name=s["name"], latitude=s["lat"], longitude=s["lng"],
                palier=s["palier"], description=s["desc"],
                conquest_radius_m=float(s["rad"]), points_value=s["p"]
            ))

        # 4. Banque de 100 Questions (Restaurée)
        q_raw = [
            # ALGORITHME & COMPLEXITÉ (25)
            {"t": "Algo", "q": "Complexité temporelle du tri fusion (Merge Sort) ?", "a": "O(n log n)", "w": ["O(n²)", "O(n)", "O(log n)"], "h": ["Diviser pour régner.", "Stable."], "d": "moyen"},
            {"t": "Algo", "q": "Détecter des cycles dans un graphe dirigé ?", "a": "Parcours DFS", "w": ["Prim", "Kruskal", "BFS"], "h": ["Pile d'appels.", "Profondeur."], "d": "difficile"},
            {"t": "Algo", "q": "Recherche BST temps moyen ?", "a": "O(log n)", "w": ["O(n)", "O(1)", "O(n log n)"], "h": ["Dichotomique.", "Hauteur arbre."], "d": "facile"},
            {"t": "Algo", "q": "Signification classe NP ?", "a": "Non-deterministic Polynomial time", "w": ["Non-Polynomial", "Nearly Polynomial", "Numerical"], "h": ["Vérifiable rapidement.", "Machine non-déterministe."], "d": "difficile"},
            {"t": "Algo", "q": "Accès élément index tableau ?", "a": "O(1)", "w": ["O(n)", "O(log n)", "O(1/n)"], "h": ["Immédiat.", "Constant."], "d": "facile"},
            {"t": "Algo", "q": "Lequel n'est PAS un tri par comparaison ?", "a": "Counting Sort", "w": ["Quicksort", "Heapsort", "Bubblesort"], "h": ["Linéaire possible.", "Utilise les valeurs."], "d": "difficile"},
            {"t": "Algo", "q": "Structure file de priorité ?", "a": "Heap", "w": ["Stack", "Linked List", "Simple Tree"], "h": ["Arbre presque complet.", "Maintient max/min."], "d": "moyen"},
            {"t": "Algo", "q": "Calcul Floyd-Warshall ?", "a": "Tous plus courts chemins", "w": ["Arbre couvrant min", "Flux max", "Source unique"], "h": ["Poids négatifs OK.", "Matrice distances."], "d": "difficile"},
            {"t": "Algo", "q": "Recherche linéaire pire cas ?", "a": "O(n)", "w": ["O(1)", "O(log n)", "O(n²)"], "h": ["Vérifie chaque item.", "Proportionnel."], "d": "facile"},
            {"t": "Algo", "q": "n en Big O représente ?", "a": "Taille données entrée", "w": ["Nb processeurs", "Temps ms", "Vitesse réseau"], "h": ["Croissance.", "Volume input."], "d": "facile"},
            {"t": "Algo", "q": "Algorithme Kruskal sert à ?", "a": "Arbre couvrant minimal", "w": ["Plus court chemin", "Tri rapide", "Hachage"], "h": ["Forêt sommets.", "Évite cycles."], "d": "moyen"},
            {"t": "Algo", "q": "Complexité matrice adjacence V sommets ?", "a": "O(V²)", "w": ["O(V)", "O(E+V)", "O(log V)"], "h": ["Grille stockage.", "V x V."], "d": "moyen"},
            {"t": "Algo", "q": "Complexité Bubble Sort ?", "a": "O(n²)", "w": ["O(n log n)", "O(n)", "O(1)"], "h": ["Boucles imbriquées.", "Inefficace."], "d": "facile"},
            {"t": "Algo", "q": "Principe Diviser pour régner ?", "a": "Sous-problèmes indépendants", "w": ["Nb serveurs", "Casser en fonctions", "Mémoire cache"], "h": ["Recursivité.", "Divide and Conquer."], "d": "facile"},
            {"t": "Algo", "q": "Classe P=NP ?", "a": "Égalité résolution/vérification", "w": ["Puissance/Vitesse", "Normalisé", "Non-Polynomial"], "h": ["Millénium Prize.", "Mystère."], "d": "moyen"},
            {"t": "Algo", "q": "Complexité parcours BFS ?", "a": "O(V + E)", "w": ["O(V²)", "O(E log V)", "O(V)"], "h": ["Visite tout.", "Linéaire."], "d": "difficile"},
            {"t": "Algo", "q": "Structure parcours DFS ?", "a": "Stack", "w": ["Queue", "Array", "Set"], "h": ["LIFO.", "Profondeur."], "d": "facile"},
            {"t": "Algo", "q": "Compression Huffman utilise ?", "a": "Arbre binaire", "w": ["RSA", "AES", "Heap"], "h": ["Fréquence caractères.", "Longueur variable."], "d": "moyen"},
            {"t": "Algo", "q": "Sommet sans voisin ?", "a": "Isolé", "w": ["Final", "Racine", "Vide"], "h": ["Degré 0.", "Seul."], "d": "facile"},
            {"t": "Algo", "q": "Karatsuba complexité ?", "a": "O(n^1.58)", "w": ["O(n²)", "O(n log n)", "O(2^n)"], "h": ["Multiplication.", "Rapide."], "d": "difficile"},
            {"t": "Algo", "q": "Graphe orienté sans cycle ?", "a": "DAG", "w": ["Tree", "Clique", "Loop"], "h": ["Directed Acyclic.", "3 lettres."], "d": "moyen"},
            {"t": "Algo", "q": "Avantage Quicksort ?", "a": "In-place performance", "w": ["Toujours O(n log n)", "Simple", "Stable"], "h": ["Sur place.", "Pratique."], "d": "moyen"},
            {"t": "Algo", "q": "Mémoïsation évite ?", "a": "Recalcul sous-problèmes", "w": ["Syntaxe", "Fuite mémoire", "Collision"], "h": ["Cache.", "Dynamique."], "d": "facile"},
            {"t": "Algo", "q": "E dans un graphe ?", "a": "Edges (Arêtes)", "w": ["Entries", "Execution", "Energy"], "h": ["Liens.", "Anglais."], "d": "facile"},
            {"t": "Algo", "q": "Hachage pire cas recherche ?", "a": "O(n)", "w": ["O(1)", "O(log n)", "O(n log n)"], "h": ["Collisions.", "Linéaire."], "d": "difficile"},

            # CODE & PROGRAMMATION (25)
            {"t": "Code", "q": "Signification SOLID ?", "a": "5 principes conception", "w": ["Robuste", "Cryptée", "Tri rapide"], "h": ["S=Single Responsibility.", "Objet."], "d": "moyen"},
            {"t": "Code", "q": "Mot-clé Java non-modifiable ?", "a": "final", "w": ["static", "const", "immutable"], "h": ["Héritage aussi.", "Dernière."], "d": "facile"},
            {"t": "Code", "q": "Protocole API REST ?", "a": "HTTP", "w": ["TCP", "UDP", "SSH"], "h": ["Web.", "Stateless."], "d": "facile"},
            {"t": "Code", "q": "Yield en Python ?", "a": "Générateur", "w": ["Stop", "Liste", "Détruit"], "h": ["Demande.", "Mémoire."], "d": "moyen"},
            {"t": "Code", "q": "Attendre Future Dart ?", "a": "await", "w": ["wait", "sleep", "block"], "h": ["async.", "Non-bloquant."], "d": "facile"},
            {"t": "Code", "q": "Lequel a un GC ?", "a": "Java", "w": ["C", "C++", "ASM"], "h": ["Auto mémoire.", "JVM."], "d": "facile"},
            {"t": "Code", "q": "typeof null en JS ?", "a": "object", "w": ["null", "undefined", "empty"], "h": ["Erreur historique.", "Pas null."], "d": "difficile"},
            {"t": "Code", "q": "Interface en POO ?", "a": "Contrat méthodes", "w": ["Fenêtre", "Global", "Data"], "h": ["Abstraction.", "Pas impl."], "d": "facile"},
            {"t": "Code", "q": "Constructeur Python ?", "a": "Initialise attributs", "w": ["Détruit", "Affiche", "Compile"], "h": ["__init__.", "Init."], "d": "facile"},
            {"t": "Code", "q": "Signification CSS ?", "a": "Cascading Style Sheets", "w": ["Computer", "Script", "Cyber"], "h": ["Cascade.", "Design."], "d": "facile"},
            {"t": "Code", "q": "1 == 1.0 Python ?", "a": "True", "w": ["False", "Error", "None"], "h": ["Valeur.", "Float."], "d": "moyen"},
            {"t": "Code", "q": "Git prépare fichiers ?", "a": "git add", "w": ["git stage", "git push", "git save"], "h": ["Index.", "Ajouter."], "d": "facile"},
            {"t": "Code", "q": "Langage Kernel ?", "a": "C", "w": ["Java", "Python", "PHP"], "h": ["Hardware.", "Vitesse."], "d": "facile"},
            {"t": "Code", "q": "DRY signifie ?", "a": "Don't Repeat Yourself", "w": ["Data Run", "Digital", "Direct"], "h": ["Duplication.", "Sec."], "d": "moyen"},
            {"t": "Code", "q": "SQL supprimer table ?", "a": "DROP", "w": ["DELETE", "REMOVE", "KILL"], "h": ["Structure.", "Lâcher."], "d": "moyen"},
            {"t": "Code", "q": "Balise HTML métadonnées ?", "a": "<head>", "w": ["<body>", "<html>", "<footer>"], "h": ["Tête.", "Invisible."], "d": "facile"},
            {"t": "Code", "q": "NaN en JS ?", "a": "Not a Number", "w": ["New Node", "Net", "Null"], "h": ["Invalide.", "0/0."], "d": "facile"},
            {"t": "Code", "q": "Map sur tableau ?", "a": "Fonction sur chaque item", "w": ["Trie", "Doublons", "GPS"], "h": ["Transformation.", "Nouveau."], "d": "facile"},
            {"t": "Code", "q": "Importer module Python ?", "a": "import", "w": ["include", "require", "load"], "h": ["6 lettres.", "Appel."], "d": "facile"},
            {"t": "Code", "q": "Flutter aligner vertical ?", "a": "Column", "w": ["Row", "Stack", "List"], "h": ["Colonne.", "Axe Y."], "d": "facile"},
            {"t": "Code", "q": "2 ** 3 Python ?", "a": "8", "w": ["6", "9", "5"], "h": ["Puissance.", "2x2x2."], "d": "facile"},
            {"t": "Code", "q": "OU logique C ?", "a": "||", "w": ["&&", "!", "|"], "h": ["Double barre.", "Pipe."], "d": "facile"},
            {"t": "Code", "q": "Git push ?", "a": "Envoie distant", "w": ["Récupère", "Commit", "Supprime"], "h": ["Pousser.", "Synchro."], "d": "facile"},
            {"t": "Code", "q": "NullPointerException ?", "a": "Accès non initialisé", "w": ["Calcul", "Réseau", "Mémoire"], "h": ["Pointeur nul.", "Vide."], "d": "moyen"},
            {"t": "Code", "q": "JSON signifie ?", "a": "JavaScript Object Notation", "w": ["Simple", "Standard", "Joint"], "h": ["Texte.", "JS."], "d": "facile"},

            # LOGIQUE & RAISONNEMENT (25)
            {"t": "Logique", "q": "1, 4, 9, 16, ?", "a": "25", "w": ["20", "36", "30"], "h": ["Carrés.", "5x5."], "d": "facile"},
            {"t": "Logique", "q": "Négation A ET B ?", "a": "NON A OU NON B", "w": ["NON A ET NON B", "A OU B", "NON A"], "h": ["De Morgan.", "Inversion."], "d": "difficile"},
            {"t": "Logique", "q": "1011 en décimal ?", "a": "11", "w": ["13", "9", "7"], "h": ["Binaire.", "8+2+1."], "d": "moyen"},
            {"t": "Logique", "q": "2, 6, 12, 20, ?", "a": "30", "w": ["24", "40", "28"], "h": ["+4, +6, +8...", "+10."], "d": "facile"},
            {"t": "Logique", "q": "2^0 ?", "a": "1", "w": ["0", "2", "Error"], "h": ["Exposant.", "Identique."], "d": "facile"},
            {"t": "Logique", "q": "Faces dodécaèdre ?", "a": "12", "w": ["20", "10", "8"], "h": ["Grec.", "12."], "d": "difficile"},
            {"t": "Logique", "q": "A hexadécimal ?", "a": "10", "w": ["11", "1", "16"], "h": ["Après 9.", "Lettre."], "d": "facile"},
            {"t": "Logique", "q": "Somme angles carré ?", "a": "360°", "w": ["180°", "90°", "270°"], "h": ["4x90.", "Cercle."], "d": "facile"},
            {"t": "Logique", "q": "Suit 1, 1, 2, 3, 5, 8, ?", "a": "13", "w": ["11", "10", "15"], "h": ["Fibonacci.", "Somme."], "d": "facile"},
            {"t": "Logique", "q": "10 % 3 ?", "a": "1", "w": ["3", "0", "0.33"], "h": ["Reste.", "Modulo."], "d": "facile"},
            {"t": "Logique", "q": "Log2(1024) ?", "a": "10", "w": ["8", "12", "100"], "h": ["2^x.", "Kilo."], "d": "moyen"},
            {"t": "Logique", "q": "Bits en 1 KB ?", "a": "8192", "w": ["1024", "1000", "8000"], "h": ["1024x8.", "Précis."], "d": "difficile"},
            {"t": "Logique", "q": "Pas un OS ?", "a": "Docker", "w": ["Linux", "macOS", "Android"], "h": ["Conteneur.", "Virtualisation."], "d": "moyen"},
            {"t": "Logique", "q": "25h après 23:00 ?", "a": "00:00", "w": ["01:00", "22:00", "23:00"], "h": ["Modulo 24.", "+1h."], "d": "facile"},
            {"t": "Logique", "q": "Bits IPv4 ?", "a": "32", "w": ["64", "128", "16"], "h": ["4 octets.", "Standard."], "d": "facile"},
            {"t": "Logique", "q": "Si P=Faux, P => Q est ?", "a": "Vrai", "w": ["Faux", "Indéterminé", "Error"], "h": ["Table de vérité implication.", "Faux implique tout."], "d": "difficile"},
            {"t": "Logique", "q": "Résultat (A AND B) OR (A AND NOT B) ?", "a": "A", "w": ["B", "Vrai", "Faux"], "h": ["Loi simplification.", "Algèbre Boole."], "d": "moyen"},
            {"t": "Logique", "q": "Nombres de 1 à 100 avec un 9 ?", "a": "19", "w": ["10", "20", "11"], "h": ["Comptez 9, 19... 89 et 90-99.", "99 est double."], "d": "difficile"},
            {"t": "Logique", "q": "Suite 1, 11, 21, 1211, ?", "a": "111221", "w": ["312211", "121121", "211211"], "h": ["Regarde et dis.", "Décrit précédent."], "d": "difficile"},
            {"t": "Logique", "q": "XOR entre 1010 et 1100 ?", "a": "0110", "w": ["1110", "1000", "0001"], "h": ["Différent = 1.", "Bit à bit."], "d": "moyen"},
            {"t": "Logique", "q": "Négation de 'Certains sont corrompus' ?", "a": "Aucun n'est corrompu", "w": ["Tous le sont", "Certains ne le sont pas", "L'agence est propre"], "h": ["Logique prédicats.", "Opposé de Certains."], "d": "difficile"},
            {"t": "Logique", "q": "Faces d'un cube ?", "a": "6", "w": ["8", "12", "4"], "h": ["Dé.", "Hexaèdre."], "d": "facile"},
            {"t": "Logique", "q": "Suite O, T, T, F, F, S, S, E, N, ?", "a": "T", "w": ["X", "Z", "S"], "h": ["One, Two, Three...", "Anglais."], "d": "difficile"},
            {"t": "Logique", "q": "Mois avec 28 jours ?", "a": "12", "w": ["1", "0", "4"], "h": ["Tous.", "Piège."], "d": "difficile"},
            {"t": "Logique", "q": "3 pilules toutes les 30 min, durée ?", "a": "60 minutes", "w": ["90 minutes", "30 minutes", "120 minutes"], "h": ["0, 30, 60.", "Intervalles."], "d": "moyen"},

            # RÉSEAU & SYSTÈME (25)
            {"t": "Réseau", "q": "Routage Dijkstra ?", "a": "OSPF", "w": ["RIP", "BGP", "EIGRP"], "h": ["Link-State.", "Shortest Path."], "d": "difficile"},
            {"t": "Réseau", "q": "Port PostgreSQL ?", "a": "5432", "w": ["3306", "8080", "27017"], "h": ["Notre DB.", "5432."], "d": "moyen"},
            {"t": "Réseau", "q": "RAID 0 signifie ?", "a": "Performance (Striping)", "w": ["Sécurité", "Parité", "Chiffre"], "h": ["Vitesse.", "Zéro redondance."], "d": "moyen"},
            {"t": "Réseau", "q": "Commande processus Linux ?", "a": "ps", "w": ["ls", "proc", "task"], "h": ["2 lettres.", "Process Status."], "d": "facile"},
            {"t": "Réseau", "q": "Signifie VPN ?", "a": "Virtual Private Network", "w": ["Visual", "Verified", "Port"], "h": ["Tunnel.", "Privé."], "d": "facile"},
            {"t": "Réseau", "q": "Sécurise TLS ?", "a": "HTTPS", "w": ["FTP", "SMTP", "Telnet"], "h": ["Cadenas.", "Web."], "d": "facile"},
            {"t": "Réseau", "q": "Loopback standard ?", "a": "127.0.0.1", "w": ["0.0.0.0", "192.168.1.1", "255.255.255.255"], "h": ["Localhost.", "Soi."], "d": "facile"},
            {"t": "Réseau", "q": "Qu'est-ce qu'un inode ?", "a": "Métadonnées fichier", "w": ["Processeur", "Admin", "Port"], "h": ["Linux filesystem.", "Index."], "d": "difficile"},
            {"t": "Réseau", "q": "Synchro heure ?", "a": "NTP", "w": ["HTTP", "SNMP", "SMTP"], "h": ["Network Time.", "123."], "d": "facile"},
            {"t": "Réseau", "q": "Couche chiffrement OSI ?", "a": "Présentation (6)", "w": ["7", "4", "3"], "h": ["Formatage.", "SSL."], "d": "difficile"},
            {"t": "Réseau", "q": "Rôle Switch ?", "a": "Relier via MAC", "w": ["Relier via IP", "Amplifier", "Virus"], "h": ["Couche 2.", "Table MAC."], "d": "facile"},
            {"t": "Réseau", "q": "Config IP Linux ?", "a": "ifconfig", "w": ["ipconfig", "netstat", "route"], "h": ["'i'.", "Interface."], "d": "facile"},
            {"t": "Réseau", "q": "Port SSH ?", "a": "22", "w": ["21", "23", "80"], "h": ["Double.", "Sécurisé."], "d": "facile"},
            {"t": "Réseau", "q": "Signifie DNS ?", "a": "Domain Name System", "w": ["Data", "Digital", "Network"], "h": ["Noms.", "Annuaire."], "d": "facile"},
            {"t": "Réseau", "q": "Transport non fiable ?", "a": "UDP", "w": ["TCP", "IP", "ICMP"], "h": ["Datagramme.", "Streaming."], "d": "facile"},
            {"t": "Réseau", "q": "Changer proprio Linux ?", "a": "chown", "w": ["chmod", "chuser", "chgrp"], "h": ["Change Owner.", "Root."], "d": "moyen"},
            {"t": "Réseau", "q": "Taille adresse MAC ?", "a": "48 bits", "w": ["32", "64", "128"], "h": ["6 octets.", "Physique."], "d": "difficile"},
            {"t": "Réseau", "q": "Protocole ping ?", "a": "ICMP", "w": ["TCP", "UDP", "ARP"], "h": ["Control Message.", "Diag."], "d": "moyen"},
            {"t": "Réseau", "q": "DHCP snooping ?", "a": "Sécurité DHCP pirates", "w": ["Accélérer", "Cacher", "Scanner"], "h": ["Filtrage L2.", "Protège."], "d": "difficile"},
            {"t": "Réseau", "q": "Masque /16 décimal ?", "a": "255.255.0.0", "w": ["255.0.0.0", "255.255.255.0", "255.255.255.255"], "h": ["2 octets 1.", "Classe B."], "d": "facile"},
            {"t": "Réseau", "q": "Port Telnet ?", "a": "23", "w": ["22", "21", "25"], "h": ["Non sécurisé.", "Vieux."], "d": "difficile"},
            {"t": "Réseau", "q": "Signifie LAN ?", "a": "Local Area Network", "w": ["Large", "Long", "Logical"], "h": ["Maison.", "Local."], "d": "facile"},
            {"t": "Réseau", "q": "Quitter SSH ?", "a": "exit", "w": ["quit", "stop", "close"], "h": ["4 lettres.", "Sortir."], "d": "facile"},
            {"t": "Réseau", "q": "Couche 4 OSI ?", "a": "Transport", "w": ["Réseau", "Session", "Liaison"], "h": ["TCP/UDP.", "Segments."], "d": "facile"},
            {"t": "Réseau", "q": "Masque /8 décimal ?", "a": "255.0.0.0", "w": ["255.255.0.0", "255.255.255.0", "0.0.0.0"], "h": ["1 octet 1.", "Classe A."], "d": "facile"},
        ]

        for rq in q_raw:
            ans = [{"text": rq["a"], "is_correct": True}]
            for wrong in rq["w"]: ans.append({"text": wrong, "is_correct": False})
            random.shuffle(ans)
            db.add(QuizQuestion(theme=rq["t"], text=rq["q"], answers=ans, hints=rq["h"], difficulty=rq["d"]))

        db.commit()
        print(f"Base de données peuplée avec succès (V3.5) !")

    except Exception as e:
        db.rollback()
        print(f"Erreur lors du seeding : {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
