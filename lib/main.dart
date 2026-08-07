import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/top_bar/top_bar.dart';
import 'widgets/bottom_bar/bottom_bar.dart';
import 'screens/mapady_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/ranking/ranking_screen.dart';
import 'screens/territory_screen.dart';

void main() {
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
      home: const RootNavigation(),
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

  final List<Widget> _screens = [
    const MapadyScreen(),
    const ShopScreen(),
    const RankingScreen(),
    const TerritoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Listen to global navigation requests
    navigationNotifier.addListener(_onNavigationRequest);
  }

  @override
  void dispose() {
    navigationNotifier.removeListener(_onNavigationRequest);
    super.dispose();
  }

  void _onNavigationRequest() {
    setState(() {
      _currentIndex = navigationNotifier.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Body Content
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Top Bar (Always visible and overlaying)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: TopBar(),
            ),
          ),

          // Bottom Bar (Always visible)
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
  }
}
