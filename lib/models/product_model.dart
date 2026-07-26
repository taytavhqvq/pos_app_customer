// ตรงกับ response ของ GET /products และ GET /products/:id
class ProductUnitModel {
  final int conid;
  final int uid;
  final String uname;
  final String? barcode;
  final int qtyBase;
  final double imprice;
  final double saleprice;

  ProductUnitModel({
    required this.conid,
    required this.uid,
    required this.uname,
    this.barcode,
    required this.qtyBase,
    required this.imprice,
    required this.saleprice,
  });

  factory ProductUnitModel.fromJson(Map<String, dynamic> json) {
    return ProductUnitModel(
      conid: json['conid'],
      uid: json['uid'],
      uname: json['uname'],
      barcode: json['barcode'],
      qtyBase: json['qty_base'],
      imprice: double.parse(json['imprice'].toString()),
      saleprice: double.parse(json['saleprice'].toString()),
    );
  }
}

class ProductModel {
  final int proid;
  final String proname;
  final bool isActive;
  final String? imageUrl;
  final String? catname;
  final List<ProductUnitModel> units;

  ProductModel({
    required this.proid,
    required this.proname,
    required this.isActive,
    this.imageUrl,
    this.catname,
    required this.units,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      proid: json['proid'],
      proname: json['proname'],
      isActive: json['is_active'] ?? true,
      imageUrl: json['image_url'],
      catname: json['catname'],
      units: (json['units'] as List<dynamic>? ?? [])
          .map((u) => ProductUnitModel.fromJson(u))
          .toList(),
    );
  }

  // หน่วยฐาน (qty_base น้อยสุด) ใช้โชว์ราคาเริ่มต้นในหน้า Dashboard
  ProductUnitModel? get baseUnit {
    if (units.isEmpty) return null;
    final sorted = [...units]..sort((a, b) => a.qtyBase.compareTo(b.qtyBase));
    return sorted.first;
  }
}
