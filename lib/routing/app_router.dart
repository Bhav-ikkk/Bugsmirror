import 'package:go_router/go_router.dart';

import '../screens/alert_detail_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/dashboard_screen.dart';
import '../widgets/app_shell.dart';
import '../widgets/state_views.dart';

String alertsLocation([String? appId]) => Uri(
  path: '/alerts',
  queryParameters: appId == null ? null : {'app': appId},
).toString();

GoRouter createRouter(String? initialLocation) => GoRouter(
  initialLocation: initialLocation,
  errorBuilder: (context, state) => AppShell(
    alertsActive: true,
    child: MessageView(
      title: 'Page not found',
      action: 'Back to alerts',
      onAction: () => context.go('/alerts'),
    ),
  ),
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(
        alertsActive: state.uri.path.startsWith('/alerts'),
        child: child,
      ),
      routes: [
        GoRoute(path: '/', builder: (_, _) => const DashboardScreen()),
        GoRoute(
          path: '/alerts',
          builder: (_, state) =>
              AlertsScreen(appId: state.uri.queryParameters['app']),
        ),
        GoRoute(
          path: '/alerts/:id',
          builder: (_, state) =>
              AlertDetailScreen(id: state.pathParameters['id'] ?? ''),
        ),
      ],
    ),
  ],
);
