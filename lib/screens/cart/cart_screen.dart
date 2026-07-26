import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../checkout/order_summary_screen.dart'; // เปลี่ยนจาก upload_payment_screen เป็นตัวนี้

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'ກະຕ່າສິນຄ້າ (${cart.totalQty} ລາຍການ)',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        automaticallyImplyLeading: false,
      ),
      body: cart.isEmpty
          ? const Center(child: Text('ບໍ່ມີສິນຄ້າໃນກະຕ່າ'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Card(
                  child: ListTile(
                    title: Text(item.product.proname),
                    subtitle: Text('${item.unit.uname} x ${item.qty}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${CurrencyFormatter.format(item.lineTotal)} ກີບ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () =>
                                  cart.updateQty(item.cartKey, item.qty - 1),
                            ),
                            Text('${item.qty}'),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () =>
                                  cart.updateQty(item.cartKey, item.qty + 1),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.danger,
                              ),
                              onPressed: () => cart.removeItem(item.cartKey),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                          // แค่ไปหน้า summary ให้ review ก่อน ยังไม่ยิง API ที่นี่
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrderSummaryScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'ຢືນຢັນສັ່ງຊື້',
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
