import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/threat_names.dart';
import '../models/alert_enums.dart';
import '../routing/app_router.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../widgets/alert_inspector.dart';
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
      void goBack() =>
          context.go(alertsLocation(provider.appId, provider.status));
      final alert = provider.byId(id);
      if (alert == null) {
        return MessageView(
          title: 'Alert not found',
          action: 'Back to alerts',
          onAction: goBack,
        );
      }
      final width = MediaQuery.sizeOf(context).width;
      final app = provider.appById(alert.appId);
      final name = getThreatDisplayName(alert.threatCode);
      final appLabel = provider.appLabel(alert.appId);
      final time = formatReportedAt(alert.reportedAt);
      final resolvedAt = provider.resolvedAt(id);
      final fields = [
        FieldValue.text('ALERT ID', alert.id, technical: true),
        FieldValue.text('THREAT', name),
        FieldValue.text('THREAT CODE', alert.threatCode, technical: true),
        FieldValue('SEVERITY', SeverityChip(alert.severity)),
        FieldValue('STATUS', StatusBadge(alert.status)),
        FieldValue.text(
          'APP ID',
          alert.appId.isEmpty ? '-' : alert.appId,
          technical: true,
        ),
        FieldValue.text('APP', appLabel),
        FieldValue.text('PLATFORM', app?.platform ?? 'Unknown'),
        FieldValue.text(
          'DEVICE MODEL',
          alert.device,
          note: alert.isDeviceModelMissing ? 'Missing in data' : null,
        ),
        FieldValue.text(
          'OS VERSION',
          alert.os,
          note: alert.isOsVersionMissing ? 'Missing in data' : null,
        ),
        FieldValue.text(
          'REPORTED AT',
          time,
          note: alert.reportedAt == null ? null : 'Your local time',
        ),
        FieldValue.text(
          'REPORTED AT (RAW)',
          alert.raw['reportedAt']?.toString() ?? '-',
          technical: true,
          note: alert.reportedAt == null ? null : 'ms since 1970 · UTC',
        ),
        for (final entry in alert.raw.entries)
          if (!const {
            'id',
            'appId',
            'threatType',
            'severity',
            'status',
            'deviceModel',
            'osVersion',
            'reportedAt',
          }.contains(entry.key))
            FieldValue.text(entry.key, entry.value?.toString() ?? '-'),
      ];

      Future<void> confirmResolution() async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialog) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('This alert will be marked as resolved.'),
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
        if (context.mounted && confirmed == true) {
          provider.resolveAlert(alert.id);
        }
      }

      final mobile = width < 800;
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: pageTitle(width)),
          const SizedBox(height: 8),
          Text(
            'Reported by $appLabel on ${alert.device} · $time',
            style: const TextStyle(
              color: TripwireColors.secondary,
              fontSize: 15,
            ),
          ),
        ],
      );
      final action = Column(
        crossAxisAlignment: mobile
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.end,
        children: [
          FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              minimumSize: Size(0, mobile ? 44 : 40),
            ),
            onPressed: confirmResolution,
            child: const Text('Mark as resolved'),
          ),
          const SizedBox(height: 5),
          Text(
            'You’ll be asked to confirm',
            textAlign: mobile ? TextAlign.center : TextAlign.right,
            style: mono(size: 10),
          ),
        ],
      );
      final metadata = FieldsPanel(fields: fields, stackLabels: width < 520);
      final raw = RawAlertPanel(
        alert: alert,
        resolvedInSession: resolvedAt != null,
      );
      final timeline = AlertTimeline(
        alert: alert,
        loadedAt: provider.lastLoadedAt,
        resolvedAt: resolvedAt,
      );

      return PageBody(
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: goBack,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                ),
                icon: const Icon(Icons.chevron_left, size: 19),
                label: const Text('Alerts'),
                key: const Key('back-to-alerts'),
              ),
              Text('/', style: mono()),
              Text(alert.id, style: mono(color: TripwireColors.ink)),
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 5,
            children: [
              SeverityChip(alert.severity),
              StatusBadge(alert.status),
              Text(alert.threatCode, style: mono(size: 10)),
            ],
          ),
          const SizedBox(height: 10),
          if (mobile) ...[
            heading,
            if (alert.status == AlertStatus.open) ...[
              const SizedBox(height: 14),
              action,
            ],
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: heading),
                if (alert.status == AlertStatus.open) ...[
                  const SizedBox(width: 18),
                  action,
                ],
              ],
            ),
          const SizedBox(height: 25),
          if (width < 900) ...[
            metadata,
            const SizedBox(height: 16),
            raw,
            const SizedBox(height: 16),
            timeline,
          ] else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 61, child: metadata),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 39,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        raw,
                        const SizedBox(height: 16),
                        Expanded(child: timeline),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}
