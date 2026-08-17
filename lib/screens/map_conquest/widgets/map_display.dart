import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapDisplay extends StatelessWidget {
  final MapLibreMapController? controller;
  final List<Map<String, dynamic>> bases;
  final bool isStyleLoaded;
  final bool isFollowingUser;
  final Function(MapLibreMapController) onMapCreated;
  final VoidCallback onStyleLoaded;
  final Function(UserLocation) onLocationUpdated;
  final String styleString;

  const MapDisplay({
    super.key,
    required this.controller,
    required this.bases,
    required this.isStyleLoaded,
    required this.isFollowingUser,
    required this.onMapCreated,
    required this.onStyleLoaded,
    required this.onLocationUpdated,
    required this.styleString,
  });

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      onMapCreated: onMapCreated,
      onStyleLoadedCallback: onStyleLoaded,
      onUserLocationUpdated: onLocationUpdated,
      initialCameraPosition: const CameraPosition(target: LatLng(-21.4536, 47.0833), zoom: 13.5),
      styleString: styleString,
      myLocationEnabled: true,
      myLocationRenderMode: MyLocationRenderMode.gps,
      myLocationTrackingMode: isFollowingUser
          ? MyLocationTrackingMode.trackingCompass
          : MyLocationTrackingMode.none,
      // On ajuste la boussole pour qu'elle soit bien visible sous la TopBar
      compassViewPosition: CompassViewPosition.topRight,
      compassViewMargins: const math.Point(24, 110),
    );
  }
}

List<LatLng> createPentagonPoints(LatLng center, double radiusInMeters) {
  List<LatLng> points = [];
  double latDegree = radiusInMeters / 111320;
  double lngDegree = radiusInMeters / (111320 * math.cos(center.latitude * math.pi / 180));
  for (int i = 0; i < 5; i++) {
    double angle = (i * 72) * math.pi / 180;
    points.add(LatLng(center.latitude + (latDegree * math.sin(angle)), center.longitude + (lngDegree * math.cos(angle))));
  }
  points.add(points.first);
  return points;
}
