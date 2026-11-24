import 'package:intl/intl.dart';

String formatReportedAt(int? timestamp) {
  if (timestamp == null) return '-';
  return DateFormat('d MMM yyyy, h:mm a', 'en_US').format(
    DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true).toLocal(),
  );
}
