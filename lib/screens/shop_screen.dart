import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'shop/widgets/shop_card.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'BOUTIQUE',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 20,
                shadows: [
                  Shadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 10)
                ],
              ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '1 250',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.monetization_on, color: AppColors.primary, size: 14),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 0, 100), // Left padding only to allow cards to reach right edge
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'GADGETS', Icons.settings_input_component),
            const SizedBox(height: 20),
            _buildShopList(
              items: [
                {
                  'name': 'Scanner EM',
                  'desc': 'Révèle les secrets cachés dans un rayon de 500m. Idéal pour les zones urbaines.',
                  'price': 450,
                  'image': 'assets/images/scanner.png',
                },
                {
                  'name': 'Clé Master',
                  'desc': 'Permet d\'ouvrir des terminaux cryptés uniques dans les secteurs protégés.',
                  'price': 850,
                  'image': 'assets/images/key.png',
                },
              ],
              category: 'GADGETS',
            ),
            
            const SizedBox(height: 40),
            
            _buildSectionHeader(context, 'AVATARS', Icons.person),
            const SizedBox(height: 20),
            _buildShopList(
              items: [
                {
                  'name': 'Ghost Protocol',
                  'desc': 'Infiltration niveau 40. Un look inspiré des nettoyeurs des bas-fonds.',
                  'price': 2500,
                  'image': 'assets/avatar/avatar_6.jpeg',
                  'special': true,
                },
                {
                  'name': 'Urbex Ninja',
                  'desc': 'Vêtements techniques haute résistance pour escalade urbaine.',
                  'price': 1200,
                  'image': 'assets/avatar/avatar_7.jpeg',
                },
              ],
              category: 'AVATARS',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildShopList({required List<Map<String, dynamic>> items, required String category}) {
    return SizedBox(
      height: 240, // Height of the card area
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ShopCard(
            name: item['name'],
            description: item['desc'],
            price: item['price'],
            imagePath: item['image'],
            category: category,
            isSpecial: item['special'] ?? false,
          );
        },
      ),
    );
  }
}
