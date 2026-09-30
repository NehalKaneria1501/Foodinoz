enum DietaryPreference {
  vegetarian,
  jain,
  swaminarayan,
  vegan,
}

extension DietaryPreferenceExt on DietaryPreference {
  String get label {
    switch (this) {
      case DietaryPreference.vegetarian:
        return 'Pure Veg';
      case DietaryPreference.jain:
        return 'Jain';
      case DietaryPreference.swaminarayan:
        return 'Swaminarayan';
      case DietaryPreference.vegan:
        return 'Vegan';
    }
  }
}

enum AsafoetidaPreference {
  withAsafoetida,
  withoutAsafoetida,
}

extension AsafoetidaPreferenceExt on AsafoetidaPreference {
  String get label {
    switch (this) {
      case AsafoetidaPreference.withAsafoetida:
        return 'With Asafoetida (Hing)';
      case AsafoetidaPreference.withoutAsafoetida:
        return 'Without Asafoetida (Hing-Free)';
    }
  }

  String get shortLabel {
    switch (this) {
      case AsafoetidaPreference.withAsafoetida:
        return 'With Hing';
      case AsafoetidaPreference.withoutAsafoetida:
        return 'Without Hing';
    }
  }

  String get badgeLabel {
    switch (this) {
      case AsafoetidaPreference.withAsafoetida:
        return 'WITH HING';
      case AsafoetidaPreference.withoutAsafoetida:
        return 'HING-FREE';
    }
  }
}

enum VegModeOption {
  regular,
  jain,
  swaminarayan,
  withAsafoetida,
  withoutAsafoetida,
}

extension VegModeOptionExt on VegModeOption {
  String get label {
    switch (this) {
      case VegModeOption.regular:
        return 'Regular Veg';
      case VegModeOption.jain:
        return 'Jain (No Root Veg)';
      case VegModeOption.swaminarayan:
        return 'Swaminarayan (No Onion/Garlic)';
      case VegModeOption.withAsafoetida:
        return 'With Asafoetida (Hing)';
      case VegModeOption.withoutAsafoetida:
        return 'Without Asafoetida (Hing-Free)';
    }
  }

