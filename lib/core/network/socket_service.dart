import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;

  void connect(String token) {
    if (_socket != null && _socket!.connected) return; // กันต่อซ้ำ

    _socket = io.io(ApiConstants.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      // ตรงกับ backend: socket.on('join_customer', (token) => { verify + join room `customer_${cid}` })
      _socket!.emit('join_customer', token);
    });

    _socket!.onDisconnect((_) {});
  }

  // payload จาก backend: { orderid, order_code, status, reason?, message }
  void onOrderStatus(void Function(Map<String, dynamic> data) callback) {
    _socket?.off('order_status'); // กันผูก listener ซ้ำ
    _socket?.on(
      'order_status',
      (data) => callback(Map<String, dynamic>.from(data)),
    );
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
