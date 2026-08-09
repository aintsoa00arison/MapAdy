import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../main.dart';

/// Un middleware/gate qui vérifie la session au démarrage
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return FutureBuilder<Map<String, dynamic>?>(
      future: authService.getSavedSession(),
      builder: (context, snapshot) {
        // En attente de la lecture des SharedPreferences
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF131318),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
            ),
          );
        }

        // Si on a une session, on va vers l'app, sinon vers Login
        if (snapshot.hasData && snapshot.data != null) {
          return const RootNavigation();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
