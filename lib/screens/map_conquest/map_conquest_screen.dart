import 'dart:convert';
import 'package:flutter/material.dart';
import '../quiz_battle/quiz_battle_screen.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_colors.dart';
import '../../services/territory_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../quiz/quiz_screen.dart';
import 'widgets/map_display.dart';
import 'widgets/normal_overlay.dart';
import 'logic/test_zone_logic.dart';
import '../../services/api_client.dart';

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
  bool _isFollowingUser = true; 
  
  Map<String, dynamic>? _nearestBase;
  bool _isInRange = false;
  double _currentAccuracy = 0.0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _btnController;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchBases();
    _requestPermission(); // Vérification des permissions au démarrage
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(_pulseController);
    _btnController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    hideBarsNotifier.addListener(_onToggleBars);
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.background,
            title: const Text("GPS REQUIS", style: TextStyle(color: AppColors.primary)),
            content: const Text("MapAdy a besoin de votre position pour détecter les secteurs à conquérir.", style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => openAppSettings(), child: const Text("PARAMÈTRES")),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
            ],
          ),
        );
      }
    }
  }

  void _onToggleBars() {
    if (mounted) {
      setState(() {
        _isConquestMode = hideBarsNotifier.value;
        if (_isConquestMode) _isFollowingUser = true;
      });
      _checkNearbyBases();
    }
  }

  @override
  void dispose() {
    hideBarsNotifier.removeListener(_onToggleBars);
    _pulseController.dispose();
    _btnController.dispose();
    super.dispose();
  }

  void _onNativeLocationUpdated(UserLocation location) {
    if (!mounted) return;

    final newPos = location.position;
    final accuracy = location.horizontalAccuracy ?? 999.0;

    setState(() {
      if (_currentLocation == null) {
        _currentLocation = newPos; 
      } else {
        final weight = accuracy < 15 ? 0.7 : (accuracy < 30 ? 0.4 : 0.15);
        _currentLocation = LatLng(
          _currentLocation!.latitude + (newPos.latitude - _currentLocation!.latitude) * weight,
          _currentLocation!.longitude + (newPos.longitude - _currentLocation!.longitude) * weight,
        );
      }
      _currentAccuracy = accuracy;
    });

    _checkNearbyBases();
  }

  void _checkNearbyBases() {
    final base = TestZoneLogic.getNearbyBase(_currentLocation, _bases);
    if (mounted) {
      setState(() {
        _nearestBase = base;
        if (base != null) {
          double dist = base['current_distance'] ?? 999.0;
          double radius = (base['conquest_radius_m'] as num).toDouble();
          _isInRange = dist <= radius;
        } else {
          _isInRange = false;
        }
      });
      if (_isInRange) _btnController.forward(); else _btnController.reverse();
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(AuthService.userKey);
    if (userJson != null) {
      final localUser = jsonDecode(userJson);
      UserService().getProfile(localUser['id']).then((updatedUser) {
        if (updatedUser != null && mounted) {
          setState(() => _userData = updatedUser);
        }
      });
      setState(() => _userData = localUser);
    }
  }

  Future<void> _fetchBases() async {
    try {
      final fetched = await TerritoryService().getAllBases();
      if (mounted) {
        setState(() {
          _bases = fetched;
        });
        if (_isStyleLoaded) _displayBases();
      }
    } catch (e) {
      debugPrint("DEBUG ERROR : Echec fetch bases: $e");
    }
  }

  void _displayBases() {
    if (_mapController == null || _bases.isEmpty || !_isStyleLoaded) return;
    _mapController!.clearFills();
    _mapController!.clearCircles();
    for (var b in _bases) {
      final center = LatLng(b['latitude'], b['longitude']);
      final zoneColor = b['owner_id'] != null ? AppColors.territoryOwned : AppColors.primary;
      _mapController!.addFill(FillOptions(
        geometry: [createPentagonPoints(center, (b['conquest_radius_m'] as num).toDouble())],
        fillColor: zoneColor.toHex(), fillOpacity: 0.2
      ));
      _mapController!.addCircle(CircleOptions(geometry: center, circleRadius: 6.0, circleColor: zoneColor.toHex(), circleOpacity: 0.9));
    }
  }

  void _initiateHack() async {
    if (_nearestBase == null || _userData == null) return;
    final response = await ApiClient().post("/bases/${_nearestBase!['id']}/check-in", {"user_id": _userData!['id']});
    final data = jsonDecode(response.body);
    if (data['status'] == "OPPONENT_FOUND") {
      _showBattleInvite(data['opponent']);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(baseId: _nearestBase!['id'], baseName: _nearestBase!['name']))).then((_) => _fetchBases());
    }
  }

  void _showBattleInvite(Map<String, dynamic> opponent) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.secondary, width: 2)),
        title: const Text("CONFLIT RÉSEAU", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(radius: 30, backgroundImage: AssetImage("assets/avatar/${opponent['avatar']}")),
          const SizedBox(height: 12),
          Text("${opponent['username']} est sur zone !", style: const TextStyle(color: Colors.white, fontSize: 14)),
          const Text("Accepter le duel ?", style: TextStyle(color: Colors.white54, fontSize: 10)),
        ]),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); _launchQuiz(solo: true); }, child: const Text("REFUSER (SOLO)", style: TextStyle(color: Colors.white24))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary), onPressed: () { Navigator.pop(context); _launchQuiz(solo: false, opponent: opponent); }, child: const Text("DUEL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _launchQuiz({required bool solo, Map<String, dynamic>? opponent}) {
    if (solo) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(baseId: _nearestBase!['id'], baseName: _nearestBase!['name']))).then((_) => _fetchBases());
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => QuizBattleScreen(baseId: _nearestBase!['id'], baseName: _nearestBase!['name'], opponentData: opponent!))).then((_) => _fetchBases());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Listener(
            onPointerDown: (_) { if (_isFollowingUser) setState(() => _isFollowingUser = false); },
            behavior: HitTestBehavior.translucent,
            child: MapDisplay(
              controller: _mapController, 
              bases: _bases, 
              isStyleLoaded: _isStyleLoaded,
              isFollowingUser: _isFollowingUser,
              onMapCreated: (c) => _mapController = c,
              onStyleLoaded: () { 
                _isStyleLoaded = true; 
                _displayBases(); 
              },
              onLocationUpdated: _onNativeLocationUpdated,
              styleString: "https://api.maptiler.com/maps/019ff69e-f86b-71eb-9174-7747851625cf/style.json?key=unUFY9uFBzpXNISNkIyg",
            ),
          ),
          if (_isConquestMode) ...[
            _buildRecenterButton(),
            _buildDistanceHUD(),
            if (_isInRange) _buildHackButton(),
          ] else
            NormalOverlay(animation: _pulseAnimation, onTap: () => hideBarsNotifier.value = true),
        ],
      ),
    );
  }

  Widget _buildDistanceHUD() {
    String message = "SCAN RÉSEAU...";
    Color textColor = AppColors.primary;

    if (_currentAccuracy > 30) {
      message = "SIGNAL GPS FAIBLE... PRÉCISION: ${_currentAccuracy.toInt()}M";
      textColor = Colors.orangeAccent;
    } else if (_nearestBase != null) {
      double dist = _nearestBase!['current_distance'] ?? 0.0;
      message = dist > 1000 ? "CIBLE À ${(dist/1000).toStringAsFixed(1)} KM" : "CIBLE À ${dist.toInt()} M";
    }

    return Positioned(bottom: 110, left: 30, right: 30, child: Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(10), border: Border.all(color: textColor.withValues(alpha: 0.3))), child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))));
  }

  Widget _buildRecenterButton() {
    return Positioned(
      right: 20, 
      bottom: 160, 
      child: FloatingActionButton(
        mini: true, 
        backgroundColor: AppColors.background.withValues(alpha: 0.8), 
        onPressed: () => setState(() => _isFollowingUser = true), 
        child: Icon(Icons.my_location, color: _isFollowingUser ? AppColors.primary : Colors.white54)
      ),
    );
  }

  Widget _buildHackButton() {
    return Positioned(bottom: 40, left: 30, right: 30, child: FadeTransition(opacity: _btnController, child: ScaleTransition(scale: _btnController, child: GestureDetector(onTap: _initiateHack, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.primary, width: 2), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 15)]), child: Center(child: Text("HACKER ${_nearestBase!['name']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2))))))));
  }
}
