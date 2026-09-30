import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'packaged_ingredients_service.dart';
import 'firebase_analytics_service.dart';

/// Google Merchant Center (GMC) Product Item
class MerchantCenterProduct {
  final String id;
  final String title;
  final String description;
  final String link;
  final String imageLink;
  final double price;
  final String currency;
  final String availability; // in_stock, out_of_stock, preorder
  final String brand;
  final String condition; // new
  final String googleProductCategory;

  const MerchantCenterProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.link,
    required this.imageLink,
    required this.price,
    this.currency = 'INR',
    this.availability = 'in_stock',
    this.brand = 'Jeerola',
    this.condition = 'new',
    this.googleProductCategory = 'Food, Beverages & Tobacco > Food Items > Seasonings & Spices',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'link': link,
        'image_link': imageLink,
        'price': '${price.toStringAsFixed(2)} $currency',
        'availability': availability,
        'brand': brand,
        'condition': condition,
        'google_product_category': googleProductCategory,
      };
}

/// Google Merchant Center Integration Service
///
/// Converts Jeerola artisan spices, packaged ingredients, and dishes into
/// Google Merchant Center (GMC) catalog feeds, and provides aligned GA4
/// e-commerce telemetry to populate Google Shopping reports in GA4.
class GoogleMerchantCenterService {
  GoogleMerchantCenterService._();
  static final GoogleMerchantCenterService instance = GoogleMerchantCenterService._();

  static const String webBaseUrl = 'https://jeerola.com';

  /// Converts a [PackagedIngredientItem] into a [MerchantCenterProduct]
  MerchantCenterProduct toMerchantCenterProduct(PackagedIngredientItem item) {
    return MerchantCenterProduct(
      id: item.id,
      title: 'Jeerola Royal ${item.name}',
      description: '${item.subtitle}. Artisan royal kitchen preparation, 100% natural, stone-ground tempering with fresh aroma.',
      link: '$webBaseUrl/products/${item.id}?utm_source=google_merchant_center&utm_medium=shopping_free_listing',
      imageLink: item.imageUrl,
      price: item.base100gPrice.toDouble(),
      currency: 'INR',
      availability: 'in_stock',
      brand: 'Jeerola',
      condition: 'new',
      googleProductCategory: 'Food, Beverages & Tobacco > Food Items > Seasonings & Spices',
    );
  }

  /// Returns all packaged items formatted as Google Merchant Center products
  List<MerchantCenterProduct> getCatalogProducts() {
    return PackagedIngredientsService.allItems.map(toMerchantCenterProduct).toList();
  }

  /// Generates Google Merchant Center JSON Product Feed
  Map<String, dynamic> generateJsonFeed() {
    return {
      'title': 'Jeerola Royal Spice Kitchen Product Feed',
      'link': webBaseUrl,
      'description': 'Real-time catalog feed for Google Merchant Center and Google Shopping Free Listings',
      'items': getCatalogProducts().map((p) => p.toJson()).toList(),
    };
  }

  /// Generates Google Merchant Center RSS 2.0 XML Feed string for upload/fetch
  String generateRss2XmlFeed() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<rss version="2.0" xmlns:g="http://base.google.com/ns/1.0">');
    buffer.writeln('  <channel>');
    buffer.writeln('    <title>Jeerola Royal Spices & Kitchen</title>');
    buffer.writeln('    <link>$webBaseUrl</link>');
    buffer.writeln('    <description>Authentic Artisan Cumin & Spice Catalog</description>');

    for (final p in getCatalogProducts()) {
      buffer.writeln('    <item>');
      buffer.writeln('      <g:id>${_escapeXml(p.id)}</g:id>');
      buffer.writeln('      <g:title>${_escapeXml(p.title)}</g:title>');
      buffer.writeln('      <g:description>${_escapeXml(p.description)}</g:description>');
      buffer.writeln('      <g:link>${_escapeXml(p.link)}</g:link>');
      buffer.writeln('      <g:image_link>${_escapeXml(p.imageLink)}</g:image_link>');
      buffer.writeln('      <g:price>${p.price.toStringAsFixed(2)} ${p.currency}</g:price>');
      buffer.writeln('      <g:availability>${p.availability}</g:availability>');
      buffer.writeln('      <g:brand>${_escapeXml(p.brand)}</g:brand>');
      buffer.writeln('      <g:condition>${p.condition}</g:condition>');
      buffer.writeln('      <g:google_product_category>${_escapeXml(p.googleProductCategory)}</g:google_product_category>');
      buffer.writeln('    </item>');
    }

    buffer.writeln('  </channel>');
    buffer.writeln('</rss>');
    return buffer.toString();
  }

  /// Produces a GA4 [AnalyticsEventItem] matching the exact Merchant Center product ID
  AnalyticsEventItem toAnalyticsEventItem({
    required PackagedIngredientItem item,
    int quantity = 1,
  }) {
    return AnalyticsEventItem(
      itemId: item.id,
      itemName: item.name,
      itemCategory: item.category.name,
      itemBrand: 'Jeerola',
      price: item.base100gPrice.toDouble(),
      quantity: quantity,
      currency: 'INR',
    );
  }

  /// Tracks when a user opens an item from a Google Shopping / Merchant Center listing
  void trackShoppingListingClick(PackagedIngredientItem item) {
    debugPrint('🛍️ [Merchant Center] Shopping click tracked for product: ${item.id}');
    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'google_shopping_product_click',
      parameters: {
        'item_id': item.id,
        'item_name': item.name,
        'item_price': item.base100gPrice,
        'source': 'google_merchant_center',
        'medium': 'shopping_free_listing',
      },
    );
  }

  String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
