import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/loading_overlay.dart';
import 'upload_payment_screen.dart';

class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key});

  Future<void> _confirmOrder(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    final order = await orderProvider.createOrder(cart.toOrderPayload());

    if (!context.mounted) return;

    if (order != null) {
      cart.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UploadPaymentScreen(order: order)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage ?? 'ສັ່ງຊື້ບໍ່ສຳເລັດ'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isSubmitting = context.watch<OrderProvider>().isSubmittingOrder;
    final serverRoot = ApiConstants.baseUrl.replaceAll('/api', '');

    return LoadingOverlay(
      isLoading: isSubmitting,
      message: 'ກຳລັງສ້າງອໍເດີ...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'ຕະກ້າສິນຄ້າ',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
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
            ? const Center(child: Text('ບໍ່ມີສິນຄ້າໃນກະຕ່າ'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ສິນຄ້າ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < cart.items.length; i++) ...[
                            if (i > 0) const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  // ===== รูปสินค้า มุมซ้าย =====
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        cart.items[i].product.imageUrl != null
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                '$serverRoot${cart.items[i].product.imageUrl}',
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => Container(
                                              width: 44,
                                              height: 44,
                                              color: Colors.grey.shade100,
                                            ),
                                            errorWidget: (_, __, ___) =>
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  color: Colors.grey.shade100,
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                    size: 18,
                                                  ),
                                                ),
                                          )
                                        : Container(
                                            width: 44,
                                            height: 44,
                                            color: Colors.grey.shade100,
                                            child: const Icon(
                                              Icons.inventory_2_outlined,
                                              color: Colors.grey,
                                              size: 22,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cart.items[i].product.proname,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${cart.items[i].qty} ${cart.items[i].unit.uname}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${CurrencyFormatter.format(cart.items[i].lineTotal)} ກີບ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ລວມ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: cart.isEmpty
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () => _confirmOrder(context),
                      child: const Text(
                        'ຢືນຢັນສັ່ງຊື້ສິນຄ້າ', // หน้านี้ยังคงเป็น "ยืนยัน" เหมือนเดิม เพราะเป็นขั้นตอนสุดท้ายจริงๆ
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
