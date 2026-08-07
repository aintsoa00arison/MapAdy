import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'widgets/ranking_card.dart';
import 'widgets/user_rank_banner.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final FixedExtentScrollController _controller = FixedExtentScrollController(initialItem: 4);
  int _focusedIndex = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> players = [
      {'rank': 1, 'name': 'CYBER_NINJA', 'wins': 142, 'points': 9999, 'avatar': 'assets/avatar/avatar_2.jpeg', 'isTop': true},
      {'rank': 2, 'name': 'SHADOW_WALKER', 'wins': 128, 'points': 8450, 'avatar': 'assets/avatar/avatar_3.jpeg', 'isTop': false},
      {'rank': 3, 'name': 'STEALTH_PUNK', 'wins': 132, 'points': 5100, 'avatar': 'assets/avatar/avatar_4.jpeg', 'isTop': false},
      {'rank': 4, 'name': 'NEON_GHOST', 'wins': 128, 'points': 4850, 'avatar': 'assets/avatar/avatar_5.jpeg', 'isTop': false},
      {'rank': 5, 'name': 'COMMANDER_NEON', 'wins': 125, 'points': 4720, 'avatar': 'assets/avatar/avatar_1.jpeg', 'isTop': false, 'isMe': true},
      {'rank': 6, 'name': 'VOID_RUNNER', 'wins': 122, 'points': 4600, 'avatar': 'assets/avatar/avatar_6.jpeg', 'isTop': false},
      {'rank': 7, 'name': 'GLITCH_KING', 'wins': 119, 'points': 4450, 'avatar': 'assets/avatar/avatar_7.jpeg', 'isTop': false},
      {'rank': 8, 'name': 'DATA_BREAKER', 'wins': 95, 'points': 3900, 'avatar': 'assets/avatar/avatar_8.jpeg', 'isTop': false},
      {'rank': 9, 'name': 'CODE_PHANTOM', 'wins': 88, 'points': 3200, 'avatar': 'assets/avatar/avatar_9.jpeg', 'isTop': false},
      {'rank': 10, 'name': 'BIO_HACKER', 'wins': 75, 'points': 2800, 'avatar': 'assets/avatar/avatar_10.jpeg', 'isTop': false},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'CLASSEMENT',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 20,
            shadows: [Shadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 10)],
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              const UserRankBanner(rank: 5, name: 'COMMANDER_NEON'),
              
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
                child: ListWheelScrollView.useDelegate(
                  controller: _controller,
                  itemExtent: 90, // Hauteur fixe pour chaque carte
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.002,
                  diameterRatio: 2.5,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _focusedIndex = index;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: players.length,
                    builder: (context, index) {
                      final player = players[index];
                      final isFocused = _focusedIndex == index;
                      
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
                                rank: player['rank'],
                                name: player['name'],
                                wins: player['wins'],
                                points: player['points'],
                                avatar: player['avatar'],
                                isCurrentUser: player['isMe'] ?? false,
                                isTopOne: player['isTop'] ?? false,
                                isFocused: isFocused, // Nouveau paramètre pour forcer le style
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 100), // Espace pour la bottom bar
            ],
          ),
        ],
      ),
    );
  }
}
