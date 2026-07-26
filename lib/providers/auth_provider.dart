import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus status = AuthStatus.unknown;
  CustomerModel? customer;
  String? token;
  bool isLoading = false;

  // เรียกตอนเปิดแอปครั้งแรก เช็คว่ามี token ค้างอยู่ไหม (auto-login)
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    final savedCustomer = prefs.getString('customer');

    if (savedToken == null || savedCustomer == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    token = savedToken;
    customer = CustomerModel.fromJson(jsonDecode(savedCustomer));
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<String?> login(String phone, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.login(phone, password);
      token = result['token'];
      customer = result['customer'] as CustomerModel;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token!);
      await prefs.setString('customer', jsonEncode(customer!.toJson()));

      status = AuthStatus.authenticated;
      isLoading = false;
      notifyListeners();
      return null; // null = สำเร็จ ไม่มี error
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> register(String phone, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      await _authService.register(phone, password);
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('customer');
    token = null;
    customer = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
