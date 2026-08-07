import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'shop/widgets/shop_card.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 110, 0, 100), // Padding haut important pour laisser la place au TopBar
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
      height: 240,
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
