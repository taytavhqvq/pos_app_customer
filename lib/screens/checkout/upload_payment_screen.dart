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
  bool _savingQr = false;
  bool _isPickingImage = false;

  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    setState(() => _isPickingImage = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _slipImage = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ບໍ່ສາມາດເປີດຄັງຮູບພາບໄດ້ ລອງໃໝ່ອີກຄັ້ງ'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

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

  Future<void> _confirmExitToDashboard(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'ຍັງບໍ່ໄດ້ອັບໂຫຼດສະລິບ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'ທ່ານຍັງບໍ່ໄດ້ອັບໂຫຼດຮູບການໂອນເງີນ ແນ່ໃຈບໍ່ວ່າຈະອອກຈາກໜ້ານີ້?\n'
                'ອໍເດີຂອງທ່ານຍັງຄ້າງຢູ່ ສາມາດກັບມາອັບໂຫຼດພາຍຫຼັງໄດ້ຈາກໜ້າ "ອໍເດີ"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),

              Container(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 12),

              const Text(
                'ໝາຍເຫດ: ບໍ່ຕ້ອງອັບໂຫລດຮູບພາບພາຍໃນ 30 ນາທີ ຖ້າທ່ານຕ້ອງການຍົກເລີກ!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text(
                        'ຍົກເລີກ',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text(
                        'ອອກ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldExit == true && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(initialIndex: 1),
        ),
        (route) => false,
      );
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
        actions: [
          if (!_uploaded)
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Colors.white),
              tooltip: 'ກັບໄປໜ້າຫຼັກ',
              onPressed: () => _confirmExitToDashboard(context),
            ),
        ],
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

            if (!_uploaded)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isPickingImage ? null : _pickImage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        disabledBackgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isPickingImage
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
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
