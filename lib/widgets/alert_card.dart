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
      focusColor: TripwireColors.track,
      hoverColor: TripwireColors.tint,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SeverityChip(alert.severity),
                      StatusBadge(alert.status),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: TripwireColors.muted,
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              getThreatDisplayName(alert.threatCode),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(threatCaption(alert.threatCode), style: mono(size: 10)),
            const SizedBox(height: 9),
            Wrap(
              spacing: 7,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      app.endsWith('(iOS)')
                          ? Icons.phone_iphone
                          : Icons.android,
                      size: 14,
                      color: TripwireColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(app, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                Text(
                  '· ${alert.device}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: TripwireColors.secondary,
                  ),
                ),
                Text(
                  '· ${formatReportedAt(alert.reportedAt)}',
                  style: mono(size: 10, color: TripwireColors.timestamp),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
