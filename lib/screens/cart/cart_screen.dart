import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../checkout/order_summary_screen.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback onGoToHome;
  const CartScreen({super.key, required this.onGoToHome});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final serverRoot = ApiConstants.baseUrl.replaceAll('/api', '');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'ຕະກ້າສິນຄ້າ',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${cart.itemCount} ລາຍການ', // เปลี่ยนจาก "ຈຳນວນ" เป็น "ລາຍການ"
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: cart.isEmpty
          ? _EmptyCart(onGoToHome: onGoToHome)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== รูปสินค้า มุมซ้าย =====
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: item.product.imageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl:
                                        '$serverRoot${item.product.imageUrl}',
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      width: 56,
                                      height: 56,
                                      color: Colors.grey.shade100,
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      width: 56,
                                      height: 56,
                                      color: Colors.grey.shade100,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 56,
                                    height: 56,
                                    color: Colors.grey.shade100,
                                    child: const Icon(
                                      Icons.inventory_2_outlined,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.proname,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // ===== ราคาต่อหน่วย แยกให้เห็นชัด =====
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '${CurrencyFormatter.format(item.unit.saleprice)} ກີບ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                    Text(
                                      ' / ${item.unit.uname}',
                                      style: const TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ===== ตัวควบคุมจำนวน พร้อมกำกับหน่วยใต้ตัวเลข =====
                          Row(
                            children: [
                              _QtyIconButton(
                                icon: Icons.remove_circle_outline,
                                onTap: () =>
                                    cart.updateQty(item.cartKey, item.qty - 1),
                              ),
                              SizedBox(
                                width: 46,
                                child: Column(
                                  children: [
                                    Text(
                                      '${item.qty}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      item.unit.uname,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _QtyIconButton(
                                icon: Icons.add_circle_outline,
                                onTap: () =>
                                    cart.updateQty(item.cartKey, item.qty + 1),
                              ),
                            ],
                          ),
                          // ===== ราคารวมของรายการนี้ + ปุ่มลบ =====
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'ລວມ',
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '${CurrencyFormatter.format(item.lineTotal)} ກີບ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              _QtyIconButton(
                                icon: Icons.delete_outline,
                                color: AppColors.danger,
                                onTap: () => cart.removeItem(item.cartKey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ລວມ', style: TextStyle(fontSize: 18)),
                        Text(
                          '${CurrencyFormatter.format(cart.totalAmount)} ກີບ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrderSummaryScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'ສັ່ງຊື້ສິນຄ້າ', // เปลี่ยนจาก "ยืนยันสั่งซื้อสินค้า" เป็น "สั่งซื้อสินค้า"
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ปุ่ม icon เล็กๆ ใช้ในแถวควบคุมจำนวน/ลบ
class _QtyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _QtyIconButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 20, color: color ?? AppColors.textDark),
      ),
    );
  }
}

// ===== Empty state =====
class _EmptyCart extends StatelessWidget {
  final VoidCallback onGoToHome;
  const _EmptyCart({required this.onGoToHome});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_basket_outlined,
                color: AppColors.secondary,
                size: 42,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ກະຕ່າວ່າງເປົ່າ',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'ເລືອກສິນຄ້າເພີ່ມເຕີມ!',
              style: TextStyle(fontSize: 13, color: AppColors.textLight),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onGoToHome,
                child: const Text(
                  'ໄປເລືອກສິນຄ້າ',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
