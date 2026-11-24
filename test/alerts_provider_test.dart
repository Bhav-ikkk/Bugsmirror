import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:security_alerts_dashboard/data/alert_repository.dart';
import 'package:security_alerts_dashboard/models/alert_enums.dart';
import 'package:security_alerts_dashboard/providers/alerts_provider.dart';

void main() {
  final source = File('assets/alerts.json').readAsStringSync();
  late AlertsProvider provider;

  setUp(() async {
    provider = AlertsProvider(
      AlertRepository(assetLoader: () async => source, delay: Duration.zero),
    );
    await provider.load();
  });

  tearDown(() => provider.dispose());

  test('resolution updates shared counts immediately and is idempotent', () {
    final before = (provider.total, provider.open, provider.highOpen);
    var notifications = 0;
    provider.addListener(() => notifications++);
    provider.resolveAlert('al_105');
    provider.resolveAlert('al_105');
    expect(provider.total, before.$1);
    expect(provider.open, before.$2 - 1);
    expect(provider.highOpen, before.$3 - 1);
    expect(provider.byId('al_105')?.status, AlertStatus.resolved);
    expect(notifications, 1);
  });

  test('filter, search and sort reset the page; resolve clamps it', () {
    provider.goToPage(3);
    provider.selectSort(AlertSort.severity);
    expect(provider.page, 1);
    provider.goToPage(2);
    provider.search('pixel');
    expect(provider.page, 1);
    provider.clearFilters();
    provider.selectStatus(AlertStatus.open);
    expect(provider.open, 11);
    provider.goToPage(3);
    provider.resolveAlert('al_105');
    expect(provider.page, 2);
  });
}
