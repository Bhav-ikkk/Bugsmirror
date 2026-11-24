import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/threat_names.dart';
import '../models/alert_enums.dart';
import '../routing/app_router.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../widgets/app_shell.dart';
import '../widgets/severity_chip.dart';
import '../widgets/state_views.dart';
import '../widgets/status_badge.dart';

class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) => LoadGuard(
    loaded: (provider) {
      void goBack() => context.go(alertsLocation(provider.appId));
      final alert = provider.byId(id);
      if (alert == null)
        return MessageView(
          title: 'Alert not found',
          action: 'Back to alerts',
          onAction: goBack,
        );

      final fields = <String, String>{
        'Alert ID': alert.id,
        'Application': provider.appLabel(alert.appId),
        'App ID': alert.appId.isEmpty ? '-' : alert.appId,
        'Threat code': alert.threatCode,
        'Device model': alert.device,
        'OS version': alert.os,
        'Reported time': formatReportedAt(alert.reportedAt),
        for (final entry in alert.raw.entries)
          if (!const {
            'id',
            'appId',
            'threatType',
            'severity',
            'deviceModel',
            'osVersion',
            'reportedAt',
            'status',
          }.contains(entry.key))
            entry.key: entry.value?.toString() ?? '-',
      };
      return PageBody(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: goBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to alerts'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            getThreatDisplayName(alert.threatCode),
            style: Theme.of(context).textTheme.headlineLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [SeverityChip(alert.severity), StatusBadge(alert.status)],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: panelDecoration(),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alert details',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (_, bounds) {
                    final width = bounds.maxWidth < 520
                        ? bounds.maxWidth
                        : (bounds.maxWidth - 18) / 2;
                    return Wrap(
                      spacing: 18,
                      runSpacing: 12,
                      children: [
                        for (final field in fields.entries)
                          SizedBox(
                            width: width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  field.key,
                                  style: const TextStyle(
                                    color: ConsoleColors.muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                SelectableText(field.value),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          if (alert.status == AlertStatus.open) ...[
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark as resolved'),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialog) => AlertDialog(
                      title: const Text('Are you sure?'),
                      content: const Text(
                        'This alert will be marked as resolved.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialog, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialog, true),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                  if (context.mounted && confirmed == true)
                    provider.resolveAlert(alert.id);
                },
              ),
            ),
          ],
        ],
      );
    },
  );
}
