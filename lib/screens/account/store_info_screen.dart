import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class _StoreData {
  static const String name = 'Minimart';
  static const String tagline = 'ຮ້ານສະດວກຊື້ໃກ້ບ້ານທ່ານ';

  static const String hoursWeekday = '08:00 - 22:00';
  static const String hoursSunday = 'ປິດ';

  static const String address =
      'ບ້ານໜອງດ້ວງເໜືອ , ເມືອງສີໂຄດຕະບອງ , ແຂວງນະຄອນຫຼວງວຽງຈັນ';

  static const String mapsQuery = '17.970508, 102.595503';

  static const String phone = '020 9428 8733';

  static const String about =
      'ພວກເຮົາໃຫ້ບໍລິການສິນຄ້າອຸປະໂພກບໍລິໂພກຄົບຄັນ ດ້ວຍລາຄາທີ່ຖືກ '
      'ພ້ອມບໍລິການສັ່ງຊື້ອອນລາຍ ເພື່ອຄວາມສະດວກສະບາຍຂອງລູກຄ້າທຸກທ່ານ.';
}

class StoreInfoScreen extends StatelessWidget {
  const StoreInfoScreen({super.key});

  Future<void> _openMaps(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_StoreData.mapsQuery)}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ບໍ່ສາມາດເປີດແຜນທີ່ໄດ້')));
    }
  }

  Future<void> _callStore(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: _StoreData.phone);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ບໍ່ສາມາດໂທອອກໄດ້')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'ຂໍ້ມູນຮ້ານຄ້າ',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.storefront,
                      color: AppColors.primary,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    _StoreData.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _StoreData.tagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _InfoSectionTitle(title: 'ເວລາເປີດ-ປິດ'),
            _InfoCard(
              icon: Icons.access_time_rounded,
              iconColor: AppColors.success,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HoursRow(day: 'ຈັນ - ເສົາ', hours: _StoreData.hoursWeekday),
                  const SizedBox(height: 6),
                  _HoursRow(day: 'ອາທິດ', hours: _StoreData.hoursSunday),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _InfoSectionTitle(title: 'ທີ່ຢູ່ຮ້ານ'),
            _InfoCard(
              icon: Icons.location_on_outlined,
              iconColor: AppColors.danger,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    _StoreData.address,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openMaps(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.map_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'ເປີດແຜນທີ່',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _InfoSectionTitle(title: 'ຕິດຕໍ່ຮ້ານ'),
            _InfoCard(
              icon: Icons.phone_outlined,
              iconColor: AppColors.secondary,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _StoreData.phone,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _callStore(context),
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text('ໂທ'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _InfoSectionTitle(title: 'ກ່ຽວກັບຮ້ານ'),
            _InfoCard(
              icon: Icons.info_outline,
              iconColor: AppColors.grey,
              child: const Text(
                _StoreData.about,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textDark,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoSectionTitle extends StatelessWidget {
  final String title;
  const _InfoSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String day;
  final String hours;
  const _HoursRow({required this.day, required this.hours});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: const TextStyle(fontSize: 13, color: AppColors.textLight),
        ),
        Text(
          hours,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
