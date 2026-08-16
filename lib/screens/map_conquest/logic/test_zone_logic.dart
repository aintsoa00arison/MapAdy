import 'package:maplibre_gl/maplibre_gl.dart';
import 'dart:math' as math;

class TestZoneLogic {
  static Map<String, dynamic>? getNearbyBase(LatLng? currentLocation, List<Map<String, dynamic>> realBases) {
    if (currentLocation == null || realBases.isEmpty) return null;

    Map<String, dynamic>? nearest;
    double minDistance = double.infinity;

    for (var b in realBases) {
      double dist = calculateDistance(currentLocation, LatLng(b['latitude'], b['longitude']));
      if (dist < minDistance) {
        minDistance = dist;
        nearest = b;
      }
    }

    if (nearest != null) {
      // On injecte la distance calculée pour l'affichage
      nearest['current_distance'] = minDistance;
      return nearest;
    }

    return null;
  }

  static double calculateDistance(LatLng p1, LatLng p2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((p2.latitude - p1.latitude) * p)/2 + 
          c(p1.latitude * p) * c(p2.latitude * p) * 
          (1 - c((p2.longitude - p1.longitude) * p))/2;
    return 12742 * math.asin(math.sqrt(a)) * 1000;
  }
}
