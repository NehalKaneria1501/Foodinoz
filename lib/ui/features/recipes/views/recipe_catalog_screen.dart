import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_card.dart';
import '../../../../core/widgets/pouch_badge.dart';
import '../../../../data/models/ingredient_model.dart';
import '../../../../data/models/recipe_model.dart';
import '../../../../data/services/packaged_ingredients_service.dart';
import '../../../../data/repositories/cooking_repository.dart';
import '../../gamification/views/challenges_hub_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../shopping_list/view_models/shopping_list_view_model.dart';
import '../view_models/recipe_view_model.dart';
import 'recipe_detail_screen.dart';

/// Available packet weight tiers for all categorized ingredients, snacks, sweets & masalas
class MasalaPackTier {
  final String label;
  final double weightGrams;
  final double priceMultiplier;

  const MasalaPackTier({
    required this.label,
    required this.weightGrams,
    required this.priceMultiplier,
  });

  static const List<MasalaPackTier> tiers = [
    MasalaPackTier(label: '100g', weightGrams: 100, priceMultiplier: 1.0),
    MasalaPackTier(label: '250g', weightGrams: 250, priceMultiplier: 2.3),
    MasalaPackTier(label: '500g', weightGrams: 500, priceMultiplier: 4.3),
    MasalaPackTier(label: '750g', weightGrams: 750, priceMultiplier: 6.2),
    MasalaPackTier(label: '1kg', weightGrams: 1000, priceMultiplier: 7.8),
  ];
}

int _getBasePriceForPouch(String pouchNumber) {
  switch (pouchNumber) {
    case 'P-08':
      return 85;
    case 'P-14':
      return 60;
    case 'P-03':
      return 70;
    case 'P-05':
      return 75;
    case 'P-11':
      return 65;
    case 'P-06':
      return 80;
    default:
      final sum = pouchNumber.codeUnits.fold(0, (acc, c) => acc + c);
      return 60 + (sum % 6) * 5;
  }
}

int _calculateTierPrice(int basePrice, double multiplier) {
  return (basePrice * multiplier).round();
}

int _calculateMrp(int price, MasalaPackTier tier) {
  return (price * 1.22).ceil();
}

enum _CatalogViewMode {
  masalaGrid,
  dishesList,
}

class RecipeCatalogScreen extends StatefulWidget {
  const RecipeCatalogScreen({super.key});

  @override
  State<RecipeCatalogScreen> createState() => _RecipeCatalogScreenState();
}

class _RecipeCatalogScreenState extends State<RecipeCatalogScreen> {
  _CatalogViewMode _viewMode = _CatalogViewMode.masalaGrid;
  IngredientCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isVegOnly = true;
  bool _withoutHingOnly = false;
  bool _jainOnly = false;
  bool _swaminarayanOnly = false;

  final List<IngredientCategory> _displayCategories = [
    IngredientCategory.fastFood,
    IngredientCategory.pastry,
    IngredientCategory.cake,
    IngredientCategory.biscuit,
    IngredientCategory.bakery,
    IngredientCategory.beverages,
    IngredientCategory.sweets,
    IngredientCategory.faraliSpecial,
    IngredientCategory.namkeenFarshan,
    IngredientCategory.spices,
  ];

  @override
  Widget build(BuildContext context) {
    final recipeVm = context.watch<RecipeViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;

    // Filter packaged items based on category, search, and diet
    final filteredPackagedItems = PackagedIngredientsService.searchAndFilter(
      query: _searchQuery,
      category: _selectedCategory == IngredientCategory.spices ? null : _selectedCategory,
      jainOnly: _jainOnly ? true : null,
      swaminarayanOnly: _swaminarayanOnly ? true : null,
      hingFreeOnly: _withoutHingOnly ? true : null,
    );

    // If Spices category is explicitly selected, we only show recipe pouches; otherwise if null we show both
    final showRecipeMasalas = _selectedCategory == null || _selectedCategory == IngredientCategory.spices;
    final filteredRecipeMasalas = showRecipeMasalas
        ? recipeVm.recipes.where((r) {
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              final mTitle = r.title.toLowerCase().contains(q);
              final mPouch = r.pouchName.toLowerCase().contains(q);
              final mNum = r.masalaPouchNumber.toLowerCase().contains(q);
              if (!mTitle && !mPouch && !mNum) return false;
            }
            if (_withoutHingOnly && !r.isHingFree) return false;
            return true;
          }).toList()
        : <RecipeModel>[];

