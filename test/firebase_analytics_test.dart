import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:jeerola/data/services/firebase_analytics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Firebase Analytics & Installations Tests', () {
    test('FirebaseAnalyticsService initializes and exposes instance', () async {
      final service = FirebaseAnalyticsService.instance;
      await service.initialize();
      expect(service, isNotNull);
    });

    test('All e-commerce and GA4 methods execute without throwing in test environment', () async {
      final service = FirebaseAnalyticsService.instance;

      // 1. Installation ID & App Instance ID
      final fid = await service.getFirebaseInstallationId();
      final appInstanceId = await service.getAppInstanceId();
      expect(fid, isNull); // Simulated test environment
      expect(appInstanceId, isNull);

      // 2. Global defaults & User Properties
      await service.setDefaultEventParameters({'version': '1.2.3'});
      await service.setUserId('123456');
      await service.setUserProperty(name: 'favorite_food', value: 'Biryani');

      // 3. Screen View
      await service.logScreenView(screenName: 'HomeScreen', screenClass: 'HomeScreenClass');

      // 4. Content Selection & Image Sharing
      await service.logSelectContent(contentType: 'image', itemId: 'IMG_001');
      await service.logShareImage(imageName: 'paneer_butter_masala.jpg', fullText: 'Delicious curry recipe');

      // 5. E-commerce Items
      final jeggings = AnalyticsEventItem(
        itemId: 'SKU_123',
        itemName: 'jeggings',
        itemCategory: 'pants',
        itemVariant: 'black',
        itemBrand: 'Google',
        price: 9.99,
        quantity: 2,
      );

      final boots = AnalyticsEventItem(
        itemId: 'SKU_456',
        itemName: 'boots',
        itemCategory: 'shoes',
        itemVariant: 'brown',
        itemBrand: 'Google',
        price: 24.99,
        quantity: 1,
      );

      final socks = AnalyticsEventItem(
        itemId: 'SKU_789',
        itemName: 'ankle_socks',
        itemCategory: 'socks',
        itemVariant: 'red',
        itemBrand: 'Google',
        price: 5.99,
        quantity: 1,
      );

      // 6. Full E-commerce Funnel Execution
      await service.logViewItemList(
        itemListId: 'L001',
        itemListName: 'Related products',
        items: [jeggings, boots, socks],
      );

      await service.logSelectItem(
        itemListId: 'L001',
        itemListName: 'Related products',
        items: [jeggings],
      );

      await service.logViewItem(
        itemId: 'SKU_123',
        itemName: 'jeggings',
        itemCategory: 'pants',
        price: 9.99,
        currency: 'USD',
        items: [jeggings],
      );

      await service.logAddToWishlist(
        currency: 'USD',
        value: 19.98,
        items: [jeggings],
      );

      await service.logAddToCart(
        itemId: 'SKU_123',
        itemName: 'jeggings',
        itemCategory: 'pants',
        price: 9.99,
        quantity: 2,
        currency: 'USD',
        customItems: [jeggings],
      );

      await service.logViewCart(
        currency: 'USD',
        value: 19.98,
        items: [jeggings],
      );

      await service.logRemoveFromCart(
        currency: 'USD',
        value: 9.99,
        items: [jeggings],
      );

      await service.logBeginCheckout(
        currency: 'USD',
        value: 15.98,
        coupon: 'SUMMER_FUN',
        items: [jeggings],
      );

      await service.logAddShippingInfo(
        currency: 'USD',
        value: 15.98,
        coupon: 'SUMMER_FUN',
        shippingTier: 'Ground',
        items: [jeggings],
      );

      await service.logAddPaymentInfo(
        currency: 'USD',
        value: 15.98,
        coupon: 'SUMMER_FUN',
        paymentType: 'Visa',
        items: [jeggings],
      );

      await service.logPurchase(
        transactionId: 'TXN_12345',
        affiliation: 'Google Store',
        currency: 'USD',
        value: 15.98,
        shipping: 2.00,
        tax: 1.66,
        coupon: 'SUMMER_FUN',
        items: [jeggings],
      );

      await service.logRefund(
        transactionId: 'TXN_12345',
        affiliation: 'Google Store',
        currency: 'USD',
        value: 15.98,
        items: [jeggings],
      );

      await service.logViewPromotion(
        promotionId: 'SUMMER_FUN',
        promotionName: 'Summer Sale',
        creativeName: 'summer2020_promo.jpg',
        creativeSlot: 'featured_app_1',
        locationId: 'HERO_BANNER',
      );

      await service.logSelectPromotion(
        promotionId: 'SUMMER_FUN',
        promotionName: 'Summer Sale',
        creativeName: 'summer2020_promo.jpg',
        creativeSlot: 'featured_app_1',
        locationId: 'HERO_BANNER',
      );

      await service.logCustomEvent(
        name: 'special_offer_clicked',
        parameters: {'offer_id': 'OFFER_001'},
      );
    });
  });
}
