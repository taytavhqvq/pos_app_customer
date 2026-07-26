import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

// map ข้อความสถานะภาษาลาวจาก backend ตรงๆ -> สี+ไอคอน (ไม่ใช้ status code แยกตามที่ตกลงกันไว้)
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case 'ຈ່າຍສຳເລັດ':
        return AppColors.success;
      case 'ລໍຖ້າຢືນຢັນການຊຳລະ':
        return AppColors.warning;
      case 'ປະຕິເສດ':
        return AppColors.danger;
      case 'ຍົກເລີກ':
        return AppColors.grey;
      default:
        return AppColors.grey;
    }
  }

  IconData get _icon {
    switch (status) {
      case 'ຈ່າຍສຳເລັດ':
        return Icons.check_circle;
      case 'ລໍຖ້າຢືນຢັນການຊຳລະ':
        return Icons.hourglass_bottom;
      case 'ປະຕິເສດ':
        return Icons.cancel;
      case 'ຍົກເລີກ':
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
