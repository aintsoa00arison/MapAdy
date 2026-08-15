import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/cyber_toast.dart';
import '../../main.dart';
import 'widgets/auth_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    final user = await _authService.loginWithGoogle();
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      CyberToast.show(context, "ACCÈS AUTORISÉ. BIENVENUE AGENT.");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RootNavigation()));
    } else if (mounted) {
      CyberToast.show(context, "ÉCHEC D'AUTHENTIFICATION. COMPTE INTROUVABLE ?", isError: true);
    }
  }

  Future<void> _handleRegister() async {
    if (_usernameController.text.trim().isEmpty) {
      CyberToast.show(context, "IDENTIFIANT REQUIS.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final user = await _authService.registerWithGoogle(_usernameController.text.trim());
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      CyberToast.show(context, "PROFIL CRÉÉ. BIENVENUE AU RÉSEAU.");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RootNavigation()));
    } else if (mounted) {
      CyberToast.show(context, "ERREUR LORS DE L'INSCRIPTION.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 50),
              AuthCard(
                isRegistering: _isRegistering,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    if (_isRegistering) _buildUsernameInput(),
                    if (_isLoading)
                      const CircularProgressIndicator(color: AppColors.primary)
                    else ...[
                      _buildMainButton(),
                      const SizedBox(height: 16),
                      _buildSwitchModeLink(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo_mapady.png',
          height: 120,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.terminal, color: AppColors.primary, size: 80),
        ),
        const SizedBox(height: 10),
        const Text(
          'MAPADY',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            fontFamily: 'Anybody',
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          _isRegistering ? 'CREATION DE PROFIL' : 'ACCÈS SYSTÈME',
          style: TextStyle(
            color: _isRegistering ? AppColors.secondary : AppColors.primary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          _isRegistering ? 'DÉFINISSEZ VOTRE\nIDENTITÉ AGENT' : 'BIENVENUE AGENT.\nVEUILLEZ ÉTABLIR\nLA CONNEXION...',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Anybody'),
        ),
      ],
    );
  }

  Widget _buildUsernameInput() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
          ),
          child: TextField(
            controller: _usernameController,
            style: const TextStyle(color: Colors.white, fontFamily: 'Anybody'),
            decoration: const InputDecoration(
              hintText: 'NOM D\'AGENT...',
              hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
              border: InputBorder.none,
              icon: Icon(Icons.chevron_right, color: AppColors.secondary, size: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMainButton() {
    final Color color = _isRegistering ? AppColors.secondary : AppColors.primary;
    return GestureDetector(
      onTap: _isRegistering ? _handleRegister : _handleLogin,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_isRegistering ? Icons.person_add : Icons.login, color: color, size: 18),
            const SizedBox(width: 10),
            Text(
              _isRegistering ? 'VALIDER INSCRIPTION' : 'SE CONNECTER',
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchModeLink() {
    return GestureDetector(
      onTap: () => setState(() => _isRegistering = !_isRegistering),
      child: Text(
        _isRegistering ? 'DÉJÀ UN COMPTE ? SE CONNECTER' : 'PAS DE COMPTE ? S\'INSCRIRE',
        style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
      ),
    );
  }
}
