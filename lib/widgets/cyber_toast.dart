import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CyberToast {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isError ? Colors.redAccent : AppColors.primary,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isError ? Colors.redAccent : AppColors.primary).withValues(alpha: 0.3),
                blurRadius: 10,
              )
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? Colors.redAccent : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: isError ? Colors.redAccent : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Anybody',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
