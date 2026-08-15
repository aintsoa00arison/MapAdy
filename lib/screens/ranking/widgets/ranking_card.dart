import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class RankingCard extends StatelessWidget {
  final Map<String, dynamic> player;
  final bool isFocused;
  final bool isCurrentUser;

  const RankingCard({
    super.key,
    required this.player,
    this.isFocused = false,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final int rank = player['rank_position'] ?? 0;
    final String name = player['username'] ?? 'AGENT';
    final int wins = player['quiz_victories'] ?? 0;
    final int points = player['gold'] ?? 0;
    final String avatarUrl = "assets/avatar/${player['avatar'] ?? 'avatar_1.jpeg'}";

    Color highlightColor;
    if (isCurrentUser) {
      highlightColor = AppColors.secondary;
    } else if (isFocused) {
      highlightColor = AppColors.primary;
    } else {
      highlightColor = Colors.white10;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isFocused 
            ? highlightColor.withValues(alpha: 0.15) 
            : Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: highlightColor.withValues(alpha: 0.8),
          width: isFocused ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            rank.toString(),
            style: TextStyle(
              color: isFocused ? highlightColor : Colors.white30,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'Anybody',
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(avatarUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isFocused ? highlightColor : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$wins Hacks réussis',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            "$points CC",
            style: TextStyle(
              color: isFocused ? highlightColor : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
