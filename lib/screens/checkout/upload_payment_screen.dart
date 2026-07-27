import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../home/dashboard_screen.dart';

class UploadPaymentScreen extends StatefulWidget {
  final OrderModel order;
  const UploadPaymentScreen({super.key, required this.order});

  @override
  State<UploadPaymentScreen> createState() => _UploadPaymentScreenState();
}

class _UploadPaymentScreenState extends State<UploadPaymentScreen> {
  File? _slipImage;
  bool _uploaded = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _slipImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_slipImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ກະລຸນາເລືອກຮູບພາບກ່ອນ')));
      return;
    }

    final orderProvider = context.read<OrderProvider>();
    final success = await orderProvider.uploadSlip(
      widget.order.orderid,
      _slipImage!,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _uploaded = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage ?? 'ອັບໂຫຼດບໍ່ສຳເລັດ'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUploading = context.watch<OrderProvider>().isUploadingSlip;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'ອັບໂຫຼດສະລິບໂອນເງີນ',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== การ์ดสรุปยอด =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ເລກທີການສັ່ງຊື້',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                      Text(
                        widget.order.orderCode,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ລາຄາລວມ',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                      Text(
                        '${CurrencyFormatter.format(widget.order.total)} ກີບ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===== QR ของร้าน ย้ายมาไว้บนช่องอัปโหลด ตามดีไซน์ =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text(
                    'ສະແກນ QR ເພື່ອຊຳລະເງີນ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'lib/assets/images/MyQR.jpeg',
                      width: 220,
                      height: 220,
                      errorBuilder: (_, __, ___) => Container(
                        width: 220,
                        height: 220,
                        color: Colors.grey.shade100,
                        child: const Icon(
                          Icons.qr_code_2,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== ส่วนอัปโหลดรูปภาพจ่ายเงิน =====
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ຮູບພາບຈ່າຍເງິນ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 10),

            // กล่อง placeholder / preview รูปที่เลือก
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _uploaded ? AppColors.success : Colors.grey.shade300,
                  width: _uploaded ? 2 : 1,
                ),
              ),
              child: _slipImage != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_slipImage!, fit: BoxFit.cover),
                        ),
                        if (_uploaded)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    )
                  : const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'ເລືອກຮູບພາບ\nພາບຈ່າຍເງີນຂອງທ່ານ',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 14),

            // ===== 2 ปุ่มแยกกัน: เลือกรูป / อัปโหลดรูป =====
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _uploaded ? null : _pickImage,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: _uploaded
                            ? Colors.grey.shade300
                            : AppColors.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'ເລືອກຮູບ',
                      style: TextStyle(
                        color: _uploaded ? Colors.grey : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _uploaded
                        ? null
                        : (isUploading || _slipImage == null ? null : _submit),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.upload, size: 18, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'ອັບໂຫລດຮູບ',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),

            if (_uploaded) ...[
              const SizedBox(height: 20),
              const Text(
                '✅ ສົ່ງຫຼັກຖານແລ້ວ ລໍຖ້າຮ້ານຄ້າກວດສອບ',
                style: TextStyle(color: AppColors.success),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    (route) => false,
                  ),
                  child: const Text(
                    'ກັບໄປໜ້າຫຼັກ',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
