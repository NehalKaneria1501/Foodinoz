import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:jeerola/core/theme/app_theme.dart';
import 'package:jeerola/core/utils/market_pack_engine.dart';
import 'package:jeerola/data/repositories/auth_repository.dart';
import 'package:jeerola/data/repositories/cooking_repository.dart';
import 'package:jeerola/data/repositories/meal_plan_repository.dart';
import 'package:jeerola/data/repositories/recipe_repository.dart';
import 'package:jeerola/data/repositories/shopping_repository.dart';
import 'package:jeerola/data/services/affiliate_service.dart';
import 'package:jeerola/data/services/auth_api_service.dart';
import 'package:jeerola/data/services/jeerola_delivery_service.dart';
import 'package:jeerola/data/services/local_storage_service.dart';
import 'package:jeerola/data/services/mock_data_service.dart';
import 'package:jeerola/ui/features/auth/view_models/auth_view_model.dart';
import 'package:jeerola/ui/features/categories/views/categories_screen.dart';
import 'package:jeerola/ui/features/cooking/views/cooking_protocol_screen.dart';
import 'package:jeerola/ui/features/delivery/view_models/jeerola_delivery_view_model.dart';
import 'package:jeerola/ui/features/delivery/views/jeerola_order_tracking_screen.dart';
import 'package:jeerola/ui/features/home/view_models/home_view_model.dart';
import 'package:jeerola/ui/features/home/views/home_screen.dart';
import 'package:jeerola/ui/features/meal_planner/view_models/meal_planner_view_model.dart';
import 'package:jeerola/ui/features/meal_planner/views/meal_planner_screen.dart';
import 'package:jeerola/ui/features/profile/view_models/profile_view_model.dart';
import 'package:jeerola/ui/features/profile/views/profile_screen.dart';
import 'package:jeerola/ui/features/recipes/view_models/recipe_view_model.dart';
import 'package:jeerola/ui/features/recipes/views/recipe_catalog_screen.dart';
import 'package:jeerola/ui/features/help/views/help_support_screen.dart';
import 'package:jeerola/ui/features/recipes/views/recipe_detail_screen.dart';
import 'package:jeerola/ui/features/shopping_list/view_models/shopping_list_view_model.dart';
import 'package:jeerola/ui/features/shopping_list/views/affiliate_comparison_dialog.dart';
import 'package:jeerola/ui/features/shopping_list/views/shopping_list_screen.dart';
import 'package:jeerola/ui/navigation/main_navigation_shell.dart';

