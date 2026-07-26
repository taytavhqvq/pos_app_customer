import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat('#,##0', 'en_US');

  static String format(num value) => _formatter.format(value);
  static String formatWithUnit(num value) => '${_formatter.format(value)} ກີບ';
}
