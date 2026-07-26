import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    return LoadingOverlay(
      isLoading: isSubmitting,
      message: 'ກຳລັງສ້າງອໍເດີ...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'ຢືນຢັນອໍເດີ',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        body: cart.isEmpty
            ? const Center(child: Text('ບໍ່ມີສິນຄ້າໃນກະຕ່າ'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ລາຍການສິນຄ້າ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ===== รายการสินค้า แบบ read-only ไม่มีปุ่มแก้ไข/ลบ =====
                    Card(
                      child: Column(
                        children: cart.items.map((item) {
                          return ListTile(
                            leading: item.product.imageUrl != null
                                ? null
                                : const Icon(
                                    Icons.inventory_2_outlined,
                                    color: AppColors.grey,
                                  ),
                            title: Text(item.product.proname),
                            subtitle: Text('${item.unit.uname} x ${item.qty}'),
                            trailing: Text(
                              '${CurrencyFormatter.format(item.lineTotal)} ກີບ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ===== สรุปยอด =====
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ຈຳນວນລາຍການ'),
                              Text('${cart.totalQty} ລາຍການ'),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'ກະລຸນາກວດສອບລາຍການໃຫ້ຖືກຕ້ອງກ່ອນກົດສົ່ງອໍເດີ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFC9930D),
                        ),
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
                        'ສົ່ງອໍເດີ',
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
