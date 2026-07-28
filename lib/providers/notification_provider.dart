import 'package:flutter/foundation.dart';
import '../core/network/socket_service.dart';
import '../models/app_notification.dart';
import 'order_provider.dart';

class NotificationProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();

  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void init(String token, OrderProvider orderProvider) {
    _socketService.connect(token);
    _socketService.onOrderStatus((data) {
      _notifications.insert(0, AppNotification.fromSocketData(data));
      // sync สถานะใน list ให้ตรงทันที ไม่ต้องรอ user pull-to-refresh เอง
      orderProvider.patchOrderStatus(data['orderid'], data['status']);
      notifyListeners();
    });
  }

  void markAllRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void disconnect() {
    _socketService.disconnect();
  }
}
