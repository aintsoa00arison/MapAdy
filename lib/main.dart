import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'widgets/top_bar/top_bar.dart';
import 'widgets/bottom_bar/bottom_bar.dart';
import 'screens/map_conquest/map_conquest_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/ranking/ranking_screen.dart';
import 'screens/territory_screen.dart';
import 'widgets/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MapAdyApp());
}

class MapAdyApp extends StatelessWidget {
  const MapAdyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mapADy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cyberNoirTheme,
      home: const AuthGate(),
    );
  }
}

class RootNavigation extends StatefulWidget {
  const RootNavigation({super.key});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  int _currentIndex = 0;
  Map<String, dynamic>? _userData;

  final List<Widget> _screens = [
    const MapConquestScreen(),
    const ShopScreen(),
    const RankingScreen(),
    const TerritoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    navigationNotifier.addListener(_onNavigationRequest);
  }

  @override
  void dispose() {
    navigationNotifier.removeListener(_onNavigationRequest);
    super.dispose();
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(AuthService.userKey);
    if (userJson != null) {
      setState(() {
        _userData = jsonDecode(userJson);
      });
      _refreshUserData();
    }
  }

  Future<void> _refreshUserData() async {
    if (_userData != null) {
      final updatedUser = await UserService().getProfile(_userData!['id']);
      if (updatedUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AuthService.userKey, jsonEncode(updatedUser));
        if (mounted) {
          setState(() {
            _userData = updatedUser;
          });
        }
      }
    }
  }

  void _onNavigationRequest() {
    setState(() {
      _currentIndex = navigationNotifier.value;
    });
    _refreshUserData();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: hideBarsNotifier,
      builder: (context, hideBars, child) {
        return Scaffold(
          body: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),

              // Top Bar : TOUJOURS visible, avec bouton retour en mode conquête
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: TopBar(
                    username: _userData?['username'] ?? 'AGENT',
                    gold: _userData?['gold'] ?? 0,
                    avatarPath: _userData?['avatar'] ?? 'avatar_1.jpeg',
                    onProfileReturn: _refreshUserData,
                    showBackButton: hideBars,
                    onBack: () {
                      hideBarsNotifier.value = false;
                    },
                  ),
                ),
              ),

              // Seule la Bottom Bar disparaît
              if (!hideBars)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CyberBottomBar(
                    activeIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
