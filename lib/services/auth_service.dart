import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/customer_model.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final res = await _dio.post(
        ApiConstants.login,
        data: {'phone': phone, 'password': password},
      );
      final data = res.data['data'];
      return {
        'token': data['token'],
        'customer': CustomerModel.fromJson(data['customer']),
      };
    } on DioException catch (e) {
      throw ApiClient.extractErrorMessage(e, 'ເຂົ້າສູ່ລະບົບບໍ່ສຳເລັດ');
    }
  }

  Future<String> register(String phone, String password) async {
    try {
      final res = await _dio.post(
        ApiConstants.register,
        data: {'phone': phone, 'password': password},
      );
      return res.data['message'] ?? 'ລົງທະບຽນສຳເລັດ';
    } on DioException catch (e) {
      throw ApiClient.extractErrorMessage(e, 'ລົງທະບຽນບໍ່ສຳເລັດ');
    }
  }

  Future<CustomerModel> getMe() async {
    try {
      final res = await _dio.get(ApiConstants.me);
      return CustomerModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiClient.extractErrorMessage(e, 'ໂຫລດຂໍ້ມູນບໍ່ສຳເລັດ');
    }
  }

  Future<String> updateProfile(String phone) async {
    try {
      final res = await _dio.put(
        ApiConstants.updateProfile,
        data: {'phone': phone},
      );
      return res.data['message'] ?? 'ແກ້ໄຂສຳເລັດ';
    } on DioException catch (e) {
      throw ApiClient.extractErrorMessage(e, 'ແກ້ໄຂບໍ່ສຳເລັດ');
    }
  }

  Future<String> changePassword(String oldPassword, String newPassword) async {
    try {
      final res = await _dio.patch(
        ApiConstants.changePassword,
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );
      return res.data['message'] ?? 'ປ່ຽນລະຫັດຜ່ານສຳເລັດ';
    } on DioException catch (e) {
      throw ApiClient.extractErrorMessage(e, 'ປ່ຽນລະຫັດຜ່ານບໍ່ສຳເລັດ');
    }
  }
}
