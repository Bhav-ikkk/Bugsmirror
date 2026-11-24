import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../data/threat_names.dart';
import '../models/alert_enums.dart';
import '../models/app_summary.dart';
import '../providers/alerts_provider.dart';
import '../routing/app_router.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../widgets/app_shell.dart';
import '../widgets/severity_chip.dart';
import '../widgets/state_views.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => LoadGuard(
    loaded: (provider) {
      final width = MediaQuery.sizeOf(context).width;
      final high = provider.highOpen;
      final subtitle =
          '${provider.total} alerts reported by the SDK across '
          '${provider.apps.length} apps. Pick an app below to see only its alerts.';
      final headline = switch (high) {
        0 => 'No high-severity threats',
        1 => '1 high-severity threat',
        _ => '$high high-severity threats',
      };
      return PageBody(
        children: [
          const SizedBox(height: 10),
          Text(
            'OVERVIEW · ${DateFormat('EEE, d MMM y', 'en_US').format(DateTime.now()).toUpperCase()}',
            style: mono(spacing: .8),
          ),
          const SizedBox(height: 21),
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 710),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: headline,
                      style: TextStyle(
                        color: high == 0
                            ? TripwireColors.green
                            : TripwireColors.high,
                      ),
                    ),
                    TextSpan(
                      text: switch (high) {
                        0 => ' are open on your apps.',
                        1 => ' is still open on your apps.',
                        _ => ' are still open on your apps.',
                      },
                    ),
                  ],
                ),
                style: pageTitle(width)
                    .copyWith(fontSize: width < 600 ? 32 : 48),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 14,
            spacing: 18,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: TripwireColors.secondary,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () {
                  provider.clearFilters();
                  provider.selectRouteFilters(null, AlertStatus.open);
                  context.go(alertsLocation(null, AlertStatus.open));
                },
                child: const Text('Review open alerts'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _OverviewMetrics(provider: provider),
          const SizedBox(height: 25),
          LayoutBuilder(
            builder: (_, bounds) {
              final apps = _AppsPanel(provider: provider);
              final latest = _LatestPanel(provider: provider);
              if (width < 960) {
                return Column(
                  children: [apps, const SizedBox(height: 14), latest],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 62, child: apps),
                  const SizedBox(width: 16),
                  Expanded(flex: 38, child: latest),
                ],
              );
            },
          ),
        ],
      );
    },
  );
}

class _OverviewMetrics extends StatelessWidget {
  const _OverviewMetrics({required this.provider});
  final AlertsProvider provider;

  @override
  Widget build(BuildContext context) {
    final counts = {
      for (final s in Severity.values) s: provider.severityCount(s),
    };
    final highApps =
        <(AppSummary, int)>[
          for (final entry in provider.summaries)
            (entry, provider.openBySeverity(entry.app.id)[Severity.high] ?? 0),
        ].where((entry) => entry.$2 > 0).toList()..sort((a, b) {
          final compare = b.$2.compareTo(a.$2);
          return compare == 0
              ? a.$1.app.label.compareTo(b.$1.app.label)
              : compare;
        });
    final cards = [
      SummaryCard(
        label: '[01] TOTAL ALERTS',
        value: provider.total,
        caption: 'alerts in alerts.json',
        icon: Icons.layers_outlined,
        detail: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MetricBar([
              for (final s in Severity.values)
                (counts[s] ?? 0, severityColor(s)),
            ]),
            const SizedBox(height: 11),
            Wrap(
              spacing: 12,
              runSpacing: 5,
              children: [
                for (final s in Severity.values)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ColorDot(severityColor(s)),
                      const SizedBox(width: 5),
                      Text('${counts[s]} ${s.label}', style: mono()),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
      SummaryCard(
        label: '[02] OPEN ALERTS',
        value: provider.open,
        caption: 'of ${provider.total} still open',
        icon: Icons.monitor_heart_outlined,
        detail: Column(
          children: [
            MetricBar([
              (provider.open, TripwireColors.ink),
              (provider.resolvedCount, TripwireColors.track),
            ]),
            const SizedBox(height: 11),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    '${provider.open} open',
                    style: mono(color: TripwireColors.ink),
                  ),
                  Text('${provider.resolvedCount} resolved', style: mono()),
                ],
              ),
            ),
          ],
        ),
      ),
      SummaryCard(
        label: '[03] HIGH SEVERITY · OPEN',
        value: provider.highOpen,
        caption: 'need attention now',
        icon: Icons.gpp_maybe_outlined,
        urgent: true,
        detail: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 12, color: TripwireColors.darkRule),
            if (highApps.isEmpty)
              Text(
                'No apps currently affected',
                style: mono(color: TripwireColors.darkMuted),
              ),
            for (final (summary, count) in highApps)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    const ColorDot(TripwireColors.high),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        summary.app.label,
                        style: mono(color: TripwireColors.surface),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '×$count',
                      style: mono(color: TripwireColors.darkMuted),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ];
    return LayoutBuilder(
      builder: (context, bounds) {
        final viewport = MediaQuery.sizeOf(context).width;
        final columns = viewport >= 900
            ? 3
            : viewport >= 640
            ? 2
            : 1;
        final width = (bounds.maxWidth - (columns - 1) * 14) / columns;
        if (columns == 3) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [for (final card in cards) Expanded(child: card)],
            ),
          );
        }
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (var i = 0; i < cards.length; i++)
              SizedBox(
                width: columns == 2 && i == 2 ? bounds.maxWidth : width,
                child: cards[i],
              ),
          ],
        );
      },
    );
  }
}

