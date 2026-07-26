import 'package:flutter/foundation.dart';
import '../core/network/socket_service.dart';
import 'order_provider.dart';

class NotificationProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();

  // เก็บ event ล่าสุดไว้โชว์ banner/snackbar ในหน้าที่เปิดอยู่
  Map<String, dynamic>? latestEvent;

  void init(String token, OrderProvider orderProvider) {
    _socketService.connect(token);
    _socketService.onOrderStatus((data) {
      latestEvent = data;
      // sync สถานะใน list ให้ตรงทันที ไม่ต้องรอ user pull-to-refresh เอง
      orderProvider.patchOrderStatus(data['orderid'], data['status']);
      notifyListeners();
    });
  }

  void clearLatestEvent() {
    latestEvent = null;
  }

  void disconnect() {
    _socketService.disconnect();
  }
}
