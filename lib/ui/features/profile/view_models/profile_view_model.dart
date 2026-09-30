import 'package:flutter/material.dart';
import '../../../../data/models/gamification_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/cooking_repository.dart';
import '../../../../data/services/firebase_firestore_service.dart';
import '../../../../data/services/live_server_api_service.dart';


class SavedAddress {
  final String id;
  final String title;
  final String addressLine;
  final String landmark;
  final bool isDefault;

  const SavedAddress({
    required this.id,
    required this.title,
    required this.addressLine,
    this.landmark = '',
    this.isDefault = false,
  });

  SavedAddress copyWith({
    String? id,
    String? title,
    String? addressLine,
    String? landmark,
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      title: title ?? this.title,
      addressLine: addressLine ?? this.addressLine,
      landmark: landmark ?? this.landmark,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class PastOrderRecord {
  final String id;
  final String storeName;
  final String dateStr;
  final double totalAmount;
  final String status;
  final List<String> items;

  const PastOrderRecord({
    required this.id,
    required this.storeName,
    required this.dateStr,
    required this.totalAmount,
    required this.status,
    required this.items,
  });
}

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final CookingRepository _cookingRepository;

  ProfileViewModel({
    required this.authRepository,
    required this.cookingRepository,
  }) : _authRepository = authRepository,
       _cookingRepository = cookingRepository {
    _loadProfile();
    _cookingRepository.addListener(_onCookingUpdated);
  }

  final AuthRepository authRepository;
  final CookingRepository cookingRepository;

  void _onCookingUpdated() {
    _gamification = _cookingRepository.gamificationProfile;
    notifyListeners();
  }

  UserModel? _user;
  GamificationProfileModel? _gamification;
  final bool _isLoading = false;

  UserModel? get user => _user;
  GamificationProfileModel? get gamification => _gamification;
  bool get isLoading => _isLoading;

  // Theme management
  String _themeMode = 'light';
  String get themeMode => _user?.themeMode ?? _themeMode;

  // Food delivery collection: 'deliver_to_address' or 'take_away'
  String get collectionPreference => _user?.collectionPreference ?? 'deliver_to_address';

  // Hear from restaurants permission
  bool get hearFromRestaurants => _user?.hearFromRestaurants ?? false;

  // J-Coins Balance
  int get jCoinsBalance => _user?.jCoinsBalance ?? 450;

  // Recommendation toggles
  bool _recRecipeMatches = true;
  bool _recMasalaAlerts = true;
  bool _recCuisineDeals = true;
  bool get recRecipeMatches => _recRecipeMatches;
  bool get recMasalaAlerts => _recMasalaAlerts;
  bool get recCuisineDeals => _recCuisineDeals;

  // Saved Addresses
  final List<SavedAddress> _savedAddresses = [
    const SavedAddress(
      id: 'addr_1',
      title: 'Home',
      addressLine: 'Flat 202, Yogibhuvan Appartment, Yagnapurush ni Pol, Shahpur, Amdavad, 380001',
      landmark: 'Ambliwali Pol',
      isDefault: true,
    ),
    const SavedAddress(
      id: 'addr_2',
      title: 'Office',
      addressLine: 'Analytics Liv, 606, Scarlet Gateway, Prahladnagar - 380015',
      landmark: 'Coorporate Road',
      isDefault: false,
    ),
    const SavedAddress(
      id: 'addr_3',
      title: "Parents' House",
      addressLine: 'Anandnagar Society, Kolki Road, Upleta, 360490',
      landmark: 'Kolki Road',
      isDefault: false,
    ),
  ];
  List<SavedAddress> get savedAddresses => List.unmodifiable(_savedAddresses);

  // Past Orders
  final List<PastOrderRecord> _pastOrders = [
    const PastOrderRecord(
      id: 'ODR-893120',
      storeName: 'Jeerola Dark Store (Indiranagar)',
      dateStr: '24 Sep 2026, 08:30 PM',
      totalAmount: 374.00,
      status: 'Delivered in 9 mins',
      items: ['P-04 Royal Shahi Garam Masala (100g)', 'Kashmiri Saffron (1g)', 'Fresh Kasuri Methi (50g)'],
    ),
    const PastOrderRecord(
      id: 'ODR-892411',
      storeName: 'Royal Spice & Curry Kitchen',
      dateStr: '21 Sep 2026, 01:15 PM',
      totalAmount: 540.00,
      status: 'Delivered',
      items: ['Paneer Tikka Masala Kit', '4 Butter Phulkas', 'Jeera Basmati Rice'],
    ),
    const PastOrderRecord(
      id: 'ODR-889024',
      storeName: 'Jeerola Express Store',
      dateStr: '15 Sep 2026, 07:45 PM',
      totalAmount: 289.00,
      status: 'Delivered',
      items: ['P-01 Lucknowi Biryani Masala', 'Organic Star Anise (50g)'],
    ),
  ];
  List<PastOrderRecord> get pastOrders => List.unmodifiable(_pastOrders);

  // Wishlist
  final List<String> _wishlistItems = [
    'P-01 Lucknowi Biryani Masala (100g)',
    'P-08 Malabar Black Pepper Reserve',
    'Amritsari Chole Pouch Kit (50g)',
    'Cold Pressed Groundnut Oil (1L)',
  ];
  List<String> get wishlistItems => List.unmodifiable(_wishlistItems);

  // Refund records
  final List<Map<String, String>> _refundHistory = [
    {
      'id': 'REF-4821',
      'orderId': 'ODR-874100',
      'amount': '₹120.00',
      'date': '12 Sep 2026',
      'status': 'Credited to Original Source',
      'item': 'Damaged seal on P-02 Pav Bhaji Pouch',
    },
    {
      'id': 'REF-3910',
      'orderId': 'ODR-862015',
      'amount': '₹75.00',
      'date': '28 Aug 2026',
      'status': 'Added to J-Coins Wallet (75 Coins)',
      'item': 'Item out of stock during instant dispatch',
    },
  ];
  List<Map<String, String>> get refundHistory => List.unmodifiable(_refundHistory);

  bool _isSyncingWithServer = false;
  bool get isSyncingWithServer => _isSyncingWithServer;
  DateTime? get lastServerSync => _authRepository.localStorageService.lastServerSync;

  void _loadProfile() {
    _user = _authRepository.getCurrentUser();
    _gamification = _cookingRepository.gamificationProfile;
    if (_user != null) {
      _themeMode = _user!.themeMode;
    }
    notifyListeners();
    // Trigger background sync with live server
    fetchLatestFromServer();
  }

  /// Fetch latest user profile, order history, and wallet details from live server
  Future<bool> fetchLatestFromServer() async {
    if (_user == null) return false;
    _isSyncingWithServer = true;
    notifyListeners();

    try {
      final latestData = await LiveServerApiService.instance.fetchLatestUserProfile(uid: _user!.id);
      if (latestData != null) {
        _user = _user!.copyWith(
          name: latestData['name'] as String? ?? _user!.name,
          email: latestData['email'] as String? ?? _user!.email,
          phoneNumber: (latestData['phone'] ?? latestData['phoneNumber']) as String? ?? _user!.phoneNumber,
          address: latestData['address'] as String? ?? _user!.address,
          jCoinsBalance: (latestData['jCoinsBalance'] as num?)?.toInt() ?? _user!.jCoinsBalance,
          vegMode: latestData['vegMode'] != null
              ? VegModeOption.values.firstWhere(
                  (e) => e.name == latestData['vegMode'],
                  orElse: () => _user!.vegMode,
                )
              : _user!.vegMode,
        );
        _authRepository.localStorageService.saveUser(_user!);
      }

      final serverOrders = await LiveServerApiService.instance.fetchLatestOrders(uid: _user!.id);
      if (serverOrders.isNotEmpty) {
        final parsed = serverOrders.map((o) {
          final itemsRaw = o['items'];
          final itemsList = itemsRaw is List ? itemsRaw.map((e) => e.toString()).toList() : <String>[];
          return PastOrderRecord(
            id: o['id']?.toString() ?? 'ODR-LIVE',
            storeName: o['storeName']?.toString() ?? 'Jeerola Kitchen',
            dateStr: o['dateStr']?.toString() ?? 'Today',
            totalAmount: (o['totalAmount'] as num?)?.toDouble() ?? 0.0,
            status: o['status']?.toString() ?? 'Simmering Live',
            items: itemsList,
          );
        }).toList();
        _pastOrders.clear();
        _pastOrders.addAll(parsed);
      }

      _authRepository.localStorageService.markServerSynced();
      return true;
    } catch (e) {
      debugPrint('Error syncing profile with server: $e');
      return false;
    } finally {
      _isSyncingWithServer = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _loadProfile();
    await fetchLatestFromServer();
  }

  void unlockBadge(String badgeId) {
    _cookingRepository.unlockBadge(badgeId);
  }

  void toggleSubscription() {
    if (_user != null) {
      _user = _user!.copyWith(isSubscribedToKit: !_user!.isSubscribedToKit);
      notifyListeners();
    }
  }

  // Update photo
  void updatePhoto(String photoUrl) {
    if (_user != null) {
      _user = _user!.copyWith(photoUrl: photoUrl);
      notifyListeners();
    }
  }

  void deletePhoto() {
    if (_user != null) {
      _user = _user!.copyWith(clearPhoto: true);
      notifyListeners();
    }
  }

  // Update text form fields
  void updatePersonalDetails({
    required String name,
    required String phoneNumber,
    required String email,
    required String address,
    required String dob,
    required String anniversaryDate,
    required String gender,
    required VegModeOption vegMode,
  }) {
    if (_user != null) {
      _user = _user!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        address: address,
        dob: dob,
        anniversaryDate: anniversaryDate,
        gender: gender,
        vegMode: vegMode,
        dietaryPreference: (vegMode == VegModeOption.jain)
            ? DietaryPreference.jain
            : (vegMode == VegModeOption.swaminarayan)
                ? DietaryPreference.swaminarayan
                : DietaryPreference.vegetarian,
        asafoetidaPreference: (vegMode == VegModeOption.withoutAsafoetida)
            ? AsafoetidaPreference.withoutAsafoetida
            : AsafoetidaPreference.withAsafoetida,
      );
      notifyListeners();

      // Sync with Firestore & SQLite
      try {
        FirebaseFirestoreService.instance.saveUserProfile(
          uid: _user!.id,
          profileData: {
            'name': name,
            'phone': phoneNumber,
            'email': email,
            'address': address,
            'dob': dob,
            'anniversaryDate': anniversaryDate,
            'gender': gender,
            'vegMode': vegMode.name,
            'jCoinsBalance': _user!.jCoinsBalance,
          },
        );
      } catch (_) {}
    }
  }

  // Theme Mode
  void setThemeMode(String mode) {
    _themeMode = mode;
    if (_user != null) {
      _user = _user!.copyWith(themeMode: mode);
      _authRepository.localStorageService.saveUser(_user!);
    }
    _authRepository.localStorageService.updateThemeMode(mode);
    notifyListeners();
  }

  // Collection preference
  void setCollectionPreference(String pref) {
    if (_user != null) {
      _user = _user!.copyWith(collectionPreference: pref);
      notifyListeners();
    }
  }

  // Hear from restaurants
  void setHearFromRestaurants(bool value) {
    if (_user != null) {
      _user = _user!.copyWith(hearFromRestaurants: value);
      notifyListeners();
    }
  }

  // Recommendation toggles
  void updateRecommendation({bool? recipeMatches, bool? masalaAlerts, bool? cuisineDeals}) {
    if (recipeMatches != null) _recRecipeMatches = recipeMatches;
    if (masalaAlerts != null) _recMasalaAlerts = masalaAlerts;
    if (cuisineDeals != null) _recCuisineDeals = cuisineDeals;
    notifyListeners();
  }

  // Add / Edit / Delete Address
  void addAddress(SavedAddress address) {
    _savedAddresses.add(address);
    notifyListeners();
  }

  void deleteAddress(String id) {
    _savedAddresses.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void setDefaultAddress(String id) {
    for (int i = 0; i < _savedAddresses.length; i++) {
      final a = _savedAddresses[i];
      _savedAddresses[i] = a.copyWith(isDefault: a.id == id);
    }
    notifyListeners();
  }

  // J-Coins Earn / Review
  void completeReviewAndEarnCoins(int coinsEarned) {
    if (_user != null) {
      final updated = _user!.jCoinsBalance + coinsEarned;
      _user = _user!.copyWith(jCoinsBalance: updated);
      notifyListeners();
    }
  }

  void removeWishlistItem(String item) {
    _wishlistItems.remove(item);
    notifyListeners();
  }

  void logout() {
    _authRepository.logout();
  }

  @override
  void dispose() {
    _cookingRepository.removeListener(_onCookingUpdated);
    super.dispose();
  }
}
