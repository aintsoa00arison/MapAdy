def get_gadget_modifiers(avatar_name: str):
    """
    Retourne les multiplicateurs ou bonus appliqués aux gadgets
    selon l'avatar actuellement équipé par le joueur.
    """
    modifiers = {
        "duration_multiplier": 1.0,
        "bonus_duration": 0,
        "refund_percent": 0.0,
        "dodge_chance": 0.5, # Par défaut 50%
        "gold_steal_multiplier": 1.0,
        "cooldown_multiplier": 1.0,
        "extra_barriers": 0,
        "immobilize_bonus": 0,
        "shop_discount": 0.0,
        "stealth_mode": False
    }

    if avatar_name == "Neon Scavenger":
        modifiers["bonus_duration"] = 2 # +2s pour GlitchScreen

    elif avatar_name == "Midnight Slice":
        modifiers["refund_percent"] = 0.5 # 50% remboursé

    elif avatar_name == "Rain Stalker":
        modifiers["dodge_chance"] = 1.0 # 100% esquive

    elif avatar_name == "Convenience Hacker":
        modifiers["gold_steal_multiplier"] = 1.2 # +20%

    elif avatar_name == "Insomnia Netrunner":
        modifiers["cooldown_multiplier"] = 0.5 # Cooldown / 2

    elif avatar_name == "Chain-Skull":
        modifiers["extra_barriers"] = 1 # 3 barrières au lieu de 2

    elif avatar_name == "Matrix Puppet":
        modifiers["immobilize_bonus"] = 2 # +2s immobilisation

    elif avatar_name == "Sicko Flex":
        modifiers["shop_discount"] = 0.15 # 15% de réduction

    elif avatar_name == "Shadow Anonymous":
        modifiers["stealth_mode"] = True

    return modifiers
