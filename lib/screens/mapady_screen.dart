import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MapadyScreen extends StatelessWidget {
  const MapadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        'assets/images/city_map_bg.png', // Background stylisé fisheye
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.grid_4x4,
              size: MediaQuery.of(context).size.width,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
