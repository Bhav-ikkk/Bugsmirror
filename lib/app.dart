import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'data/alert_repository.dart';
import 'providers/alerts_provider.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class SecurityAlertsApp extends StatefulWidget {
  const SecurityAlertsApp({
    super.key,
    this.repository = const AlertRepository(),
    this.initialLocation,
  });
  final AlertRepository repository;
  final String? initialLocation;

  @override
  State<SecurityAlertsApp> createState() => _SecurityAlertsAppState();
}

class _SecurityAlertsAppState extends State<SecurityAlertsApp> {
  late final router = createRouter(widget.initialLocation);

  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AlertsProvider(widget.repository)..load(),
    child: MaterialApp.router(
      title: 'Security Alerts Dashboard',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: router,
    ),
  );
}
