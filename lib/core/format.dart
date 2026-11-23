const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// `1234.5` -> `$1,234.50`. Pass [sign] to get `+$1,234.50` for positives.
String money(num value, {bool sign = false}) {
  final abs = value.abs().toStringAsFixed(2).split('.');
  final whole = abs[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  final text = '\$$whole.${abs[1]}';
  if (value < 0) return '-$text';
  return sign ? '+$text' : text;
}

String weekdayShort(DateTime d) => _weekdays[d.weekday - 1];

/// Today / Yesterday / Mon, Nov 17
String dayLabel(DateTime date, DateTime now) {
  final a = DateTime.utc(date.year, date.month, date.day);
  final b = DateTime.utc(now.year, now.month, now.day);
  final diff = b.difference(a).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return '${weekdayShort(date)}, ${_months[date.month - 1]} ${date.day}';
}

String timeLabel(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${d.hour < 12 ? 'AM' : 'PM'}';
}
