class GadgetInfluenceManager {
  /// Calcule les statistiques réelles d'un gadget en fonction de l'avatar équipé.
  static Map<String, dynamic> getEffectiveStats(String gadgetNames, String currentAvatar) {
    // Stats de base par défaut
    Map<String, dynamic> stats = {
      "duration": 3.0,
      "dodge_chance": 0.5,
      "refund_rate": 0.0,
      "gold_bonus": 1.0,
      "cooldown": 10.0,
      "barriers": 2,
      "immobilize_time": 2.0,
      "discount": 0.0,
      "stealth": false
    };

    // Application des influences d'avatar
    switch (currentAvatar) {
      case "avatar_1.jpeg": // Neon Scavenger
        stats["duration"] = 5.0; // +2s
        break;
      
      case "avatar_3.jpeg": // Midnight Slice
        stats["refund_rate"] = 0.5; // 50%
        break;

      case "avatar_4.jpeg": // Rain Stalker
        stats["dodge_chance"] = 1.0; // 100%
        break;

      case "avatar_5.jpeg": // Convenience Hacker
        stats["gold_bonus"] = 1.2; // +20%
        break;

      case "avatar_6.jpeg": // Insomnia Netrunner
        stats["cooldown"] = 5.0; // 50% reduction
        break;

      case "avatar_7.jpeg": // Chain-Skull
        stats["barriers"] = 3;
        break;

      case "avatar_8.jpeg": // Matrix Puppet
        stats["immobilize_time"] = 4.0; // +2s
        break;

      case "avatar_9.jpeg": // Sicko Flex
        stats["discount"] = 0.15;
        break;

      case "avatar_10.jpeg": // Shadow Anonymous
        stats["stealth"] = true;
        break;
    }

    return stats;
  }
}
