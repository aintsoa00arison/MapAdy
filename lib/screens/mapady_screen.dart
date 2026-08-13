import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as loc;
import '../theme/app_colors.dart';
import '../services/territory_service.dart';
import '../services/auth_service.dart';

// Notifier global pour masquer les barres de navigation
final ValueNotifier<bool> hideBarsNotifier = ValueNotifier<bool>(false);

class MapadyScreen extends StatefulWidget {
  const MapadyScreen({super.key});

  @override
  State<MapadyScreen> createState() => _MapadyScreenState();
}

class _MapadyScreenState extends State<MapadyScreen> with TickerProviderStateMixin {
  MapLibreMapController? _mapController;
  List<Map<String, dynamic>> _bases = [];
  bool _isStyleLoaded = false;
  bool _isConquestMode = false;
  Map<String, dynamic>? _userData;
  LatLng? _currentLocation;
  final loc.Location _locationService = loc.Location();

  // Animations
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _btnScaleController;
  late Animation<double> _btnScaleAnimation;

  static const String maptilerStyle = 
      "https://api.maptiler.com/maps/019ff69e-f86b-71eb-9174-7747851625cf/style.json?key=unUFY9uFBzpXNISNkIyg";

  @override
  void initState() {
    super.initState();
    _fetchBases();
    _loadUserData();
    _checkLocationPermission();
    
    // Pulsation pour le scanner
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_pulseController);

    // Animation Zoom In/Out pour le bouton
    _btnScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _btnScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _btnScaleController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return;
    }

    // Récupérer la position initiale pour centrer la carte
    final locationData = await _locationService.getLocation();
    if (mounted) {
      setState(() {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 14.0));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _btnScaleController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(AuthService.userKey);
    if (userJson != null) {
      setState(() => _userData = jsonDecode(userJson));
    }
  }

  Future<void> _fetchBases() async {
    final bases = await TerritoryService().getAllBases();
    if (mounted) {
      setState(() => _bases = bases);
      _displayBasesOnMap();
    }
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  void _onUserLocationUpdated(UserLocation location) {
    if (mounted) {
      setState(() {
        _currentLocation = location.position;
      });
    }
  }

  void _onStyleLoaded() {
    _isStyleLoaded = true;
    _displayBasesOnMap();
  }

  void _displayBasesOnMap() {
    if (_mapController == null || _bases.isEmpty || !_isStyleLoaded) return;
    _mapController!.clearFills();
    _mapController!.clearCircles();

    for (var base in _bases) {
      final center = LatLng(base['latitude'], base['longitude']);
      final radius = (base['conquest_radius_m'] as num).toDouble();

      _mapController!.addFill(FillOptions(
        geometry: [_createPentagonPoints(center, radius)],
        fillColor: AppColors.primary.toHex(),
        fillOpacity: 0.15,
        fillOutlineColor: AppColors.primary.toHex(),
      ));

      _mapController!.addCircle(CircleOptions(
        geometry: center,
        circleRadius: 8.0,
        circleColor: AppColors.secondary.toHex(),
        circleOpacity: 0.8,
        circleBlur: 0.5,
      ));
    }
  }

  List<LatLng> _createPentagonPoints(LatLng center, double radiusInMeters) {
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

  void _toggleConquestMode(bool active) {
    setState(() {
      _isConquestMode = active;
    });
    hideBarsNotifier.value = active;
    
    // Si on active le mode et qu'on a une position, on centre
    if (active && _currentLocation != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          MapLibreMap(
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,
            onUserLocationUpdated: _onUserLocationUpdated,
            initialCameraPosition: const CameraPosition(target: LatLng(-21.4536, 47.0833), zoom: 13.5),
            styleString: maptilerStyle,
            myLocationEnabled: true,
            myLocationRenderMode: MyLocationRenderMode.normal,
            myLocationTrackingMode: _isConquestMode ? MyLocationTrackingMode.tracking : MyLocationTrackingMode.none,
          ),
          
          if (_isConquestMode) _buildConquestHUD(),
          
          _buildConquestButton(),
        ],
      ),
    );
  }

  Widget _buildConquestButton() {
    return Positioned(
      bottom: _isConquestMode ? 40 : 120,
      left: 40,
      right: 40,
      child: ScaleTransition(
        scale: _btnScaleAnimation,
        child: GestureDetector(
          onTap: () => _toggleConquestMode(!_isConquestMode),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _isConquestMode ? Colors.red.withValues(alpha: 0.8) : AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _isConquestMode ? Colors.red : AppColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: (_isConquestMode ? Colors.red : AppColors.primary).withValues(alpha: 0.4), 
                  blurRadius: 15
                )
              ],
            ),
            child: Text(
              _isConquestMode ? "ANNULER LA CONQUÊTE" : "PARTIR À LA CONQUÊTE",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConquestHUD() {
    return Stack(
      children: [
        // SCANNER OVERLAY
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),

        // TOP HUD
        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleConquestMode(false),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background.withValues(alpha: 0.8),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          "${_userData?['gold'] ?? 0} CC",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary, width: 2),
                  boxShadow: [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.3), blurRadius: 10)],
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage("assets/avatar/${_userData?['avatar'] ?? 'avatar_1.jpeg'}"),
                ),
              ),
            ],
          ),
        ),

        // STATUS BAR
        Positioned(
          bottom: 110,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2 * _pulseAnimation.value),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withValues(alpha: _pulseAnimation.value)),
                  ),
                  child: const Text(
                    "SCANNER ACTIF - POSITION ROUGE",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

extension ColorToHex on Color {
  String toHex() => '#${(toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}