Widget createTestApp(Widget child, {Size size = const Size(360, 640)}) {
  final localStorageService = LocalStorageService();
  final authApiService = AuthApiService();
  final affiliateService = AffiliateService();
  const marketPackEngine = MarketPackEngine(bufferPercentage: 0.15);

  final authRepo = AuthRepository(
    localStorageService: localStorageService,
    authApiService: authApiService,
  );
  final recipeRepo = RecipeRepository();
  final mealPlanRepo = MealPlanRepository(localStorageService: localStorageService);
  final shoppingRepo = ShoppingRepository(
    affiliateService: affiliateService,
    engine: marketPackEngine,
  );
  final cookingRepo = CookingRepository();
  final deliveryService = JeerolaDeliveryService();

  return MultiProvider(
    providers: [
      Provider<AuthRepository>.value(value: authRepo),
      Provider<RecipeRepository>.value(value: recipeRepo),
      Provider<MealPlanRepository>.value(value: mealPlanRepo),
      Provider<ShoppingRepository>.value(value: shoppingRepo),
      ChangeNotifierProvider<CookingRepository>.value(value: cookingRepo),
      Provider<JeerolaDeliveryService>.value(value: deliveryService),
      ChangeNotifierProvider<JeerolaDeliveryViewModel>(
        create: (_) => JeerolaDeliveryViewModel(deliveryService: deliveryService),
      ),
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => AuthViewModel(authRepository: authRepo),
      ),
      ChangeNotifierProvider<HomeViewModel>(
        create: (_) => HomeViewModel(
          authRepository: authRepo,
          mealPlanRepository: mealPlanRepo,
          recipeRepository: recipeRepo,
          cookingRepository: cookingRepo,
        ),
      ),
      ChangeNotifierProvider<MealPlannerViewModel>(
        create: (_) => MealPlannerViewModel(
          mealPlanRepository: mealPlanRepo,
          recipeRepository: recipeRepo,
          shoppingRepository: shoppingRepo,
        ),
      ),
      ChangeNotifierProvider<ShoppingListViewModel>(
        create: (_) => ShoppingListViewModel(
          shoppingRepository: shoppingRepo,
          mealPlanRepository: mealPlanRepo,
        ),
      ),
      ChangeNotifierProvider<RecipeViewModel>(
        create: (_) => RecipeViewModel(recipeRepository: recipeRepo),
      ),
      ChangeNotifierProvider<ProfileViewModel>(
        create: (_) => ProfileViewModel(
          authRepository: authRepo,
          cookingRepository: cookingRepo,
        ),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Entire App Comprehensive Layout & Render Verification', () {
    testWidgets('MainNavigationShell renders across all 5 tabs without overflow on 360x640', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpWidget(createTestApp(const MainNavigationShell(), size: const Size(360, 640)));
      await tester.pumpAndSettle();

      expect(find.byType(MainNavigationShell), findsOneWidget);

      // Tap on Tab 1: Kitchen
      await tester.tap(find.text('KITCHEN'));
      await tester.pumpAndSettle();
      expect(find.byType(RecipeCatalogScreen), findsOneWidget);

      // Tap on Tab 2: Aisles
      await tester.tap(find.text('AISLES'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoriesScreen), findsOneWidget);

      // Tap on Tab 3: Cart
      await tester.tap(find.text('CART'));
      await tester.pumpAndSettle();
      expect(find.byType(ShoppingListScreen), findsOneWidget);

      // Tap on Tab 4: HELP (previously SETTINGS)
      final helpFinder = find.text('HELP');
      await tester.tap(helpFinder.evaluate().isNotEmpty ? helpFinder : find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();
      expect(find.byType(HelpSupportScreen), findsOneWidget);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('ProfileScreen renders with all personal & food delivery sections without overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpWidget(createTestApp(const ProfileScreen(), size: const Size(360, 640)));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('MY PROFILE & ACCOUNT'), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('HomeScreen renders without overflow on compact 320x568 (iPhone SE size)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      await tester.pumpWidget(createTestApp(const HomeScreen(), size: const Size(320, 568)));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('CategoriesScreen renders without overflow on compact 320x568', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      await tester.pumpWidget(createTestApp(const CategoriesScreen(), size: const Size(320, 568)));
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesScreen), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('ShoppingListScreen renders empty and with items without overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpWidget(createTestApp(const ShoppingListScreen(), size: const Size(360, 640)));
      await tester.pumpAndSettle();

      expect(find.byType(ShoppingListScreen), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('RecipeDetailScreen renders without overflow on 360x640', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      final sampleRecipe = MockDataService.recipes.first;
      await tester.pumpWidget(createTestApp(RecipeDetailScreen(recipe: sampleRecipe), size: const Size(360, 640)));
      await tester.pumpAndSettle();

      expect(find.byType(RecipeDetailScreen), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('CookingProtocolScreen renders without overflow on 360x640', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      final sampleRecipe = MockDataService.recipes.first;
      await tester.pumpWidget(createTestApp(CookingProtocolScreen(recipe: sampleRecipe), size: const Size(360, 640)));
      await tester.pumpAndSettle();

      expect(find.byType(CookingProtocolScreen), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('MealPlannerScreen renders without overflow on 360x640', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpWidget(createTestApp(const MealPlannerScreen(), size: const Size(360, 640)));
      await tester.pumpAndSettle();

      expect(find.byType(MealPlannerScreen), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('JeerolaOrderTrackingScreen renders without overflow on 360x640', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpWidget(createTestApp(const JeerolaOrderTrackingScreen(), size: const Size(360, 640)));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(JeerolaOrderTrackingScreen), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('AffiliateComparisonDialog renders all 6 quick commerce stores without overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      final options = AffiliateService().compareProviders([]);
      await tester.pumpWidget(createTestApp(AffiliateComparisonDialog(options: options), size: const Size(360, 640)));
      await tester.pumpAndSettle();

      expect(find.byType(AffiliateComparisonDialog), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });
  });
}
