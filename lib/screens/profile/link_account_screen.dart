import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../theme/app_colors.dart';
import '../../services/user_service.dart';
import '../../widgets/cyber_toast.dart';

class LinkAccountScreen extends StatefulWidget {
  final int userId;
  const LinkAccountScreen({super.key, required this.userId});

  @override
  State<LinkAccountScreen> createState() => _LinkAccountScreenState();
}

class _LinkAccountScreenState extends State<LinkAccountScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  
  bool _isVerified = false;
  bool _codeSent = false;
  bool _isLoading = false;

  Future<void> _authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour modifier vos données sensibles',
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
      if (didAuthenticate && mounted) {
        setState(() => _isVerified = true);
        CyberToast.show(context, "IDENTITÉ VÉRIFIÉE.");
      }
    } catch (e) {
      if (mounted) {
        CyberToast.show(context, "ÉCHEC DE VÉRIFICATION.", isError: true);
      }
    }
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      if (mounted) CyberToast.show(context, "EMAIL INVALIDE.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final success = await UserService().sendVerificationCode(widget.userId, email);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        setState(() => _codeSent = true);
        CyberToast.show(context, "CODE DE VÉRIFICATION ENVOYÉ.");
      } else {
        CyberToast.show(context, "ERREUR LORS DE L'ENVOI DU CODE.", isError: true);
      }
    }
  }

  Future<void> _verifyAndSave() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      if (mounted) CyberToast.show(context, "CODE REQUIS.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final result = await UserService().verifyCodeAndUpdateEmail(
      widget.userId, 
      _emailController.text.trim(), 
      code
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (result != null) {
        CyberToast.show(context, "EMAIL MIS À JOUR AVEC SUCCÈS.");
        Navigator.pop(context);
      } else {
        CyberToast.show(context, "CODE INCORRECT OU EXPIRÉ.", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('LIER LE COMPTE', style: TextStyle(fontFamily: 'Anybody', fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (!_isVerified)
              _buildVerificationStep()
            else if (!_codeSent)
              _buildEmailStep()
            else
              _buildCodeStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      children: [
        const SizedBox(height: 50),
        const Icon(Icons.fingerprint, color: AppColors.secondary, size: 80),
        const SizedBox(height: 24),
        const Text('VÉRIFICATION REQUISE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('Utilisez votre empreinte ou code PIN pour déverrouiller cette option.', 
          textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _authenticate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('VÉRIFIER MON IDENTITÉ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NOUVELLE ADRESSE EMAIL', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'ENTREZ L\'EMAIL...',
              hintStyle: TextStyle(color: Colors.white24),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('ENVOYER LE CODE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VÉRIFICATION DU CODE', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Text('Un code a été envoyé à ${_emailController.text}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
          ),
          child: TextField(
            controller: _codeController,
            style: const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 20),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '******',
              hintStyle: TextStyle(color: Colors.white10, letterSpacing: 8),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyAndSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('VÉRIFIER ET METTRE À JOUR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _codeSent = false),
          child: const Text('MODIFIER L\'EMAIL', style: TextStyle(color: Colors.white24)),
        ),
      ],
    );
  }
}
