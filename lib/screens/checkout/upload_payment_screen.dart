import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gal/gal.dart'; // เพิ่ม import นี้
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
  bool _savingQr = false; // เพิ่ม state สำหรับ loading ตอนบันทึก QR

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

  // ===== เพิ่ม method นี้ — บันทึกรูป QR ของร้านลง gallery =====
  Future<void> _saveQrImage() async {
    setState(() => _savingQr = true);
    try {
      final byteData = await rootBundle.load('lib/assets/images/MyQR.jpeg');
      final bytes = byteData.buffer.asUint8List();

      await Gal.putImageBytes(
        bytes,
        name: 'minimart_qr_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ບັນທຶກຮູບ QR ລົງເຄື່ອງແລ້ວ')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ບັນທຶກຮູບບໍ່ສຳເລັດ ກະລຸນາອະນຸຍາດເຂົ້າເຖິງຮູບພາບ'),
        ),
      );
    } finally {
      if (mounted) setState(() => _savingQr = false);
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
              padding: const EdgeInsets.all(14),
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
                  const SizedBox(height: 6),
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
            const SizedBox(height: 12),

            // ===== QR ของร้าน + ปุ่มบันทึกรูป =====
            // ซ่อนไปเลยหลังอัปโหลดสำเร็จ เพราะไม่จำเป็นต้องใช้อีก
            // (ลดความสูงหน้าจอ + กันไม่ให้ layout กระโดดตอนโชว์ผลอัปโหลด)
            if (!_uploaded) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Text(
                      'ສະແກນ QR ເພື່ອຊຳລະເງີນ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'lib/assets/images/MyQR.jpeg',
                        width: 150,
                        height: 150,
                        errorBuilder: (_, __, ___) => Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey.shade100,
                          child: const Icon(
                            Icons.qr_code_2,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _savingQr ? null : _saveQrImage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: _savingQr
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.download,
                              size: 16,
                              color: AppColors.primary,
                            ),
                      label: Text(
                        _savingQr ? 'ກຳລັງບັນທຶກ...' : 'ບັນທຶກຮູບ',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ===== ส่วนอัปโหลดรูปภาพจ่ายเงิน =====
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ຮູບພາບຈ່າຍເງິນ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              height: 150,
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
                            size: 36,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'ເລືອກຮູບພາບ\nພາບຈ່າຍເງີນຂອງທ່ານ',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // ===== ปุ่ม เลือกรูป/อัปโหลด — ซ่อนหลังอัปโหลดสำเร็จ ไม่ต้องโชว์ปุ่ม disable ค้างไว้ =====
            if (!_uploaded)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickImage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'ເລືອກຮູບ',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (isUploading || _slipImage == null)
                          ? null
                          : _submit,
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
                                Icon(
                                  Icons.upload,
                                  size: 18,
                                  color: Colors.white,
                                ),
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
              const SizedBox(height: 16),
              const Text(
                '✅ ສົ່ງຫຼັກຖານແລ້ວ ລໍຖ້າຮ້ານຄ້າກວດສອບ',
                style: TextStyle(color: AppColors.success),
              ),
              const SizedBox(height: 14),
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
                    MaterialPageRoute(
                      builder: (_) => const DashboardScreen(initialIndex: 1),
                    ),
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
