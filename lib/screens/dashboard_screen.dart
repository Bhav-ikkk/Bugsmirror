import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../routing/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/state_views.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => LoadGuard(
    loaded: (provider) {
      final theme = Theme.of(context).textTheme;
      return PageBody(
        children: [
          Text(
            'Dashboard',
            style: theme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            'Monitor security alerts across your apps.',
            style: theme.bodyLarge,
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (_, constraints) {
              const gap = 12.0;
              final columns = constraints.maxWidth >= 660 ? 3 : 2;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: width,
                    child: SummaryCard(
                      label: 'Total alerts',
                      value: provider.total,
                      icon: Icons.notifications_none_rounded,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: SummaryCard(
                      label: 'Open alerts',
                      value: provider.open,
                      icon: Icons.pending_actions_outlined,
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth < 660
                        ? constraints.maxWidth
                        : width,
                    child: SummaryCard(
                      label: 'High severity open alerts',
                      value: provider.highOpen,
                      icon: Icons.warning_amber_rounded,
                      urgent: true,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Monitored apps',
                  style: theme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  provider.clearFilters();
                  context.go('/alerts');
                },
                icon: const Icon(Icons.list_alt_outlined, size: 18),
                label: const Text('All alerts'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Material(
            color: ConsoleColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: ConsoleColors.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                if (provider.summaries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('No monitored apps'),
                  ),
                for (final summary in provider.summaries) ...[
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: ConsoleColors.blueSoft,
                      foregroundColor: ConsoleColors.blue,
                      child: Icon(
                        summary.app.platform == 'iOS'
                            ? Icons.phone_iphone_outlined
                            : Icons.android_outlined,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      summary.app.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${summary.openCount} open',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: ConsoleColors.muted,
                        ),
                      ],
                    ),
                    onTap: () {
                      provider.clearFilters();
                      provider.selectApp(summary.app.id);
                      context.go(alertsLocation(summary.app.id));
                    },
                  ),
                  if (summary != provider.summaries.last &&
                      summary.app.id != provider.summaries.last.app.id)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
      );
    },
  );
}
