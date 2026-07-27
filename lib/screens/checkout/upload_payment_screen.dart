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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ກະລຸນາອັບໂຫຼດຮູບການໂອນເງີນ')),
      );
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
          'ອັບໂຫຼດຫຼັກຖານການໂອນເງີນ',
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ອໍເດີທີ່: ${widget.order.orderCode}'),
                    Text(
                      '${CurrencyFormatter.format(widget.order.total)} ກີບ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ===== QR ของร้าน (static asset ตามที่ตกลงกันไว้) =====
            const Text(
              'ສະແກນ QR ເພື່ອຊຳລະເງີນ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'lib/assets/images/MyQR.jpeg',
                width: 220,
                height: 220,
              ),
            ),
            const SizedBox(height: 24),

            // ===== ช่องอัปโหลดสลิป =====
            const Text(
              'ອັບໂຫຼດຮູບການໂອນເງີນ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _uploaded ? null : _pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _uploaded ? AppColors.success : Colors.grey.shade300,
                    width: _uploaded ? 2 : 1,
                    style: BorderStyle.solid,
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
                              'ເລືອກຮູບພາບ ການໂອນຈ່າຍ',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _uploaded
                      ? Colors.grey.shade300
                      : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _uploaded
                    ? () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                        (route) => false,
                      )
                    : (isUploading ? null : _submit),
                child: isUploading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _uploaded ? 'ກັບໄປໜ້າຫຼັກ' : 'ຢືນຢັນສົ່ງ',
                        style: TextStyle(
                          color: _uploaded ? AppColors.textDark : Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),

            if (_uploaded)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  '✅ ສົ່ງຫຼັກຖານແລ້ວ ລໍຖ້າຮ້ານຄ້າກວດສອບ',
                  style: TextStyle(color: AppColors.success),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
