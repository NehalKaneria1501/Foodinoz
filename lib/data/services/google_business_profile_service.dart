import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_analytics_service.dart';

/// Google Business Profile (GBP) Location Model
class GoogleBusinessLocation {
  final String storeId;
  final String name;
  final String address;
  final String city;
  final String pincode;
  final String phone;
  final double latitude;
  final double longitude;
  final String placeId;
  final String gbpMapUrl;
  final String reviewUrl;
  final double rating;

  const GoogleBusinessLocation({
    required this.storeId,
    required this.name,
    required this.address,
    required this.city,
    required this.pincode,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.placeId,
    required this.gbpMapUrl,
    required this.reviewUrl,
    this.rating = 4.9,
  });
}

/// Google Business Profile Integration Service
///
/// Connects physical Jeerola restaurant kitchens and dark store locations
/// with Google Analytics 4 (GA4) and Google Business Profile listings.
class GoogleBusinessProfileService {
  GoogleBusinessProfileService._();
  static final GoogleBusinessProfileService instance = GoogleBusinessProfileService._();

  /// Registered Jeerola Google Business Profile Locations
  final List<GoogleBusinessLocation> locations = const [
    GoogleBusinessLocation(
      storeId: 'ds_indiranagar_03',
      name: 'Indiranagar Jeerola Flagship Kitchen',
      address: '24 Gourmet Walk, 100ft Road, Indiranagar, Bengaluru 560038',
      city: 'Bengaluru',
      pincode: '560038',
      phone: '+919265754161',
      latitude: 12.9784,
      longitude: 77.6408,
      placeId: 'ChIJ57Z8v4sUrjsR0P0bZ_jeerola_blr',
      gbpMapUrl: 'https://maps.google.com/?cid=1082648291034',
      reviewUrl: 'https://search.google.com/local/writereview?placeid=ChIJ57Z8v4sUrjsR0P0bZ_jeerola_blr',
      rating: 4.98,
    ),
    GoogleBusinessLocation(
      storeId: 'ds_shahpur_01',
      name: 'Shahpur Heritage Kitchen Hub',
      address: 'Near Delhi Darwaja, Shahpur, Amdavad 380001',
      city: 'Ahmedabad',
      pincode: '380001',
      phone: '+919265754161',
      latitude: 23.0338,
      longitude: 72.5850,
      placeId: 'ChIJ7Z8v4sUrjsR0P0bZ_jeerola_ahd',
      gbpMapUrl: 'https://maps.google.com/?cid=678980676298',
      reviewUrl: 'https://search.google.com/local/writereview?placeid=ChIJ7Z8v4sUrjsR0P0bZ_jeerola_ahd',
      rating: 4.95,
    ),
    GoogleBusinessLocation(
      storeId: 'ds_navrangpura_02',
      name: 'Navrangpura Express Spice Depot',
      address: 'C.G. Road, Navrangpura, Amdavad 380009',
      city: 'Ahmedabad',
      pincode: '380009',
      phone: '+919265754161',
      latitude: 23.0360,
      longitude: 72.5590,
      placeId: 'ChIJ3Z8v4sUrjsR0P0bZ_jeerola_nav',
      gbpMapUrl: 'https://maps.google.com/?cid=404256776147',
      reviewUrl: 'https://search.google.com/local/writereview?placeid=ChIJ3Z8v4sUrjsR0P0bZ_jeerola_nav',
      rating: 4.90,
    ),
  ];

  /// Tracks when a user views a Google Business Profile location in the app
  void trackStoreProfileView(GoogleBusinessLocation location) {
    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'view_store_profile',
      parameters: {
        'store_id': location.storeId,
        'store_name': location.name,
        'city': location.city,
        'place_id': location.placeId,
        'source': 'google_business_profile',
      },
    );
  }

  /// Opens the store on Google Maps and logs the direction intent to GA4
  Future<void> openInGoogleMaps(GoogleBusinessLocation location) async {
    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'get_store_directions',
      parameters: {
        'store_id': location.storeId,
        'store_name': location.name,
        'place_id': location.placeId,
      },
    );

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}&query_place_id=${location.placeId}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Initiates a phone call to the store and logs the phone click event to GA4
  Future<void> callStore(GoogleBusinessLocation location) async {
    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'call_store',
      parameters: {
        'store_id': location.storeId,
        'store_name': location.name,
        'phone_number': location.phone,
      },
    );

    final uri = Uri.parse('tel:${location.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Opens the Google Business Profile review dialog and logs review intent to GA4
  Future<void> openGoogleReview(GoogleBusinessLocation location) async {
    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'open_store_review',
      parameters: {
        'store_id': location.storeId,
        'store_name': location.name,
        'place_id': location.placeId,
      },
    );

    final uri = Uri.parse(location.reviewUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Tracks order revenue attributed to a specific physical Google Business Profile hub
  void trackStoreOrder({
    required GoogleBusinessLocation location,
    required String orderId,
    required double orderValue,
  }) {
    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'local_store_order',
      parameters: {
        'order_id': orderId,
        'order_value': orderValue,
        'store_id': location.storeId,
        'store_name': location.name,
        'store_city': location.city,
        'place_id': location.placeId,
        'source': 'google_business_profile',
      },
    );
  }

  /// Attributes incoming app traffic originating from Google Business Profile (Search/Maps)
  Future<void> handleIncomingGbpReferral({
    required String utmSource,
    required String utmMedium,
    String? storeId,
  }) async {
    if (utmSource == 'google_business_profile' || utmMedium == 'organic_local') {
      debugPrint('📍 [GBP] App launched from Google Business Profile referral: store=$storeId');
      await FirebaseAnalyticsService.instance.setUserProperty(
        name: 'preferred_store_hub',
        value: storeId ?? 'indiranagar_flagship',
      );
      FirebaseAnalyticsService.instance.logCustomEvent(
        name: 'gbp_local_referral',
        parameters: {
          'utm_source': utmSource,
          'utm_medium': utmMedium,
          'store_id': storeId ?? 'unknown',
        },
      );
    }
  }
}
