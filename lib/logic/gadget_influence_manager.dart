class GadgetInfluenceManager {
  /// Calcule les statistiques réelles des gadgets en fonction de l'avatar équipé.
  static Map<String, dynamic> getEffectiveStats(String? currentAvatar) {
    // Statistiques de base par défaut
    Map<String, dynamic> stats = {
      "glitch_duration": 3,      // 3 secondes par défaut
      "safedrop_charges": 2,     // 2 chances par défaut
      "cyberspy_charges": 2,     // 2 révélations par défaut
      "irontwin_extra": 4,       // +4 questions par défaut
      "gold_multiplier": 1.0,    // Multiplicateur de gains
    };

    if (currentAvatar == null) return stats;

    // Application des influences spécifiques aux avatars
    switch (currentAvatar) {
      case "avatar_1.jpeg": // Neon Scavenger
        stats["glitch_duration"] = 5; // +2s de brouillage (Malus pour l'attaquant si le défenseur l'a? Non, c'est l'avatar de l'attaquant ici)
        // Note: Dans MapAdy, les influences d'avatar aident l'ATTAQUANT à mieux utiliser ses gadgets
        // ou à mieux résister aux défenses.
        break;
      
      case "avatar_3.jpeg": // Midnight Slice
        stats["safedrop_charges"] = 3; // +1 chance de sauvetage
        break;

      case "avatar_4.jpeg": // Rain Stalker
        // Rain Stalker pourrait rendre le GhostKey plus efficace (ex: bonus de temps)
        break;

      case "avatar_5.jpeg": // Convenience Hacker
        stats["gold_multiplier"] = 1.2; // +20% de CC gagnés
        break;

      case "avatar_7.jpeg": // Chain-Skull
        // Si l'attaquant a Chain-Skull, peut-être qu'il réduit l'effet IronTwin?
        stats["irontwin_extra"] = 2; // Réduit la barrière IronTwin de 4 à 2 questions sup
        break;

      case "avatar_10.jpeg": // Shadow Anonymous
        stats["cyberspy_charges"] = 4; // +2 révélations CyberSpy
        break;
    }

    return stats;
  }
}
