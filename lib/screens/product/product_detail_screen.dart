import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final int proid;
  const ProductDetailScreen({super.key, required this.proid});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ไม่ auto-select แล้ว ต้องเป็น null จนกว่าผู้ใช้จะเลือกเอง
  ProductUnitModel? _selectedUnit;
  int _qty = 1;

  void _resetSelection() {
    setState(() {
      _selectedUnit = null;
      _qty = 1;
    });
  }

  void _addToCart(ProductModel product) {
    context.read<CartProvider>().addItem(product, _selectedUnit!, _qty);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ເພີ່ມ "${product.proname}" ລົງໃນຕະກ້າແລ້ວ'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // reset กลับเป็นค่าเริ่มต้น เหมือนตอนเพิ่งเปิดหน้านี้ครั้งแรก
    _resetSelection();
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>().findById(widget.proid);
    final cartTotalQty = context.watch<CartProvider>().totalQty;

    if (product == null) {
      return const Scaffold(body: Center(child: Text('ບໍ່ພົບຂໍ້ມູນສິນຄ້າ')));
    }

    final serverRoot = ApiConstants.baseUrl.replaceAll('/api', '');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          product.proname,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // ===== ไอคอนตะกร้า + badge จำนวนรวมในตะกร้า =====
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_basket_outlined),
                onPressed: () => Navigator.pop(context, true),
              ),
              if (cartTotalQty > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$cartTotalQty',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: product.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: '$serverRoot${product.imageUrl}',
                      fit: BoxFit.contain,
                    )
                  : Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.inventory_2_outlined, size: 60),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.proname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'ເລືອກຫົວໜ່ວຍ',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ແຕ່ລະໜ່ວຍມີລາຄາຕ່າງກັນ ກະລຸນາເລືອກໜ່ວຍທີ່ຕ້ອງການກ່ອນໃສ່ຈຳນວນ',
                    style: TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 10),

                  // ===== การ์ดเลือกหน่วย แบบ custom ไม่ auto-select =====
                  ...product.units.map((unit) {
                    final isSelected = _selectedUnit?.uid == unit.uid;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedUnit = unit),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : Colors.grey.shade300,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected
                                  ? AppColors.secondary
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    unit.uname,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // จำนวนพื้นฐานของหน่วยนี้ ดึงจาก qty_base จริงเสมอ ไม่ hardcode
                                  Text(
                                    '${unit.qtyBase} ຫົວໜ່ວຍພື້ນຖານ',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${CurrencyFormatter.format(unit.saleprice)} ກີບ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // ===== ช่องเลือกจำนวน ดีไซน์ใหม่แบบ pill =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ຈຳນວນ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _QtyButton(
                              icon: Icons.remove,
                              onTap: () => setState(() {
                                if (_qty > 1) _qty--;
                              }),
                            ),
                            SizedBox(
                              width: 36,
                              child: Text(
                                '$_qty',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _QtyButton(
                              icon: Icons.add,
                              onTap: () => setState(() => _qty++),
                              filled: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _selectedUnit == null
                  ? null
                  : () => _addToCart(product),
              child: const Text(
                'ເພີ່ມສິນຄ້າລົງໃນຕະກ້າ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ปุ่ม +/- ทรงกลม ใช้ในช่องเลือกจำนวน
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        margin: const EdgeInsets.all(4),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: filled ? AppColors.secondary : Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled ? Colors.white : AppColors.textDark,
        ),
      ),
    );
  }
}
