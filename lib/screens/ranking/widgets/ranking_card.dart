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
    final int territories = player['territories_captured'] ?? 0;
    final String rankTitle = player['rank_title'] ?? 'ROOKIE';
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          // RANG NUMERIQUE
          SizedBox(
            width: 30,
            child: Text(
              rank.toString(),
              style: TextStyle(
                color: isFocused ? highlightColor : Colors.white30,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                fontFamily: 'Anybody',
              ),
            ),
          ),
          
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(avatarUrl),
          ),
          const SizedBox(width: 12),
          
          // INFOS AGENT
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
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  rankTitle,
                  style: TextStyle(
                    color: isFocused ? highlightColor.withValues(alpha: 0.7) : AppColors.primary.withValues(alpha: 0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          
          // STATS (MISSIONS & TERRITOIRES)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, color: AppColors.primary, size: 10),
                  const SizedBox(width: 4),
                  Text(
                    "$wins HACKS",
                    style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.flag, color: AppColors.secondary, size: 10),
                  const SizedBox(width: 4),
                  Text(
                    "$territories ZONES",
                    style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
