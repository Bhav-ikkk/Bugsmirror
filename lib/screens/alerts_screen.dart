import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/alerts_provider.dart';
import '../routing/app_router.dart';
import '../theme/app_theme.dart';
import '../utils/alert_query_engine.dart';
import '../utils/csv_exporter.dart';
import '../utils/web_download.dart';
import '../widgets/alert_card.dart';
import '../widgets/alerts_filter_bar.dart';
import '../widgets/alerts_table.dart';
import '../widgets/app_shell.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/state_views.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key, this.appId});
  final String? appId;

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    _syncRouteFilter();
  }

  @override
  void didUpdateWidget(covariant AlertsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appId != oldWidget.appId) _syncRouteFilter();
  }

  void _syncRouteFilter() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AlertsProvider>().selectApp(widget.appId);
    });
  }

  @override
  Widget build(BuildContext context) => LoadGuard(
    loaded: (provider) {
      final all = provider.filtered();
      final page = alertsOnPage(all, provider.page);
      void selectApp(String? id) {
        provider.selectApp(id);
        context.go(alertsLocation(id));
      }

      void clear() {
        provider.clearFilters();
        context.go('/alerts');
      }

      void open(String id) => context.go('/alerts/${Uri.encodeComponent(id)}');
      return PageBody(
        children: [
          Text(
            'Alerts',
            style: Theme.of(context).textTheme.headlineLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          const Text('Review, filter and resolve reported security events.'),
          const SizedBox(height: 20),
          AlertsFilterBar(
            provider: provider,
            onSelectApp: selectApp,
            onClear: clear,
            onExport: all.isEmpty
                ? null
                : () => downloadCsv(exportAlerts(all, provider.appLabel)),
          ),
          const SizedBox(height: 18),
          Text(
            '${all.length} matching ${all.length == 1 ? 'alert' : 'alerts'}',
            style: const TextStyle(
              color: ConsoleColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          if (page.isEmpty)
            Container(
              decoration: panelDecoration(),
              constraints: const BoxConstraints(minHeight: 180),
              child: MessageView(
                title: 'No alerts match these filters',
                action: 'Clear filters',
                onAction: clear,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, _) {
                if (MediaQuery.sizeOf(context).width >= 800) {
                  return AlertsTable(
                    alerts: page,
                    appLabel: provider.appLabel,
                    onOpen: open,
                  );
                }
                return Column(
                  children: [
                    for (final alert in page)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AlertCard(
                          alert: alert,
                          app: provider.appLabel(alert.appId),
                          onOpen: () => open(alert.id),
                        ),
                      ),
                  ],
                );
              },
            ),
          const SizedBox(height: 12),
          PaginationBar(
            page: provider.page,
            totalPages: pageCount(all.length),
            onPage: provider.goToPage,
          ),
        ],
      );
    },
  );
}
