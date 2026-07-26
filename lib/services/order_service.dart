import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/order_model.dart';
import '../models/pagination_model.dart';

class OrderService {
  final Dio _dio = ApiClient().dio;

  // POST /orders/online
  Future<OrderModel> createOrder(List<Map<String, dynamic>> items) async {
    try {
      final res = await _dio.post(
        ApiConstants.createOnlineOrder,
        data: {'items': items},
      );
      return OrderModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiClient.extractErrorMessage(e, 'ສັ່ງຊື້ບໍ່ສຳເລັດ');
    }
  }

  // GET /orders/my?page=&limit=&status= -> ตอบกลับเป็น { orders: [...], pagination: {...} }
  Future<Map<String, dynamic>> getMyOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final res = await _dio.get(
        ApiConstants.myOrders,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        },
      );
      final data = res.data['data'];
      final List<dynamic> ordersJson = data['orders'];
      return {
        'orders': ordersJson.map((o) => OrderModel.fromJson(o)).toList(),
        'pagination': PaginationModel.fromJson(data['pagination']),
      };
    } on DioException catch (e) {
      throw ApiClient.extractErrorMessage(e, 'ໂຫລດປະຫວັດການສັ່ງຊື້ບໍ່ສຳເລັດ');
    }
  }

  // GET /orders/my/:id
  Future<OrderModel> getOrderDetail(int orderid) async {
    try {
      final res = await _dio.get(ApiConstants.myOrderDetail(orderid));
      return OrderModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiClient.extractErrorMessage(e, 'ໂຫລດຂໍ້ມູນອໍເດີບໍ່ສຳເລັດ');
    }
  }
}