class _AppsPanel extends StatelessWidget {
  const _AppsPanel({required this.provider});
  final AlertsProvider provider;

  @override
  Widget build(BuildContext context) => _Panel(
    children: [
      Padding(
        padding: const EdgeInsets.all(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apps',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 3),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 8,
                runSpacing: 5,
                children: [
                  const Text(
                    'Select an app to open its alerts, already filtered.',
                    style: TextStyle(color: TripwireColors.secondary),
                  ),
                  Text(
                    'SORTED BY OPEN ALERTS',
                    style: mono(size: 10, spacing: .55),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ColoredBox(
        color: TripwireColors.tint,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('APP', style: mono(size: 10, spacing: .65)),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'OPEN BY SEVERITY',
                  style: mono(size: 10, spacing: .65),
                ),
              ),
              Text('OPEN', style: mono(size: 10, spacing: .65)),
              const SizedBox(width: 15),
            ],
          ),
        ),
      ),
      for (final summary in provider.summaries)
        _AppRow(
          summary: summary,
          counts: provider.openBySeverity(summary.app.id),
          onOpen: () {
            provider.clearFilters();
            provider.selectRouteFilters(summary.app.id, null);
            context.go(alertsLocation(summary.app.id));
          },
        ),
      if (provider.summaries.isEmpty)
        const Padding(
          padding: EdgeInsets.all(18),
          child: Text('No monitored apps'),
        ),
    ],
  );
}

class _AppRow extends StatelessWidget {
  const _AppRow({
    required this.summary,
    required this.counts,
    required this.onOpen,
  });
  final AppSummary summary;
  final Map<Severity, int> counts;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Divider(height: 1),
      InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: TripwireColors.track,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(
                        summary.app.platform == 'iOS'
                            ? Icons.phone_iphone
                            : Icons.android,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary.app.label,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(summary.app.id, style: mono(size: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Semantics(
                    label: Severity.values
                        .map((s) => '${counts[s]} ${s.label}')
                        .join(', '),
                    child: Wrap(
                      spacing: 3,
                      runSpacing: 3,
                      children: [
                        for (final s in Severity.values)
                          for (var i = 0; i < (counts[s] ?? 0).clamp(0, 8); i++)
                            ColorDot(severityColor(s), size: 8),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                '${summary.openCount}',
                style: mono(size: 19, color: TripwireColors.ink),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: TripwireColors.muted,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _LatestPanel extends StatelessWidget {
  const _LatestPanel({required this.provider});
  final AlertsProvider provider;

  @override
  Widget build(BuildContext context) {
    final alerts = provider.latestOpenAlerts.take(4);
    return _Panel(
      children: [
        Padding(
          padding: const EdgeInsets.all(19),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest open',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Newest first',
                      style: TextStyle(color: TripwireColors.secondary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  provider.clearFilters();
                  context.go('/alerts');
                },
                child: const Text(
                  'All alerts',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
        for (final alert in alerts) ...[
          const Divider(height: 1),
          InkWell(
            onTap: () => context.go('/alerts/${Uri.encodeComponent(alert.id)}'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(19, 13, 19, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 5,
                      children: [
                        SeverityChip(alert.severity),
                        Text(
                          formatReportedAt(alert.reportedAt),
                          style: mono(size: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    getThreatDisplayName(alert.threatCode),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${provider.appLabel(alert.appId)} · ${alert.device}',
                    style: const TextStyle(color: TripwireColors.secondary),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (alerts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(19),
            child: Text('No open alerts'),
          ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Material(
    color: TripwireColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tripwire.panelRadius),
      side: const BorderSide(color: TripwireColors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}
