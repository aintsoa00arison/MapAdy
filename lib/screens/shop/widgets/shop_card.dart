import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/modals/purchase_modal.dart';

class ShopCard extends StatelessWidget {
  final String name;
  final String description;
  final int price;
  final String imagePath;
  final String category;
  final bool isSpecial;

  const ShopCard({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.category,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainColor = isSpecial ? AppColors.secondary : AppColors.primary;

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: mainColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      category == 'GADGETS' ? Icons.settings_input_component : Icons.person,
                      color: mainColor.withValues(alpha: 0.4),
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Info Area
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Anybody',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$price',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.monetization_on, color: mainColor, size: 14),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => PurchaseModal.show(
                          context, 
                          itemName: name, 
                          price: price, 
                          category: category
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: mainColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: mainColor.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            'ACHETER',
                            style: TextStyle(
                              color: mainColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
