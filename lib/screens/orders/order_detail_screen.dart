import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/api_constants.dart';
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

  // กล่องข้อความสีตามสถานะ ด้านล่างยอดรวม
  Widget _buildStatusMessage(order) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String title;
    String? subtitle;

    if (order.isPaid) {
      bgColor = const Color(0xFFE8F5E9);
      textColor = AppColors.success;
      icon = Icons.check_circle;
      title = 'ຄຳສັ່ງຊື້ຂອງທ່ານສຳເລັດແລ້ວ.';
      subtitle = 'ຂອບໃຈທີ່ເລືອກຊື້ສິນຄ້າກັບຮ້ານ minimart';
    } else if (order.isPending && order.slipImageUrl == null) {
      // ยังไม่แนบสลิปเลย — ต้องแยกจากเคส "รอร้านตรวจ"
      bgColor = const Color(0xFFFFF3E0);
      textColor = AppColors.warning;
      icon = Icons.upload_file;
      title = 'ກະລຸນາອັບໂຫຼດຮູບການໂອນເງີນເພື່ອດຳເນີນການຕໍ່';
      subtitle = 'ອໍເດີຈະຖືກຍົກເລີກອັດຕະໂນມັດຖ້າບໍ່ອັບໂຫຼດພາຍໃນ 30 ນາທີ';
    } else if (order.isPending) {
      // มีสลิปแล้ว รอแอดมินตรวจ
      bgColor = const Color(0xFFFFF3E0);
      textColor = AppColors.warning;
      icon = Icons.hourglass_bottom;
      title = 'ຮູບພາບຈ່າຍເງິນຂອງທ່ານຍັງບໍ່ໄດ້ຮັບການຢືນຢັນ';
      subtitle = 'ກະລຸນາລໍຖ້າຮ້ານຄ້າກວດສອບ';
    } else {
      // rejected / cancelled
      bgColor = const Color(0xFFFDECEA);
      textColor = AppColors.danger;
      icon = Icons.cancel;
      title = order.isRejected ? 'ຮູບພາບຈ່າຍເງິນບໍ່ຖືກຕ້ອງ' : 'ອໍເດີຖືກຍົກເລີກ';
      subtitle = order.rejectReason ?? 'ກະລຸນາຕິດຕໍ່ຮ້ານຄ້າ';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: textColor, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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
        title: order != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    order.orderCode,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    DateFormatter.formatDate(order.createdAt),
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              )
            : const Text(
                'ລາຍລະອຽດອໍເດີ',
                style: TextStyle(color: Colors.white, fontSize: 16),
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
                  const Text(
                    'ສິນຄ້າ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  // ===== การ์ดรายการสินค้า custom row กันบั๊ก layout =====
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < order.items.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ===== รูปสินค้า =====
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: order.items[i].imageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl:
                                              '${ApiConstants.baseUrl.replaceAll('/api', '')}${order.items[i].imageUrl}',
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => Container(
                                            width: 48,
                                            height: 48,
                                            color: Colors.grey.shade100,
                                          ),
                                          errorWidget: (_, __, ___) =>
                                              Container(
                                                width: 48,
                                                height: 48,
                                                color: Colors.grey.shade100,
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                  size: 18,
                                                ),
                                              ),
                                        )
                                      : Container(
                                          width: 48,
                                          height: 48,
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
                                        order.items[i].proname,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      // ===== ราคาต่อหน่วย x จำนวน =====
                                      Text(
                                        '${CurrencyFormatter.format(order.items[i].unitPrice)} ກີບ / ${order.items[i].uname}  ×  ${order.items[i].qty}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // ===== ราคารวมของรายการนี้ =====
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
                                      '${CurrencyFormatter.format(order.items[i].lineTotal)} ກີບ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== ยอดรวม =====
                  Container(
                    width: double.infinity,
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
                          '${CurrencyFormatter.format(order.total)} ກີບ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== กล่องข้อความสถานะ ตามภาพ 12/13/14 =====
                  _buildStatusMessage(order),

                  // ===== ปุ่มอัปโหลดใหม่ (เฉพาะกรณีปฏิเสธแบบ resubmit ได้) =====
                  if (order.isRejected ||
                      (order.isPending && order.slipImageUrl == null)) ...[
                    const SizedBox(height: 12),
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
                ],
              ),
            ),
    );
  }
}
