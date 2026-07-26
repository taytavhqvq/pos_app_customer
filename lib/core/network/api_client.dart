import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'http://<YOUR_SERVER_IP>:3000/api';

  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // token หมดอายุ (24h ตามที่ตั้งไว้ฝั่ง backend) → เด้งกลับ login
          if (error.response?.statusCode == 401) {
            // TODO: เรียก AuthProvider.logout() + navigate ไป LoginScreen
          }
          return handler.next(error);
        },
      ),
    );
  }
}
