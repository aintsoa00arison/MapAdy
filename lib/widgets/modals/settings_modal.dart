import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/audio_service.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsModal(),
    );
  }

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late double _musicVolume;
  late double _sfxVolume;
  bool _notifications = true;
  bool _haptic = true;

  @override
  void initState() {
    super.initState();
    _musicVolume = AudioService().musicVolume;
    _sfxVolume = AudioService().sfxVolume;
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.85),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSection(
                      title: 'CONTROLE AUDIO',
                      icon: Icons.volume_up_outlined,
                      children: [
                        _buildSliderRow('Musique de fond', _musicVolume, (v) {
                          setState(() => _musicVolume = v);
                          AudioService().setMusicVolume(v);
                        }),
                        _buildSliderRow('Effets Sonores', _sfxVolume, (v) {
                          setState(() => _sfxVolume = v);
                          AudioService().setSfxVolume(v);
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'PREFERENCES SYSTEME',
                      icon: Icons.settings_suggest_outlined,
                      children: [
                        _buildSwitchRow('Notifications Push', _notifications, (v) => setState(() => _notifications = v)),
                        _buildSwitchRow('Retour Haptique', _haptic, (v) => setState(() => _haptic = v)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Section Signature
                    _buildSignature(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignature() {
    return Column(
      children: [
        Divider(color: AppColors.primary.withValues(alpha: 0.1), thickness: 1),
        const SizedBox(height: 15),
        const Text(
          'DEVELOPED BY AGENTS',
          style: TextStyle(
            color: Colors.white24,
            fontSize: 8,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _nameTag('RANJA'),
            _nameTag('LANDRY'),
            _nameTag('HONTY'),
            _nameTag('AINTSOA'),
          ],
        ),
        const SizedBox(height: 15),
        const Text(
          'mapADy OS v1.0.1 © 2026',
          style: TextStyle(color: Colors.white10, fontSize: 7),
        ),
      ],
    );
  }

  Widget _nameTag(String name) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          fontFamily: 'Anybody',
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'PARAMETRES',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              shadows: [Shadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 10)],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.primary, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
              Text(
                '${(value * 100).toInt()}%',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: value,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
