import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import 'widgets/ranking_card.dart';
import 'widgets/user_rank_banner.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late FixedExtentScrollController _controller;
  int _focusedIndex = 0;
  List<dynamic> _players = [];
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    // 1. Charger l'utilisateur local pour savoir qui est "Moi"
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(AuthService.userKey);
    if (userJson != null) {
      _currentUser = jsonDecode(userJson);
    }

    // 2. Récupérer le classement depuis le serveur
    final leaderboard = await UserService().getLeaderboard();
    
    if (leaderboard != null) {
      // Trouver l'index de l'utilisateur actuel dans le classement
      int myIndex = leaderboard.indexWhere((p) => p['id'] == _currentUser?['id']);
      
      setState(() {
        _players = leaderboard;
        _focusedIndex = myIndex != -1 ? myIndex : 0;
        _isLoading = false;
        _controller = FixedExtentScrollController(initialItem: _focusedIndex);
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // Infos pour la bannière du haut (basées sur l'utilisateur actuel dans la liste)
    final myDataInList = _players.firstWhere(
      (p) => p['id'] == _currentUser?['id'], 
      orElse: () => _players.isNotEmpty ? _players[0] : {'rank_position': 0, 'username': '---'}
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 110), 
              UserRankBanner(
                rank: myDataInList['rank_position'], 
                name: myDataInList['username']
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOP TERRITOIRE', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, color: Colors.white38)),
                    Text('SAISON 4', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, color: Colors.white38)),
                  ],
                ),
              ),

              Expanded(
                child: _players.isEmpty 
                ? const Center(child: Text("AUCUNE DONNÉE", style: TextStyle(color: Colors.white24)))
                : ListWheelScrollView.useDelegate(
                  controller: _controller,
                  itemExtent: 85, 
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.002,
                  diameterRatio: 2.5,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _focusedIndex = index;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: _players.length,
                    builder: (context, index) {
                      final player = _players[index];
                      final isFocused = _focusedIndex == index;
                      final isMe = player['id'] == _currentUser?['id'];
                      
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: AnimatedScale(
                            scale: isFocused ? 1.05 : 0.85,
                            duration: const Duration(milliseconds: 200),
                            child: AnimatedOpacity(
                              opacity: isFocused ? 1.0 : 0.5,
                              duration: const Duration(milliseconds: 200),
                              child: RankingCard(
                                rank: player['rank_position'],
                                name: player['username'],
                                wins: player['quiz_victories'],
                                points: player['gold'],
                                avatar: player['avatar'],
                                isCurrentUser: isMe,
                                isTopOne: player['rank_position'] == 1,
                                isFocused: isFocused,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ],
      ),
    );
  }
}
