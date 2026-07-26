import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(String? isoString) {
    if (isoString == null) return '-';
    final date = DateTime.parse(isoString).toLocal();
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(String? isoString) {
    if (isoString == null) return '-';
    final date = DateTime.parse(isoString).toLocal();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
