import 'package:maplibre_gl/maplibre_gl.dart';
import 'dart:math' as math;

class TestZoneLogic {
  static Map<String, dynamic>? getNearbyTestBase(LatLng? currentLocation, List<Map<String, dynamic>> realBases) {
    if (currentLocation == null) return null;

    // Vérifier d'abord s'il y a une vraie base à proximité
    for (var b in realBases) {
      double dist = calculateDistance(currentLocation, LatLng(b['latitude'], b['longitude']));
      if (dist <= (b['conquest_radius_m'] as num).toDouble()) {
        return b;
      }
    }

    // Sinon, créer une zone de test virtuelle à la position actuelle
    return {
      "id": 0, 
      "name": "ZONE DE TEST LOCALE",
      "latitude": currentLocation.latitude,
      "longitude": currentLocation.longitude,
      "conquest_radius_m": 150.0,
      "is_test": true
    };
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
