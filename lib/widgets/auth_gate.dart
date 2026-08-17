import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../main.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isInitializing = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
    // On écoute le changement de session une seule fois pour la redirection
    UserSession.userNotifier.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    UserSession.userNotifier.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    final hasUser = UserSession.userNotifier.value != null;
    if (hasUser != _isLoggedIn) {
      setState(() {
        _isLoggedIn = hasUser;
      });
    }
  }

  Future<void> _checkSession() async {
    final user = await AuthService().getSavedSession();
    if (mounted) {
      setState(() {
        _isLoggedIn = user != null;
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Color(0xFF131318),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00F0FF))),
      );
    }

    // On retourne l'un ou l'autre. Flutter gérera la transition proprement.
    return _isLoggedIn ? const RootNavigation() : const LoginScreen();
  }
}
