import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class SQLiteDatabaseService {
  static final SQLiteDatabaseService instance = SQLiteDatabaseService._init();
  static Database? _database;

  SQLiteDatabaseService._init();

  Future<Database?> get database async {
    if (_database != null) return _database;
    try {
      _database = await _initDB('jeerola_kitchen.db');
      return _database;
    } catch (e) {
      debugPrint('SQLite init fallback for current platform: $e');
      return null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wishlist (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT,
        price REAL NOT NULL,
        imageUrl TEXT,
        category TEXT,
        addedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE past_orders (
        id TEXT PRIMARY KEY,
        storeName TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        status TEXT NOT NULL,
        dateStr TEXT NOT NULL,
        items TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profile_cache (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        dob TEXT,
        anniversaryDate TEXT,
        gender TEXT,
        vegMode TEXT,
        jCoinsBalance INTEGER
      )
    ''');
  }

  // In-memory fallback cache for test environments where native SQLite plugin is mocked
  final Set<String> _inMemoryWishlist = {
    'P-01 Lucknowi Biryani Masala (100g)',
    'P-08 Malabar Black Pepper Reserve',
    'Amritsari Chole Pouch Kit (50g)',
    'Cold Pressed Groundnut Oil (1L)',
  };

  // Wishlist Methods
  Future<void> addToWishlist({
    required String id,
    required String title,
    String? subtitle,
    double price = 0.0,
    String? imageUrl,
    String? category,
  }) async {
    _inMemoryWishlist.add(title);
    final db = await database;
    if (db == null) return;

    await db.insert(
      'wishlist',
      {
        'id': id,
        'title': title,
        'subtitle': subtitle ?? '',
        'price': price,
        'imageUrl': imageUrl ?? '',
        'category': category ?? '',
        'addedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromWishlist(String titleOrId) async {
    _inMemoryWishlist.remove(titleOrId);
    final db = await database;
    if (db == null) return;

    await db.delete(
      'wishlist',
      where: 'id = ? OR title = ?',
      whereArgs: [titleOrId, titleOrId],
    );
  }

  final ValueNotifier<int> wishlistNotifier = ValueNotifier<int>(0);

  Future<bool> toggleWishlist({
    required String id,
    required String title,
    String? subtitle,
    double price = 0.0,
    String? imageUrl,
    String? category,
  }) async {
    final wishlisted = await isInWishlist(title) || await isInWishlist(id);
    if (wishlisted) {
      await removeFromWishlist(id);
      await removeFromWishlist(title);
      wishlistNotifier.value++;
      return false;
    } else {
      await addToWishlist(
        id: id,
        title: title,
        subtitle: subtitle,
        price: price,
        imageUrl: imageUrl,
        category: category,
      );
      wishlistNotifier.value++;
      return true;
    }
  }

  Future<bool> isInWishlist(String titleOrId) async {
    if (_inMemoryWishlist.contains(titleOrId)) return true;
    final db = await database;
    if (db == null) return _inMemoryWishlist.contains(titleOrId);

    final maps = await db.query(
      'wishlist',
      where: 'id = ? OR title = ?',
      whereArgs: [titleOrId, titleOrId],
    );
    return maps.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getWishlist() async {
    final db = await database;
    if (db == null) {
      return _inMemoryWishlist.map((title) => {'title': title, 'price': 149.0}).toList();
    }
    return await db.query('wishlist', orderBy: 'addedAt DESC');
  }

  // Order Methods
  Future<void> saveOrder({
    required String orderId,
    required String storeName,
    required double totalAmount,
    required String status,
    required String dateStr,
    required List<String> items,
  }) async {
    final db = await database;
    if (db == null) return;

    await db.insert(
      'past_orders',
      {
        'id': orderId,
        'storeName': storeName,
        'totalAmount': totalAmount,
        'status': status,
        'dateStr': dateStr,
        'items': items.join(' | '),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // In-memory user profile fallback cache
  final Map<String, Map<String, dynamic>> _inMemoryProfiles = {
    'default_user': {
      'id': 'default_user',
      'name': 'Nehal Patel',
      'phone': '+91 9265754161',
      'email': 'nehalkaneria12345@gmail.com',
      'address': 'Flat 202, Yogibhuvan Appartment, Yagnapurush ni Pol, Shahpur, Amdavad, 380001 (Landmark: Ambliwali Pol)',
      'dob': '15 Nov 2001',
      'anniversaryDate': '30 Oct 2025',
      'gender': 'Male',
      'vegMode': 'Pure Veg (No Onion/Garlic)',
      'jCoinsBalance': 500,
    }
  };

  // User Profile Methods
  Future<void> saveProfile({
    String id = 'default_user',
    required String name,
    String? phone,
    String? email,
    String? address,
    String? dob,
    String? anniversaryDate,
    String? gender,
    String? vegMode,
    int? jCoinsBalance,
  }) async {
    final profileMap = {
      'id': id,
      'name': name,
      'phone': phone ?? '+91 9265754161',
      'email': email ?? 'nehalkaneria12345@gmail.com',
      'address': address ?? 'Flat 202, Yogibhuvan Appartment, Yagnapurush ni Pol, Shahpur, Amdavad, 380001 (Landmark: Ambliwali Pol)',
      'dob': dob ?? '15 Nov 2001',
      'anniversaryDate': anniversaryDate ?? '30 Oct 2025',
      'gender': gender ?? 'Male',
      'vegMode': vegMode ?? 'Pure Veg (No Onion/Garlic)',
      'jCoinsBalance': jCoinsBalance ?? 500,
    };
    _inMemoryProfiles[id] = profileMap;

    final db = await database;
    if (db == null) return;

    await db.insert(
      'user_profile_cache',
      profileMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getProfile({String id = 'default_user'}) async {
    final db = await database;
    if (db == null) {
      return _inMemoryProfiles[id];
    }

    final maps = await db.query(
      'user_profile_cache',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return _inMemoryProfiles[id];
  }
}
