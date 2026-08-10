from database import SessionLocal, engine, Base
import models
from models import AvatarItem, Gadget, QuizQuestion
import random

def seed_database():
    print("--- RÉINITIALISATION ET GÉNÉRATION DE 100 QUESTIONS DE NIVEAU L ---")
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()

    try:
        # 1. Avatars
        db.add(AvatarItem(name="Agent Standard", description="Avatar de base du réseau. Aucune influence.", image_url="avatar_default.jpeg", price=0))
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

        # 2. Gadgets
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

        # 3. 100 Questions techniques de haut niveau
        q_data = [
            # ALGORITHME & COMPLEXITÉ (25)
            {"t": "Algorithme & Complexité", "q": "Quelle est la complexité d'un tri par fusion (Merge Sort) dans le pire des cas ?", "a": "O(n log n)", "w": ["O(n²)", "O(n)", "O(log n)"], "h": ["C'est un tri par division.", "Il est stable et optimal."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Quel algorithme est utilisé pour trouver le plus court chemin dans un graphe avec poids négatifs ?", "a": "Bellman-Ford", "w": ["Dijkstra", "A*", "Prim"], "h": ["Plus lent que Dijkstra.", "Gère les cycles négatifs."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Complexité temporelle de l'insertion dans une table de hachage (cas moyen) ?", "a": "O(1)", "w": ["O(n)", "O(log n)", "O(n log n)"], "h": ["C'est un accès direct par clé.", "Indépendant du nombre d'items."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Que signifie la classe P dans la théorie de la complexité ?", "a": "Résoluble en temps polynomial", "w": ["Résoluble en temps proportionnel", "Problème non-déterministe", "Puissance calculatoire"], "h": ["Machines déterministes.", "Polynomial time."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Quel est le principe de l'algorithme glouton (Greedy) ?", "a": "Choix optimal local à chaque étape", "w": ["Exploration de tous les cas", "Division en sous-problèmes", "Retour en arrière si erreur"], "h": ["Pas de marche arrière.", "Avidité."], "d": "facile"},
            {"t": "Algorithme & Complexité", "q": "Complexité spatiale d'un parcours en largeur (BFS) sur un graphe de n sommets ?", "a": "O(n)", "w": ["O(1)", "O(log n)", "O(n²)"], "h": ["Dépend de la file d'attente.", "Stocke les nœuds visités."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Quel structure de données utilise le tri par tas (Heapsort) ?", "a": "Arbre binaire complet", "w": ["Liste chaînée", "Table de hachage", "Pile LIFO"], "h": ["Utilise un tas (max-heap).", "Structure arborescente."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Dans quel cas Dijkstra échoue-t-il ?", "a": "Poids d'arêtes négatifs", "w": ["Graphes non-orientés", "Cycles de poids positifs", "Graphes denses"], "h": ["Suppose des poids positifs.", "Calcul de distance cumulée."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Qu'est-ce qu'un graphe acyclique ?", "a": "Un graphe sans cycle", "w": ["Un graphe sans sommet", "Un graphe orienté uniquement", "Un graphe complet"], "h": ["Pas de retour au point de départ.", "Arborescence."], "d": "facile"},
            {"t": "Algorithme & Complexité", "q": "Complexité du pire cas pour Quicksort avec un mauvais choix de pivot ?", "a": "O(n²)", "w": ["O(n log n)", "O(n)", "O(n!)"], "h": ["Arrive sur tableau déjà trié.", "Pivot = min ou max."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Propriété d'un Arbre Binaire de Recherche (BST) ?", "a": "Fils gauche < Parent < Fils droit", "w": ["Fils gauche > Parent", "Tous les nœuds ont 3 fils", "Les feuilles sont toutes au même niveau"], "h": ["Structure ordonnée.", "Recherche dichotomique."], "d": "facile"},
            {"t": "Algorithme & Complexité", "q": "Quel algorithme calcule l'arbre couvrant minimal d'un graphe ?", "a": "Kruskal", "w": ["Floyd-Warshall", "DFS", "PageRank"], "h": ["Utilise une forêt de sommets.", "Tri des arêtes par poids."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Complexité de la recherche binaire ?", "a": "O(log n)", "w": ["O(n)", "O(1)", "O(n²)"], "h": ["Divise l'espace par deux.", "Tableau trié requis."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Que permet la programmation dynamique ?", "a": "Optimiser via stockage de résultats", "w": ["Accélérer le processeur", "Paralléliser le code", "Gérer la mémoire manuellement"], "h": ["Évite les calculs redondants.", "Ex: Fibonacci."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Quel est le facteur de charge idéal d'une table de hachage ?", "a": "0.7 à 0.8", "w": ["1.0", "2.0", "0.1"], "h": ["Compromis collision/mémoire.", "Redimensionnement automatique."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Nombre max d'arêtes dans un graphe simple de n sommets ?", "a": "n(n-1)/2", "w": ["n²", "2n", "n!"], "h": ["Graphe complet K_n.", "Somme des degrés."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Quelle structure de données est utilisée pour le backtracking ?", "a": "Pile (Stack)", "w": ["File (Queue)", "Matrice", "Liste"], "h": ["Last-In First-Out.", "Récursivité."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Différence entre BFS et DFS ?", "a": "Structure FIFO vs LIFO", "w": ["Vitesse de calcul", "Langage de programmation", "Précision des résultats"], "h": ["Largeur vs Profondeur.", "Queue vs Stack."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Complexité temporelle du tri par tas ?", "a": "O(n log n)", "w": ["O(n²)", "O(log n)", "O(n)"], "h": ["Même pire cas que Fusion.", "Utilise un Max-Heap."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Algorithme optimal pour le tri de petits tableaux ?", "a": "Insertion Sort", "w": ["Merge Sort", "Quick Sort", "Bogo Sort"], "h": ["Efficace sur petites tailles.", "Simplicité O(n²)."], "d": "facile"},
            {"t": "Algorithme & Complexité", "q": "Que signifie un problème NP-complet ?", "a": "Le plus dur de la classe NP", "w": ["Non-Polynomial", "Nouveau Problème", "Normalisé"], "h": ["Si on en résout un, on les résout tous.", "Réduction polynomiale."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Algorithme pour trouver les composantes fortement connexes ?", "a": "Tarjan", "w": ["Dijkstra", "Kruskal", "A*"], "h": ["Utilise le parcours DFS.", "Graphes orientés."], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Complexité d'accès au n-ième élément d'une liste chaînée ?", "a": "O(n)", "w": ["O(1)", "O(log n)", "O(n log n)"], "h": ["Pas d'indexation directe.", "Parcours de nœud en nœud."], "d": "moyen"},
            {"t": "Algorithme & Complexité", "q": "Que fait l'algorithme A* ?", "a": "Plus court chemin avec heuristique", "w": ["Tri de données massives", "Compression de fichiers", "Cryptage symétrique"], "h": ["Extension de Dijkstra.", "f(n) = g(n) + h(n)"], "d": "difficile"},
            {"t": "Algorithme & Complexité", "q": "Une machine déterministe peut-elle résoudre un problème NP en temps P ?", "a": "Question irrésolue (P vs NP)", "w": ["Oui toujours", "Jamais", "Seulement le dimanche"], "h": ["Le plus grand mystère info.", "P = NP ?"], "d": "difficile"},

            # CODE & PROGRAMMATION (25)
            {"t": "Code & Programmation", "q": "En Python, que fait le 'GIL' (Global Interpreter Lock) ?", "a": "Empêche le multi-threading CPU réel", "w": ["Accélère la boucle for", "Chiffre le code source", "Bloque l'accès internet"], "h": ["Un seul thread à la fois.", "Problème historique de CPython."], "d": "difficile"},
            {"t": "Code & Programmation", "q": "En Dart, à quoi sert le mot-clé 'async*' ?", "a": "Définir un générateur de flux (Stream)", "w": ["Lancer une tâche en arrière-plan", "Déclarer une variable asynchrone", "Arrêter une Future"], "h": ["Utilisé avec yield.", "Retourne un Stream."], "d": "difficile"},
            {"t": "Code & Programmation", "q": "Quel design pattern utilise une instance unique d'une classe ?", "a": "Singleton", "w": ["Factory", "Observer", "Strategy"], "h": ["Constructeur privé.", "Instance globale unique."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Que signifie 'immutabilité' en programmation ?", "a": "L'état ne peut pas changer après création", "w": ["Le code ne peut pas être lu", "La variable est accessible partout", "Le programme ne s'arrête jamais"], "h": ["Utile en fonctionnel.", "Thread-safe par nature."], "d": "facile"},
            {"t": "Code & Programmation", "q": "En Java, où sont stockés les objets créés avec 'new' ?", "a": "Le Heap (Tas)", "w": ["La Stack (Pile)", "Le Registre", "Le Cache L1"], "h": ["Nettoyé par le GC.", "Mémoire dynamique."], "d": "moyen"},
            {"t": "Code & Programmation", "q": "Quel opérateur JavaScript compare la valeur ET le type ?", "a": "===", "w": ["==", "=", "!="], "h": ["Triple égalité.", "Strict equality."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Qu'est-ce qu'une 'Closure' en programmation ?", "a": "Fonction gardant accès à sa portée parente", "w": ["Fermeture du programme", "Un bug de mémoire", "Un type de variable privée"], "h": ["Portée lexicale.", "Fonction dans une fonction."], "d": "difficile"},
            {"t": "Code & Programmation", "q": "En Flutter, quel widget est la base de l'arbre visuel ?", "a": "Widget", "w": ["Class", "Layout", "View"], "h": ["Tout est ...", "Structure arborescente."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Que fait 'git rebase' ?", "a": "Réécrit l'historique des commits", "w": ["Supprime le dépôt distant", "Fusionne les branches sans changer l'ID", "Crée une copie du projet"], "h": ["Déplace les commits.", "Historique linéaire."], "d": "moyen"},
            {"t": "Code & Programmation", "q": "Quel langage utilise le Garbage Collector pour la mémoire ?", "a": "Java", "w": ["C", "C++", "Assembleur"], "h": ["Gestion automatique.", "Machine virtuelle."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Que renvoie 'typeof []' en JavaScript ?", "a": "object", "w": ["array", "list", "undefined"], "h": ["Piège classique du JS.", "Les tableaux sont des objets."], "d": "difficile"},
            {"t": "Code & Programmation", "q": "En Python, que fait l'instruction 'yield' ?", "a": "Transforme la fonction en générateur", "w": ["Arrête le programme", "Retourne une erreur", "Importe un module"], "h": ["Production de valeurs une par une.", "Lazy evaluation."], "d": "moyen"},
            {"t": "Code & Programmation", "q": "Quel protocole utilise une API REST par définition ?", "a": "HTTP", "w": ["FTP", "TCP", "SSH"], "h": ["Stateless.", "Web services."], "d": "facile"},
            {"t": "Code & Programmation", "q": "En C++, qu'est-ce qu'un pointeur ?", "a": "Variable stockant une adresse mémoire", "w": ["Une icône de souris", "Une fonction récursive", "Un type de donnée booléen"], "h": ["Référence directe à la RAM.", "Symbole *."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Que signifie SOLID en ingénierie logicielle ?", "a": "5 principes de conception objet", "w": ["Une base de données robuste", "Un type de cryptage", "Un framework JavaScript"], "h": ["S pour Single Responsibility.", "Design patterns."], "d": "difficile"},
            {"t": "Code & Programmation", "q": "En Dart, comment gérer plusieurs futurs simultanés ?", "a": "Future.wait()", "w": ["Future.all()", "async.start()", "then.multiple()"], "h": ["Attend toutes les réponses.", "Liste de futures."], "d": "difficile"},
            {"t": "Code & Programmation", "q": "Quelle est la sortie de : print(bool('False')) en Python ?", "a": "True", "w": ["False", "Error", "None"], "h": ["Une chaîne non vide est vraie.", "Piège de casting."], "d": "difficile"},
            {"t": "Code & Programmation", "q": "Quel mot-clé en Java empêche l'héritage d'une classe ?", "a": "final", "w": ["static", "private", "sealed"], "h": ["Utilisé aussi pour les constantes.", "Dernière version."], "d": "moyen"},
            {"t": "Code & Programmation", "q": "Que fait un décorateur en Python ?", "a": "Modifie le comportement d'une fonction", "w": ["Change la couleur du texte", "Trie une liste", "Crée une interface graphique"], "h": ["Design pattern Wrapper.", "Symbole @."], "d": "difficile"},
            {"t": "Code & Programmation", "q": "En SQL, différence entre WHERE et HAVING ?", "a": "HAVING filtre après agrégation", "w": ["Aucune différence", "WHERE est plus rapide", "HAVING est pour les colonnes"], "h": ["Utilisé avec GROUP BY.", "Filtre de groupe."], "d": "moyen"},
            {"t": "Code & Programmation", "q": "Que signifie ACID pour les transactions SQL ?", "a": "Atomicité Cohérence Isolation Durabilité", "w": ["Access Code ID", "Active Core Interactive Data", "Auto Check Internal Device"], "h": ["Garantit la fiabilité.", "4 piliers."], "d": "moyen"},
            {"t": "Code & Programmation", "q": "En CSS, que fait 'display: flex' ?", "a": "Active le modèle de boîte flexible", "w": ["Change la police", "Cache l'élément", "Crée une grille complexe"], "h": ["Alignement facile.", "Flexbox."], "d": "facile"},
            {"t": "Code & Programmation", "q": "Quel langage est compilé en Bytecode ?", "a": "Java", "w": ["Python", "JS", "C"], "h": ["Utilise la JVM.", "Fichiers .class."], "d": "moyen"},
            {"t": "Code & Programmation", "q": "En JS, qu'est-ce que 'Event Bubbling' ?", "a": "Propagation de l'événement vers le haut", "w": ["Un bug d'interface", "Une animation de boutons", "Le rafraîchissement automatique"], "h": ["Du fils vers le parent.", "DOM propagation."], "d": "difficile"},
            {"t": "Code & Programmation", "q": "Que fait 'List<int> x = const [1, 2];' en Dart ?", "a": "Crée une liste immuable au build", "w": ["Crée une liste vide", "Donne une erreur de type", "Réserve la mémoire uniquement"], "h": ["Temps de compilation.", "Identité constante."], "d": "moyen"},

            # LOGIQUE & RAISONNEMENT (25)
            {"t": "Logique & Raisonnement", "q": "Si P est Faux, que vaut 'P implique Q' ?", "a": "Vrai", "w": ["Faux", "Indéterminé", "Dépend de Q"], "h": ["Table de vérité de l'implication.", "Le faux implique n'importe quoi."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Quel est le résultat de : (A AND B) OR (A AND NOT B) ?", "a": "A", "w": ["B", "True", "False"], "h": ["Loi de simplification.", "Simplifiez l'expression."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Combien de nombres de 1 à 100 contiennent le chiffre 9 ?", "a": "19", "w": ["10", "20", "11"], "h": ["Comptez 9, 19... 89 et 90-99.", "Attention au 99 (double)."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Suite : 1, 11, 21, 1211, 111221, ?", "a": "312211", "w": ["1112211", "121121", "211211"], "h": ["Suite 'Regarde et dis'.", "Décris le nombre précédent."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Un bit vaut 0 ou 1. Combien d'états pour 8 bits ?", "a": "256", "w": ["128", "512", "64"], "h": ["2 à la puissance 8.", "Un octet."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Négation de 'Certains agents sont corrompus' ?", "a": "Aucun agent n'est corrompu", "w": ["Tous les agents sont corrompus", "Certains agents ne sont pas corrompus", "L'agence est propre"], "h": ["Logique des prédicats.", "L'opposé du 'Certains'."], "d": "moyen"},
            {"t": "Logique & Raisonnement", "q": "XOR entre 1010 et 1100 ?", "a": "0110", "w": ["1110", "1000", "0001"], "h": ["Vrai si différent.", "Bit à bit."], "d": "moyen"},
            {"t": "Logique & Raisonnement", "q": "Combien d'adresses IP dans un /24 ?", "a": "256", "w": ["254", "512", "128"], "h": ["Total des adresses.", "2^(32-24)."], "d": "moyen"},
            {"t": "Logique & Raisonnement", "q": "L'énigme du menteur : A dit 'B ment', B dit 'A ment'.", "a": "Paradoxe", "w": ["A dit vrai", "B dit vrai", "Les deux mentent"], "h": ["Boucle infinie.", "Inconsistance."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Somme des entiers de 1 à 10 ?", "a": "55", "w": ["50", "45", "60"], "h": ["Formule de Gauss n(n+1)/2.", "10*11 / 2."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Complète : 2, 6, 12, 20, 30, ?", "a": "42", "w": ["40", "36", "50"], "h": ["Écarts : +4, +6, +8, +10...", "+12."], "d": "moyen"},
            {"t": "Logique & Raisonnement", "q": "Porte logicielle qui inverse l'entrée ?", "a": "NOT", "w": ["AND", "OR", "NAND"], "h": ["Inverseur.", "1 devient 0."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "En hexadécimal, quelle est la valeur de 'F' ?", "a": "15", "w": ["16", "10", "14"], "h": ["A=10, B=11...", "Dernier chiffre hexa."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Loi de De Morgan : NOT (A OR B) est ?", "a": "NOT A AND NOT B", "w": ["NOT A OR NOT B", "A AND B", "NOT A"], "h": ["Inversez le signe et les termes.", "Théorème booléen."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Dans une base 2, que vaut 1 + 1 ?", "a": "10", "w": ["2", "0", "11"], "h": ["Retenue binaire.", "Zéro et un."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Paradoxe de Russell : l'ensemble qui ne se contient pas ?", "a": "N'existe pas logiquement", "w": ["Contient tout", "Contient seulement le vide", "Est fini"], "h": ["Théorie des ensembles.", "Contradiction."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Si 5 machines font 5 widgets en 5 min, combien pour 100 mach. / 100 wid. ?", "a": "5 minutes", "w": ["100 min", "1 min", "20 min"], "h": ["Vitesse unitaire constante.", "Parallélisme."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Que vaut 2^10 ?", "a": "1024", "w": ["1000", "2048", "512"], "h": ["Un Kilo-octet.", "Base info."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Si un médecin te donne 3 pilules à prendre toutes les 30 min. Combien de temps ?", "a": "60 minutes", "w": ["90 minutes", "30 minutes", "120 minutes"], "h": ["0 min, 30 min, 60 min.", "Intervalle vs durée."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "L'intrus : Linux, Windows, macOS, Android, Docker ?", "a": "Docker", "w": ["Linux", "macOS", "Windows"], "h": ["Les autres sont des OS.", "C'est un conteneur."], "d": "moyen"},
            {"t": "Logique & Raisonnement", "q": "Résultat de 10 % 3 ?", "a": "1", "w": ["3", "0", "3.33"], "h": ["Le reste de la division.", "Modulo."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Suite : O, T, T, F, F, S, S, E, N, ?", "a": "T", "w": ["X", "Z", "S"], "h": ["Initiales des nombres anglais.", "One, Two, Three..."], "d": "difficile"},
            {"t": "Logique & Raisonnement", "q": "Négation de 'A ET B' ?", "a": "NON A OU NON B", "w": ["NON A ET NON B", "A OU B", "NON A"], "h": ["Loi de De Morgan.", "Changement de signe."], "d": "moyen"},
            {"t": "Logique & Raisonnement", "q": "Combien de faces sur un cube ?", "a": "6", "w": ["8", "12", "4"], "h": ["Dé à jouer.", "Hexaèdre."], "d": "facile"},
            {"t": "Logique & Raisonnement", "q": "Quelle heure est-il 25 heures après 23:00 ?", "a": "00:00 (Minuit)", "w": ["23:00", "01:00", "22:00"], "h": ["Modulo 24.", "Un jour et une heure."], "d": "moyen"},

            # RÉSEAU & SYSTÈME (25)
            {"t": "Réseau & Système", "q": "Quel protocole utilise le port 53 ?", "a": "DNS", "w": ["DHCP", "HTTP", "SMTP"], "h": ["Résolution de noms.", "Essentiel au web."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Qu'est-ce qu'une adresse MAC ?", "a": "Identifiant physique unique de la carte réseau", "w": ["Adresse IP de l'ordinateur Apple", "Un code de sécurité wifi", "Le nom de l'utilisateur session"], "h": ["Hexadécimal.", "Couche 2 OSI."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Rôle de la commande 'netstat' ?", "a": "Afficher les connexions réseau actives", "w": ["Redémarrer le routeur", "Changer le mot de passe wifi", "Scanner les virus"], "h": ["Statistiques réseau.", "Ports ouverts."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Signification de l'acronyme VPN ?", "a": "Virtual Private Network", "w": ["Verified Protocol Node", "Visual Path Network", "Virtual Power Net"], "h": ["Tunnel sécurisé.", "Réseau privé."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Quel protocole sécurise HTTPS ?", "a": "TLS / SSL", "w": ["SSH", "WPA2", "IPsec"], "h": ["Certificats x509.", "Cadenas vert."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Couche OSI du protocole IP ?", "a": "Réseau (3)", "w": ["Transport (4)", "Liaison (2)", "Session (5)"], "h": ["Adresse de routage.", "Paquets."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Qu'est-ce qu'un inode dans un système Linux ?", "a": "Structure stockant les métadonnées d'un fichier", "w": ["Le nom d'un fichier", "Un utilisateur administrateur", "Une commande de suppression"], "h": ["Index node.", "Ne contient pas le nom."], "d": "difficile"},
            {"t": "Réseau & Système", "q": "Port par défaut de MySQL ?", "a": "3306", "w": ["5432", "8080", "27017"], "h": ["Nombre commençant par 3.", "Base de données."], "d": "difficile"},
            {"t": "Réseau & Système", "q": "Quelle est l'adresse de loopback IPv4 ?", "a": "127.0.0.1", "w": ["192.168.1.1", "0.0.0.0", "255.255.255.255"], "h": ["localhost.", "C'est vous-même."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Rôle d'un serveur Proxy ?", "a": "Intermédiaire entre client et serveur", "w": ["Stocker les e-mails", "Accélérer le processeur", "Nettoyer la base de données"], "h": ["Mandataire.", "Filtrage et cache."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Quelle commande Linux liste les fichiers d'un dossier ?", "a": "ls", "w": ["dir", "list", "show"], "h": ["2 lettres.", "List."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Qu'est-ce que le 'Kernell' d'un OS ?", "a": "Le cœur gérant les ressources matérielles", "w": ["L'interface graphique", "Le navigateur web par défaut", "Le disque dur physique"], "h": ["Noyau.", "Pont hardware/software."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Protocole pour transférer des fichiers en SSH ?", "a": "SFTP", "w": ["FTP", "FTPS", "HTTP"], "h": ["Secure FTP.", "Port 22."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Combien de couches dans le modèle TCP/IP ?", "a": "4", "w": ["7", "5", "3"], "h": ["Simplification de l'OSI.", "Application, Transport..."], "d": "difficile"},
            {"t": "Réseau & Système", "q": "Qu'est-ce qu'une attaque par Injection SQL ?", "a": "Insertion de code malveillant dans une requête DB", "w": ["Saturer le réseau", "Voler des cookies de session", "Casser un mot de passe wifi"], "h": ["Cible la base de données.", "Inputs non protégés."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Signification de DHCP ?", "a": "Dynamic Host Configuration Protocol", "w": ["Data Hyper Core Process", "Direct Hub Control Path", "Digital Host Central Port"], "h": ["D pour Dynamic.", "H pour Host."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Quel port utilise le protocole SMTP ?", "a": "25", "w": ["110", "143", "443"], "h": ["Envoi de mail.", "Vieux standard."], "d": "difficile"},
            {"t": "Réseau & Système", "q": "Quelle commande Linux change les permissions ?", "a": "chmod", "w": ["chown", "permit", "access"], "h": ["Change Mode.", "Octal: 755."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Quelle IP est celle du broadcast dans 192.168.1.0/24 ?", "a": "192.168.1.255", "w": ["192.168.1.0", "192.168.1.1", "192.168.1.254"], "h": ["Dernière adresse du bloc.", "Tout à 1."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Qu'est-ce que 'sudo' sous Linux ?", "a": "Exécuter une commande avec les droits root", "w": ["Supprimer un dossier", "Éteindre l'ordinateur", "Installer un programme"], "h": ["Substitute User Do.", "Super-utilisateur."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Quel protocole utilise des paquets appelés 'datagrammes' ?", "a": "UDP", "w": ["TCP", "HTTP", "SSH"], "h": ["Non orienté connexion.", "Rapide."], "d": "difficile"},
            {"t": "Réseau & Système", "q": "Que signifie RAID 1 en stockage ?", "a": "Mise en miroir (Mirroring)", "w": ["Répartition (Striping)", "Double parité", "Chiffrement disque"], "h": ["Copie identique sur 2 disques.", "Sécurité."], "d": "moyen"},
            {"t": "Réseau & Système", "q": "Rôle du registre de processeur 'Program Counter' ?", "a": "Adresse de la prochaine instruction à exécuter", "w": ["Compter les secondes", "Stocker les résultats", "Gérer les interruptions"], "h": ["PC.", "Séquenceur."], "d": "difficile"},
            {"t": "Réseau & Système", "q": "Quelle commande Linux affiche l'espace disque ?", "a": "df", "w": ["du", "free", "disk"], "h": ["Disk Free.", "-h pour humain."], "d": "facile"},
            {"t": "Réseau & Système", "q": "Qu'est-ce que le 'Swapping' ?", "a": "Utilisation du disque dur comme RAM virtuelle", "w": ["Changer d'utilisateur", "Échanger des fichiers", "Mettre à jour l'OS"], "h": ["Mémoire d'échange.", "Lenteur du système."], "d": "moyen"}
        ]

        # Insertion avec mélange des réponses
        for rq in q_data:
            ans = [{"text": rq["a"], "is_correct": True}]
            for wrong in rq["w"]:
                ans.append({"text": wrong, "is_correct": False})
            random.shuffle(ans)

            q = QuizQuestion(
                theme=rq["t"],
                text=rq["q"],
                answers=ans,
                hints=rq["h"],
                difficulty=rq["d"]
            )
            db.add(q)

        db.commit()
        print(f"Base de données peuplée avec succès (100 questions techniques) !")

    except Exception as e:
        db.rollback()
        print(f"Erreur lors du seeding : {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
