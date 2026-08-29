import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  static String formatDateTime(DateTime dateTime) => _dateTimeFormat.format(dateTime);
  static String formatDate(DateTime dateTime) => _dateFormat.format(dateTime);
  static String formatTime(DateTime dateTime) => _timeFormat.format(dateTime);
}
