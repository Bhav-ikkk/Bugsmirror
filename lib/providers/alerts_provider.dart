import 'package:flutter/foundation.dart';

import '../data/alert_repository.dart';
import '../models/alert.dart';
import '../models/alert_enums.dart';
import '../models/app_summary.dart';
import '../utils/alert_query_engine.dart';

enum LoadState { loading, loaded, error }

class AlertsProvider extends ChangeNotifier {
  AlertsProvider(this.repository);
  final AlertRepository repository;
  List<Alert> _alerts = [];
  List<MonitoredApp> _apps = [];
  bool _disposed = false;
  int _request = 0;
  LoadState state = LoadState.loading;
  String? _appId;
  Severity? severity;
  AlertStatus? status;
  AlertSort sort = AlertSort.newest;
  String deviceSearch = '';
  int page = 1;

  Future<void> load() async {
    final request = ++_request;
    state = LoadState.loading;
    notifyListeners();
    try {
      final data = await repository.load();
      if (_disposed || request != _request) return;
      _alerts = data.alerts.toList();
      _apps = data.apps;
      state = LoadState.loaded;
      page = 1;
    } catch (_) {
      if (_disposed || request != _request) return;
      state = LoadState.error;
    }
    notifyListeners();
  }

  List<MonitoredApp> get apps => List.unmodifiable(_apps);
  int get total => _alerts.length;
  int get open => _alerts.where((a) => a.status == AlertStatus.open).length;
  int get highOpen => _alerts
      .where((a) => a.status == AlertStatus.open && a.severity == Severity.high)
      .length;
  String? get appId => _appId;

  List<AppSummary> get summaries {
    final counts = <String, int>{};
    for (final alert in _alerts.where((a) => a.status == AlertStatus.open)) {
      counts.update(alert.appId, (count) => count + 1, ifAbsent: () => 1);
    }
    return _apps.map((app) => AppSummary(app, counts[app.id] ?? 0)).toList()
      ..sort((a, b) {
        final byCount = b.openCount.compareTo(a.openCount);
        return byCount == 0 ? a.app.label.compareTo(b.app.label) : byCount;
      });
  }

  String appLabel(String id) =>
      _apps.where((app) => app.id == id).firstOrNull?.label ??
      'Unknown app (Unknown)';
  Alert? byId(String id) => _alerts.where((a) => a.id == id).firstOrNull;

  List<Alert> filtered({String? routeAppId}) => queryAlerts(
    _alerts,
    appId: routeAppId ?? _appId,
    severity: severity,
    status: status,
    deviceSearch: deviceSearch,
    sort: sort,
  );

  void selectApp(String? value) {
    if (_appId == value) return;
    _appId = value;
    _resetPage();
  }

  void selectSeverity(Severity? value) {
    severity = value;
    _resetPage();
  }

  void selectStatus(AlertStatus? value) {
    status = value;
    _resetPage();
  }

  void selectSort(AlertSort value) {
    sort = value;
    _resetPage();
  }

  void search(String value) {
    deviceSearch = value;
    _resetPage();
  }

  void clearFilters() {
    _appId = null;
    severity = null;
    status = null;
    deviceSearch = '';
    sort = AlertSort.newest;
    _resetPage();
  }

  void _resetPage() {
    page = 1;
    notifyListeners();
  }

  void goToPage(int value) {
    page = value.clamp(1, pageCount(filtered().length));
    notifyListeners();
  }

  void resolveAlert(String id) {
    final index = _alerts.indexWhere(
      (a) => a.id == id && a.status == AlertStatus.open,
    );
    if (index < 0) return;
    _alerts[index] = _alerts[index].resolved();
    page = page.clamp(1, pageCount(filtered().length));
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
