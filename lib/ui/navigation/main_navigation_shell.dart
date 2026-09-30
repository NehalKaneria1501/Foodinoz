import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/quick_commerce_cart_bottom_bar.dart';
import '../features/categories/views/categories_screen.dart';
import '../features/help/views/help_support_screen.dart';
import '../features/home/views/home_screen.dart';
import '../features/recipes/views/recipe_catalog_screen.dart';
import '../features/shopping_list/view_models/shopping_list_view_model.dart';
import '../features/shopping_list/views/shopping_list_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialTab;

  const MainNavigationShell({super.key, this.initialTab = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shoppingVm = context.watch<ShoppingListViewModel>();
    final cartItemCount = shoppingVm.totalItemCount;

    final screens = [
      HomeScreen(onNavigateTab: _onTabChanged),
      const RecipeCatalogScreen(),
      CategoriesScreen(onNavigateTab: _onTabChanged),
      const ShoppingListScreen(),
      const HelpSupportScreen(),
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBg = isDark ? AppColors.surfaceBlack : Colors.white;
    final navBorder = isDark ? AppColors.gridLine : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // Floating Quick Commerce Cart Bar (Only when items in cart and not already on cart tab)
          if (_currentIndex != 3 && cartItemCount > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: QuickCommerceCartBottomBar(
                  onViewCartPressed: () => _onTabChanged(3),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: navBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabChanged,
          type: BottomNavigationBarType.fixed,
          backgroundColor: navBg,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDark ? AppColors.outline : AppColors.lightTextSecondary,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle: AppTypography.metadata.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: AppTypography.metadata.copyWith(
            color: isDark ? AppColors.outline : AppColors.lightTextSecondary,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'HOME',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu),
              label: 'KITCHEN',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'AISLES',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_bag_outlined),
                  if (cartItemCount > 0)
                    Positioned(
                      right: -8,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$cartItemCount',
                          style: AppTypography.metadata.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_bag),
                  if (cartItemCount > 0)
                    Positioned(
                      right: -8,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$cartItemCount',
                          style: AppTypography.metadata.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: 'CART',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.help_outline),
              activeIcon: Icon(Icons.help),
              label: 'HELP',
            ),
          ],
        ),
      ),
    );
  }
}
