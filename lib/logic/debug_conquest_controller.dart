import 'package:flutter/material.dart';

enum DebugDefenseType {
  none,
  glitchScreen,
  ironTwin,
  frostTrap,
  drainCash,
  safeDrop,
  ghostKey,
  cyberspy
}

class DebugConquestController {
  static final DebugConquestController _instance = DebugConquestController._internal();
  factory DebugConquestController() => _instance;
  DebugConquestController._internal();

  DebugDefenseType activeTestDefense = DebugDefenseType.none;

  List<String> getActiveEffects() {
    switch (activeTestDefense) {
      case DebugDefenseType.glitchScreen:
        return ["GLITCHSCREEN"];
      case DebugDefenseType.ironTwin:
        return ["IRON_TWIN"];
      case DebugDefenseType.frostTrap:
        return ["FROSTTRAP"];
      case DebugDefenseType.drainCash:
        return ["DRAINCASH"];
      case DebugDefenseType.safeDrop:
        return ["SAFEDROP"];
      case DebugDefenseType.ghostKey:
        return ["GHOSTKEY"];
      case DebugDefenseType.cyberspy:
        return ["CYBERSPY"];
      default:
        return [];
    }
  }

  int getTotalNeeded() {
    return activeTestDefense == DebugDefenseType.ironTwin ? 10 : 6;
  }
}
