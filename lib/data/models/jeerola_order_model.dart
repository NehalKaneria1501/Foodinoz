enum JeerolaOrderStatus {
  confirmed,
  preparingInKitchen,
  outForDelivery,
  arrived,
  delivered;

  String get displayName {
    switch (this) {
      case JeerolaOrderStatus.confirmed:
        return 'Order Confirmed';
      case JeerolaOrderStatus.preparingInKitchen:
        return 'Simmering in Kitchen';
      case JeerolaOrderStatus.outForDelivery:
        return 'Out for Delivery';
      case JeerolaOrderStatus.arrived:
        return 'Arrived at Doorstep';
      case JeerolaOrderStatus.delivered:
        return 'Delivered';
    }
  }

  String get description {
    switch (this) {
      case JeerolaOrderStatus.confirmed:
        return 'Kitchen has received and accepted your order.';
      case JeerolaOrderStatus.preparingInKitchen:
        return 'Chef is preparing royal gravies with stone-ground spices.';
      case JeerolaOrderStatus.outForDelivery:
        return 'Jeerola Delivery Captain is on the way with heated thermal pack.';
      case JeerolaOrderStatus.arrived:
        return 'Captain has arrived at your gate. Please share handover PIN.';
      case JeerolaOrderStatus.delivered:
        return 'Order handed over hot & fresh. Bon Appétit!';
    }
  }

  double get defaultProgress {
    switch (this) {
      case JeerolaOrderStatus.confirmed:
        return 0.15;
      case JeerolaOrderStatus.preparingInKitchen:
        return 0.50;
      case JeerolaOrderStatus.outForDelivery:
        return 0.85;
      case JeerolaOrderStatus.arrived:
        return 0.98;
      case JeerolaOrderStatus.delivered:
        return 1.0;
    }
  }
}

class JeerolaOrderItem {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final bool isChefSpecial;
  final String category;

  const JeerolaOrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.isChefSpecial = false,
    this.category = 'Dish',
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'isChefSpecial': isChefSpecial,
        'category': category,
      };

  factory JeerolaOrderItem.fromJson(Map<String, dynamic> json) => JeerolaOrderItem(
        id: json['id'] as String,
        name: json['name'] as String,
        quantity: (json['quantity'] as num).toInt(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
        isChefSpecial: json['isChefSpecial'] as bool? ?? false,
        category: json['category'] as String? ?? 'Dish',
      );
}

class JeerolaRider {
  final String name;
  final String phone;
  final String vehicleNumber;
  final double rating;
  final int tripsCompleted;
  final String badge;

  const JeerolaRider({
    required this.name,
    required this.phone,
    required this.vehicleNumber,
    this.rating = 4.9,
    this.tripsCompleted = 1420,
    this.badge = 'Jeerola Express Captain',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'vehicleNumber': vehicleNumber,
        'rating': rating,
        'tripsCompleted': tripsCompleted,
        'badge': badge,
      };

  factory JeerolaRider.fromJson(Map<String, dynamic> json) => JeerolaRider(
        name: json['name'] as String? ?? 'Vikram Singh',
        phone: json['phone'] as String? ?? '+91 9265754161',
        vehicleNumber: json['vehicleNumber'] as String? ?? 'KA-03-JR-9901',
        rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
        tripsCompleted: (json['tripsCompleted'] as num?)?.toInt() ?? 1420,
        badge: json['badge'] as String? ?? 'Jeerola Express Captain',
      );
}

class JeerolaOrderModel {
  final String orderId;
  final JeerolaOrderStatus status;
  final List<JeerolaOrderItem> items;
  final double subtotal;
  final double packagingFee;
  final double deliveryFee;
  final double totalAmount;
  final String deliveryAddress;
  final DateTime placedAt;
  final int estimatedMinutesRemaining;
  final JeerolaRider rider;
  final String handoverOtp;
  final String kitchenNote;
  final double progressPercent;

  const JeerolaOrderModel({
    required this.orderId,
    required this.status,
    required this.items,
    required this.subtotal,
    this.packagingFee = 0.0,
    this.deliveryFee = 0.0,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.placedAt,
    required this.estimatedMinutesRemaining,
    required this.rider,
    required this.handoverOtp,
    required this.kitchenNote,
    required this.progressPercent,
  });

  JeerolaOrderModel copyWith({
    String? orderId,
    JeerolaOrderStatus? status,
    List<JeerolaOrderItem>? items,
    double? subtotal,
    double? packagingFee,
    double? deliveryFee,
    double? totalAmount,
    String? deliveryAddress,
    DateTime? placedAt,
    int? estimatedMinutesRemaining,
    JeerolaRider? rider,
    String? handoverOtp,
    String? kitchenNote,
    double? progressPercent,
  }) {
    return JeerolaOrderModel(
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      packagingFee: packagingFee ?? this.packagingFee,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      placedAt: placedAt ?? this.placedAt,
      estimatedMinutesRemaining: estimatedMinutesRemaining ?? this.estimatedMinutesRemaining,
      rider: rider ?? this.rider,
      handoverOtp: handoverOtp ?? this.handoverOtp,
      kitchenNote: kitchenNote ?? this.kitchenNote,
      progressPercent: progressPercent ?? this.progressPercent,
    );
  }

  String get formattedDistanceRemaining {
    if (status == JeerolaOrderStatus.delivered) return 'Delivered';
    if (status == JeerolaOrderStatus.arrived) return 'Arrived at Gate';
    if (status == JeerolaOrderStatus.confirmed || status == JeerolaOrderStatus.preparingInKitchen) {
      return 'At Kitchen (3.2 km away)';
    }
    // During outForDelivery (progress 0.60 to 0.90)
    final deliveryProgress = ((progressPercent - 0.60) / 0.30).clamp(0.0, 1.0);
    final distanceKm = (3.2 * (1.0 - deliveryProgress));
    if (distanceKm < 0.2) {
      return 'Arriving now (< 200 m)';
    } else if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()} m away';
    }
    return '${distanceKm.toStringAsFixed(1)} km away';
  }
}
