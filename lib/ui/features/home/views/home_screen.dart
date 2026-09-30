import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/brutalist_card.dart';
import '../../../../core/widgets/delivery_address_sheet.dart';
import '../../../../core/widgets/pouch_badge.dart';
import '../../../../core/widgets/quick_commerce_product_card.dart';
import '../../../../data/models/ingredient_model.dart';
import '../../../../data/models/quick_commerce_product_model.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/services/quick_commerce_service.dart';
import '../../delivery/view_models/jeerola_delivery_view_model.dart';
import '../../delivery/views/jeerola_order_tracking_screen.dart';
import '../../recipes/views/recipe_detail_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../ai_chat/views/jeerola_ai_chat_screen.dart';
import '../../shopping_list/view_models/shopping_list_view_model.dart';
import '../view_models/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _deliveryAddress =
      '202,Yogi Bhuvan, Ambliwali Pol(Yagnapurush ni Pol)';
  QuickCommerceStore? _selectedStoreFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Grocery Aisles Category Selector
  int _selectedGroceryCategoryIndex = 0;
  final List<Map<String, dynamic>> _groceryCategories = [
    {'name': 'All Aisles', 'category': null, 'icon': Icons.all_inclusive},
    {
      'name': 'Dairy & Bread',
      'category': IngredientCategory.dairy,
      'icon': Icons.emoji_food_beverage_sharp,
    },
    {
      'name': 'Farm Veggies',
      'category': IngredientCategory.vegetables,
      'icon': Icons.eco_outlined,
    },
    {
      'name': 'Jeerola Spices',
      'category': IngredientCategory.spices,
      'icon': Icons.grain_outlined,
    },
    {
      'name': 'DMart Wholesale',
      'category': IngredientCategory.pantry,
      'icon': Icons.inventory_2_outlined,
    },
    {
      'name': 'Munchies & Snacks',
      'category': IngredientCategory.namkeenFarshan,
      'icon': Icons.fastfood_outlined,
    },
    {
      'name': 'Drinks & Juices',
      'category': IngredientCategory.beverages,
      'icon': Icons.local_drink_outlined,
    },
  ];

  // Restaurant Recipe Cuisines
  int _selectedRestaurantCuisineIndex = 0;
  final List<Map<String, dynamic>> _restaurantCuisines = const [
    {'name': 'All Kitchen', 'cuisine': 'All', 'icon': Icons.restaurant_menu},
    {
      'name': 'Curries & Gravies',
      'cuisine': 'North Indian',
      'icon': Icons.soup_kitchen,
    },
    {
      'name': 'Gujarati Delights',
      'cuisine': 'Gujarati',
      'icon': Icons.rice_bowl,
    },
    {
      'name': 'Street Food Chaat',
      'cuisine': 'Street Food',
      'icon': Icons.fastfood,
    },
    {'name': 'Farali & Vrat', 'cuisine': 'Farali & Vrat', 'icon': Icons.spa},
    {
      'name': 'Indo-Chinese',
      'cuisine': 'Indo-Chinese',
      'icon': Icons.ramen_dining,
    },
  ];

  // Sensory Craving Moods (Designed to stimulate salivation & appetite upon app entry)
  final List<Map<String, dynamic>> _cravingMoods = const [
    {
      'title': 'Sizzling Curries',
      'aroma': 'Rich butter gravy & kasuri methi',
      'tag': 'PIPING HOT',
      'tagColor': Color(0xFFFF5722),
      'emoji': '🍛',
      'gradient': [Color(0xFF3E1408), Color(0xFF1E0A04)],
      'borderColor': Color(0xFFFF5722),
      'imageUrl': 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=400&q=80',
      'targetCuisine': 'North Indian',
    },
    {
      'title': 'Hot Butter Naan',
      'aroma': 'Fresh from tandoor, melting ghee',
      'tag': 'SMOKY',
      'tagColor': Color(0xFFFFA000),
      'emoji': '🫓',
      'gradient': [Color(0xFF382305), Color(0xFF1C1102)],
      'borderColor': Color(0xFFFFA000),
      'imageUrl': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=400&q=80',
      'targetCuisine': 'North Indian',
    },
    {
      'title': 'Royal Dum Biryani',
      'aroma': 'Slow-cooked saffron & fried onions',
      'tag': 'ROYAL DUM',
      'tagColor': Color(0xFFE65100),
      'emoji': '🍚',
      'gradient': [Color(0xFF3D1A00), Color(0xFF1F0D00)],
      'borderColor': Color(0xFFFF8F00),
      'imageUrl': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=400&q=80',
      'targetCuisine': 'North Indian',
    },
    {
      'title': 'Crispy Street Chaat',
      'aroma': 'Tangy tamarind & chilled mint sev',
      'tag': 'CRUNCHY',
      'tagColor': Color(0xFF43A047),
      'emoji': '🥟',
      'gradient': [Color(0xFF112E14), Color(0xFF09170A)],
      'borderColor': Color(0xFF43A047),
      'imageUrl': 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?auto=format&fit=crop&w=400&q=80',
      'targetCuisine': 'Street Food',
    },
    {
      'title': 'Desi Dal Tadka',
      'aroma': 'Double ghee & sizzling roasted jeera',
      'tag': 'COMFORT',
      'tagColor': Color(0xFFFFB300),
      'emoji': '🍲',
      'gradient': [Color(0xFF332600), Color(0xFF1A1300)],
      'borderColor': Color(0xFFFFC107),
      'imageUrl': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?/auto=format&fit=crop&w=400&q=80',
      'targetCuisine': 'Gujarati',
    },
    {
      'title': 'Warm Gulab Jamun',
      'aroma': 'Piping hot, dripping in rose syrup',
      'tag': 'SWEET',
      'tagColor': Color(0xFFD81B60),
      'emoji': '🍨',
      'gradient': [Color(0xFF38081A), Color(0xFF1C040D)],
      'borderColor': Color(0xFFE91E63),
      'imageUrl': 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=400&q=80',
      'targetCuisine': 'Gujarati',
    },
  ];

  // Flash Sale Timer Ticker
  late Timer _flashTimer;
  int _secondsRemaining = 9845; // ~2h 44m

  // 10-Category Promotional Bestsellers Image Slider
  late final PageController _promoPageController;
  Timer? _promoTimer;
  int _currentPromoIndex = 0;

  final List<Map<String, dynamic>> _promoBestsellers = [
    {
      'category': 'ARTISAN SPICES',
      'title': 'Jeerola Royal Garam Masala',
      'subtitle': 'P-08 Stone-Ground Secret Blend • 35% OFF',
      'badge': 'BESTSELLER #1',
      'badgeColor': const Color(0xFFFF5722),
      'store': 'Jeerola Kitchen',
      'storeColor': const Color(0xFFE64A19),
      'price': '₹85',
      'mrp': '₹130',
      'imageUrl': 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?auto=format&fit=crop&w=600&q=80',
      'tag': '100% Stone-Ground',
    },
    {
      'category': 'MEAL KITS',
      'title': 'Paneer Butter Masala Kit',
      'subtitle': 'Pre-portioned Fresh Veggies & Spice Pouches',
      'badge': '15-MIN RESTAURANT',
      'badgeColor': const Color(0xFFE23744),
      'store': 'Jeerola Kitchen',
      'storeColor': const Color(0xFFE64A19),
      'price': '₹249',
      'mrp': '₹320',
      'imageUrl': 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=600&q=80',
      'tag': 'Chef Signature Kit',
    },
    {
      'category': 'DAIRY & BREAD',
      'title': 'Amul Taaza Homogenised Milk',
      'subtitle': '1 Litre Pure Cow Milk • 10-Min Flash Drop',
      'badge': '10-MIN DROP',
      'badgeColor': const Color(0xFF2196F3),
      'store': 'Zepto Instant',
      'storeColor': const Color(0xFF880E4F),
      'price': '₹54',
      'mrp': '₹56',
      'imageUrl': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=600&q=80',
      'tag': 'Daily Essential',
    },
    {
      'category': 'FARM VEGGIES',
      'title': 'Organic Hybrid Tomatoes & Coriander',
      'subtitle': '1kg Crisp Farm Handpicked Harvest',
      'badge': 'SUPER FRESH',
      'badgeColor': const Color(0xFF4CAF50),
      'store': 'Blinkit Superstore',
      'storeColor': const Color(0xFFF9D923),
      'price': '₹38',
      'mrp': '₹60',
      'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=600&q=80',
      'tag': 'No Chemicals',
    },
    {
      'category': 'DMART WHOLESALE',
      'title': 'Aashirvaad Shudh Chakki Atta 5kg',
      'subtitle': '100% Whole Wheat Grain Flour',
      'badge': 'MIN 33% OFF',
      'badgeColor': const Color(0xFF008848),
      'store': 'DMart Ready',
      'storeColor': const Color(0xFF008848),
      'price': '₹219',
      'mrp': '₹295',
      'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=80',
      'tag': 'Lowest City Price',
    },
    {
      'category': 'MUNCHIES & FARSHAN',
      'title': "Haldiram's Nagpur Aloo Bhujia",
      'subtitle': '400g Crispy Spicy Sev Munchies',
      'badge': 'BUY 1 GET 1',
      'badgeColor': const Color(0xFFFF9800),
      'store': 'JioMart Super',
      'storeColor': const Color(0xFF005691),
      'price': '₹98',
      'mrp': '₹140',
      'imageUrl': 'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?auto=format&fit=crop&w=600&q=80',
      'tag': 'Tea-Time Crunch',
    },
    {
      'category': 'DRINKS & JUICES',
      'title': 'Real 100% Mixed Fruit Juice 1L',
      'subtitle': 'No Added Preservatives • Chilled',
      'badge': 'FLAT 25% OFF',
      'badgeColor': const Color(0xFF9C27B0),
      'store': 'Swiggy Instamart',
      'storeColor': const Color(0xFFFC8019),
      'price': '₹99',
      'mrp': '₹135',
      'imageUrl': 'https://images.unsplash.com/photo-1613478223719-2ab802602423?auto=format&fit=crop&w=600&q=80',
      'tag': 'Chilled in 12m',
    },
    {
      'category': 'OILS & GHEE',
      'title': 'Fortune Sunlite Sunflower Oil 1L',
      'subtitle': 'Fortified Vitamin A & D Pouch',
      'badge': 'SUPER SAVER',
      'badgeColor': const Color(0xFFFBC02D),
      'store': 'BigBasket Daily',
      'storeColor': const Color(0xFF84C225),
      'price': '₹124',
      'mrp': '₹165',
      'imageUrl': 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=600&q=80',
      'tag': 'Purity Guaranteed',
    },
    {
      'category': 'ROYAL GRAINS',
      'title': 'Daawat Rozana Super Basmati Rice 5kg',
      'subtitle': 'Long Grain Aromatic Basmati',
      'badge': 'WHOLESALE DEAL',
      'badgeColor': const Color(0xFF795548),
      'store': 'DMart Ready',
      'storeColor': const Color(0xFF008848),
      'price': '₹399',
      'mrp': '₹560',
      'imageUrl': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=600&q=80',
      'tag': 'Biryani & Pulao Special',
    },
    {
      'category': 'CHEF SPECIAL',
      'title': 'Jeerola Special Dum Biryani Kit',
      'subtitle': 'Includes Saffron Infusion & Spice Pouch P-08',
      'badge': 'CHEF SECRET',
      'badgeColor': const Color(0xFFE64A19),
      'store': 'Jeerola Kitchen',
      'storeColor': const Color(0xFFE64A19),
      'price': '₹199',
      'mrp': '₹280',
      'imageUrl': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=600&q=80',
      'tag': 'Cook in 25 Minutes',
    },
  ];

  @override
  void initState() {
    super.initState();
    _promoPageController = PageController();
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _promoPageController.hasClients) {
        final nextIndex = (_currentPromoIndex + 1) % _promoBestsellers.length;
        _promoPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    _flashTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoPageController.dispose();
    _flashTimer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final deliveryVm = context.watch<JeerolaDeliveryViewModel>();
    final user = homeVm.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 12,
        title: InkWell(
          onTap: () {
            DeliveryAddressSheet.show(
              context,
              currentAddress: _deliveryAddress,
              onAddressSelected: (newAddr) =>
                  setState(() => _deliveryAddress = newAddr),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const AppLogo(size: AppLogoSize.small, showText: false),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.sproutGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.flash_on,
                                  size: 10,
                                  color: Colors.white,
                                ),
                                Text(
                                  '10-15M',
                                  style: AppTypography.metadata.copyWith(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'DELIVER TO',
                              style: AppTypography.metadata.copyWith(
                                color: AppColors.secondary,
                                fontSize: 9,
                                letterSpacing: 1.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _deliveryAddress,
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          // AI Chef Icon
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
            tooltip: 'Jeerola Royal AI Chef',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const JeerolaAiChatScreen()),
              );
            },
          ),
          // Profile Icon (replaces cart icon)
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
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: homeVm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
              onRefresh: () async => homeVm.refreshData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 6.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Greeting
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WELCOME,',
                                style: AppTypography.metadata.copyWith(
                                  color: AppColors.secondary,
                                  fontSize: 9.5,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              Text(
                                user?.name ?? 'Nehal Patel',
                                style: AppTypography.headlineSm.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceContainerHigh : const Color(0xFFFFECE5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.restaurant,
                                color: AppColors.primary,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'JEEROLA CHEF',
                                style: AppTypography.metadata.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Search Bar & Filter Action
                    _buildModernSearchBar(context),
                    const SizedBox(height: 12),

                    // Sensory Appetite & Craving Bar
                    _buildSensoryCravingBar(context),
                    const SizedBox(height: 16),

                    // 10-Category Promotional Bestseller Carousel
                    _buildPromotionalBestsellerSlider(context),
                    const SizedBox(height: 16),

                    // Active Live Delivery Tracker Banner (If Order Active)
                    if (deliveryVm.hasActiveDelivery) ...[
                      _buildActiveDeliveryBanner(context, deliveryVm),
                      const SizedBox(height: 16),
                    ],

                    // Flash Deals & DMart Ready Wholesale Zone (Huge Savings Ticker)
                    _buildFlashDealsSection(context),
                    const SizedBox(height: 18),

                    // Restaurant & Chef Special Meal Kits Section (Swiggy / Zomato Kitchen)
                    _buildRestaurantKitsSection(context),
                    const SizedBox(height: 18),

                    // Instant Grocery Aisles (Blinkit & Zepto 10-Min Supermarket Grid)
                    _buildInstantGroceryAislesSection(context),
                    const SizedBox(height: 18),

                    // Curated Restaurant Dishes Carousel (Paneer Butter Masala, Undhiyu, etc.)
                    _buildRestaurantDishesCarousel(context),
                    const SizedBox(height: 18),

                    // Smart Meal Planner & Duration Selector
                    _buildSmartMealPlannerCard(context, homeVm),
                    const SizedBox(
                      height: 80,
                    ), // Padding for bottom floating cart
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.auto_awesome, size: 18, color: AppColors.secondary),
        label: Text(
          'AI CHEF',
          style: AppTypography.metadata.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const JeerolaAiChatScreen()),
          );
        },
      ),
    );
  }

  // =========================================================================
  // 1. MODERN SEARCH & VOICE BAR
  // =========================================================================
  Widget _buildModernSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceContainer : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.gridLine : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : const Color(0x0E8A4B08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: AppTypography.bodySm.copyWith(
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search 'Paneer', 'Amul Milk', 'DMart Rice', 'Jeera Pouch'...",
                    hintStyle: AppTypography.bodySm.copyWith(
                      color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  onSubmitted: (_) {
                    if (widget.onNavigateTab != null) {
                      widget.onNavigateTab!(2); // Go to aisles/categories
                    }
                  },
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 16,
                    color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceContainerHigh : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune,
                  color: AppColors.secondary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Quick Search Filter Badges
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                '⚡ 10-Min Drop',
                isSelected: _selectedStoreFilter == QuickCommerceStore.zepto,
                onTap: () {
                  setState(
                    () => _selectedStoreFilter =
                        _selectedStoreFilter == QuickCommerceStore.zepto
                        ? null
                        : QuickCommerceStore.zepto,
                  );
                },
              ),
              _buildFilterChip(
                '🥘 Chef Kits',
                isSelected:
                    _selectedStoreFilter == QuickCommerceStore.jeerolaKitchen,
                onTap: () {
                  setState(
                    () => _selectedStoreFilter =
                        _selectedStoreFilter ==
                            QuickCommerceStore.jeerolaKitchen
                        ? null
                        : QuickCommerceStore.jeerolaKitchen,
                  );
                },
              ),
              _buildFilterChip(
                '🏷️ DMart Ready Deals',
                isSelected:
                    _selectedStoreFilter == QuickCommerceStore.dmartReady,
                onTap: () {
                  setState(
                    () => _selectedStoreFilter =
                        _selectedStoreFilter == QuickCommerceStore.dmartReady
                        ? null
                        : QuickCommerceStore.dmartReady,
                  );
                },
              ),
              _buildFilterChip(
                '🥬 Farm Fresh',
                isSelected:
                    _selectedStoreFilter == QuickCommerceStore.bigBasket,
                onTap: () {
                  setState(
                    () => _selectedStoreFilter =
                        _selectedStoreFilter == QuickCommerceStore.bigBasket
                        ? null
                        : QuickCommerceStore.bigBasket,
                  );
                },
              ),
              _buildFilterChip(
                '🔵 JioMart Bulk',
                isSelected: _selectedStoreFilter == QuickCommerceStore.jioMart,
                onTap: () {
                  setState(
                    () => _selectedStoreFilter =
                        _selectedStoreFilter == QuickCommerceStore.jioMart
                        ? null
                        : QuickCommerceStore.jioMart,
                  );
                },
              ),
              _buildFilterChip(
                '🟢 100% Veg & Jain',
                isSelected: false,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Filtered to 100% Pure Veg & Jain Friendly options',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String text, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.surfaceContainerLow : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.gridLine : AppColors.lightBorder),
              width: 1.0,
            ),
            boxShadow: isDark
                ? null
                : [
                    const BoxShadow(
                      color: Color(0x088A4B08),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Text(
            text,
            style: AppTypography.metadata.copyWith(
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary),
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // SENSORY APPETITE CRAVING BAR ("WHAT ARE YOU CRAVING RIGHT NOW?")
  // =========================================================================
  Widget _buildSensoryCravingBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with pulsing aroma flame and appetizing invite
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3D00).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF3D00).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.whatshot_rounded,
                      color: Color(0xFFFF3D00),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WHAT ARE YOU CRAVING?',
                          style: AppTypography.metadata.copyWith(
                            color: isDark ? AppColors.secondary : AppColors.burntSienna,
                            fontSize: 10,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Fresh aroma • Sizzling & served hot',
                          style: AppTypography.bodySm.copyWith(
                            color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5722).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF5722), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5722),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'TAWA LIVE',
                    style: AppTypography.metadata.copyWith(
                      color: const Color(0xFFFF5722),
                      fontWeight: FontWeight.w900,
                      fontSize: 8.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Horizontal List of 6 Mouth-Watering Craving Cards
        SizedBox(
          height: 138,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _cravingMoods.length,
            separatorBuilder: (context, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final mood = _cravingMoods[index];
              return _buildCravingMoodCard(context, mood);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCravingMoodCard(
    BuildContext context,
    Map<String, dynamic> mood,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = mood['borderColor'] as Color;
    final gradientColors = mood['gradient'] as List<Color>;

    return InkWell(
      onTap: () {
        final targetCuisine = mood['targetCuisine'] as String;
        final targetIdx = _restaurantCuisines.indexWhere(
          (c) => c['cuisine'] == targetCuisine,
        );
        if (targetIdx != -1) {
          setState(() => _selectedRestaurantCuisineIndex = targetIdx);
        }
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColors.lightSurfaceCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor, width: 1.2),
            ),
            content: Row(
              children: [
                Text(
                  mood['emoji'] as String,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Craving: ${mood['title']}',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        mood['aroma'] as String,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 145,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? gradientColors
                : [
                    borderColor.withValues(alpha: 0.15),
                    AppColors.lightSurfaceWarm,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor.withValues(alpha: isDark ? 0.55 : 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: isDark ? 0.12 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Imagery with appetizing vignette overlay
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.28 : 0.16,
                child: Image.network(
                  mood['imageUrl'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(),
                ),
              ),
            ),
            // Card Content
            Padding(
              padding: const EdgeInsets.all(9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mood['emoji'] as String,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: mood['tagColor'] as Color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            mood['tag'] as String,
                            style: AppTypography.metadata.copyWith(
                              color: Colors.white,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    mood['title'] as String,
                    style: AppTypography.headlineSm.copyWith(
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mood['aroma'] as String,
                    style: AppTypography.bodySm.copyWith(
                      color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                      fontSize: 9.5,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 2. PROMOTIONAL BESTSELLER IMAGE SLIDER (UP TO 10 CATEGORIES)
  // =========================================================================
  Widget _buildPromotionalBestsellerSlider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'CATEGORY BESTSELLERS',
                      style: AppTypography.metadata.copyWith(
                        color: AppColors.secondary,
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'UP TO 50% OFF',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.primary,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${_currentPromoIndex + 1}/${_promoBestsellers.length}',
              style: AppTypography.metadata.copyWith(
                color: AppColors.secondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 172,
          child: PageView.builder(
            controller: _promoPageController,
            itemCount: _promoBestsellers.length,
            onPageChanged: (index) {
              setState(() => _currentPromoIndex = index);
            },
            itemBuilder: (context, index) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final promo = _promoBestsellers[index];
              final badgeColor =
                  promo['badgeColor'] as Color? ?? AppColors.primary;
              final storeColor =
                  promo['storeColor'] as Color? ?? AppColors.secondary;

              return Container(
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      storeColor.withValues(alpha: isDark ? 0.18 : 0.10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? storeColor.withValues(alpha: 0.6)
                        : AppColors.lightBorder,
                    width: 1.2,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: storeColor.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Row(
                      children: [
                        // Left Text & Info
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 2,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: badgeColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        promo['badge'] as String,
                                        style: AppTypography.metadata.copyWith(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      promo['category'] as String,
                                      style: AppTypography.metadata.copyWith(
                                        color: isDark ? AppColors.secondary : AppColors.burntSienna,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  promo['title'] as String,
                                  style: AppTypography.headlineSm.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  promo['subtitle'] as String,
                                  style: AppTypography.metadata.copyWith(
                                    fontSize: 9,
                                    color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 2,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      promo['price'] as String,
                                      style: AppTypography.headlineSm.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      promo['mrp'] as String,
                                      style: AppTypography.metadata.copyWith(
                                        color: isDark ? AppColors.secondary : AppColors.lightTextTertiary,
                                        fontSize: 9.5,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: storeColor.withValues(
                                          alpha: 0.25,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        promo['store'] as String,
                                        style: AppTypography.metadata.copyWith(
                                          color: storeColor,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right Image Container
                        Expanded(
                          flex: 2,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                promo['imageUrl'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: isDark ? AppColors.surfaceContainer : AppColors.lightSurfaceWarm,
                                    child: Center(
                                      child: Icon(
                                        Icons.shopping_bag,
                                        size: 36,
                                        color: storeColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                                            .withValues(alpha: 0.92),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.4],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: InkWell(
                                  onTap: () {
                                    final priceClean =
                                        double.tryParse(
                                          (promo['price'] as String).replaceAll(
                                            '₹',
                                            '',
                                          ),
                                        ) ??
                                        99.0;
                                    context
                                        .read<ShoppingListViewModel>()
                                        .addOrIncrementItem(
                                          id: 'promo_${promo['title'].hashCode}',
                                          name: promo['title'] as String,
                                          category: IngredientCategory.pantry,
                                          price: priceClean,
                                          unit: 'pack',
                                          packSize: 1,
                                          packUnit: 'pack',
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${promo['title']} added to Cart! ⚡',
                                        ),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: AppColors.primary,
                                        action: SnackBarAction(
                                          label: 'VIEW CART',
                                          textColor: Colors.white,
                                          onPressed: () =>
                                              widget.onNavigateTab?.call(2),
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.add,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'ADD',
                                          style: AppTypography.metadata
                                              .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 10,
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
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_promoBestsellers.length, (idx) {
            final isCurrent = idx == _currentPromoIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: isCurrent ? 16 : 4,
              height: 4,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primary
                    : AppColors.secondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }

  // =========================================================================
  // 3. FLASH DEALS & DMART READY WHOLESALE ZONE
  // =========================================================================
  Widget _buildFlashDealsSection(BuildContext context) {
    final deals = QuickCommerceService.getFlashDeals();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Flash Header with Live Ticker
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF008848), // DMart Emerald Green
                Color(0xFF005A30),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.flash_on,
                      color: AppColors.saffronYellow,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'DMART & JIOMART STEALS',
                        style: AppTypography.metadata.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 10.5,
                          letterSpacing: 0.6,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      color: AppColors.saffronYellow,
                      size: 11,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatTimer(_secondsRemaining),
                      style: AppTypography.metadata.copyWith(
                        color: AppColors.saffronYellow,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Deals Horizontal Scroll
        SizedBox(
          height: 270,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: deals.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = deals[index];
              return QuickCommerceProductCard(product: product);
            },
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 4. RESTAURANT & CHEF SPECIAL MEAL KITS SECTION
  // =========================================================================
  Widget _buildRestaurantKitsSection(BuildContext context) {
    final kits = QuickCommerceService.getRestaurantKits();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JEEROLA GOURMET KITCHEN',
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.secondary,
                      letterSpacing: 1.2,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Chef Handcrafted Meal Kits & Spice Pouches',
                    style: AppTypography.headlineSm.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(1); // Go to recipes tab
                }
              },
              child: Text(
                'SEE ALL →',
                style: AppTypography.metadata.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 270,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kits.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = kits[index];
              return QuickCommerceProductCard(product: product);
            },
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 5. INSTANT GROCERY AISLES (BLINKIT & ZEPTO CATEGORY PRODUCT GRID)
  // =========================================================================
  Widget _buildInstantGroceryAislesSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCat =
        _groceryCategories[_selectedGroceryCategoryIndex]['category']
            as IngredientCategory?;
    var products = QuickCommerceService.products;

    if (_selectedStoreFilter != null) {
      products = products
          .where((p) => p.store == _selectedStoreFilter)
          .toList();
    }
    if (selectedCat != null) {
      products = products.where((p) => p.category == selectedCat).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      products = products
          .where(
            (p) =>
                p.title.toLowerCase().contains(q) ||
                p.brand.toLowerCase().contains(q),
          )
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '10-MIN QUICK COMMERCE AISLES',
                    style: AppTypography.metadata.copyWith(
                      color: isDark ? AppColors.secondary : AppColors.burntSienna,
                      letterSpacing: 1.2,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Daily Dairy, Veggies & Munchies',
                    style: AppTypography.headlineSm.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(2); // Go to Categories / Aisles tab
                }
              },
              child: Text(
                'ALL AISLES →',
                style: AppTypography.metadata.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Aisle Categories Pills
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _groceryCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _groceryCategories[index];
              final isSelected = _selectedGroceryCategoryIndex == index;

              return InkWell(
                onTap: () =>
                    setState(() => _selectedGroceryCategoryIndex = index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.surfaceContainer : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                    ),
                    boxShadow: isDark || isSelected
                        ? null
                        : [
                            const BoxShadow(
                              color: Color(0x068A4B08),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        size: 14,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.secondary : AppColors.burntSienna),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat['name'] as String,
                        style: AppTypography.bodySm.copyWith(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Products Grid / Horizontal List
        if (products.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceContainer : AppColors.lightSurfaceWarm,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.gridLine : AppColors.lightBorder,
              ),
            ),
            child: Text(
              'No items matching selected store or aisle.',
              style: AppTypography.bodySm.copyWith(
                color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
              ),
            ),
          )
        else
          SizedBox(
            height: 270,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final product = products[index];
                return QuickCommerceProductCard(product: product);
              },
            ),
          ),
      ],
    );
  }

  // =========================================================================
  // 7. RESTAURANT DISHES CAROUSEL
  // =========================================================================
  Widget _buildRestaurantDishesCarousel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCuisine =
        _restaurantCuisines[_selectedRestaurantCuisineIndex]['cuisine']
            as String;
    final allRecipes = MockDataService.recipes;

    final filtered = selectedCuisine == 'All'
        ? allRecipes.take(8).toList()
        : allRecipes
              .where(
                (r) => r.cuisine.toLowerCase() == selectedCuisine.toLowerCase(),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RESTAURANT RECIPES & COOKING KITS',
                    style: AppTypography.metadata.copyWith(
                      color: isDark ? AppColors.secondary : AppColors.burntSienna,
                      letterSpacing: 1.2,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cook Gourmet Kitchen Specials',
                    style: AppTypography.headlineSm.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(1);
                }
              },
              child: Text(
                'BROWSE ALL (${allRecipes.length}) →',
                style: AppTypography.metadata.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Cuisine pills
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _restaurantCuisines.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final c = _restaurantCuisines[index];
              final isSelected = _selectedRestaurantCuisineIndex == index;

              return InkWell(
                onTap: () =>
                    setState(() => _selectedRestaurantCuisineIndex = index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondaryOrange
                        : (isDark ? AppColors.surfaceContainer : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondaryOrange
                          : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                    ),
                    boxShadow: isDark || isSelected
                        ? null
                        : [
                            const BoxShadow(
                              color: Color(0x068A4B08),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Text(
                    c['name'] as String,
                    style: AppTypography.bodySm.copyWith(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 215,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final recipe = filtered[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: recipe),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 168,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceContainer : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.gridLine : AppColors.lightBorder,
                    ),
                    boxShadow: isDark
                        ? null
                        : [
                            const BoxShadow(
                              color: Color(0x0A8A4B08),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 105,
                            width: 168,
                            child: Image.network(
                              recipe.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                                child: const Center(
                                  child: Icon(
                                    Icons.restaurant,
                                    color: AppColors.secondary,
                                  ),
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
                            bottom: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 10,
                                    color: AppColors.gold,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${recipe.rating}',
                                    style: AppTypography.metadata.copyWith(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.title,
                              style: AppTypography.bodySm.copyWith(
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              recipe.cuisine,
                              style: AppTypography.metadata.copyWith(
                                color: isDark ? AppColors.secondary : AppColors.burntSienna,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Kit: ₹199',
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.sproutGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '⏱ ${recipe.totalTimeMinutes}m',
                                  style: AppTypography.metadata.copyWith(
                                    fontSize: 9.5,
                                    color: isDark ? AppColors.secondary : AppColors.lightTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 8. ACTIVE LIVE DELIVERY BANNER
  // =========================================================================
  Widget _buildActiveDeliveryBanner(
    BuildContext context,
    JeerolaDeliveryViewModel deliveryVm,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final order = deliveryVm.activeOrder;
    if (order == null) return const SizedBox.shrink();

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const JeerolaOrderTrackingScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.25),
              isDark ? AppColors.surfaceContainerHigh : const Color(0xFFFFF7ED),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.delivery_dining,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.sproutGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'EXPRESS GROCERY & KIT DELIVERY',
                          style: AppTypography.metadata.copyWith(
                            color: AppColors.sproutGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                            letterSpacing: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.status.displayName,
                    style: AppTypography.headlineSm.copyWith(
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    order.estimatedMinutesRemaining > 0
                        ? 'ETA ~${order.estimatedMinutesRemaining} mins • Tap to track courier'
                        : 'Arrived at your gate • Handover PIN: ${order.handoverOtp}',
                    style: AppTypography.bodySm.copyWith(
                      color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TRACK',
                    style: AppTypography.metadata.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 9. SMART MEAL PLANNER CARD
  // =========================================================================
  Widget _buildSmartMealPlannerCard(
    BuildContext context,
    HomeViewModel homeVm,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BrutalistCard(
      borderColor: isDark ? AppColors.primaryContainer : AppColors.primary.withValues(alpha: 0.3),
      borderWidth: 1.5,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SMART MEAL PLANNER',
                style: AppTypography.metadata.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const Icon(
                Icons.calendar_month,
                color: AppColors.primary,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Automate Weekly & Monthly Grocery Pack',
            style: AppTypography.headlineMd,
          ),
          const SizedBox(height: 6),
          Text(
            'Auto-aggregate ingredients across recipes, apply 15% safety buffer, and map to nearest market packs.',
            style: AppTypography.bodySm,
          ),
          const SizedBox(height: 14),

          // 7 / 15 / 30 Days Toggle
          Row(
            children: [7, 15, 30].map((days) {
              final isSelected = homeVm.selectedDurationDays == days;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: InkWell(
                    onTap: () => homeVm.updateDuration(days),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$days DAYS',
                        style: AppTypography.metadata.copyWith(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {
              if (widget.onNavigateTab != null) {
                widget.onNavigateTab!(3); // Go to shopping cart
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('GENERATE COMBINED BASKET'),
          ),
        ],
      ),
    );
  }
}