  String get shortBadge {
    switch (this) {
      case VegModeOption.regular:
        return 'REGULAR';
      case VegModeOption.jain:
        return 'JAIN';
      case VegModeOption.swaminarayan:
        return 'SWAMINARAYAN';
      case VegModeOption.withAsafoetida:
        return 'WITH HING';
      case VegModeOption.withoutAsafoetida:
        return 'HING-FREE';
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? photoUrl;
  final String address;
  final String dob;
  final String anniversaryDate;
  final String gender;
  final VegModeOption vegMode;
  final DietaryPreference dietaryPreference;
  final AsafoetidaPreference asafoetidaPreference;
  final List<String> preferredCuisines;
  final List<String> mealPreferences;
  final int familyMembersCount;
  final bool isSubscribedToKit;
  final String themeMode; // 'dark' | 'light'
  final String collectionPreference; // 'deliver_to_address' | 'take_away'
  final bool hearFromRestaurants;
  final int jCoinsBalance;
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    this.email = 'nehalkaneria12345@gmail.com',
    required this.phoneNumber,
    this.photoUrl,
    this.address = 'Flat 202, Yogibhuvan Appartment, Yagnapurush ni Pol, Shahpur, Amdavad, 380001',
    this.dob = '15 Nov 2001',
    this.anniversaryDate = '30 Oct 2025',
    this.gender = 'Male',
    this.vegMode = VegModeOption.regular,
    this.dietaryPreference = DietaryPreference.vegetarian,
    this.asafoetidaPreference = AsafoetidaPreference.withAsafoetida,
    this.preferredCuisines = const ['North Indian', 'South Indian', 'Gujarati'],
    this.mealPreferences = const ['Breakfast', 'Lunch', 'Dinner'],
    this.familyMembersCount = 3,
    this.isSubscribedToKit = false,
    this.themeMode = 'light',
    this.collectionPreference = 'deliver_to_address',
    this.hearFromRestaurants = false,
    this.jCoinsBalance = 450,
    this.token,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    bool clearPhoto = false,
    String? address,
    String? dob,
    String? anniversaryDate,
    String? gender,
    VegModeOption? vegMode,
    DietaryPreference? dietaryPreference,
    AsafoetidaPreference? asafoetidaPreference,
    List<String>? preferredCuisines,
    List<String>? mealPreferences,
    int? familyMembersCount,
    bool? isSubscribedToKit,
    String? themeMode,
    String? collectionPreference,
    bool? hearFromRestaurants,
    int? jCoinsBalance,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
      address: address ?? this.address,
      dob: dob ?? this.dob,
      anniversaryDate: anniversaryDate ?? this.anniversaryDate,
      gender: gender ?? this.gender,
      vegMode: vegMode ?? this.vegMode,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      asafoetidaPreference: asafoetidaPreference ?? this.asafoetidaPreference,
      preferredCuisines: preferredCuisines ?? this.preferredCuisines,
      mealPreferences: mealPreferences ?? this.mealPreferences,
      familyMembersCount: familyMembersCount ?? this.familyMembersCount,
      isSubscribedToKit: isSubscribedToKit ?? this.isSubscribedToKit,
      themeMode: themeMode ?? this.themeMode,
      collectionPreference: collectionPreference ?? this.collectionPreference,
      hearFromRestaurants: hearFromRestaurants ?? this.hearFromRestaurants,
      jCoinsBalance: jCoinsBalance ?? this.jCoinsBalance,
      token: token ?? this.token,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name']?.toString() ?? 'Food Connoisseur',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? json['phone']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString(),
      address: json['address']?.toString() ?? 'Flat 202, Yogi Bhuvan Appartment, Ambliwali Pol, Shahpur, Amdavad, 380001',
      dob: json['dob']?.toString() ?? '15 Nov 2001',
      anniversaryDate: json['anniversaryDate']?.toString() ?? '30 Oct 2025',
      gender: json['gender']?.toString() ?? 'Male',
      vegMode: VegModeOption.values.firstWhere(
        (e) => e.name == json['vegMode'],
        orElse: () => VegModeOption.regular,
      ),
      dietaryPreference: DietaryPreference.values.firstWhere(
        (e) => e.name == json['dietaryPreference'],
        orElse: () => DietaryPreference.vegetarian,
      ),
      asafoetidaPreference: AsafoetidaPreference.values.firstWhere(
        (e) => e.name == json['asafoetidaPreference'],
        orElse: () => AsafoetidaPreference.withAsafoetida,
      ),
      familyMembersCount: json['familyMembersCount'] as int? ?? 3,
      isSubscribedToKit: json['isSubscribedToKit'] as bool? ?? false,
      themeMode: json['themeMode']?.toString() ?? 'light',
      collectionPreference: json['collectionPreference']?.toString() ?? 'deliver_to_address',
      hearFromRestaurants: json['hearFromRestaurants'] as bool? ?? false,
      jCoinsBalance: json['jCoinsBalance'] as int? ?? 450,
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'address': address,
      'dob': dob,
      'anniversaryDate': anniversaryDate,
      'gender': gender,
      'vegMode': vegMode.name,
      'dietaryPreference': dietaryPreference.name,
      'asafoetidaPreference': asafoetidaPreference.name,
      'preferredCuisines': preferredCuisines,
      'mealPreferences': mealPreferences,
      'familyMembersCount': familyMembersCount,
      'isSubscribedToKit': isSubscribedToKit,
      'themeMode': themeMode,
      'collectionPreference': collectionPreference,
      'hearFromRestaurants': hearFromRestaurants,
      'jCoinsBalance': jCoinsBalance,
      'token': token,
    };
  }
}
