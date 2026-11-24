import 'package:material_ui/material_ui.dart';

import '../data/threat_names.dart';
import '../models/alert.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
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
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: ConsoleColors.line),
    ),
    color: ConsoleColors.surface,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    getThreatDisplayName(alert.threatCode),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: ConsoleColors.muted,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(app),
            Text(
              alert.device,
              style: const TextStyle(color: ConsoleColors.muted),
            ),
            Text(
              formatReportedAt(alert.reportedAt),
              style: const TextStyle(color: ConsoleColors.muted),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                SeverityChip(alert.severity),
                StatusBadge(alert.status),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
