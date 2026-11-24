import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/alerts_provider.dart';
import '../theme/app_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.alertsActive, required this.child});
  final bool alertsActive;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        ColoredBox(
          color: ConsoleColors.navy,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: LayoutBuilder(
                builder: (context, bounds) {
                  final compact = bounds.maxWidth < 560;
                  final brand = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: ConsoleColors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          size: 20,
                          color: ConsoleColors.surface,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Security Alerts',
                        style: TextStyle(
                          color: ConsoleColors.surface,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                  final nav = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NavLink(
                        label: 'Dashboard',
                        selected: !alertsActive,
                        onPressed: () => context.go('/'),
                      ),
                      const SizedBox(width: 4),
                      _NavLink(
                        label: 'Alerts',
                        selected: alertsActive,
                        onPressed: () {
                          if (!alertsActive) {
                            context.read<AlertsProvider>().clearFilters();
                          }
                          context.go('/alerts');
                        },
                      ),
                    ],
                  );
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 16 : 30,
                      vertical: 10,
                    ),
                    child: compact
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [brand, const SizedBox(height: 8), nav],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [brand, nav],
                          ),
                  );
                },
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.selected,
    required this.onPressed,
  });
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    style: TextButton.styleFrom(
      foregroundColor: selected ? ConsoleColors.surface : ConsoleColors.navText,
      backgroundColor: selected ? ConsoleColors.blue : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    ),
    onPressed: onPressed,
    child: Text(label),
  );
}

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, bounds) {
      final padding = bounds.maxWidth < 600 ? 16.0 : 30.0;
      return SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, 28, padding, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      );
    },
  );
}
