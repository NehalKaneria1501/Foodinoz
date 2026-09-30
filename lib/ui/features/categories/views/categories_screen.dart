import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/quick_commerce_product_card.dart';
import '../../../../data/models/ingredient_model.dart';
import '../../../../data/services/quick_commerce_service.dart';
import '../../profile/views/profile_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const CategoriesScreen({super.key, this.onNavigateTab});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  IngredientCategory _selectedCategory = IngredientCategory.dairy;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categoryList = [
    {
      'category': IngredientCategory.dairy,
      'name': 'Dairy & Bread',
      'icon': Icons.egg_alt_outlined,
      'color': const Color(0xFF2196F3),
      'badge': '10 MINS',
    },
    {
      'category': IngredientCategory.vegetables,
      'name': 'Farm Veggies',
      'icon': Icons.eco_outlined,
      'color': const Color(0xFF4CAF50),
      'badge': 'FRESH',
    },
    {
      'category': IngredientCategory.spices,
      'name': 'Jeerola Spices',
      'icon': Icons.grain_outlined,
      'color': const Color(0xFFFF5722),
      'badge': 'ARTISAN',
    },
    {
      'category': IngredientCategory.pantry,
      'name': 'DMart Wholesale',
      'icon': Icons.inventory_2_outlined,
      'color': const Color(0xFF008848),
      'badge': 'MIN 33% OFF',
    },
    {
      'category': IngredientCategory.namkeenFarshan,
      'name': 'Munchies & Snacks',
      'icon': Icons.fastfood_outlined,
      'color': const Color(0xFFFF9800),
      'badge': 'CRUNCH',
    },
    {
      'category': IngredientCategory.beverages,
      'name': 'Drinks & Juices',
      'icon': Icons.local_drink_outlined,
      'color': const Color(0xFF9C27B0),
      'badge': 'CHILLED',
    },
    {
      'category': IngredientCategory.bakery,
      'name': 'Bakery & Toast',
      'icon': Icons.bakery_dining_outlined,
      'color': const Color(0xFF795548),
      'badge': 'DAILY',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final allProducts = QuickCommerceService.products;
    final filtered = allProducts.where((p) {
      final matchesCategory = p.category == _selectedCategory;
      if (_searchQuery.isEmpty) return matchesCategory;
      final q = _searchQuery.toLowerCase();
      return matchesCategory &&
          (p.title.toLowerCase().contains(q) || p.brand.toLowerCase().contains(q));
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GROCERY DEPARTMENTS & AISLES',
              style: AppTypography.metadata.copyWith(
                color: AppColors.secondary,
                letterSpacing: 1.2,
                fontSize: 10,
              ),
            ),
            Text(
              'Blinkit, Zepto, DMart & JioMart Store',
              style: AppTypography.headlineSm.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.primaryContainer : const Color(0xFFFFECE5),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: const Icon(Icons.person, size: 18, color: AppColors.primary),
            ),
            tooltip: 'User Profile & Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search within Department
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceContainer : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                boxShadow: isDark
                    ? null
                    : [
                        const BoxShadow(
                          color: Color(0x0C8A4B08),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search within departments...',
                        hintStyle: AppTypography.bodySm.copyWith(
                          color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                          fontSize: 12,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 16,
                        color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                      ),
                      onPressed: () => setState(() => _searchQuery = ''),
                    ),
                ],
              ),
            ),
          ),

          // Two-pane Browser: Left Categories List, Right Products Grid
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Navigation Rail (Blinkit / Zepto / BigBasket style)
                Container(
                  width: 90,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm,
                    border: Border(
                      right: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: _categoryList.length,
                    itemBuilder: (context, index) {
                      final item = _categoryList[index];
                      final cat = item['category'] as IngredientCategory;
                      final isSelected = _selectedCategory == cat;
                      final catColor = item['color'] as Color;

                      return InkWell(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.surfaceContainerHigh : Colors.white)
                                : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                width: 3.5,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? catColor.withValues(alpha: 0.25)
                                      : (isDark ? AppColors.surfaceContainer : Colors.white),
                                  shape: BoxShape.circle,
                                  border: isDark ? null : Border.all(color: AppColors.lightBorder, width: 0.8),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: isSelected
                                      ? (isDark ? catColor : AppColors.primary)
                                      : (isDark ? AppColors.outline : AppColors.lightTextSecondary),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['name'] as String,
                                style: AppTypography.metadata.copyWith(
                                  color: isSelected
                                      ? (isDark ? Colors.white : AppColors.primary)
                                      : (isDark ? AppColors.outline : AppColors.lightTextSecondary),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 9.5,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Right Pane: Product Grid
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.outline),
                              const SizedBox(height: 10),
                              Text('No products found in this aisle', style: AppTypography.bodySm),
                            ],
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final paneWidth = constraints.maxWidth;
                            final isCompact = paneWidth < 280;
                            final crossAxisCount = isCompact ? 1 : 2;
                            final childAspectRatio = isCompact ? 0.78 : 0.52;

                            return GridView.builder(
                              padding: const EdgeInsets.all(10),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: childAspectRatio,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final product = filtered[index];
                                return QuickCommerceProductCard(product: product);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
