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
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);

    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (phone.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'ກະລຸນາປ້ອນຂໍ້ມູນໃຫ້ຄົບຖ້ວນ');
      return;
    }
    if (!RegExp(r'^\d{8}$').hasMatch(phone)) {
      setState(() => _errorMessage = 'ໝາຍເລກໂທລະສັບຕ້ອງມີ 8 ໂຕ');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວ');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'ລະຫັດຜ່ານບໍ່ກົງກັນ');
      return;
    }
    if (!_acceptTerms) {
      setState(() => _errorMessage = 'ກະລຸນາຍອມຮັບເງື່ອນໄຂການໃຊ້ງານ');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final error = await authProvider.register(phone, password);

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ລົງທະບຽນສຳເລັດ ກະລຸນາເຂົ້າສູ່ລະບົບ')),
      );
      Navigator.pop(context);
    } else {
      setState(() => _errorMessage = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // ===== Top bar มีปุ่มย้อนกลับ ตามดีไซน์ =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'ສະໝັກສະມາຊິກ',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.storefront,
                        color: AppColors.primary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Minimart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          if (_errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDECEA),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '⚠️ $_errorMessage',
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          AppTextField(
                            hint: 'ເບີໂທ',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            hint: 'ລະຫັດຜ່ານ',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            hint: 'ຢືນຢັນລະຫັດຜ່ານ',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Checkbox(
                                value: _acceptTerms,
                                onChanged: (v) =>
                                    setState(() => _acceptTerms = v ?? false),
                              ),
                              const Expanded(
                                child: Text(
                                  'ຂ້າພະເຈົ້າຍອມຮັບເງື່ອນໄຂການໃຊ້ງານ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          AppButton(
                            label: 'ສະໝັກສະມາຊິກ',
                            onPressed: _handleRegister,
                            isLoading: isLoading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
