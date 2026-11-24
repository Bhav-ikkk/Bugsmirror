class MonitoredApp {
  const MonitoredApp(this.id, this.name, this.platform);
  final String id;
  final String name;
  final String platform;

  String get label => '$name ($platform)';
}

class AppSummary {
  const AppSummary(this.app, this.openCount);
  final MonitoredApp app;
  final int openCount;
}
