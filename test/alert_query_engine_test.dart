import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:security_alerts_dashboard/data/alert_repository.dart';
import 'package:security_alerts_dashboard/models/alert_enums.dart';
import 'package:security_alerts_dashboard/utils/alert_query_engine.dart';

void main() {
  final alerts = AlertRepository.parse(
    File('assets/alerts.json').readAsStringSync(),
  ).alerts;

  test('sort ranks severity explicitly and breaks ties newest-first', () {
    final sorted = queryAlerts(alerts, sort: AlertSort.severity);
    expect(
      sorted.map((a) => a.severity.index),
      orderedEquals(sorted.map((a) => a.severity.index).toList()..sort()),
    );
    expect(sorted.take(3).map((a) => a.id), ['al_105', 'al_112', 'al_111']);
    expect(queryAlerts(alerts).first.id, 'al_110');
    expect(alerts.first.id, 'al_106');
  });

  test('combines app, severity, status and normalized device search', () {
    expect(
      queryAlerts(
        alerts,
        appId: 'app_1',
        severity: Severity.high,
        status: AlertStatus.open,
        deviceSearch: ' UnKnOwN ',
      ).single.id,
      'al_103',
    );
    expect(
      queryAlerts(alerts, appId: 'app_2', deviceSearch: 'unknown'),
      isEmpty,
    );
  });

  test('pages contain five matches and clamp to available results', () {
    final all = queryAlerts(alerts);
    expect(pageCount(all.length), 3);
    expect(alertsOnPage(all, 1), hasLength(5));
    expect(alertsOnPage(all, 3), hasLength(4));
    expect(alertsOnPage(all, 99), alertsOnPage(all, 3));
    expect(alertsOnPage([], 3), isEmpty);
  });
}
