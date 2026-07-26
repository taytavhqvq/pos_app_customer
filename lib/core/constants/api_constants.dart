class ApiConstants {
  static const String baseUrl =
      'http://localhost:3000/api'; //'http://10.0.2.2:3000/api';
  // Android Emulator ใช้ 10.0.2.2 แทน localhost
  // มือถือจริงในวง LAN เดียวกัน เปลี่ยนเป็น IP เครื่อง backend เช่น http://192.168.1.50:3000/api
  static const String socketUrl = 'http://localhost:3000';

  // ===== Auth (customer) =====
  static const String login = '/customers/login';
  static const String register = '/customers/register';
  static const String me = '/customers/me';
  static const String updateProfile = '/customers/profile';
  static const String changePassword = '/customers/change-password';

  // ===== Products =====
  static const String products = '/products';
  static String productDetail(int proid) => '/products/$proid';
  static const String categories = '/categories';

  // ===== Orders =====
  static const String createOnlineOrder = '/orders/online';
  static const String myOrders = '/orders/my';
  static String myOrderDetail(int orderid) => '/orders/my/$orderid';

  // ===== Payments =====
  static String uploadSlip(int orderid) => '/payments/upload/$orderid';
}
