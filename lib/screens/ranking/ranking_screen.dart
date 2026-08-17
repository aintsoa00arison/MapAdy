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
  List<Map<String, dynamic>> _players = [];
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
    
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(AuthService.userKey);
    if (userJson != null) {
      _currentUser = jsonDecode(userJson);
    }

    final leaderboard = await UserService().getLeaderboard();
    
    if (mounted) {
      setState(() {
        _players = leaderboard;
        int myIndex = _players.indexWhere((p) => p['id'] == _currentUser?['id']);
        _focusedIndex = myIndex != -1 ? myIndex : 0;
        _isLoading = false;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_players.isNotEmpty) {
          _controller.jumpToItem(_focusedIndex);
        }
      });
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

    // Gestion robuste de l'utilisateur actuel dans la liste
    Map<String, dynamic> myDataInList = {'rank_position': 0, 'username': '---', 'rank_title': 'ROOKIE'};
    if (_players.isNotEmpty) {
      myDataInList = _players.firstWhere(
        (p) => p['id'] == _currentUser?['id'],
        orElse: () => Map<String, dynamic>.from(_players[0]),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 110), 
              UserRankBanner(
                rank: myDataInList['rank_position'], 
                name: myDataInList['username'],
                rankTitle: myDataInList['rank_title'],
              ),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: _controller,
                  itemExtent: 100, // Taille réduite (anciennement 180)
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() => _focusedIndex = index);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: _players.length,
                    builder: (context, index) {
                      return RankingCard(
                        player: _players[index],
                        isFocused: index == _focusedIndex,
                        isCurrentUser: _players[index]['id'] == _currentUser?['id'],
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
