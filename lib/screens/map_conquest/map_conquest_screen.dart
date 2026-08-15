import 'dart:convert';
import 'package:flutter/material.dart';
import '../quiz_battle/quiz_battle_screen.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as loc;
import '../../theme/app_colors.dart';
import '../../services/territory_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../logic/debug_conquest_controller.dart';
import '../quiz/quiz_screen.dart';
import 'widgets/map_display.dart';
import 'widgets/custom_location_pin.dart';
import 'widgets/normal_overlay.dart';
import 'widgets/conquest_hud.dart';
import 'widgets/debug_defense_selector.dart';
import 'logic/test_zone_logic.dart';

final ValueNotifier<bool> hideBarsNotifier = ValueNotifier<bool>(false);

class MapConquestScreen extends StatefulWidget {
  const MapConquestScreen({super.key});

  @override
  State<MapConquestScreen> createState() => _MapConquestScreenState();
}

class _MapConquestScreenState extends State<MapConquestScreen> with TickerProviderStateMixin {
  MapLibreMapController? _mapController;
  List<Map<String, dynamic>> _bases = [];
  bool _isStyleLoaded = false;
  bool _isConquestMode = false;
  Map<String, dynamic>? _userData;
  LatLng? _currentLocation;
  Offset _userMarkerOffset = Offset.zero;
  final loc.Location _locationService = loc.Location();
  
  Map<String, dynamic>? _nearbyBase;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchBases();
    _initLocation();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(_pulseController);
    
    hideBarsNotifier.addListener(_onToggleBars);
  }

  void _onToggleBars() {
    if (mounted) {
      setState(() {
        _isConquestMode = hideBarsNotifier.value;
      });
      _checkNearbyBases(); // Force le rafraîchissement immédiat des boutons
      if (_isConquestMode && _currentLocation != null) {
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 16.5));
      }
    }
  }

  @override
  void dispose() {
    hideBarsNotifier.removeListener(_onToggleBars);
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await _locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationService.requestService();
        if (!serviceEnabled) return;
      }

      loc.PermissionStatus permission = await _locationService.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await _locationService.requestPermission();
        if (permission != loc.PermissionStatus.granted) return;
      }

      // Vitesse maximale pour les tests
      await _locationService.changeSettings(accuracy: loc.LocationAccuracy.high, interval: 1000, distanceFilter: 1);

      _locationService.onLocationChanged.listen((data) {
        if (mounted && data.latitude != null) {
          setState(() {
            _currentLocation = LatLng(data.latitude!, data.longitude!);
          });
          _updateMarkerPosition();
          _checkNearbyBases();
        }
      });
      
      // Position initiale forcée si possible
      final initial = await _locationService.getLocation();
      if (initial.latitude != null) {
         setState(() {
            _currentLocation = LatLng(initial.latitude!, initial.longitude!);
          });
          _checkNearbyBases();
      }
    } catch (e) {}
  }

  void _checkNearbyBases() {
    final base = TestZoneLogic.getNearbyTestBase(_currentLocation, _bases);
    if (mounted) setState(() => _nearbyBase = base);
  }

  void _updateMarkerPosition() async {
    if (_mapController == null || _currentLocation == null) return;
    final pos = await _mapController!.toScreenLocation(_currentLocation!);
    if (mounted) setState(() => _userMarkerOffset = Offset(pos.x.toDouble(), pos.y.toDouble()));
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(AuthService.userKey);
    if (userJson != null) {
      final localUser = jsonDecode(userJson);
      final updatedUser = await UserService().getProfile(localUser['id']);
      if (updatedUser != null && mounted) {
        setState(() => _userData = updatedUser);
      } else {
        setState(() => _userData = localUser);
      }
    }
  }

  Future<void> _fetchBases() async {
    _bases = await TerritoryService().getAllBases();
    _displayBases();
  }

  void _displayBases() {
    if (_mapController == null || _bases.isEmpty || !_isStyleLoaded) return;
    _mapController!.clearFills();
    _mapController!.clearCircles();
    for (var b in _bases) {
      final center = LatLng(b['latitude'], b['longitude']);
      _mapController!.addFill(FillOptions(
        geometry: [createPentagonPoints(center, (b['conquest_radius_m'] as num).toDouble())],
        fillColor: b['owner_id'] != null ? Colors.green.toHex() : AppColors.primary.toHex(), 
        fillOpacity: 0.15,
      ));
      _mapController!.addCircle(CircleOptions(geometry: center, circleRadius: 6.0, circleColor: AppColors.secondary.toHex()));
    }
  }

  void _startHackSession() {
    if (_nearbyBase == null) return;

    if (_nearbyBase!['id'] == 0) {
      DebugDefenseSelector.show(context, (type) {
        final debugController = DebugConquestController();
        debugController.activeTestDefense = type;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              baseId: 0,
              baseName: "ZONE DE TEST",
              debugEffects: debugController.getActiveEffects(),
            ),
          ),
        ).then((_) => _loadUserData());
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            baseId: _nearbyBase!['id'],
            baseName: _nearbyBase!['name'],
          ),
        ),
      ).then((_) => _fetchBases());
    }
  }

  void _startBattleSession() {
    if (_nearbyBase == null) return;
    
    // Simulation d'un adversaire
    final dummyOpponent = {
      "id": 999,
      "username": "X-SHADOW",
      "avatar": "avatar_7.jpeg",
      "gold": 5000
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizBattleScreen(
          baseId: _nearbyBase!['id'] ?? 0,
          baseName: _nearbyBase!['name'] ?? "ZONE INCONNUE",
          opponentData: dummyOpponent,
        ),
      ),
    ).then((_) => _loadUserData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          MapDisplay(
            controller: _mapController, bases: _bases, isStyleLoaded: _isStyleLoaded,
            onMapCreated: (c) => _mapController = c,
            onStyleLoaded: () { _isStyleLoaded = true; _displayBases(); _updateMarkerPosition(); },
            onCameraMove: _updateMarkerPosition,
            onLocationUpdated: (loc) {
               _currentLocation = loc.position;
               _updateMarkerPosition();
               _checkNearbyBases();
            },
            styleString: "https://api.maptiler.com/maps/019ff69e-f86b-71eb-9174-7747851625cf/style.json?key=unUFY9uFBzpXNISNkIyg",
          ),
          
          if (_currentLocation != null && _userMarkerOffset != Offset.zero)
            CustomLocationPin(offset: _userMarkerOffset, animation: _pulseAnimation, avatar: _userData?['avatar']),
          
          if (_isConquestMode) ...[
            if (_nearbyBase != null) _buildActionButtons(),
          ] else
            NormalOverlay(animation: _pulseAnimation, onTap: () => hideBarsNotifier.value = true),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 60,
      left: 30,
      right: 30,
      child: Column(
        children: [
          GestureDetector(
            onTap: _startHackSession,
            child: _buildButton("HACKER ZONE", Colors.greenAccent),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _startBattleSession,
            child: _buildButton("SIMULER BATTLE", AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 15)],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2),
        ),
      ),
    );
  }
}
