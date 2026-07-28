class AppNotification {
  final int orderid;
  final String orderCode;
  final String status;
  final String message;
  final DateTime receivedAt;
  bool isRead;

  AppNotification({
    required this.orderid,
    required this.orderCode,
    required this.status,
    required this.message,
    required this.receivedAt,
    this.isRead = false,
  });

  factory AppNotification.fromSocketData(Map<String, dynamic> data) {
    return AppNotification(
      orderid: data['orderid'],
      orderCode: data['order_code'] ?? '',
      status: data['status'] ?? '',
      message: data['message'] ?? '',
      receivedAt: DateTime.now(),
    );
  }
}
