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
import 'services/audio_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  await AudioService().init();
  await NotificationService().init();
  AudioService().startBGM();

  runApp(const MapAdyApp());
}

class MapAdyApp extends StatefulWidget {
  const MapAdyApp({super.key});

  @override
  State<MapAdyApp> createState() => _MapAdyAppState();
}

class _MapAdyAppState extends State<MapAdyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      AudioService().pauseBGM();
    } else if (state == AppLifecycleState.resumed) {
      AudioService().resumeBGM();
    }
  }

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

  Widget _getSelectedScreen(int index) {
    switch (index) {
      case 0: return const MapConquestScreen();
      case 1: return const ShopScreen();
      case 2: return const RankingScreen();
      case 3: return const TerritoryScreen();
      default: return const MapConquestScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    _userData = UserSession.userNotifier.value;
    navigationNotifier.addListener(_onNavigationRequest);
    _refreshUserData();
    
    NotificationService().showNotification(
      id: 0,
      title: "SYSTÈME EN LIGNE",
      body: "Connexion sécurisée établie. Prêt pour la conquête, Agent.",
    );
  }

  @override
  void dispose() {
    navigationNotifier.removeListener(_onNavigationRequest);
    super.dispose();
  }

  Future<void> _refreshUserData() async {
    final user = UserSession.userNotifier.value;
    if (user != null) {
      UserService().getProfile(user['id']).then((updatedUser) {
        if (updatedUser != null && mounted) {
          UserSession.setUser(updatedUser);
          setState(() => _userData = updatedUser);
        }
      });
    }
  }

  void _onNavigationRequest() {
    if (mounted) {
      setState(() {
        _currentIndex = navigationNotifier.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: hideBarsNotifier,
      builder: (context, hideBars, child) {
        return Scaffold(
          body: Stack(
            children: [
              _getSelectedScreen(_currentIndex),
              Positioned(
                top: 0, left: 0, right: 0,
                child: SafeArea(
                  child: ValueListenableBuilder<Map<String, dynamic>?>(
                    valueListenable: UserSession.userNotifier,
                    builder: (context, user, child) {
                      return TopBar(
                        username: user?['username'] ?? 'AGENT',
                        gold: user?['gold'] ?? 0,
                        avatarPath: user?['avatar'] ?? 'avatar_1.jpeg',
                        onProfileReturn: _refreshUserData,
                        showBackButton: hideBars,
                        onBack: () => hideBarsNotifier.value = false,
                      );
                    },
                  ),
                ),
              ),
              if (!hideBars)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: CyberBottomBar(
                    activeIndex: _currentIndex,
                    onTap: (index) => setState(() => _currentIndex = index),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
