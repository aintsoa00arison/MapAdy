from database import SessionLocal, engine, Base
import models
from models import AvatarItem, Gadget, QuizQuestion, GameBase, PalierTopographique
import random
import math

def seed_database():
    print("--- RÉINITIALISATION COMPLÈTE (100 QUESTIONS + GRANDS QUARTIERS) ---")
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        # 1. Avatars & Gadgets
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

        gadgets = [
            Gadget(name="GlitchScreen", description="Brouille le texte pendant 3s.", price=300, image_url="GlitchScreen.jpeg"),
            Gadget(name="IronTwin", description="Double barrière de protection.", price=450, image_url="IronTwin.jpeg"),
            Gadget(name="DrainCash", description="Vole les points en cas d'erreur.", price=400, image_url="DrainCash.jpeg"),
            Gadget(name="FrostTrap", description="Gèle l'adversaire.", price=350, image_url="FrostTrap.jpeg"),
            Gadget(name="GhostKey", description="Permet de traverser les barrières.", price=500, image_url="GhostKey.jpeg"),
            Gadget(name="SafeDrop", description="Bouclier anti-échec.", price=600, image_url="SafeDrop.jpeg"),
            Gadget(name="Overheat", description="Accélère le chrono ennemi.", price=550, image_url="Overheat.jpeg"),
            Gadget(name="Cyberspy", description="Scanne le type de question.", price=250, image_url="Cyberspy.jpeg"),
            Gadget(name="floral", description="Gadget bonus mystère.", price=200, image_url="floral.jpeg"),
        ]
        db.add_all(gadgets)

        # 2. Grands Secteurs de Fianarantsoa (Larges zones de conquête)
        print("Déploiement des secteurs de contrôle urbain...")
        sectors = [
            {"name": "SECTEUR ANJOMA", "lat": -21.4546, "lng": 47.0875, "rad": 150, "p": 300, "palier": PalierTopographique.BASSE, "desc": "Zone commerciale et logistique majeure."},
            {"name": "CORE AMPASAMBAZAHA", "lat": -21.4491, "lng": 47.0880, "rad": 200, "p": 450, "palier": PalierTopographique.MOYENNE, "desc": "Centre administratif et arène centrale."},
            {"name": "CAMPUS ANDRAINJATO", "lat": -21.4617, "lng": 47.1118, "rad": 300, "p": 1000, "palier": PalierTopographique.BASSE, "desc": "Le pôle technologique et scientifique."},
            {"name": "CITADELLE AMBOZONTANY", "lat": -21.4580, "lng": 47.0760, "rad": 180, "p": 600, "palier": PalierTopographique.HAUTE, "desc": "Le sommet historique et stratégique."},
            {"name": "RELAIS ANOSY", "lat": -21.4520, "lng": 47.0850, "rad": 120, "p": 250, "palier": PalierTopographique.MOYENNE, "desc": "Nœud de communication autour du lac."},
            {"name": "BASTION ROVA", "lat": -21.4597, "lng": 47.0768, "rad": 140, "p": 500, "palier": PalierTopographique.HAUTE, "desc": "L'ancien palais sous haute surveillance."},
            {"name": "UPLINK TSIANOLONDROA", "lat": -21.4505, "lng": 47.0835, "rad": 110, "p": 200, "palier": PalierTopographique.MOYENNE, "desc": "Zone de haute densité résidentielle."},
            {"name": "DATA CENTER ENI", "lat": -21.4551, "lng": 47.0934, "rad": 250, "p": 800, "palier": PalierTopographique.BASSE, "desc": "Le temple du code et de l'intrusion."},
            {"name": "SCANNER POINT-DE-VUE", "lat": -21.4455, "lng": 47.0782, "rad": 130, "p": 350, "palier": PalierTopographique.HAUTE, "desc": "Surveillance panoramique de la ville."}
        ]

        for s in sectors:
            db.add(GameBase(
                name=s["name"], latitude=s["lat"], longitude=s["lng"],
                palier=s["palier"], description=s["desc"],
                conquest_radius_m=float(s["rad"]), points_value=s["p"]
            ))

        # 3. Les 100 Questions techniques de niveau L (Restaurées)
        q_data = [
            # ALGORITHME & COMPLEXITÉ (25)
            {"t": "Algorithme & Complexité", "q": "Quelle est la complexité temporelle du tri fusion (Merge Sort) dans le pire des cas ?", "a": "O(n log n)", "w": ["O(n²)", "O(n)", "O(log n)"], "h": ["Division par deux à chaque étape.", "Tri stable."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Quel algorithme est utilisé pour détecter des cycles dans un graphe dirigé ?", "a": "Parcours DFS", "w": ["Algorithme de Prim", "Algorithme de Kruskal", "Parcours BFS"], "h": ["Utilise la pile d'appels.", "Recherche en profondeur."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Dans un Arbre Binaire de Recherche, quel est le temps de recherche moyen ?", "a": "O(log n)", "w": ["O(n)", "O(1)", "O(n log n)"], "h": ["Similaire à une recherche dichotomique.", "Dépend de la hauteur de l'arbre."], "d": "facile"},
            {"t": "Algorithme & Complexité", "q": "Que signifie la classe de complexité NP ?", "a": "Non-deterministic Polynomial time", "w": ["Non-Polynomial time", "Nearly Polynomial", "Numerical Process"], "h": ["Vérifiable en temps polynomial.", "Machine non-déterministe."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Quelle est la complexité d'accès à un élément par son index dans un tableau ?", "a": "O(1)", "w": ["O(n)", "O(log n)", "O(1/n)"], "h": ["Accès immédiat.", "Temps constant."], "d": "facile"},
            {"t": "Algorithme & Complexité", "q": "Lequel de ces tris n'est PAS un tri par comparaison ?", "a": "Tri par dénombrement (Counting Sort)", "w": ["Quicksort", "Heapsort", "Bubblesort"], "h": ["Complexité linéaire possible.", "Utilise les valeurs comme index."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Structure de données optimale pour implémenter une file de priorité ?", "a": "Tas (Heap)", "w": ["Pile (Stack)", "Liste chaînée", "Arbre binaire simple"], "h": ["Arbre binaire presque complet.", "Maintient l'élément max ou min."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Que calcule l'algorithme de Floyd-Warshall ?", "a": "Tous les plus courts chemins entre tous les nœuds", "w": ["L'arbre couvrant minimal", "Le flux maximum dans un réseau", "Le plus court chemin d'une source unique"], "h": ["Poids négatifs autorisés.", "Matrice de distances."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Complexité temporelle d'une recherche linéaire dans le pire cas ?", "a": "O(n)", "w": ["O(1)", "O(log n)", "O(n²)"], "h": ["On vérifie chaque élément.", "Échelle proportionnelle."], "d": "facile"},
            {"t": "Algorithme & Complexité", "q": "Dans la notation Big O, que représente n ?", "a": "La taille des données d'entrée", "w": ["Le nombre de processeurs", "Le temps en millisecondes", "La vitesse du réseau"], "h": ["Paramètre de croissance.", "Volume de l'input."], "d": "facile"},
            {"t": "Algorithme & Complexité", "q": "Quel algorithme glouton est utilisé pour l'arbre couvrant minimal ?", "a": "Kruskal", "w": ["Dijkstra", "A*", "Bellman-Ford"], "h": ["Tri des arêtes.", "Évite les cycles."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Complexité spatiale d'une matrice d'adjacence pour un graphe de V sommets ?", "a": "O(V²)", "w": ["O(V)", "O(E+V)", "O(log V)"], "h": ["Stockage en grille.", "V x V cases."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Quelle est la complexité du tri à bulles (Bubble Sort) ?", "a": "O(n²)", "w": ["O(n log n)", "O(n)", "O(1)"], "h": ["Deux boucles imbriquées.", "Très inefficace."], "d": "facile"},
            {"t": "Algorithme & Complexité", "q": "Quel est le principe du paradigme 'Diviser pour régner' ?", "a": "Découper un problème en sous-problèmes indépendants", "w": ["Utiliser plusieurs serveurs", "Casser le code en fonctions", "Optimiser la mémoire cache"], "h": ["Divide and Conquer.", "Recursivité."], "d": "facile"},
            {"t": "Algorithme & Complexité", "q": "Que signifie la classe P=NP ?", "a": "Égalité entre résolution et vérification rapide", "w": ["Puissance égale à la vitesse", "Problème Normalisé", "Processus Non-Polynomial"], "h": ["Millénium Prize.", "Mystère informatique."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Quelle est la complexité d'un parcours BFS ?", "a": "O(V + E)", "w": ["O(V²)", "O(E log V)", "O(V)"], "h": ["Visite sommets et arêtes.", "Linéaire."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Structure de données utilisée pour le parcours DFS ?", "a": "Pile (Stack)", "w": ["File (Queue)", "Tableau", "Set"], "h": ["LIFO.", "Profondeur."], "d": "facile"},
            {"t": "Algorithme & Complexité", "q": "Algorithme de compression sans perte utilisant un arbre binaire ?", "a": "Codage de Huffman", "w": ["Codage RSA", "Algorithme AES", "Tri par tas"], "h": ["Fréquence des caractères.", "Codes de longueur variable."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Comment appelle-t-on un sommet sans voisin ?", "a": "Sommet isolé", "w": ["Sommet final", "Sommet racine", "Sommet vide"], "h": ["Degré 0.", "Tout seul."], "d": "facile"},
            {"t": "Algorithme & Complexité", "q": "Complexité temporelle de l'algorithme de Karatsuba ?", "a": "O(n^1.58)", "w": ["O(n²)", "O(n log n)", "O(2^n)"], "h": ["Multiplication d'entiers.", "Plus rapide que n²."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Un graphe orienté sans cycle est un...", "a": "DAG", "w": ["Tree", "Clique", "Loop"], "h": ["Directed Acyclic Graph.", "3 lettres."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Quel est l'avantage du tri rapide (Quicksort) ?", "a": "Performant en pratique (in-place)", "w": ["Toujours O(n log n)", "Simple à coder", "Stable"], "h": ["Tri sur place.", "Rapide malgré le pire cas."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Que permet d'éviter la mémoïsation ?", "a": "Le recalcul de sous-problèmes identiques", "w": ["Les erreurs de syntaxe", "Les fuites mémoire", "Les collisions de hachage"], "h": ["Cache de résultats.", "Programmation dynamique."], "d": "facile"},
            {"t": "Algorithme & Complexité", "q": "Dans un graphe, que représente E ?", "a": "Le nombre d'arêtes (Edges)", "w": ["Le nombre d'entrées", "Le temps d'exécution", "L'énergie consommée"], "h": ["Liens entre sommets.", "Anglais."], "d": "facile"},
            {"t": "Algorithme & Complexité", "q": "Complexité du pire cas pour la recherche dans une table de hachage ?", "a": "O(n)", "w": ["O(1)", "O(log n)", "O(n log n)"], "h": ["Arrive lors de collisions massives.", "Toutes les clés au même endroit."], "d": "difficile"},

            # CODE & PROGRAMMATION (25)
            {"t": "Code & Programmation", "q": "Que signifie l'acronyme SOLID ?", "a": "5 principes de conception logicielle", "w": ["Un langage robuste", "Une base de données cryptée", "Une méthode de tri rapide"], "h": ["S pour Single Responsibility.", "Architecture objet."], "d": "moyen"},
            {"t": "Code & Programmation", "q": "En Java, quel mot-clé empêche la modification d'une variable ?", "a": "final", "w": ["static", "const", "immutable"], "h": ["Utilisé aussi pour l'héritage.", "Dernière valeur."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Quel protocole est utilisé par les API REST ?", "a": "HTTP", "w": ["TCP", "UDP", "SSH"], "h": ["Protocole web.", "Stateless."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Que fait l'instruction 'yield' en Python ?", "a": "Crée un générateur", "w": ["Stoppe le programme", "Retourne une liste", "Détruit une variable"], "h": ["Production à la demande.", "Économe en mémoire."], "d": "moyen"},
            {"t": "Code & Programmation", "q": "En Dart, comment forcer l'attente d'une Future ?", "a": "await", "w": ["wait", "sleep", "block"], "h": ["Utilisé avec async.", "Attente non-bloquante."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Quel langage utilise un Garbage Collector ?", "a": "Java", "w": ["C", "C++", "Assembleur"], "h": ["Gestion auto mémoire.", "JVM."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Que renvoie 'typeof null' en JavaScript ?", "a": "object", "w": ["null", "undefined", "empty"], "h": ["Erreur historique du JS.", "Pas un type null."], "d": "difficile"},
            {"t": "Code & Programmation", "q": "Qu'est-ce qu'une interface en POO ?", "a": "Un contrat définissant des méthodes", "w": ["Une fenêtre visuelle", "Une variable globale", "Un type de donnée"], "h": ["Pas d'implémentation.", "Abstraction."], "d": "facile"},
            {"t": "Code & Programmation", "q": "En Python, que fait le constructeur ?", "a": "Initialise les attributs de l'objet", "w": ["Détruit l'objet", "Affiche le code", "Compile le script"], "h": ["__init__.", "Naissance."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Que signifie CSS ?", "a": "Cascading Style Sheets", "w": ["Computer Style Sheet", "Code Script System", "Cyber Style Source"], "h": ["Style en cascade.", "Design web."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Quelle est la sortie de print(1 == 1.0) en Python ?", "a": "True", "w": ["False", "Error", "None"], "h": ["Comparaison de valeur.", "Fractions."], "d": "moyen"},
            {"t": "Code & Programmation", "q": "En Git, quelle commande prépare les fichiers pour le commit ?", "a": "git add", "w": ["git stage", "git push", "git save"], "h": ["Zone d'indexation.", "Ajouter."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Langage utilisé pour le développement système (Kernel) ?", "a": "C", "w": ["Java", "Python", "PHP"], "h": ["Proche du hardware.", "Performances max."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Que signifie DRY en programmation ?", "a": "Don't Repeat Yourself", "w": ["Data Run Yearly", "Digital Real Yield", "Direct Router Yield"], "h": ["Éviter la duplication.", "Sec en anglais."], "d": "moyen"},
            {"t": "Code & Programmation", "q": "En SQL, commande pour supprimer une table ?", "a": "DROP TABLE", "w": ["DELETE TABLE", "REMOVE TABLE", "KILL TABLE"], "h": ["Suppression structurelle.", "Lâcher."], "d": "moyen"},
            {"t": "Code & Programmation", "q": "Quelle balise HTML contient les métadonnées ?", "a": "<head>", "w": ["<body>", "<html>", "<meta>"], "h": ["La tête.", "Non visible sur la page."], "d": "facile"},
            {"t": "Code & Programmation", "q": "En JS, qu'est-ce que 'NaN' ?", "a": "Not a Number", "w": ["New Access Node", "Net and Node", "Null and None"], "h": ["Résultat de calcul invalide.", "0/0."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Que fait un 'map' sur un tableau ?", "a": "Applique une fonction à chaque élément", "w": ["Trie les éléments", "Supprime les doublons", "Affiche la position GPS"], "h": ["Transformation.", "Nouveau tableau."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Mot-clé pour importer un module en Python ?", "a": "import", "w": ["include", "require", "load"], "h": ["6 lettres.", "Appel externe."], "d": "facile"},
            {"t": "Code & Programmation", "q": "En Flutter, widget pour aligner verticalement ?", "a": "Column", "w": ["Row", "Stack", "List"], "h": ["Colonne.", "Axe Y."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Que renvoie print(2 ** 3) en Python ?", "a": "8", "w": ["6", "9", "5"], "h": ["Puissance.", "2x2x2."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Symbole pour l'opérateur 'OU' logique en C ?", "a": "||", "w": ["&&", "!", "|"], "h": ["Double barre.", "Pipe."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Que fait 'git push' ?", "a": "Envoie les commits sur le serveur distant", "w": ["Récupère les changements", "Crée un nouveau commit", "Supprime une branche"], "h": ["Pousser.", "Synchronisation."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Quel type d'erreur est un 'NullPointerException' ?", "a": "Accès à un objet non initialisé", "w": ["Erreur de calcul", "Erreur réseau", "Dépassement mémoire"], "h": ["Pointeur nul.", "Référence vide."], "d": "moyen"},
            {"t": "Code & Programmation", "q": "Signification de JSON ?", "a": "JavaScript Object Notation", "w": ["Just Simple Object Net", "Java Standard Open Node", "Joint Script Open Net"], "h": ["Format texte.", "JS."], "d": "facile"},

            # LOGIQUE & RAISONNEMENT (25)
            {"t": "Logique & Raisonnement", "q": "Complète : 1, 4, 9, 16, ?", "a": "25", "w": ["20", "36", "30"], "h": ["Carrés parfaits.", "5x5."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Si tous les A sont B, et certains B sont C, est-ce que certains A sont C ?", "a": "Pas forcément", "w": ["Oui toujours", "Jamais", "Seulement si C est A"], "h": ["Regardez les cercles d'Euler.", "Incertitude."], "d": "moyen"},
            {"t": "Logique & Raisonnement", "q": "Négation de 'A ET B' ?", "a": "NON A OU NON B", "w": ["NON A ET NON B", "A OU B", "NON A"], "h": ["Lois de De Morgan.", "Inversion."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Quelle est la valeur de 1011 en décimal ?", "a": "11", "w": ["13", "9", "7"], "h": ["Binaire.", "8+2+1."], "d": "moyen"},
            {"t": "Logique & Raisonnement", "q": "Complète : 2, 6, 12, 20, ?", "a": "30", "w": ["24", "40", "28"], "h": ["Écarts : +4, +6, +8...", "+10."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Que vaut 2^0 ?", "a": "1", "w": ["0", "2", "Erreur"], "h": ["Propriété des exposants.", "Toujours identique."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Vrai ou Faux : (VRAI OU FAUX) ET FAUX ?", "a": "Faux", "w": ["Vrai", "Indéterminé", "Error"], "h": ["Priorité parenthèses.", "Condition ET."], "d": "moyen"},
            {"t": "Logique & Raisonnement", "q": "Suite : 3, 5, 9, 17, ?", "a": "33", "w": ["35", "25", "31"], "h": ["x2 - 1.", "Écarts : 2, 4, 8, 16."], "d": "moyen"},
            {"t": "Logique & Raisonnement", "q": "Combien de faces sur un dodécaèdre ?", "a": "12", "w": ["20", "10", "8"], "h": ["Préfixe grec.", "Dé à 12."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Si 3 chats mangent 3 souris en 3 min, combien de temps pour 100 chats ?", "a": "3 minutes", "w": ["100 min", "1 min", "300 min"], "h": ["Action en parallèle.", "Même rythme."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Valeur de 'A' en hexadécimal ?", "a": "10", "w": ["11", "1", "16"], "h": ["Après le chiffre 9.", "Début des lettres."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Inverse de (A AND B) en porte logique ?", "a": "NAND", "w": ["NOR", "XOR", "XNOR"], "h": ["Not AND.", "4 lettres."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Somme des angles d'un carré ?", "a": "360°", "w": ["180°", "90°", "270°"], "h": ["4 x 90°.", "Cercle complet."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Complète : O, T, T, F, F, S, S, E, N, ?", "a": "T", "w": ["X", "Z", "O"], "h": ["Nombres anglais.", "One, Two, Three..."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Quel chiffre suit : 1, 1, 2, 3, 5, 8, ?", "a": "13", "w": ["11", "10", "15"], "h": ["Fibonacci.", "Somme."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Résultat de 10 % 3 ?", "a": "1", "w": ["3", "0", "0.33"], "h": ["Reste de division.", "Modulo."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Si un médecin donne 3 pilules, une toutes les 30 min, durée ?", "a": "60 minutes", "w": ["90 minutes", "30 minutes", "120 minutes"], "h": ["0, 30, 60.", "Intervalles."], "d": "moyen"},
            {"t": "Logique & Raisonnement", "q": "Que vaut log2(1024) ?", "a": "10", "w": ["8", "12", "100"], "h": ["Puissances de 2.", "Kilo-octet."], "d": "moyen"},
            {"t": "Logique & Raisonnement", "q": "Combien de mois ont 28 jours ?", "a": "12", "w": ["1", "0", "4"], "h": ["Tous les mois.", "Question piège."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Paradoxe : 'Cette phrase est fausse' ?", "a": "Paradoxe d'Épiménide", "w": ["Paradoxe de Russell", "Effet Mandela", "Loi de Murphy"], "h": ["Auto-référence.", "Contradiction."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Combien de bits dans un kilooctet (KB) ?", "a": "8192", "w": ["1024", "1000", "8000"], "h": ["1024 octets x 8 bits.", "Calcul précis."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Lequel n'est pas un OS ?", "a": "Docker", "w": ["Linux", "macOS", "Android"], "h": ["C'est un conteneur.", "Virtualisation."], "d": "moyen"},
            {"t": "Logique & Raisonnement", "q": "Si tu me retournes, je suis tout. Si tu me coupes, je suis rien ?", "a": "Le chiffre 8", "w": ["Le chiffre 0", "La lettre O", "Une pomme"], "h": ["Vertical vs Horizontal.", "Infini."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Quelle heure 25h après 23:00 ?", "a": "00:00", "w": ["01:00", "22:00", "23:00"], "h": ["Modulo 24.", "1 jour + 1 heure."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Nombre de bits d'une adresse IPv4 ?", "a": "32", "w": ["64", "128", "16"], "h": ["4 octets.", "Standard."], "d": "facile"},

            # RÉSEAU & SYSTÈME (25)
            {"t": "Réseau & Système", "q": "Protocole de routage utilisant Dijkstra ?", "a": "OSPF", "w": ["RIP", "BGP", "EIGRP"], "h": ["Link-State.", "Shortest Path First."], "d": "difficile"},
            {"t": "Réseau & Système", "q": "Quel port pour une DB PostgreSQL ?", "a": "5432", "w": ["3306", "8080", "27017"], "h": ["Notre DB actuelle.", "5-4-3-2."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Rôle de la couche 2 OSI ?", "a": "Liaison de données (MAC)", "w": ["Routage (IP)", "Transport (TCP)", "Physique (Câble)"], "h": ["Adresses physiques.", "Trames."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Que signifie RAID 0 ?", "a": "Striping (Performance)", "w": ["Mirroring (Sécurité)", "Parité", "Chiffrement"], "h": ["Vitesse max.", "Zéro redondance."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Quelle commande liste les processus sous Linux ?", "a": "ps", "w": ["ls", "proc", "task"], "h": ["2 lettres.", "Process Status."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Signification de VPN ?", "a": "Virtual Private Network", "w": ["Visual Path Net", "Virtual Port Node", "Verified Private Node"], "h": ["Tunnel.", "Privé."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Quel protocole sécurise TLS ?", "a": "HTTPS", "w": ["FTP", "SMTP", "Telnet"], "h": ["Cadenas vert.", "Web sécurisé."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Adresse loopback standard ?", "a": "127.0.0.1", "w": ["0.0.0.0", "192.168.0.1", "255.255.255.255"], "h": ["Localhost.", "Soi-même."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Qu'est-ce qu'un inode ?", "a": "Structure de métadonnées de fichier", "w": ["Un type de processeur", "Un utilisateur admin", "Un port réseau"], "h": ["Linux filesystem.", "Index node."], "d": "difficile"},
            {"t": "Réseau & Système", "q": "Protocole pour synchroniser l'heure ?", "a": "NTP", "w": ["HTTP", "SNMP", "SMTP"], "h": ["Network Time.", "Port 123."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Attaque 'Man in the middle' ?", "a": "MITM", "w": ["DDoS", "SQLi", "Phishing"], "h": ["Interception.", "Milieu."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Couche OSI gérant le chiffrement ?", "a": "Couche 6 (Présentation)", "w": ["Couche 7", "Couche 4", "Couche 3"], "h": ["Formatage données.", "SSL/TLS."], "d": "difficile"},
            {"t": "Réseau & Système", "q": "Rôle du commutateur (Switch) ?", "a": "Relier hôtes via adresses MAC", "w": ["Relier réseaux via IP", "Amplifier le signal", "Bloquer les virus"], "h": ["Couche 2.", "Table MAC."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Commande pour voir la config IP (Linux) ?", "a": "ifconfig", "w": ["ipconfig", "netstat", "route"], "h": ["Commence par 'i'.", "Interface."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Port par défaut du serveur SSH ?", "a": "22", "w": ["21", "23", "80"], "h": ["Double chiffre.", "Sécurisé."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Que signifie DNS ?", "a": "Domain Name System", "w": ["Data Node System", "Digital Net Service", "Domain Network Server"], "h": ["Noms de domaines.", "Annuaire."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Protocole de transport non fiable et rapide ?", "a": "UDP", "w": ["TCP", "IP", "ICMP"], "h": ["Datagramme.", "Streaming/Jeux."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Quelle commande Linux change le propriétaire ?", "a": "chown", "w": ["chmod", "chuser", "chgrp"], "h": ["Change Owner.", "Root."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Taille d'une adresse MAC ?", "a": "48 bits", "w": ["32 bits", "64 bits", "128 bits"], "h": ["6 octets.", "Physique."], "d": "difficile"},
            {"t": "Réseau & Système", "q": "Protocole pour le ping ?", "a": "ICMP", "w": ["TCP", "UDP", "ARP"], "h": ["Internet Control Message.", "Diagnostic."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Qu'est-ce que le 'DHCP snooping' ?", "a": "Sécurité contre les serveurs DHCP pirates", "w": ["Accélérer l'attribution IP", "Cacher son IP", "Scanner les ports"], "h": ["Filtrage couche 2.", "Protection."], "d": "difficile"},
            {"t": "Réseau & Système", "q": "Notation décimale du masque /16 ?", "a": "255.255.0.0", "w": ["255.0.0.0", "255.255.255.0", "255.255.255.255"], "h": ["2 octets à 1.", "Classe B."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Quel port utilise le protocole Telnet ?", "a": "23", "w": ["22", "21", "25"], "h": ["Non sécurisé.", "Vieux standard."], "d": "difficile"},
            {"t": "Réseau & Système", "q": "Que signifie l'acronyme LAN ?", "a": "Local Area Network", "w": ["Large Access Net", "Long Area Node", "Logical Auto Net"], "h": ["Réseau local.", "Maison/Bureau."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Commande pour quitter une session SSH ?", "a": "exit", "w": ["quit", "stop", "close"], "h": ["4 lettres.", "Sortir."], "d": "facile"}
        ]

        for rq in q_data:
            ans = [{"text": rq["a"], "is_correct": True}]
            for wrong in rq["w"]: ans.append({"text": wrong, "is_correct": False})
            random.shuffle(ans)
            db.add(QuizQuestion(theme=rq["t"], text=rq["q"], answers=ans, hints=rq["h"], difficulty=rq["d"]))

        db.commit()
        print(f"Base de données peuplée avec succès (100 Questions + Grands Quartiers) !")

    except Exception as e:
        db.rollback()
        print(f"Erreur lors du seeding : {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
