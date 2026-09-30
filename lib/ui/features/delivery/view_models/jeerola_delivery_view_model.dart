import 'package:flutter/foundation.dart';
import '../../../../data/models/jeerola_order_model.dart';
import '../../../../data/services/jeerola_delivery_service.dart';

class JeerolaDeliveryViewModel extends ChangeNotifier {
  final JeerolaDeliveryService _service;

  JeerolaDeliveryViewModel({required JeerolaDeliveryService deliveryService})
      : _service = deliveryService {
    _service.onOrderUpdated = () {
      notifyListeners();
    };
  }

  JeerolaOrderModel? get activeOrder => _service.activeOrder;
  bool get hasActiveDelivery => _service.hasActiveDelivery;
  List<JeerolaOrderModel> get orderHistory => _service.orderHistory;
  bool get isAutoTracking => _service.isAutoTracking;

  /// Start automatic order tracking with periodic ticker
  void startAutoTracking({
    Duration tickInterval = const Duration(milliseconds: 1500),
    double progressStep = 0.025,
  }) {
    _service.startAutoTracking(
      tickInterval: tickInterval,
      progressStep: progressStep,
    );
    notifyListeners();
  }

  /// Pause/stop automatic order tracking
  void stopAutoTracking() {
    _service.stopAutoTracking();
    notifyListeners();
  }

  /// Toggle automatic tracking
  void toggleAutoTracking() {
    _service.toggleAutoTracking();
    notifyListeners();
  }

  /// Advance to next status node (for testing / manual skip)
  void advanceStatus() {
    _service.advanceStatus();
    notifyListeners();
  }

  JeerolaOrderModel placeOrder({
    required List<JeerolaOrderItem> items,
    required String deliveryAddress,
  }) {
    final order = _service.placeOrder(
      items: items,
      deliveryAddress: deliveryAddress,
    );
    _service.startAutoTracking();
    notifyListeners();
    return order;
  }

  void cancelActiveOrder() {
    _service.cancelActiveOrder();
    notifyListeners();
  }

  void resetOrder() {
    _service.resetOrder();
    notifyListeners();
  }

  @override
  void dispose() {
    _service.stopAutoTracking();
    super.dispose();
  }
}
