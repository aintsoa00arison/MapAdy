import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../services/territory_service.dart';
import '../services/auth_service.dart';
import 'map_conquest/widgets/defense_modal.dart';

class TerritoryScreen extends StatefulWidget {
  const TerritoryScreen({super.key});

  @override
  State<TerritoryScreen> createState() => _TerritoryScreenState();
}

class _TerritoryScreenState extends State<TerritoryScreen> {
  List<Map<String, dynamic>> _ownedBases = [];
  bool _isLoading = true;
  int _userId = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AuthService.userKey);
    if (userJson != null) {
      final user = jsonDecode(userJson);
      _userId = user['id'];
      
      final bases = await TerritoryService().getOwnedBases(_userId);
      if (mounted) {
        setState(() {
          _ownedBases = bases;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 80),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildNotificationArea(),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
                  : _ownedBases.isEmpty 
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _ownedBases.length,
                        itemBuilder: (context, index) => _buildTerritoryCard(_ownedBases[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "${_ownedBases.length}",
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 48,
            fontWeight: FontWeight.w900,
            fontFamily: 'Anybody',
            shadows: [Shadow(color: AppColors.secondary, blurRadius: 20)],
          ),
        ),
        const Text(
          "TOTAL TERRITORIES CONTROLLED",
          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ],
    );
  }

  Widget _buildNotificationArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1425),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: AppColors.secondary, size: 16),
              SizedBox(width: 8),
              Text(
                "ALERT: System stable. No intrusion detected.",
                style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.security, color: AppColors.primary, size: 16),
              SizedBox(width: 8),
              Text(
                "REINFORCEMENT: Shields active in all sectors.",
                style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTerritoryCard(Map<String, dynamic> base) {
    final activeDefenses = base['active_defenses'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.hudDecoration.copyWith(
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
                ),
                child: const Icon(Icons.business, color: AppColors.secondary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      base['name'].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text("SYSTÈMES ACTIFS :", style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    if (activeDefenses.isEmpty)
                      const Text("AUCUNE DÉFENSE ACTIVÉE", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontStyle: FontStyle.italic))
                    else
                      Wrap(
                        spacing: 8,
                        children: activeDefenses.map((def) {
                          final gadget = def['gadget'];
                          return Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                            ),
                            child: Tooltip(
                              message: gadget['name'],
                              child: Image.asset(
                                'assets/skins/${gadget['image_url']}',
                                width: 20,
                                height: 20,
                                errorBuilder: (c, e, s) => const Icon(Icons.shield, color: AppColors.secondary, size: 16),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await DefenseModal.show(context, _userId, base['id'], base['name']);
                _loadData(); // Rafraîchir pour voir le nouveau gadget activé
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.secondary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text("PROTÉGER", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.flag_outlined, color: Colors.white24, size: 64),
        SizedBox(height: 16),
        Text("AUCUN TERRITOIRE SOUS CONTRÔLE", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
        Text("Partez à la conquête pour dominer Fianarantsoa.", style: TextStyle(color: Colors.white24, fontSize: 12), textAlign: TextAlign.center),
      ],
    );
  }
}
