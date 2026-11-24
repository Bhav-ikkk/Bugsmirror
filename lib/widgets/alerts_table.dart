import 'package:material_ui/material_ui.dart';

import '../data/threat_names.dart';
import '../models/alert.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import 'severity_chip.dart';
import 'status_badge.dart';

class AlertsTable extends StatelessWidget {
  const AlertsTable({
    super.key,
    required this.alerts,
    required this.appLabel,
    required this.onOpen,
  });
  final List<Alert> alerts;
  final String Function(String) appLabel;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) => Container(
    decoration: panelDecoration(),
    clipBehavior: Clip.antiAlias,
    child: LayoutBuilder(
      builder: (_, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            columnSpacing: 22,
            headingRowColor: const WidgetStatePropertyAll(ConsoleColors.canvas),
            headingTextStyle: const TextStyle(
              color: ConsoleColors.muted,
              fontWeight: FontWeight.w700,
            ),
            dataRowMinHeight: 56,
            showCheckboxColumn: false,
            columns: const [
              DataColumn(label: Text('Threat')),
              DataColumn(label: Text('Severity')),
              DataColumn(label: Text('App')),
              DataColumn(label: Text('Device')),
              DataColumn(label: Text('Reported')),
              DataColumn(label: Text('Status')),
            ],
            rows: [
              for (final alert in alerts)
                DataRow(
                  key: ValueKey(alert.id),
                  onSelectChanged: (_) => onOpen(alert.id),
                  cells: [
                    DataCell(
                      TextButton(
                        onPressed: () => onOpen(alert.id),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(getThreatDisplayName(alert.threatCode)),
                      ),
                    ),
                    DataCell(SeverityChip(alert.severity)),
                    DataCell(Text(appLabel(alert.appId))),
                    DataCell(Text(alert.device)),
                    DataCell(Text(formatReportedAt(alert.reportedAt))),
                    DataCell(StatusBadge(alert.status)),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
