import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:security_alerts_dashboard/data/alert_repository.dart';
import 'package:security_alerts_dashboard/data/threat_names.dart';
import 'package:security_alerts_dashboard/models/alert_enums.dart';

void main() {
  test('supplied records preserve app identity and normalize dirty data', () {
    final data = AlertRepository.parse(
      File('assets/alerts.json').readAsStringSync(),
    );
    expect(data.alerts, hasLength(14));
    expect(
      data.apps.map((a) => a.label),
      containsAll([
        'QuickPay (Android)',
        'QuickPay (iOS)',
        'ShopKart (Android)',
      ]),
    );
    expect(data.alerts.singleWhere((a) => a.id == 'al_103').device, 'Unknown');
    expect(data.alerts.singleWhere((a) => a.id == 'al_107').os, '-');
    expect(
      data.alerts.singleWhere((a) => a.id == 'al_111').severity,
      Severity.high,
    );
    expect(getThreatDisplayName(' ROOT_DETECTED '), 'Rooted device');
    expect(getThreatDisplayName('SCREEN_RECORDING'), 'SCREEN_RECORDING');
  });

  test('a malformed row cannot cause field casts or date crashes', () {
    final data = AlertRepository.parse(
      '{"alerts":[null,3,{"deviceModel":[],"reportedAt":9999999999999999,"osVersion":null}]}',
    );
    final alert = data.alerts.single;
    expect(alert.device, 'Unknown');
    expect(alert.os, '-');
    expect(alert.reportedAt, isNull);
    expect(alert.severity, Severity.low);
    expect(alert.status, AlertStatus.open);
    expect(() => AlertRepository.parse('[]'), throwsFormatException);
  });
}
