import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;

  void connect(String token) {
    _socket = io.io('http://<YOUR_SERVER_IP>:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      _socket!.emit(
        'join_customer',
        token,
      ); // ตรงกับ backend ที่ verify token + decoded.role === 'customer'
    });
  }

  void onOrderStatus(void Function(dynamic data) callback) {
    _socket?.on('order_status', callback);
    // payload: { orderid, order_code, status, reason?, message }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
  }
}
