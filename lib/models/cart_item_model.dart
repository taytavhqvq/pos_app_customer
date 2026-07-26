import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final ProductUnitModel unit;
  int qty;

  CartItemModel({required this.product, required this.unit, this.qty = 1});

  double get lineTotal => unit.saleprice * qty;

  // ใช้เป็น key เทียบว่าเป็นแถวเดียวกันไหม (สินค้าเดียวกัน + หน่วยเดียวกัน)
  String get cartKey => '${product.proid}_${unit.uid}';
}
