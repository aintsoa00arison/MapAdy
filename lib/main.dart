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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Body Content
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Top Bar (Always visible)
          // Hide TopBar on Ranking for specific look or keep it? 
          // User wanted TopBar visible in previous steps, but Ranking has its own AppBar.
          // Let's keep it consistent: RankingScreen now doesn't need its own AppBar if Root handles it.
          if (_currentIndex != 2) // Optional: hide standard top bar on Ranking if preferred
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
