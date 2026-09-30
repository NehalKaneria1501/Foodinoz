import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Theme & Core
import 'core/theme/app_theme.dart';
import 'core/utils/market_pack_engine.dart';

// Services
import 'data/services/affiliate_service.dart';
import 'data/services/auth_api_service.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/firebase_messaging_service.dart';

// Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/cooking_repository.dart';
import 'data/repositories/meal_plan_repository.dart';
import 'data/repositories/recipe_repository.dart';
import 'data/repositories/shopping_repository.dart';

// ViewModels
import 'ui/features/auth/view_models/auth_view_model.dart';
import 'ui/features/home/view_models/home_view_model.dart';
import 'ui/features/meal_planner/view_models/meal_planner_view_model.dart';
import 'ui/features/profile/view_models/profile_view_model.dart';
import 'ui/features/recipes/view_models/recipe_view_model.dart';
import 'ui/features/shopping_list/view_models/shopping_list_view_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'data/services/jeerola_delivery_service.dart';
import 'data/services/firebase_analytics_service.dart';
import 'data/services/firebase_free_services.dart';
import 'ui/features/ai_chat/view_models/jeerola_ai_chat_view_model.dart';
import 'ui/features/delivery/view_models/jeerola_delivery_view_model.dart';
import 'ui/features/splash/views/splash_screen.dart';

/// Global ScaffoldMessenger key to render pure Flutter in-app notification banners
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Global Navigator key for app-wide toasts and navigation overlays
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Immediately launch Flutter UI so screen renders on frame 1 without any blank screen
  runApp(const JeerolaApp());

  // 2. Initialize Firebase and background services asynchronously without blocking the UI thread
  unawaited(
    FirebaseFreeServices.instance.initializeAll().catchError((e) {
      debugPrint('Firebase free services initialized in fallback mode: $e');
    }),
  );
}

class JeerolaApp extends StatefulWidget {
  const JeerolaApp({super.key});

  @override
  State<JeerolaApp> createState() => _JeerolaAppState();
}

class _JeerolaAppState extends State<JeerolaApp> {
  StreamSubscription? _fcmSubscription;
  late final LocalStorageService _localStorageService;
  late final AuthApiService _authApiService;
  late final AffiliateService _affiliateService;
  late final MarketPackEngine _marketPackEngine;
  late final AuthRepository _authRepository;
  late final RecipeRepository _recipeRepository;
  late final MealPlanRepository _mealPlanRepository;
  late final ShoppingRepository _shoppingRepository;
  late final CookingRepository _cookingRepository;
  late final JeerolaDeliveryService _deliveryService;

  @override
  void initState() {
    super.initState();
    _localStorageService = LocalStorageService();
    _localStorageService.init();
    _authApiService = AuthApiService();
    _affiliateService = AffiliateService();
    _marketPackEngine = const MarketPackEngine(bufferPercentage: 0.15);

    _authRepository = AuthRepository(
      localStorageService: _localStorageService,
      authApiService: _authApiService,
    );
    _recipeRepository = RecipeRepository();
    _mealPlanRepository = MealPlanRepository(localStorageService: _localStorageService);
    _shoppingRepository = ShoppingRepository(
      affiliateService: _affiliateService,
      engine: _marketPackEngine,
    );
    _cookingRepository = CookingRepository();
    _deliveryService = JeerolaDeliveryService();

    // Listen to push notification stream purely in Flutter (Zero native Android Java/Kotlin dependencies)
    _fcmSubscription = FirebaseMessagingService.instance.onMessageStream.listen((message) {
      final title = message.notification?.title ?? message.data['title'] ?? 'Jeerola Notification';
      final body = message.notification?.body ?? message.data['body'] ?? '';

      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Color(0xFFD4AF37)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    if (body.isNotEmpty)
                      Text(
                        body,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                  ],
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    _authApiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<AuthRepository>.value(value: _authRepository),
        Provider<RecipeRepository>.value(value: _recipeRepository),
        Provider<MealPlanRepository>.value(value: _mealPlanRepository),
        Provider<ShoppingRepository>.value(value: _shoppingRepository),
        ChangeNotifierProvider<CookingRepository>.value(value: _cookingRepository),
        Provider<JeerolaDeliveryService>.value(value: _deliveryService),

        // ViewModels
        ChangeNotifierProvider<JeerolaDeliveryViewModel>(
          create: (_) => JeerolaDeliveryViewModel(deliveryService: _deliveryService),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(authRepository: _authRepository),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => HomeViewModel(
            authRepository: _authRepository,
            mealPlanRepository: _mealPlanRepository,
            recipeRepository: _recipeRepository,
            cookingRepository: _cookingRepository,
          ),
        ),
        ChangeNotifierProvider<MealPlannerViewModel>(
          create: (_) => MealPlannerViewModel(
            mealPlanRepository: _mealPlanRepository,
            recipeRepository: _recipeRepository,
            shoppingRepository: _shoppingRepository,
          ),
        ),
        ChangeNotifierProvider<ShoppingListViewModel>(
          create: (_) => ShoppingListViewModel(
            shoppingRepository: _shoppingRepository,
            mealPlanRepository: _mealPlanRepository,
          ),
        ),
        ChangeNotifierProvider<RecipeViewModel>(
          create: (_) => RecipeViewModel(recipeRepository: _recipeRepository),
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => ProfileViewModel(
            authRepository: _authRepository,
            cookingRepository: _cookingRepository,
          ),
        ),
        ChangeNotifierProvider<JeerolaAiChatViewModel>(
          create: (_) => JeerolaAiChatViewModel(),
        ),
      ],
      child: Consumer<ProfileViewModel>(
        builder: (context, profileVm, child) {
          final isLight = profileVm.themeMode == 'light';
          return MaterialApp(
            title: 'Jeerola - Restaurant & Spice Kitchen',
            navigatorKey: rootNavigatorKey,
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
            navigatorObservers: [
              if (FirebaseAnalyticsService.instance.analytics != null)
                FirebaseAnalyticsObserver(analytics: FirebaseAnalyticsService.instance.analytics!),
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}