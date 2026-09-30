import 'dart:async';
import 'dart:math';
import '../models/jeerola_order_model.dart';

class JeerolaDeliveryService {
  JeerolaOrderModel? _activeOrder;
  final List<JeerolaOrderModel> _history = [];
  Timer? _autoTrackTimer;
  bool _isAutoTracking = false;
  Duration _tickInterval = const Duration(milliseconds: 1500);
  double _progressStep = 0.025;

  /// Callback when order state or live progress ticks
  void Function()? onOrderUpdated;

  JeerolaDeliveryService() {
    _initDefaultOrder();
  }

  void _initDefaultOrder() {
    final now = DateTime.now();
    _activeOrder = JeerolaOrderModel(
      orderId: 'JRL-8942-EXPRESS',
      status: JeerolaOrderStatus.preparingInKitchen,
      items: const [
        JeerolaOrderItem(
          id: 'dish_01',
          name: 'Royal Jeera Murgh Dum Handi',
          quantity: 1,
          unitPrice: 389.0,
          isChefSpecial: true,
          category: 'Curries & Gravies',
        ),
        JeerolaOrderItem(
          id: 'dish_02',
          name: 'Slow-Cooked Cumin Spice Biryani',
          quantity: 1,
          unitPrice: 349.0,
          isChefSpecial: true,
          category: 'Biryani & Rice',
        ),
        JeerolaOrderItem(
          id: 'spice_01',
          name: 'Artisan Stone-Ground Roasted Jeera Pouch',
          quantity: 2,
          unitPrice: 65.0,
          category: 'Artisan Spices',
        ),
      ],
      subtotal: 868.0,
      packagingFee: 0.0,
      deliveryFee: 0.0,
      totalAmount: 868.0,
      deliveryAddress: '24 Gourmet Walk, Suite 402, Indiranagar',
      placedAt: now.subtract(const Duration(minutes: 8)),
      estimatedMinutesRemaining: 16,
      rider: const JeerolaRider(
        name: 'Vikram Singh',
        phone: '+91 9265754161',
        vehicleNumber: 'KA-03-JR-9901',
        rating: 4.95,
        tripsCompleted: 1540,
        badge: 'Jeerola Super Captain',
      ),
      handoverOtp: '4829',
      kitchenNote: 'Infusing royal whole cumin with cold-pressed ghee and simmering gravy.',
      progressPercent: 0.50,
    );
  }

  JeerolaOrderModel? get activeOrder => _activeOrder;
  List<JeerolaOrderModel> get orderHistory => List.unmodifiable(_history);
  bool get hasActiveDelivery =>
      _activeOrder != null && _activeOrder!.status != JeerolaOrderStatus.delivered;
  bool get isAutoTracking => _isAutoTracking;

  /// Starts automatic real-time order tracking with periodic ticker
  void startAutoTracking({
    Duration tickInterval = const Duration(milliseconds: 1500),
    double progressStep = 0.025,
  }) {
    if (_activeOrder == null || _activeOrder!.status == JeerolaOrderStatus.delivered) {
      return;
    }
    _tickInterval = tickInterval;
    _progressStep = progressStep;
    _isAutoTracking = true;
    _autoTrackTimer?.cancel();
    _autoTrackTimer = Timer.periodic(_tickInterval, (_) => _autoTrackTick());
    onOrderUpdated?.call();
  }

  /// Stops automatic tracking ticker
  void stopAutoTracking() {
    _isAutoTracking = false;
    _autoTrackTimer?.cancel();
    _autoTrackTimer = null;
    onOrderUpdated?.call();
  }

  /// Toggle automatic tracking on/off
  void toggleAutoTracking() {
    if (_isAutoTracking) {
      stopAutoTracking();
    } else {
      startAutoTracking();
    }
  }

  /// Periodic tick for live automatic progression
  void _autoTrackTick() {
    if (_activeOrder == null) {
      stopAutoTracking();
      return;
    }

    if (_activeOrder!.status == JeerolaOrderStatus.delivered) {
      stopAutoTracking();
      return;
    }

    final currentProgress = _activeOrder!.progressPercent;
    final newProgress = (currentProgress + _progressStep).clamp(0.0, 1.0);
    _applyProgress(newProgress);
  }

