import '../models/alert.dart';
import '../models/alert_enums.dart';

const pageSize = 5;

List<Alert> queryAlerts(
  Iterable<Alert> source, {
  String? appId,
  Severity? severity,
  AlertStatus? status,
  String deviceSearch = '',
  AlertSort sort = AlertSort.newest,
}) {
  final query = deviceSearch.trim().toLowerCase();
  final result = source
      .where(
        (alert) =>
            (appId == null || appId == alert.appId) &&
            (severity == null || severity == alert.severity) &&
            (status == null || status == alert.status) &&
            alert.device.toLowerCase().contains(query),
      )
      .toList();
  result.sort((a, b) {
    if (sort == AlertSort.severity) {
      final rank = a.severity.index.compareTo(b.severity.index);
      if (rank != 0) return rank;
    }
    final newest = (b.reportedAt ?? -8640000000000001).compareTo(
      a.reportedAt ?? -8640000000000001,
    );
    return newest != 0 ? newest : a.id.compareTo(b.id);
  });
  return result;
}

int pageCount(int length) =>
    length == 0 ? 1 : (length + pageSize - 1) ~/ pageSize;

List<Alert> alertsOnPage(List<Alert> sorted, int page) => sorted
    .skip((page.clamp(1, pageCount(sorted.length)) - 1) * pageSize)
    .take(pageSize)
    .toList();
