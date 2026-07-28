import 'dart:async';
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

  // ===== cache ผลลัพธ์ filter ไว้ ไม่คำนวณใหม่ทุกครั้งที่ถูกอ่าน =====
  List<ProductModel> _filteredProductsCache = [];
  List<ProductModel> get filteredProducts => _filteredProductsCache;

  // ===== debounce สำหรับช่องค้นหา =====
  Timer? _searchDebounce;

  void _recomputeFilteredProducts() {
    final query = searchQuery.toLowerCase();
    final selectedCatName = selectedCatId == null
        ? null
        : _categoryName(selectedCatId!);

    _filteredProductsCache = _allProducts.where((p) {
      final matchSearch = p.proname.toLowerCase().contains(query);
      final matchCat = selectedCatId == null || p.catname == selectedCatName;
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
      _recomputeFilteredProducts();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(int? catid) {
    selectedCatId = catid;
    _recomputeFilteredProducts(); // เปลี่ยนหมวด ไม่ต้องหน่วง อยากให้ตอบสนองทันที
    notifyListeners();
  }

  // ===== แก้ตรงนี้: หน่วงเวลาก่อนคำนวณ filter จริง =====
  void setSearchQuery(String query) {
    searchQuery =
        query; // เก็บค่าล่าสุดไว้ก่อน (เผื่อ debounce ยิงช้ากว่าที่พิมพ์จริง)

    _searchDebounce?.cancel(); // ยกเลิกตัวจับเวลาเก่า ถ้ายังพิมพ์ต่อ
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _recomputeFilteredProducts();
      notifyListeners(); // rebuild แค่ตอนหยุดพิมพ์ครบ 300ms เท่านั้น
    });
  }

  ProductModel? findById(int proid) {
    final match = _allProducts.where((p) => p.proid == proid);
    return match.isEmpty ? null : match.first;
  }

  // ===== ต้อง cancel timer ตอน provider ถูกทำลาย กัน memory leak / setState หลัง dispose =====
  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