  /// Apply simulated live telemetry progress smoothly
  void _applyProgress(double progress) {
    if (_activeOrder == null) return;

    JeerolaOrderStatus newStatus;
    int remainingMinutes;
    String note;

    if (progress < 0.25) {
      newStatus = JeerolaOrderStatus.confirmed;
      remainingMinutes = ((1.0 - progress) * 25).round().clamp(18, 25);
      note = 'Order confirmed. Chef preparing signature spices and ingredients.';
    } else if (progress < 0.60) {
      newStatus = JeerolaOrderStatus.preparingInKitchen;
      final localRatio = (progress - 0.25) / (0.60 - 0.25);
      remainingMinutes = (18 - (localRatio * 8)).round().clamp(10, 18);
      note = 'Chef is simmering gravies and tempering whole spices in clay pots.';
    } else if (progress < 0.90) {
      newStatus = JeerolaOrderStatus.outForDelivery;
      final localRatio = (progress - 0.60) / (0.90 - 0.60);
      remainingMinutes = (10 - (localRatio * 8)).round().clamp(2, 10);
      note = 'Order packed in thermal insulation bag. Captain Vikram is en route.';
    } else if (progress < 1.0) {
      newStatus = JeerolaOrderStatus.arrived;
      remainingMinutes = 1;
      note = 'Captain has arrived at your address. Please provide Handover PIN.';
    } else {
      newStatus = JeerolaOrderStatus.delivered;
      remainingMinutes = 0;
      note = 'Order safely delivered. Enjoy your royal meal!';
    }

    _activeOrder = _activeOrder!.copyWith(
      status: newStatus,
      progressPercent: progress,
      estimatedMinutesRemaining: remainingMinutes,
      kitchenNote: note,
    );

    if (newStatus == JeerolaOrderStatus.delivered) {
      if (!_history.contains(_activeOrder)) {
        _history.insert(0, _activeOrder!);
      }
      stopAutoTracking();
    }

    onOrderUpdated?.call();
  }

  /// Place a new direct delivery order with Jeerola Kitchen
  JeerolaOrderModel placeOrder({
    required List<JeerolaOrderItem> items,
    required String deliveryAddress,
  }) {
    final now = DateTime.now();
    final randomId = 'JRL-${1000 + Random().nextInt(9000)}-EXPRESS';
    final randomOtp = (1000 + Random().nextInt(9000)).toString();

    double subtotal = 0;
    for (final item in items) {
      subtotal += item.totalPrice;
    }

    final newOrder = JeerolaOrderModel(
      orderId: randomId,
      status: JeerolaOrderStatus.confirmed,
      items: items,
      subtotal: subtotal,
      packagingFee: 0.0,
      deliveryFee: 0.0,
      totalAmount: subtotal,
      deliveryAddress: deliveryAddress,
      placedAt: now,
      estimatedMinutesRemaining: 24,
      rider: const JeerolaRider(
        name: 'Vikram Singh',
        phone: '+91 9265754161',
        vehicleNumber: 'KA-03-JR-9901',
        rating: 4.95,
      ),
      handoverOtp: randomOtp,
      kitchenNote: 'Order received. Chef preparing signature spices and ingredients.',
      progressPercent: 0.15,
    );

    if (_activeOrder != null) {
      _history.insert(0, _activeOrder!);
    }
    _activeOrder = newOrder;
    onOrderUpdated?.call();
    return newOrder;
  }

  /// Advance to next status node (for manual testing / skip)
  JeerolaOrderModel? advanceStatus() {
    if (_activeOrder == null) return null;

    JeerolaOrderStatus nextStatus;
    int remainingMinutes;
    String note;
    double targetProgress;

    switch (_activeOrder!.status) {
      case JeerolaOrderStatus.confirmed:
        nextStatus = JeerolaOrderStatus.preparingInKitchen;
        remainingMinutes = 16;
        note = 'Chef is simmering gravies and tempering whole spices in clay pots.';
        targetProgress = 0.50;
        break;
      case JeerolaOrderStatus.preparingInKitchen:
        nextStatus = JeerolaOrderStatus.outForDelivery;
        remainingMinutes = 8;
        note = 'Order packed in thermal insulation bag. Captain Vikram is en route.';
        targetProgress = 0.85;
        break;
      case JeerolaOrderStatus.outForDelivery:
        nextStatus = JeerolaOrderStatus.arrived;
        remainingMinutes = 1;
        note = 'Captain has arrived at your address. Please provide Handover PIN.';
        targetProgress = 0.98;
        break;
      case JeerolaOrderStatus.arrived:
        nextStatus = JeerolaOrderStatus.delivered;
        remainingMinutes = 0;
        note = 'Order safely delivered. Enjoy your royal meal!';
        targetProgress = 1.0;
        stopAutoTracking();
        break;
      case JeerolaOrderStatus.delivered:
        // Reset to confirmed for continuous demo replay
        nextStatus = JeerolaOrderStatus.confirmed;
        remainingMinutes = 25;
        note = 'New order confirmed by Jeerola Kitchen.';
        targetProgress = 0.15;
        break;
    }

    _activeOrder = _activeOrder!.copyWith(
      status: nextStatus,
      estimatedMinutesRemaining: remainingMinutes,
      kitchenNote: note,
      progressPercent: targetProgress,
    );

    if (nextStatus == JeerolaOrderStatus.delivered) {
      if (!_history.contains(_activeOrder)) {
        _history.insert(0, _activeOrder!);
      }
    }

    onOrderUpdated?.call();
    return _activeOrder;
  }

  void cancelActiveOrder() {
    stopAutoTracking();
    if (_activeOrder != null) {
      _activeOrder = null;
    }
    onOrderUpdated?.call();
  }

  void resetOrder() {
    stopAutoTracking();
    _initDefaultOrder();
    onOrderUpdated?.call();
  }

  void dispose() {
    stopAutoTracking();
  }
}
