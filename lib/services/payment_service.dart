import 'dart:io';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class PaymentService {
  final Dio _dio = ApiClient().dio;

  // POST /payments/upload/:orderid -> multipart/form-data field name = 'image'
  Future<String> uploadSlip(int orderid, File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'slip.jpg',
        ),
      });
      final res = await _dio.post(
        ApiConstants.uploadSlip(orderid),
        data: formData,
      );
      return res.data['message'] ?? 'ອັບໂຫຼດສຳເລັດ';
    } on DioException catch (e) {
      throw ApiClient.extractErrorMessage(e, 'ອັບໂຫຼດຮູບບໍ່ສຳເລັດ');
    }
  }
}
