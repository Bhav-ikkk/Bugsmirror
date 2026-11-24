import 'package:material_ui/material_ui.dart';

import '../data/threat_names.dart';
import '../models/alert.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import 'alerts_table.dart';
import 'severity_chip.dart';
import 'status_badge.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({
    super.key,
    required this.alert,
    required this.app,
    required this.onOpen,
  });
  final Alert alert;
  final String app;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Material(
    color: TripwireColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tripwire.panelRadius),
      side: const BorderSide(color: TripwireColors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    getThreatDisplayName(alert.threatCode),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: TripwireColors.muted,
                ),
              ],
            ),
            Text(threatCaption(alert.threatCode), style: mono(size: 10)),
            const SizedBox(height: 8),
            Text(app),
            Text(
              alert.device,
              style: const TextStyle(color: TripwireColors.secondary),
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SeverityChip(alert.severity),
                StatusBadge(alert.status),
                Text(formatReportedAt(alert.reportedAt), style: mono(size: 10)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
