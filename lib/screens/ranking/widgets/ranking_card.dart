import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class RankingCard extends StatelessWidget {
  final int rank;
  final String name;
  final int wins;
  final int points;
  final String avatar;
  final bool isCurrentUser;
  final bool isTopOne;
  final bool isFocused;

  const RankingCard({
    super.key,
    required this.rank,
    required this.name,
    required this.wins,
    required this.points,
    required this.avatar,
    this.isCurrentUser = false,
    this.isTopOne = false,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    Color highlightColor;
    if (isCurrentUser) {
      highlightColor = AppColors.secondary;
    } else if (isFocused) {
      highlightColor = AppColors.primary;
    } else {
      highlightColor = Colors.white24;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isFocused 
            ? highlightColor.withValues(alpha: 0.1) 
            : Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: highlightColor.withValues(alpha: isFocused ? 0.8 : 0.1),
          width: isFocused ? 2 : 1,
        ),
        boxShadow: isFocused ? [
          BoxShadow(
            color: highlightColor.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 1,
          )
        ] : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 25,
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
          
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isFocused ? highlightColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black,
              backgroundImage: AssetImage(avatar),
              child: ClipOval(
                child: Image.asset(
                  avatar,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                    Icon(Icons.person, color: highlightColor, size: 20),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Name and Wins - Fixed with Flexible to avoid overflow
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
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.close, 
                      color: isFocused ? highlightColor.withValues(alpha: 0.7) : Colors.white10, 
                      size: 12
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '$wins Victoires',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isFocused ? highlightColor.withValues(alpha: 0.7) : Colors.white10, 
                          fontSize: 10,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),

          // Points Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: highlightColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  points.toString(),
                  style: TextStyle(
                    color: isFocused ? highlightColor : Colors.white30,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.monetization_on,
                  color: highlightColor,
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
