import 'package:intl/intl.dart';

String timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat.yMMMd().format(time);
}

String formatDate(DateTime time) => DateFormat.yMMMd().format(time);

String formatPrice(double value) {
  if (value == value.roundToDouble()) return '\रु ${value.toStringAsFixed(0)}';
  return '\$${value.toStringAsFixed(2)}';
}

bool isValidEmail(String value) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
