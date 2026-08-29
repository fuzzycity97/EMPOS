import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: 'EGP ',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormatter = NumberFormat.currency(
    symbol: '',
    decimalDigits: 2,
  );

  static String format(num amount) {
    return _formatter.format(amount);
  }

  static String formatPlain(num amount) {
    return _compactFormatter.format(amount).trim();
  }
}
