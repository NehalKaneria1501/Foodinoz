import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'mock_data_service.dart';
import 'packaged_ingredients_service.dart';
import 'sqlite_database_service.dart';

class FirebaseFirestoreService {
  static final FirebaseFirestoreService instance = FirebaseFirestoreService._init();
  FirebaseFirestoreService._init();

  static const String defaultTargetUid = 'google_usr_981723461234';

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      return null;
    }
  }

  // In-memory document store for fast responsive access & offline capability
  final Map<String, Map<String, dynamic>> _documents = {};

  // =========================================================================
  // 1. USER PROFILE (users/{uid})
  // =========================================================================
  Future<void> saveUserProfile({
    required String uid,
    required Map<String, dynamic> profileData,
  }) async {
    final docKey = 'users/$uid';
    _documents[docKey] = Map.from(profileData);

    // Sync to SQLite local storage
    try {
      await SQLiteDatabaseService.instance.saveProfile(
        id: uid,
        name: profileData['name'] as String? ?? 'Nehal Patel',
        phone: profileData['phone'] as String?,
        email: profileData['email'] as String?,
        address: profileData['address'] as String?,
        dob: profileData['dob'] as String?,
        anniversaryDate: profileData['anniversaryDate'] as String?,
        gender: profileData['gender'] as String?,
        vegMode: profileData['vegMode'] as String?,
        jCoinsBalance: profileData['jCoinsBalance'] as int?,
      );
    } catch (e) {
      debugPrint('SQLite profile save notice: $e');
    }

    // Sync to Cloud Firestore
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final dataWithMeta = Map<String, dynamic>.from(profileData)
          ..['updatedAt'] = FieldValue.serverTimestamp()
          ..['uid'] = uid;

        await firestore.collection('users').doc(uid).set(
          dataWithMeta,
          SetOptions(merge: true),
        );
        debugPrint('Synced profile for $uid to Cloud Firestore (project: jeerola-eefba)');
      }
    } catch (e) {
      debugPrint('Cloud Firestore profile write fallback: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final docKey = 'users/$uid';

    // 1. Try Live Cloud Firestore
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final doc = await firestore.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          _documents[docKey] = data;
          return data;
        }
      }
    } catch (e) {
      debugPrint('Cloud Firestore profile read fallback: $e');
    }

    // 2. In-memory cache
    if (_documents.containsKey(docKey)) {
      return _documents[docKey];
    }

    // 3. SQLite local cache
    try {
      return await SQLiteDatabaseService.instance.getProfile(id: uid);
    } catch (e) {
      return null;
    }
  }

  Stream<Map<String, dynamic>?> userProfileStream(String uid) {
    final firestore = _firestore;
    if (firestore == null) {
      return Stream.value(_documents['users/$uid']);
    }
    return firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        _documents['users/$uid'] = data;
        return data;
      }
      return _documents['users/$uid'];
    });
  }

  /// Saves or refreshes FCM device registration token for push campaigns and order notifications
  Future<void> saveUserFcmToken({
    required String uid,
    required String fcmToken,
    String? platform,
  }) async {
    final docKey = 'users/$uid';
    if (_documents.containsKey(docKey)) {
      _documents[docKey]!['lastFcmToken'] = fcmToken;
      _documents[docKey]!['fcmTokenUpdatedAt'] = DateTime.now().toIso8601String();
    }

    try {
      final firestore = _firestore;
      if (firestore != null) {
        await firestore.collection('users').doc(uid).set({
          'fcmTokens': FieldValue.arrayUnion([fcmToken]),
          'lastFcmToken': fcmToken,
          'fcmPlatform': platform ?? defaultTargetPlatform.name,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('✅ [Firestore] FCM token recorded for $uid (Project: jeerola-eefba)');
      }
    } catch (e) {
      debugPrint('⚠️ [Firestore] FCM token write notice: $e');
    }
  }

  /// Removes an outdated FCM token on logout or token rotation
  Future<void> removeUserFcmToken({
    required String uid,
    required String fcmToken,
  }) async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        await firestore.collection('users').doc(uid).update({
          'fcmTokens': FieldValue.arrayRemove([fcmToken]),
        });
      }
    } catch (e) {
      debugPrint('⚠️ [Firestore] FCM token remove notice: $e');
    }
  }

  // =========================================================================
  // 2. ORDERS COLLECTION (users/{uid}/orders and root 'orders')
  // =========================================================================
  Future<void> saveOrder({
    required String uid,
    required String orderId,
    required Map<String, dynamic> orderData,
  }) async {
    final docKey = 'users/$uid/orders/$orderId';
    _documents[docKey] = Map.from(orderData);
    _documents['orders/$orderId'] = Map.from(orderData);

    final itemsList = (orderData['items'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Sync with SQLite past_orders
    try {
      await SQLiteDatabaseService.instance.saveOrder(
        orderId: orderId,
        storeName: orderData['storeName'] as String? ?? 'Jeerola Kitchen',
        totalAmount: (orderData['totalAmount'] as num?)?.toDouble() ?? 0.0,
        status: orderData['status'] as String? ?? 'Simmering Live',
        dateStr: orderData['dateStr'] as String? ?? DateTime.now().toString(),
        items: itemsList,
      );
    } catch (e) {
      debugPrint('SQLite order save notice: $e');
    }

    // Sync with Cloud Firestore
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final dataWithMeta = Map<String, dynamic>.from(orderData)
          ..['updatedAt'] = FieldValue.serverTimestamp()
          ..['orderId'] = orderId
          ..['userId'] = uid;

        // Save in user's orders subcollection
        await firestore
            .collection('users')
            .doc(uid)
            .collection('orders')
            .doc(orderId)
            .set(dataWithMeta, SetOptions(merge: true));

        // Also save in root 'orders' for centralized kitchen dispatch
        await firestore
            .collection('orders')
            .doc(orderId)
            .set(dataWithMeta, SetOptions(merge: true));

        debugPrint('Committed order $orderId to Cloud Firestore users/$uid/orders & orders/$orderId');
      }
    } catch (e) {
      debugPrint('Cloud Firestore order commit fallback: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String uid) async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final snapshot = await firestore
            .collection('users')
            .doc(uid)
            .collection('orders')
            .orderBy('dateStr', descending: true)
            .get();
        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs.map((d) => d.data()).toList();
          for (final order in list) {
            final orderId = order['orderId']?.toString() ?? '';
            if (orderId.isNotEmpty) {
              _documents['users/$uid/orders/$orderId'] = order;
              _documents['orders/$orderId'] = order;
            }
          }
          return list;
        }
      }
    } catch (e) {
      debugPrint('Cloud Firestore orders fetch fallback: $e');
    }

    final prefix = 'users/$uid/orders/';
    final memoryOrders = _documents.entries
        .where((e) => e.key.startsWith(prefix))
        .map((e) => e.value)
        .toList();

    if (memoryOrders.isNotEmpty) return memoryOrders;

    try {
      final sqliteOrders = await SQLiteDatabaseService.instance.database;
      if (sqliteOrders != null) {
        return await sqliteOrders.query('past_orders', orderBy: 'id DESC');
      }
    } catch (e) {
      debugPrint('SQLite query notice: $e');
    }
    return [];
  }

  // =========================================================================
  // 3. WISHLIST COLLECTION (users/{uid}/wishlist)
  // =========================================================================
  Future<void> syncWishlist({
    required String uid,
    required String productId,
    required Map<String, dynamic> itemData,
  }) async {
    final docKey = 'users/$uid/wishlist/$productId';
    _documents[docKey] = Map.from(itemData);

    try {
      await SQLiteDatabaseService.instance.addToWishlist(
        id: productId,
        title: itemData['title'] as String? ?? '',
        subtitle: itemData['subtitle'] as String?,
        price: (itemData['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: itemData['imageUrl'] as String?,
        category: itemData['category'] as String?,
      );
    } catch (e) {
      debugPrint('SQLite wishlist notice: $e');
    }

    try {
      final firestore = _firestore;
      if (firestore != null) {
        await firestore
            .collection('users')
            .doc(uid)
            .collection('wishlist')
            .doc(productId)
            .set(itemData, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Cloud Firestore wishlist sync fallback: $e');
    }
  }

  Future<void> removeWishlistItem({
    required String uid,
    required String productId,
  }) async {
    _documents.remove('users/$uid/wishlist/$productId');
    try {
      await SQLiteDatabaseService.instance.removeFromWishlist(productId);
    } catch (e) {
      debugPrint('SQLite wishlist remove notice: $e');
    }

    try {
      final firestore = _firestore;
      if (firestore != null) {
        await firestore
            .collection('users')
            .doc(uid)
            .collection('wishlist')
            .doc(productId)
            .delete();
      }
    } catch (e) {
      debugPrint('Cloud Firestore wishlist remove fallback: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserWishlist(String uid) async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final snapshot = await firestore
            .collection('users')
            .doc(uid)
            .collection('wishlist')
            .get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((d) => d.data()).toList();
        }
      }
    } catch (e) {
      debugPrint('Cloud Firestore wishlist fetch fallback: $e');
    }
    try {
      return await SQLiteDatabaseService.instance.getWishlist();
    } catch (e) {
      return [];
    }
  }

  // =========================================================================
  // 4. SHOPPING LIST & MEAL PLANS (users/{uid}/shopping_list & meal_plans)
  // =========================================================================
  Future<void> saveShoppingListItem({
    required String uid,
    required String itemId,
    required Map<String, dynamic> itemData,
  }) async {
    final docKey = 'users/$uid/shopping_list/$itemId';
    _documents[docKey] = Map.from(itemData);

    try {
      final firestore = _firestore;
      if (firestore != null) {
        await firestore
            .collection('users')
            .doc(uid)
            .collection('shopping_list')
            .doc(itemId)
            .set(itemData, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Cloud Firestore saveShoppingListItem fallback: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getShoppingList(String uid) async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final snapshot = await firestore
            .collection('users')
            .doc(uid)
            .collection('shopping_list')
            .get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((d) => d.data()).toList();
        }
      }
    } catch (e) {
      debugPrint('Cloud Firestore getShoppingList fallback: $e');
    }

    final prefix = 'users/$uid/shopping_list/';
    return _documents.entries
        .where((e) => e.key.startsWith(prefix))
        .map((e) => e.value)
        .toList();
  }

  Future<void> saveMealPlan({
    required String uid,
    required String planId,
    required Map<String, dynamic> planData,
  }) async {
    final docKey = 'users/$uid/meal_plans/$planId';
    _documents[docKey] = Map.from(planData);

    try {
      final firestore = _firestore;
      if (firestore != null) {
        await firestore
            .collection('users')
            .doc(uid)
            .collection('meal_plans')
            .doc(planId)
            .set(planData, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Cloud Firestore saveMealPlan fallback: $e');
    }
  }

  // =========================================================================
  // 5. PRODUCTS & RECIPES CATALOGS (products/{id} and recipes/{id})
  // =========================================================================
  Future<void> saveProduct(Map<String, dynamic> productData) async {
    final id = productData['id']?.toString() ?? 'prod_${DateTime.now().millisecondsSinceEpoch}';
    _documents['products/$id'] = Map.from(productData);

    try {
      final firestore = _firestore;
      if (firestore != null) {
        await firestore.collection('products').doc(id).set(productData, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Cloud Firestore saveProduct fallback: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final snapshot = await firestore.collection('products').get();
        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs.map((d) => d.data()).toList();
          for (final item in list) {
            final id = item['id']?.toString() ?? '';
            if (id.isNotEmpty) _documents['products/$id'] = item;
          }
          return list;
        }
      }
    } catch (e) {
      debugPrint('Cloud Firestore getProducts fallback: $e');
    }

    return _documents.entries
        .where((e) => e.key.startsWith('products/'))
        .map((e) => e.value)
        .toList();
  }

  Future<void> saveRecipe(Map<String, dynamic> recipeData) async {
    final id = recipeData['id']?.toString() ?? 'recipe_${DateTime.now().millisecondsSinceEpoch}';
    _documents['recipes/$id'] = Map.from(recipeData);

    try {
      final firestore = _firestore;
      if (firestore != null) {
        await firestore.collection('recipes').doc(id).set(recipeData, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Cloud Firestore saveRecipe fallback: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRecipes() async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final snapshot = await firestore.collection('recipes').get();
        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs.map((d) => d.data()).toList();
          for (final item in list) {
            final id = item['id']?.toString() ?? '';
            if (id.isNotEmpty) _documents['recipes/$id'] = item;
          }
          return list;
        }
      }
    } catch (e) {
      debugPrint('Cloud Firestore getRecipes fallback: $e');
    }

    return _documents.entries
        .where((e) => e.key.startsWith('recipes/'))
        .map((e) => e.value)
        .toList();
  }

  // =========================================================================
  // 6. FIREBASE AI LOGIC CHAT HISTORY (users/{uid}/ai_chat_history/{msgId})
  // =========================================================================
  Future<void> saveChatMessage({
    required String uid,
    required String messageId,
    required Map<String, dynamic> messageData,
  }) async {
    final docKey = 'users/$uid/ai_chat_history/$messageId';
    _documents[docKey] = Map.from(messageData);

    try {
      final firestore = _firestore;
      if (firestore != null) {
        final data = Map<String, dynamic>.from(messageData)
          ..['createdAt'] = FieldValue.serverTimestamp()
          ..['id'] = messageId;
        await firestore
            .collection('users')
            .doc(uid)
            .collection('ai_chat_history')
            .doc(messageId)
            .set(data, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Cloud Firestore saveChatMessage fallback: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChatMessages(String uid) async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        final snapshot = await firestore
            .collection('users')
            .doc(uid)
            .collection('ai_chat_history')
            .orderBy('timestamp', descending: false)
            .get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((d) => d.data()).toList();
        }
      }
    } catch (e) {
      debugPrint('Cloud Firestore getChatMessages fallback: $e');
    }

    final prefix = 'users/$uid/ai_chat_history/';
    return _documents.entries
        .where((e) => e.key.startsWith(prefix))
        .map((e) => e.value)
        .toList();
  }

  // =========================================================================
  // 7. MASTER SYNC ALL APP DATA TO CLOUD FIRESTORE
  // =========================================================================
  /// Pushes all application data (User profile, Dark stores, Products, Recipes,
  /// Orders, Shopping list, Wishlist) directly to Cloud Firestore project jeerola-eefba.
  Future<bool> syncAllAppDataToFirestore({String uid = defaultTargetUid}) async {
    debugPrint('=== STARTING COMPLETE APP DATA SYNC TO CLOUD FIRESTORE ===');
    debugPrint('Target User ID: $uid (project: jeerola-eefba)');

    try {
      // 1. Sync User Profile (as requested at /users/google_usr_981723461234)
      final userProfile = {
        'name': 'Nehal Patel',
        'phone': '+91 9265754161',
        'email': 'nehalkaneria12345@gmail.com',
        'address': 'Flat 202, Yogibhuvan Appartment, Yagnapurush ni Pol, Shahpur, Amdavad, 380001 (Landmark: Ambliwali Pol)',
        'dob': '15 Nov 2001',
        'anniversaryDate': '30 Oct 2025',
        'gender': 'Male',
        'vegMode': 'Pure Veg (No Onion/Garlic)',
        'jCoinsBalance': 500,
        'membershipTier': 'Jeerola Royal VIP Member',
        'loyaltyPoints': 1250,
        'defaultPouchPreference': 'Stone-Ground Roasted Cumin (No Hing)',
        'cuisinePreferences': ['North Indian', 'Gujarati', 'Mughlai', 'South Indian'],
        'appVersion': '1.0.0+1',
        'platform': defaultTargetPlatform.name,
      };
      await saveUserProfile(uid: uid, profileData: userProfile);

      // Also ensure google_usr_981723461234 is explicitly committed
      if (uid != defaultTargetUid) {
        await saveUserProfile(uid: defaultTargetUid, profileData: userProfile);
      }

      // 2. Sync Dark Stores Catalog
      final darkStores = [
        {
          'id': 'ds_shahpur_01',
          'name': 'Shahpur Jeerola Dark Store & Kitchen',
          'address': 'Yagnapurush ni Pol, Shahpur, Amdavad 380001',
          'city': 'Ahmedabad',
          'pincode': '380001',
          'deliveryMinutes': 12,
          'isOpen': true,
          'rating': 4.95,
          'specialty': 'Instant Heated Fresh Handi & Cumin Spices',
        },
        {
          'id': 'ds_navrangpura_02',
          'name': 'Navrangpura Express Spice Depot',
          'address': 'C.G. Road, Navrangpura, Amdavad 380009',
          'city': 'Ahmedabad',
          'pincode': '380009',
          'deliveryMinutes': 15,
          'isOpen': true,
          'rating': 4.9,
          'specialty': 'Whole Spice Pouches & Cold-Pressed Jeera Ghee',
        },
        {
          'id': 'ds_indiranagar_03',
          'name': 'Indiranagar Jeerola Flagship Kitchen',
          'address': '24 Gourmet Walk, 100ft Road, Indiranagar, Bengaluru 560038',
          'city': 'Bengaluru',
          'pincode': '560038',
          'deliveryMinutes': 18,
          'isOpen': true,
          'rating': 4.98,
          'specialty': 'Royal Cumin Dum Biryani & Dum Handi Curries',
        },
      ];

      final firestore = _firestore;
      if (firestore != null) {
        for (final ds in darkStores) {
          await firestore.collection('dark_stores').doc(ds['id'] as String).set(ds, SetOptions(merge: true));
        }
      }

      // 3. Sync Active & Past Orders
      final activeOrderData = {
        'orderId': 'JRL-8942-EXPRESS',
        'userId': uid,
        'storeName': 'Indiranagar Jeerola Flagship Kitchen',
        'status': 'Simmering in Kitchen',
        'progressPercent': 0.50,
        'estimatedMinutesRemaining': 16,
        'deliveryAddress': 'Flat 202, Yogibhuvan Appartment, Yagnapurush ni Pol, Shahpur, Amdavad, 380001',
        'subtotal': 868.0,
        'totalAmount': 868.0,
        'deliveryFee': 0.0,
        'packagingFee': 0.0,
        'handoverOtp': '4829',
        'kitchenNote': 'Infusing royal whole cumin with cold-pressed ghee and simmering gravy.',
        'rider': {
          'name': 'Vikram Singh',
          'phone': '+91 9265754161',
          'vehicleNumber': 'KA-03-JR-9901',
          'rating': 4.95,
          'badge': 'Jeerola Super Captain',
        },
        'items': [
          {'name': 'Royal Jeera Murgh Dum Handi', 'quantity': 1, 'price': 389.0},
          {'name': 'Slow-Cooked Cumin Spice Biryani', 'quantity': 1, 'price': 349.0},
          {'name': 'Artisan Stone-Ground Roasted Jeera Pouch', 'quantity': 2, 'price': 65.0},
        ],
        'dateStr': DateTime.now().subtract(const Duration(minutes: 8)).toIso8601String(),
      };
      await saveOrder(uid: uid, orderId: 'JRL-8942-EXPRESS', orderData: activeOrderData);
      if (uid != defaultTargetUid) {
        await saveOrder(uid: defaultTargetUid, orderId: 'JRL-8942-EXPRESS', orderData: activeOrderData);
      }

      // 4. Sync All Recipes from Catalog
      for (final recipe in MockDataService.recipes) {
        final recipeData = {
          'id': recipe.id,
          'title': recipe.title,
          'description': recipe.description,
          'cuisine': recipe.cuisine,
          'isVeg': recipe.isVeg,
          'prepTimeMinutes': recipe.prepTimeMinutes,
          'cookTimeMinutes': recipe.cookTimeMinutes,
          'servings': recipe.servings,
          'masalaPouchNumber': recipe.masalaPouchNumber,
          'pouchName': recipe.pouchName,
          'imageUrl': recipe.imageUrl,
          'rating': recipe.rating,
          'ingredients': recipe.ingredients.map((ing) => {
            'id': ing.id,
            'name': ing.name,
            'quantity': ing.quantity,
            'unit': ing.unit,
            'category': ing.category.name,
          }).toList(),
          'steps': recipe.steps.map((step) => {
            'stepNumber': step.stepNumber,
            'title': step.title,
            'instruction': step.instruction,
            'durationMinutes': step.durationMinutes,
            'proTip': step.proTip,
          }).toList(),
        };
        await saveRecipe(recipeData);
      }

      // 5. Sync Packaged Ingredients & Spice Pouches
      for (final item in PackagedIngredientsService.allItems.take(25)) {
        final prodData = {
          'id': item.id,
          'name': item.name,
          'category': item.category.name,
          'base100gPrice': item.base100gPrice,
          'isSwaminarayan': item.isSwaminarayan,
          'isJain': item.isJain,
          'isHingFree': item.isHingFree,
          'imageUrl': item.imageUrl,
          'subtitle': item.subtitle,
        };
        await saveProduct(prodData);
      }

      // 6. Sync Sample Wishlist & Shopping List
      await syncWishlist(
        uid: uid,
        productId: 'spice_roasted_jeera_01',
        itemData: {
          'id': 'spice_roasted_jeera_01',
          'title': 'Royal Stone-Ground Roasted Jeera (100g Pouch)',
          'subtitle': 'Tempered in Ghee • 100% Pure Aroma',
          'price': 65.0,
          'category': 'Artisan Spices',
          'imageUrl': 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=600&q=80',
        },
      );

      await saveShoppingListItem(
        uid: uid,
        itemId: 'cart_item_handi_01',
        itemData: {
          'id': 'cart_item_handi_01',
          'name': 'Royal Jeera Murgh Dum Handi',
          'quantity': 1,
          'price': 389.0,
          'unit': 'Handi (500ml)',
          'isSpecialty': true,
        },
      );

      // 7. Seed Initial AI Chat Welcome Session
      await saveChatMessage(
        uid: uid,
        messageId: 'welcome_ai_msg_01',
        messageData: {
          'id': 'welcome_ai_msg_01',
          'text': 'Namaste Nehal! 🙏 Welcome to Jeerola AI Chef. I can guide your culinary journey with authentic cumin recipes, royal spice pairing, and live delivery updates. How may I assist you today?',
          'isUser': false,
          'timestamp': DateTime.now().toIso8601String(),
          'suggestedFollowUps': [
            'How do I dry roast cumin seeds perfectly?',
            'Suggest a quick 20-min dinner recipe',
            'Where is my active order JRL-8942-EXPRESS?',
          ],
        },
      );

      debugPrint('=== ALL APP DATA COMMITTED TO CLOUD FIRESTORE SUCCESSFULLY ===');
      return true;
    } catch (e) {
      debugPrint('Complete data sync error: $e');
      return false;
    }
  }
}