    final totalGridItemsCount = (_selectedCategory == IngredientCategory.spices)
        ? filteredRecipeMasalas.length
        : (filteredPackagedItems.length + (_selectedCategory == null ? filteredRecipeMasalas.length : 0));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('JEEROLA STORE & PACKET CATALOG'),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: isDark ? AppColors.surfaceContainerHigh : const Color(0xFFFFECE5),
                child: const Icon(Icons.person, color: AppColors.primary, size: 16),
              ),
            ),
            tooltip: 'Chef Profile & Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Chef Badges & Cooking Challenges Section (Kitchen Feature)
                _buildKitchenBadgesAndChallenges(context),
                // View Mode Switcher (Packets Grid vs Dish Protocols)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isDark ? AppColors.surfaceContainerLow : AppColors.lightBackground,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _viewMode = _CatalogViewMode.masalaGrid),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _viewMode == _CatalogViewMode.masalaGrid
                                  ? AppColors.primary
                                  : (isDark ? AppColors.surfaceContainer : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _viewMode == _CatalogViewMode.masalaGrid
                                    ? AppColors.primary
                                    : (isDark ? AppColors.outlineVariant : AppColors.lightBorder),
                              ),
                              boxShadow: isDark
                                  ? null
                                  : [
                                      const BoxShadow(
                                        color: Color(0x0A8A4B08),
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.grid_view_sharp,
                                  size: 14,
                                  color: _viewMode == _CatalogViewMode.masalaGrid
                                      ? Colors.white
                                      : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'MASALAS & SPICES (GRID)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _viewMode == _CatalogViewMode.masalaGrid
                                            ? Colors.white
                                            : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _viewMode = _CatalogViewMode.dishesList),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _viewMode == _CatalogViewMode.dishesList
                                  ? AppColors.primary
                                  : (isDark ? AppColors.surfaceContainer : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _viewMode == _CatalogViewMode.dishesList
                                    ? AppColors.primary
                                    : (isDark ? AppColors.outlineVariant : AppColors.lightBorder),
                              ),
                              boxShadow: isDark
                                  ? null
                                  : [
                                      const BoxShadow(
                                        color: Color(0x0A8A4B08),
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book_outlined,
                                  size: 14,
                                  color: _viewMode == _CatalogViewMode.dishesList
                                      ? Colors.white
                                      : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'DISH PROTOCOLS',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _viewMode == _CatalogViewMode.dishesList
                                            ? Colors.white
                                            : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  color: isDark ? AppColors.surfaceContainer : Colors.white,
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                      recipeVm.onSearch(val);
                    },
                    style: AppTypography.bodyMd.copyWith(
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search 150+ food items, sweets, namkeen, or masalas...',
                      hintStyle: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                      ),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      fillColor: isDark ? AppColors.surfaceBlack : AppColors.lightSurfaceWarm,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                                recipeVm.onSearch('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),

                // Horizontal Category Selector Chips (9 Categories + Masalas + All)
                if (_viewMode == _CatalogViewMode.masalaGrid)
                  Container(
                    height: 44,
                    color: isDark ? AppColors.surfaceContainerLow : AppColors.lightBackground,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      children: [
                        // ALL CATEGORIES
                        Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: FilterChip(
                            label: const Text('All Packets'),
                            selected: _selectedCategory == null,
                            onSelected: (_) => setState(() => _selectedCategory = null),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
                            selectedColor: isDark ? AppColors.primaryContainer : const Color(0xFFFFECE5),
                            side: BorderSide(
                              color: _selectedCategory == null
                                  ? AppColors.primary
                                  : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                            ),
                            labelStyle: AppTypography.metadata.copyWith(
                              color: _selectedCategory == null
                                  ? AppColors.primary
                                  : (isDark ? AppColors.onSurface : AppColors.lightTextSecondary),
                              fontWeight: _selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        // Specific Categories
                        ..._displayCategories.map((cat) {
                          final isSel = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: FilterChip(
                              label: Text(cat.displayName),
                              selected: isSel,
                              onSelected: (_) => setState(() => _selectedCategory = isSel ? null : cat),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
                              selectedColor: isDark ? AppColors.primaryContainer : const Color(0xFFFFECE5),
                              side: BorderSide(
                                color: isSel
                                    ? AppColors.primary
                                    : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                              ),
                              labelStyle: AppTypography.metadata.copyWith(
                                color: isSel
                                    ? AppColors.primary
                                    : (isDark ? AppColors.onSurface : AppColors.lightTextSecondary),
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                // Dietary Filter Chips Bar (Pure Veg, Without Hing, Jain, Swaminarayan)
                Container(
                  height: 38,
                  color: isDark ? AppColors.surfaceContainerLow : AppColors.lightBackground,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                    children: [
                      // Veg Only Toggle
                      FilterChip(
                        label: const Text('Pure Veg'),
                        selected: _isVegOnly,
                        onSelected: (val) => setState(() => _isVegOnly = val),
                        avatar: const Icon(Icons.circle, size: 8, color: Colors.green),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
                        selectedColor: isDark ? AppColors.primaryContainer : const Color(0xFFFFECE5),
                        side: BorderSide(
                          color: _isVegOnly ? AppColors.sproutGreen : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                        ),
                        labelStyle: AppTypography.metadata.copyWith(
                          color: _isVegOnly ? AppColors.sproutGreen : (isDark ? AppColors.onSurface : AppColors.lightTextSecondary),
                          fontWeight: _isVegOnly ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Without Hing (Asafoetida-Free) Toggle
                      FilterChip(
                        label: const Text('Without Hing (હીંગ મુક્ત)'),
                        selected: _withoutHingOnly,
                        onSelected: (val) {
                          setState(() => _withoutHingOnly = val);
                          recipeVm.onToggleWithoutAsafoetida(val);
                        },
                        avatar: Icon(
                          _withoutHingOnly ? Icons.check_circle : Icons.block,
                          size: 13,
                          color: _withoutHingOnly ? AppColors.sproutGreen : AppColors.terracotta,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
                        selectedColor: isDark ? AppColors.primaryContainer : const Color(0xFFFFECE5),
                        side: BorderSide(
                          color: _withoutHingOnly ? AppColors.sproutGreen : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                        ),
                        labelStyle: AppTypography.metadata.copyWith(
                          color: _withoutHingOnly ? AppColors.sproutGreen : (isDark ? AppColors.onSurface : AppColors.lightTextSecondary),
                          fontWeight: _withoutHingOnly ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Jain Only Toggle
                      FilterChip(
                        label: const Text('Jain'),
                        selected: _jainOnly,
                        onSelected: (val) => setState(() => _jainOnly = val),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
                        selectedColor: isDark ? AppColors.primaryContainer : const Color(0xFFFFECE5),
                        side: BorderSide(
                          color: _jainOnly ? AppColors.sproutGreen : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                        ),
                        labelStyle: AppTypography.metadata.copyWith(
                          color: _jainOnly ? AppColors.sproutGreen : (isDark ? AppColors.onSurface : AppColors.lightTextSecondary),
                          fontWeight: _jainOnly ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Swaminarayan Toggle
                      FilterChip(
                        label: const Text('Swaminarayan'),
                        selected: _swaminarayanOnly,
                        onSelected: (val) => setState(() => _swaminarayanOnly = val),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
                        selectedColor: isDark ? AppColors.primaryContainer : const Color(0xFFFFECE5),
                        side: BorderSide(
                          color: _swaminarayanOnly ? AppColors.sproutGreen : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                        ),
                        labelStyle: AppTypography.metadata.copyWith(
                          color: _swaminarayanOnly ? AppColors.sproutGreen : (isDark ? AppColors.onSurface : AppColors.lightTextSecondary),
                          fontWeight: _swaminarayanOnly ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          ),

          // Content Area: Grid of Categorized Packets OR Dish List
          if (_viewMode == _CatalogViewMode.masalaGrid) ...[
            if (totalGridItemsCount == 0)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text('No food packets found matching criteria', style: AppTypography.bodyMd),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(10.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 900
                        ? 4
                        : (screenWidth > 600 ? 3 : 2),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: screenWidth > 600 ? 0.58 : 0.52,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // If Spices category is active, render recipe masalas
                      if (_selectedCategory == IngredientCategory.spices) {
                        final recipe = filteredRecipeMasalas[index];
                        return _MasalaPacketCard(
                          key: ValueKey('masala_${recipe.id}'),
                          recipe: recipe,
                        );
                      }

                      // If category is null (ALL), recipe masalas appear first, then packaged items
                      if (_selectedCategory == null) {
                        if (index < filteredRecipeMasalas.length) {
                          final recipe = filteredRecipeMasalas[index];
                          return _MasalaPacketCard(
                            key: ValueKey('masala_${recipe.id}'),
                            recipe: recipe,
                          );
                        }
                        final pkgIndex = index - filteredRecipeMasalas.length;
                        final item = filteredPackagedItems[pkgIndex];
                        return _PackagedFoodCard(
                          key: ValueKey('pkg_${item.id}'),
                          item: item,
                        );
                      }

                      // Otherwise render packaged items of that specific category
                      final item = filteredPackagedItems[index];
                      return _PackagedFoodCard(
                        key: ValueKey('pkg_${item.id}'),
                        item: item,
                      );
                    },
                    childCount: totalGridItemsCount,
                  ),
                ),
              ),
          ] else ...[
            if (recipeVm.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (recipeVm.recipes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text('No recipes found matching your criteria', style: AppTypography.bodyMd),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList.separated(
                  itemCount: recipeVm.recipes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final recipe = recipeVm.recipes[index];
                    return _RecipeItemCard(
                      recipe: recipe,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(recipe: recipe),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildKitchenBadgesAndChallenges(BuildContext context) {
    CookingRepository? cookingRepo;
    try {
      cookingRepo = Provider.of<CookingRepository>(context);
    } catch (_) {
      cookingRepo = null;
    }
    if (cookingRepo == null) return const SizedBox.shrink();
    final repo = cookingRepo;

    final profile = repo.gamificationProfile;
    final badges = profile.badges;
    final challenges = profile.challenges;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.primaryContainer : AppColors.lightBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: AppColors.primary, size: 15),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'CHEF BADGES & CHALLENGES',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          fontSize: 9.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChallengesHubScreen(
                        cookingRepository: repo,
                      ),
                    ),
                  );
                },
                child: Text(
                  'VIEW ALL (${badges.length}) ➔',
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.sproutGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: badges.take(4).map((b) {
                final isUnlocked = b.isUnlocked;
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : (isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isUnlocked
                          ? AppColors.primary
                          : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(b.iconCode, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        b.title,
                        style: AppTypography.metadata.copyWith(
                          color: isUnlocked
                              ? (isDark ? Colors.white : AppColors.primaryDark)
                              : (isDark ? AppColors.outline : AppColors.lightTextTertiary),
                          fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          if (challenges.isNotEmpty) ...[
            Builder(
              builder: (context) {
                final activeChal = challenges.first;
                final progressFraction = activeChal.progressRatio;
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChallengesHubScreen(
                          cookingRepository: repo,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on, color: AppColors.secondaryOrange, size: 13),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeChal.title,
                                style: AppTypography.metadata.copyWith(
                                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: progressFraction,
                                  backgroundColor: isDark ? AppColors.gridLine : AppColors.lightBorder,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sproutGreen),
                                  minHeight: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${activeChal.currentProgress}/${activeChal.targetProgress}',
                          style: AppTypography.metadata.copyWith(
                            color: AppColors.sproutGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Grid card for Packaged Ingredients / Foods across all 9 Categories with 100g, 250g, 500g, 750g, 1kg packets
class _PackagedFoodCard extends StatefulWidget {
  final PackagedIngredientItem item;

  const _PackagedFoodCard({super.key, required this.item});

  @override
  State<_PackagedFoodCard> createState() => _PackagedFoodCardState();
}

class _PackagedFoodCardState extends State<_PackagedFoodCard> {
  int _selectedTierIndex = 0; // Default 100g

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = widget.item;
    final tier = MasalaPackTier.tiers[_selectedTierIndex];
    final price = _calculateTierPrice(item.base100gPrice, tier.priceMultiplier);
    final mrp = _calculateMrp(price, tier);
    final shoppingVm = Provider.of<ShoppingListViewModel>(context);
    final itemName = '${item.name} (${tier.label})';
    final existingItem = shoppingVm.items.where((i) => i.name == itemName).firstOrNull;
    final inCartCount = existingItem?.packCount ?? 0;

    return BrutalistCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Adaptive image banner with category and diet badges
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                    child: const Center(
                      child: Icon(Icons.fastfood_outlined, size: 36, color: AppColors.outline),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Category Tag top-left
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    color: AppColors.primary,
                    child: Text(
                      item.category.displayName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Dietary tag top-right
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.isHingFree
                          ? AppColors.sproutGreen
                          : (isDark ? AppColors.surfaceBlack.withValues(alpha: 0.85) : Colors.white),
                      border: Border.all(
                        color: item.isHingFree
                            ? AppColors.sproutGreen
                            : (isDark ? AppColors.outlineVariant : AppColors.lightBorder),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      item.isSwaminarayan
                          ? 'SWAMINARAYAN'
                          : (item.isJain ? 'JAIN' : (item.isHingFree ? 'HING-FREE' : 'SPICY')),
                      style: AppTypography.metadata.copyWith(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: item.isHingFree
                            ? Colors.white
                            : (isDark ? AppColors.saffronYellow : AppColors.burntSienna),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content & Packet details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Item Name
                Text(
                  item.name,
                  style: AppTypography.headlineSm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Subtitle
                Text(
                  item.subtitle,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 9.5,
                    color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),

                // 5 Packet Weights (100g, 250g, 500g, 750g, 1kg)
                Row(
                  children: [
                    for (int i = 0; i < MasalaPackTier.tiers.length; i++) ...[
                      if (i > 0) const SizedBox(width: 3),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _selectedTierIndex = i),
                          child: Container(
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: i == _selectedTierIndex
                                  ? AppColors.sproutGreen
                                  : (isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm),
                              border: Border.all(
                                color: i == _selectedTierIndex
                                    ? AppColors.sproutGreen
                                    : (isDark ? AppColors.outlineVariant : AppColors.lightBorder),
                                width: 1,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                MasalaPackTier.tiers[i].label,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: i == _selectedTierIndex ? FontWeight.bold : FontWeight.w500,
                                  color: i == _selectedTierIndex
                                      ? Colors.white
                                      : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),

                // Price & Strikethrough Row
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹$price',
                        style: AppTypography.numericData.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.sproutGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '₹$mrp',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        color: isDark ? AppColors.primaryContainer : const Color(0xFFE8F5E9),
                        child: Text(
                          'Save ₹${mrp - price}',
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.sproutGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),

                // Add to Cart / Plus-Minus Stepper Button
                inCartCount > 0
                    ? Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm,
                          border: Border.all(color: AppColors.sproutGreen, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (inCartCount > 1) {
                                    shoppingVm.updatePackCount(existingItem!.id, inCartCount - 1);
                                  } else {
                                    shoppingVm.removeItem(existingItem!.id);
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.remove,
                                    size: 14,
                                    color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: isDark ? AppColors.gridLine : AppColors.lightBorder,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              alignment: Alignment.center,
                              child: Text(
                                '$inCartCount in cart',
                                style: AppTypography.metadata.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.sproutGreen,
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: isDark ? AppColors.gridLine : AppColors.lightBorder,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  shoppingVm.updatePackCount(existingItem!.id, inCartCount + 1);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.add, size: 14, color: AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            padding: EdgeInsets.zero,
                          ),
                          icon: const Icon(Icons.add_shopping_cart, size: 12),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'ADD ${tier.label.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          onPressed: () {
                            shoppingVm.addCustomItem(
                              name: itemName,
                              category: item.category,
                              quantity: tier.weightGrams,
                              unit: 'g',
                              estimatedPrice: price.toDouble(),
                              packCount: 1,
                            );

                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.sproutGreen,
                                content: Text(
                                  'Added ${item.name} (${tier.label}) • ₹$price to cart',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
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

/// Grid card displaying a Recipe's Masala Pouch with 100g, 250g, 500g, 750g, 1kg packets & pricing
class _MasalaPacketCard extends StatefulWidget {
  final RecipeModel recipe;

  const _MasalaPacketCard({super.key, required this.recipe});

  @override
  State<_MasalaPacketCard> createState() => _MasalaPacketCardState();
}

class _MasalaPacketCardState extends State<_MasalaPacketCard> {
  int _selectedTierIndex = 0; // Default to 100g

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recipe = widget.recipe;
    final tier = MasalaPackTier.tiers[_selectedTierIndex];
    final basePrice = _getBasePriceForPouch(recipe.masalaPouchNumber);
    final price = _calculateTierPrice(basePrice, tier.priceMultiplier);
    final mrp = _calculateMrp(price, tier);
    final shoppingVm = Provider.of<ShoppingListViewModel>(context);
    final itemName = '${recipe.pouchName} Masala (${tier.label})';
    final existingItem = shoppingVm.items.where((i) => i.name == itemName).firstOrNull;
    final inCartCount = existingItem?.packCount ?? 0;

    return BrutalistCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Adaptive image banner that fills remaining space and prevents any overflow
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailScreen(recipe: recipe),
                  ),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                      child: const Center(
                        child: Icon(Icons.soup_kitchen, size: 36, color: AppColors.outline),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.5),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: PouchBadge(
                      pouchNumber: recipe.masalaPouchNumber,
                      pouchName: recipe.pouchName,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: !recipe.containsAsafoetida
                            ? AppColors.sproutGreen
                            : (isDark ? AppColors.surfaceBlack.withValues(alpha: 0.85) : Colors.white),
                        border: Border.all(
                          color: !recipe.containsAsafoetida
                              ? AppColors.sproutGreen
                              : (isDark ? AppColors.outlineVariant : AppColors.lightBorder),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        !recipe.containsAsafoetida ? 'HING-FREE' : 'WITH HING',
                        style: AppTypography.metadata.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: !recipe.containsAsafoetida
                            ? Colors.white
                            : (isDark ? AppColors.saffronYellow : AppColors.burntSienna),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      color: Colors.black.withValues(alpha: 0.82),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 11, color: AppColors.saffronYellow),
                          const SizedBox(width: 3),
                          Text(
                            '${recipe.rating}',
                            style: AppTypography.numericData.copyWith(fontSize: 10, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content & Packet details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Masala pouch name
                Text(
                  '${recipe.pouchName} Masala',
                  style: AppTypography.headlineSm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Dish Pairing
                Row(
                  children: [
                    const Icon(Icons.restaurant_menu, size: 10, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'For ${recipe.title}',
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 10,
                          color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Packet Sizes (100g, 250g, 500g, 750g, 1kg)
                Row(
                  children: [
                    for (int i = 0; i < MasalaPackTier.tiers.length; i++) ...[
                      if (i > 0) const SizedBox(width: 3),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _selectedTierIndex = i;
                            });
                          },
                          child: Container(
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: i == _selectedTierIndex
                                  ? AppColors.sproutGreen
                                  : (isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm),
                              border: Border.all(
                                color: i == _selectedTierIndex
                                    ? AppColors.sproutGreen
                                    : (isDark ? AppColors.outlineVariant : AppColors.lightBorder),
                                width: 1,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                MasalaPackTier.tiers[i].label,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: i == _selectedTierIndex ? FontWeight.bold : FontWeight.w500,
                                  color: i == _selectedTierIndex
                                      ? Colors.white
                                      : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),

                // Price & Strikethrough Row with Fit protection
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹$price',
                        style: AppTypography.numericData.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.sproutGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '₹$mrp',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        color: isDark ? AppColors.primaryContainer : const Color(0xFFE8F5E9),
                        child: Text(
                          'Save ₹${mrp - price}',
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.sproutGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),

                // Add Packet to Cart / Plus-Minus Stepper Button
                inCartCount > 0
                    ? Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm,
                          border: Border.all(color: AppColors.sproutGreen, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (inCartCount > 1) {
                                    shoppingVm.updatePackCount(existingItem!.id, inCartCount - 1);
                                  } else {
                                    shoppingVm.removeItem(existingItem!.id);
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.remove,
                                    size: 14,
                                    color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: isDark ? AppColors.gridLine : AppColors.lightBorder,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              alignment: Alignment.center,
                              child: Text(
                                '$inCartCount in cart',
                                style: AppTypography.metadata.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.sproutGreen,
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: isDark ? AppColors.gridLine : AppColors.lightBorder,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  shoppingVm.updatePackCount(existingItem!.id, inCartCount + 1);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.add, size: 14, color: AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            padding: EdgeInsets.zero,
                          ),
                          icon: const Icon(Icons.add_shopping_cart, size: 12),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'ADD ${tier.label.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          onPressed: () {
                            shoppingVm.addCustomItem(
                              name: itemName,
                              category: IngredientCategory.spices,
                              quantity: tier.weightGrams,
                              unit: 'g',
                              estimatedPrice: price.toDouble(),
                              packCount: 1,
                            );

                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.sproutGreen,
                                content: Text(
                                  'Added ${recipe.pouchName} Masala (${tier.label}) • ₹$price to cart',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
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

class _RecipeItemCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback onTap;

  const _RecipeItemCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BrutalistCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner with image & pouch badge
          Stack(
            children: [
              SizedBox(
                height: 140,
                width: double.infinity,
                child: Image.network(
                  recipe.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                    child: const Center(child: Icon(Icons.restaurant, size: 40, color: AppColors.outline)),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: PouchBadge(
                  pouchNumber: recipe.masalaPouchNumber,
                  pouchName: recipe.pouchName,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: !recipe.containsAsafoetida
                        ? AppColors.sproutGreen
                        : (isDark ? AppColors.surfaceBlack.withValues(alpha: 0.85) : Colors.white),
                    border: Border.all(
                      color: !recipe.containsAsafoetida
                          ? AppColors.sproutGreen
                          : (isDark ? AppColors.outlineVariant : AppColors.lightBorder),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    !recipe.containsAsafoetida ? 'HING-FREE' : 'WITH HING',
                    style: AppTypography.metadata.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: !recipe.containsAsafoetida
                          ? Colors.white
                          : (isDark ? AppColors.saffronYellow : AppColors.burntSienna),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: Colors.black.withValues(alpha: 0.82),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: AppColors.saffronYellow),
                      const SizedBox(width: 4),
                      Text('${recipe.rating}', style: AppTypography.numericData.copyWith(fontSize: 11, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(recipe.title, style: AppTypography.headlineSm),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${recipe.totalTimeMinutes}m',
                      style: AppTypography.numericData.copyWith(color: AppColors.sproutGreen, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  recipe.description,
                  style: AppTypography.bodySm,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${recipe.ingredients.length} INGREDIENTS',
                      style: AppTypography.metadata,
                    ),
                    const Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                    Text(
                      '${recipe.steps.length} COOKING STEPS',
                      style: AppTypography.metadata.copyWith(color: AppColors.secondaryOrange),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


