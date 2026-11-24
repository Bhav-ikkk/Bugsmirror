import 'package:material_ui/material_ui.dart';

import '../data/threat_names.dart';
import '../models/alert.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import 'severity_chip.dart';
import 'status_badge.dart';

String threatCaption(String code) => threatDisplayNames.containsKey(code.trim())
    ? code
    : 'Unmapped code · shown as-is';

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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, bounds) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: bounds.maxWidth),
        child: DataTable(
          columnSpacing: 19,
          horizontalMargin: 15,
          headingRowHeight: 38,
          headingRowColor: const WidgetStatePropertyAll(TripwireColors.tint),
          headingTextStyle: mono(size: 10, spacing: .65),
          dataRowMinHeight: 57,
          dataRowMaxHeight: 76,
          dataTextStyle: const TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 13,
            color: TripwireColors.ink,
          ),
          dividerThickness: .7,
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('THREAT')),
            DataColumn(label: Text('SEVERITY')),
            DataColumn(label: Text('APP')),
            DataColumn(label: Text('DEVICE')),
            DataColumn(label: Text('REPORTED')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: SizedBox.shrink()),
          ],
          rows: [for (final alert in alerts) _row(alert)],
        ),
      ),
    ),
  );

  DataRow _row(Alert alert) {
    final app = appLabel(alert.appId);
    return DataRow(
      key: ValueKey(alert.id),
      onSelectChanged: (_) => onOpen(alert.id),
      cells: [
        DataCell(
          SizedBox(
            width: 205,
            child: TextButton(
              onPressed: () => onOpen(alert.id),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getThreatDisplayName(alert.threatCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    threatCaption(alert.threatCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: mono(size: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
        DataCell(SeverityChip(alert.severity)),
        DataCell(
          SizedBox(
            width: 164,
            child: Row(
              children: [
                Icon(
                  app.endsWith('(iOS)') ? Icons.phone_iphone : Icons.android,
                  size: 14,
                  color: TripwireColors.muted,
                ),
                const SizedBox(width: 5),
                Expanded(child: Text(app, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 165,
            child: Text(
              alert.device,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: alert.isDeviceModelMissing
                    ? TripwireColors.muted
                    : TripwireColors.ink,
              ),
            ),
          ),
        ),
        DataCell(
          Text(formatReportedAt(alert.reportedAt), style: mono(size: 10)),
        ),
        DataCell(StatusBadge(alert.status)),
        const DataCell(
          Icon(Icons.chevron_right, color: TripwireColors.muted, size: 16),
        ),
      ],
    );
  }
}
