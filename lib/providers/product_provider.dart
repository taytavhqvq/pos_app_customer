import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<ProductModel> _allProducts = [];
  List<CategoryModel> categories = [];
  int? selectedCatId; // null = ทั้งหมด
  String searchQuery = '';
  bool isLoading = false;
  String? errorMessage;

  // filter ฝั่ง client ตามที่ backend ไม่รองรับ query param
  List<ProductModel> get filteredProducts {
    return _allProducts.where((p) {
      final matchSearch = p.proname.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchCat =
          selectedCatId == null || p.catname == _categoryName(selectedCatId!);
      return matchSearch && matchCat;
    }).toList();
  }

  String? _categoryName(int catid) {
    final match = categories.where((c) => c.catid == catid);
    return match.isEmpty ? null : match.first.catname;
  }

  Future<void> loadAll() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.getAllProducts(),
        _service.getCategories(),
      ]);
      _allProducts = results[0] as List<ProductModel>;
      categories = results[1] as List<CategoryModel>;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(int? catid) {
    selectedCatId = catid;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  ProductModel? findById(int proid) {
    final match = _allProducts.where((p) => p.proid == proid);
    return match.isEmpty ? null : match.first;
  }
}
