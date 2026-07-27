import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;

  // error แยกตามช่อง แทนการใช้ banner รวมอันเดียว
  String? _phoneError;
  String? _passwordError;
  String? _confirmError;
  String? _termsError;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _phoneError = null;
      _passwordError = null;
      _confirmError = null;
      _termsError = null;
    });

    bool valid = true;
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (phone.isEmpty) {
      _phoneError = 'ກະລຸນາປ້ອນເບີໂທ';
      valid = false;
    } else if (!RegExp(r'^\d{8}$').hasMatch(phone)) {
      _phoneError = 'ໝາຍເລກໂທລະສັບຕ້ອງມີ 8 ໂຕ';
      valid = false;
    }

    if (password.isEmpty) {
      _passwordError = 'ກະລຸນາປ້ອນລະຫັດຜ່ານ';
      valid = false;
    } else if (password.length < 6) {
      _passwordError = 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວ';
      valid = false;
    }

    if (confirm.isEmpty) {
      _confirmError = 'ກະລຸນາຢືນຢັນລະຫັດຜ່ານ';
      valid = false;
    } else if (password.isNotEmpty && password != confirm) {
      // โชว์ error ใต้ทั้ง 2 ช่องตามที่ออกแบบไว้
      _passwordError = 'ລະຫັດຜ່ານບໍ່ຕົງກັນ';
      _confirmError = 'ລະຫັດຜ່ານບໍ່ຕົງກັນ';
      valid = false;
    }

    if (!_acceptTerms) {
      _termsError = 'ກະລຸນາຍອມຮັບເງື່ອນໄຂການໃຊ້ງານກ່ອນ';
      valid = false;
    }

    setState(() {});
    return valid;
  }

  Future<void> _handleRegister() async {
    if (!_validate()) return;

    final authProvider = context.read<AuthProvider>();
    final error = await authProvider.register(
      _phoneController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ລົງທະບຽນສຳເລັດ ກະລຸນາເຂົ້າສູ່ລະບົບ')),
      );
      Navigator.pop(context); // กลับไป login เสมอ ห้ามเข้าหน้าหลักตรง
    } else {
      // error จาก backend ตอนนี้มีแค่กรณีเบอร์ซ้ำ -> เป็น field-level ของช่องเบอร์
      setState(() => _phoneError = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'ສ້າງບັນຊີ',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              // ===== Logo — pattern เดียวกับหน้า login =====
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.storefront,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Minimart',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),

              AppTextField(
                label: 'ເບີໂທລະສັບ',
                hint: 'ເບີໂທລະສັບ',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
                errorText: _phoneError,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'ລະຫັດຜ່ານ',
                hint: 'ຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ',
                controller: _passwordController,
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                errorText: _passwordError,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'ຢືນຢັນລະຫັດຜ່ານ',
                hint: 'ຢືນຢັນລະຫັດຜ່ານ',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                errorText: _confirmError,
              ),
              const SizedBox(height: 12),

              // ===== Checkbox ยอมรับเงื่อนไข =====
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    activeColor: AppColors.primary,
                    onChanged: (v) {
                      setState(() {
                        _acceptTerms = v ?? false;
                        if (_acceptTerms) _termsError = null;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        'ຂ້ອຍຍອມຮັບຂໍ້ກຳນົດການໃຊ້ງານ ແລະ ນະໂຍບາຍຄວາມເປັນສ່ວນຕົວ',
                        style: TextStyle(
                          fontSize: 13,
                          color: _termsError != null
                              ? AppColors.danger
                              : AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_termsError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _termsError!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              AppButton(
                label: 'ລົງທະບຽນ',
                onPressed: _handleRegister,
                isLoading: isLoading,
              ),
              const SizedBox(height: 20),

              // ===== ลิงก์กลับไป login มีเส้นประขนาบ =====
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFDDD8C8))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ມີບັນຊີຢູ່ແລ້ວ? ',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'ເຂົ້າສູ່ລະບົບ',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFDDD8C8))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
