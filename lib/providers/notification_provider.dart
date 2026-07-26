import 'package:flutter/foundation.dart';
import '../core/network/socket_service.dart';

class NotificationProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();
  final List<Map<String, dynamic>> _orderStatusEvents = [];

  List<Map<String, dynamic>> get events => _orderStatusEvents;

  void init(String token) {
    _socketService.connect(token);
    _socketService.onOrderStatus((data) {
      _orderStatusEvents.insert(0, data);
      notifyListeners(); // อัปเดต badge/snackbar ทันทีที่ admin กด verify/reject
    });
  }

  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
