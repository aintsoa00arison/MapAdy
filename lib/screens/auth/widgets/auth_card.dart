import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../ranking/widgets/user_rank_banner.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  final bool isRegistering;

  const AuthCard({super.key, required this.child, required this.isRegistering});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: isRegistering ? 480 : 380,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipPath(
            clipper: BannerClipper(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (isRegistering ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.15),
                    AppColors.background,
                  ],
                ),
                border: Border.all(
                  color: (isRegistering ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: child,
          ),
        ],
      ),
    );
  }
}
