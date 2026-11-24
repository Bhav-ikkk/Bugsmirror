import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_alerts_dashboard/models/alert.dart';
import 'package:security_alerts_dashboard/utils/csv_exporter.dart';

void main() {
  test('CSV round-trips quotes, commas and newlines safely', () {
    final alert = Alert.fromJson({
      'threatType': 'ROOT_DETECTED',
      'deviceModel': 'Phone, "A"\nSecond line',
      'osVersion': '-',
    }, fallbackId: 'x');
    final csv = exportAlerts([alert], (_) => '=unsafe');
    final rows = const CsvToListConverter(shouldParseNumbers: false)
        .convert(csv);
    expect(rows[1][0], 'Rooted device');
    expect(rows[1][2], "'=unsafe");
    expect(rows[1][3], 'Phone, "A"\nSecond line');
    expect(rows[1][4], '-');
  });

  test('guards formula prefixes', () {
    for (final value in ['=1', '+1', '-1', '@SUM', '\t1', '\r1', '  =1']) {
      expect(spreadsheetSafe(value), "'$value");
    }
    expect(spreadsheetSafe('-'), '-');
  });
}
