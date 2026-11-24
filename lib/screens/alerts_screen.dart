import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/alert_enums.dart';
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
  const AlertsScreen({super.key, this.appId, this.status});
  final String? appId;
  final AlertStatus? status;

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    _syncRouteFilters();
  }

  @override
  void didUpdateWidget(covariant AlertsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appId != oldWidget.appId || widget.status != oldWidget.status) {
      _syncRouteFilters();
    }
  }

  void _syncRouteFilters() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AlertsProvider>().selectRouteFilters(
          widget.appId,
          widget.status,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => LoadGuard(
    loaded: (provider) {
      final all = provider.filtered();
      final page = alertsOnPage(all, provider.page);
      final width = MediaQuery.sizeOf(context).width;
      void selectRoute(String? id, AlertStatus? status) {
        provider.selectRouteFilters(id, status);
        context.go(alertsLocation(id, status));
      }

      void clear() {
        provider.clearFilters();
        context.go('/alerts');
      }

      void open(String id) => context.go('/alerts/${Uri.encodeComponent(id)}');
      final pagination = PaginationBar(
        page: provider.page,
        totalPages: pageCount(all.length),
        itemCount: page.length,
        totalItems: all.length,
        onPage: provider.goToPage,
      );
      return PageBody(
        children: [
          Text(
            'ALERTS · ${provider.open} OPEN OF ${provider.total}',
            style: mono(spacing: .8),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Text('Every alert, one place.', style: pageTitle(width)),
              OutlinedButton(
                onPressed: all.isEmpty
                    ? null
                    : () => downloadCsv(exportAlerts(all, provider.appLabel)),
                child: const Text('Export CSV'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AlertsFilterBar(
            provider: provider,
            matching: all.length,
            onClear: clear,
            onSelectApp: (app) => selectRoute(app, provider.status),
            onSelectStatus: (status) => selectRoute(provider.appId, status),
          ),
          const SizedBox(height: 16),
          if (page.isEmpty)
            Container(
              decoration: panelDecoration(),
              constraints: const BoxConstraints(minHeight: 190),
              child: MessageView(
                title: 'No alerts match these filters',
                action: 'Clear filters',
                onAction: clear,
              ),
            )
          else if (width >= 800)
            Container(
              decoration: panelDecoration(),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  AlertsTable(
                    alerts: page,
                    appLabel: provider.appLabel,
                    onOpen: open,
                  ),
                  const Divider(height: 1),
                  pagination,
                ],
              ),
            )
          else ...[
            for (final alert in page)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AlertCard(
                  alert: alert,
                  app: provider.appLabel(alert.appId),
                  onOpen: () => open(alert.id),
                ),
              ),
            const SizedBox(height: 3),
            Container(decoration: panelDecoration(), child: pagination),
          ],
        ],
      );
    },
  );
}
