import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/order_provider.dart';
import '../../widgets/status_badge.dart';
import '../checkout/upload_payment_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderid;
  const OrderDetailScreen({super.key, required this.orderid});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrderDetail(widget.orderid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final order = orderProvider.selectedOrder;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          order != null ? order.orderCode : 'ລາຍລະອຽດອໍເດີ',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          if (order != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: StatusBadge(status: order.status)),
            ),
        ],
      ),
      body: orderProvider.isLoadingDetail || order == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormatter.formatDateTime(order.createdAt),
                    style: const TextStyle(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 16),

                  // ===== รายการสินค้า =====
                  Card(
                    child: Column(
                      children: order.items
                          .map(
                            (item) => ListTile(
                              title: Text(item.proname),
                              subtitle: Text('${item.qty} ${item.uname}'),
                              trailing: Text(
                                '${CurrencyFormatter.format(item.lineTotal)} ກີບ',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

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
                        '${CurrencyFormatter.format(order.total)} ກີບ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  // ===== แจ้งเตือนถูกปฏิเสธ (สิ่งที่แก้ backend เพิ่ม join tbpayments ไว้รองรับ) =====
                  if (order.isRejected) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECEA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.danger.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '⚠️ ການຊຳລະເງິນຖືກປະຕິເສດ',
                            style: TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (order.rejectReason != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'ເຫດຜົນ: ${order.rejectReason}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UploadPaymentScreen(order: order),
                          ),
                        ),
                        child: const Text(
                          'ອັບໂຫຼດຮູບໃໝ່',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],

                  // ===== รอตรวจสอบ - โชว์รูปสลิปที่ส่งไปแล้ว (ถ้ามี) =====
                  if (order.isPending && order.slipImageUrl != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'ຮູບການໂອນເງີນທີ່ສົ່ງ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '⏳ ລໍຖ້າຮ້ານຄ້າກວດສອບ',
                      style: TextStyle(color: AppColors.warning),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
