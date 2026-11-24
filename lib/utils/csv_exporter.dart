import 'package:csv/csv.dart';

import '../data/threat_names.dart';
import '../models/alert.dart';
import 'date_formatter.dart';

String spreadsheetSafe(String value) {
  if (value == '-') return value;
  final trimmed = value.trimLeft();
  final risky =
      value.startsWith('\t') ||
      value.startsWith('\r') ||
      RegExp(r'^[=+@\-]').hasMatch(trimmed);
  return risky ? "'$value" : value;
}

String exportAlerts(Iterable<Alert> alerts, String Function(String) appLabel) =>
    const ListToCsvConverter().convert([
      [
        'Threat',
        'Severity',
        'App',
        'Device model',
        'OS version',
        'Reported time',
        'Status',
      ],
      for (final alert in alerts)
        [
          getThreatDisplayName(alert.threatCode),
          alert.severity.label,
          appLabel(alert.appId),
          alert.device,
          alert.os,
          formatReportedAt(alert.reportedAt),
          alert.status.label,
        ].map(spreadsheetSafe).toList(),
    ]);
