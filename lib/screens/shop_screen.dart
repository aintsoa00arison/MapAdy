import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/shop_service.dart';
import 'shop/widgets/shop_card.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ShopService _shopService = ShopService();
  List<dynamic> _gadgets = [];
  List<dynamic> _avatars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShopData();
  }

  Future<void> _fetchShopData() async {
    setState(() => _isLoading = true);
    final gadgets = await _shopService.getGadgets();
    final avatars = await _shopService.getAvatars();
    
    if (mounted) {
      setState(() {
        _gadgets = gadgets ?? [];
        _avatars = avatars ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchShopData,
        color: AppColors.primary,
        backgroundColor: AppColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 110, 0, 100),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, 'GADGETS', Icons.settings_input_component),
              const SizedBox(height: 20),
              _buildShopList(
                items: _gadgets,
                category: 'GADGETS',
              ),
              
              const SizedBox(height: 40),
              
              _buildSectionHeader(context, 'AVATARS', Icons.person),
              const SizedBox(height: 20),
              _buildShopList(
                items: _avatars,
                category: 'AVATARS',
              ),
            ],
          ),
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

  Widget _buildShopList({required List<dynamic> items, required String category}) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text("AUCUN ARTICLE DISPONIBLE", style: TextStyle(color: Colors.white10, fontSize: 12)),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ShopCard(
            itemId: item['id'],
            name: item['name'],
            description: item['description'] ?? '',
            price: item['price'],
            imagePath: item['image_url'] ?? '',
            category: category,
            isSpecial: category == 'AVATARS',
          );
        },
      ),
    );
  }
}
