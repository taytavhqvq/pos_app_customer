import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductService {
  final Dio _dio = ApiClient().dio;

  // GET /products - ไม่มี query param filter ที่ backend เลย ต้องดึงมาทั้งหมดแล้ว filter ฝั่ง client
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final res = await _dio.get(ApiConstants.products);
      final List<dynamic> data = res.data['data'];
      // ลูกค้าใช้ authenticateFlexible -> backend คืนเฉพาะ is_active = true มาให้อยู่แล้ว
      return data.map((p) => ProductModel.fromJson(p)).toList();
    } on DioException catch (e) {
      throw ApiClient.extractErrorMessage(e, 'ໂຫລດຂໍ້ມູນສິນຄ້າບໍ່ສຳເລັດ');
    }
  }

  Future<ProductModel> getProductDetail(int proid) async {
    try {
      final res = await _dio.get(ApiConstants.productDetail(proid));
      return ProductModel.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw ApiClient.extractErrorMessage(e, 'ໂຫລດຂໍ້ມູນສິນຄ້າບໍ່ສຳເລັດ');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await _dio.get(ApiConstants.categories);
      final List<dynamic> data = res.data['data'];
      return data.map((c) => CategoryModel.fromJson(c)).toList();
    } on DioException catch (e) {
      throw ApiClient.extractErrorMessage(e, 'ໂຫລດຂໍ້ມູນໝວດໝູ່ບໍ່ສຳເລັດ');
    }
  }
}
