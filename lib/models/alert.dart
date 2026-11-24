import 'alert_enums.dart';

String readText(Object? value, String fallback) =>
    value is String && value.trim().isNotEmpty ? value.trim() : fallback;

class Alert {
  const Alert._(
    this.id,
    this.appId,
    this.threatCode,
    this.severity,
    this.device,
    this.os,
    this.reportedAt,
    this.status,
    this.raw,
  );

  factory Alert.fromJson(
    Map<String, Object?> json, {
    required String fallbackId,
  }) {
    final timestamp = json['reportedAt'];
    final millis = switch (timestamp) {
      int value => value,
      String value => int.tryParse(value.trim()),
      _ => null,
    };
    return Alert._(
      readText(json['id'], fallbackId),
      readText(json['appId'], ''),
      json['threatType'] is String ? json['threatType'].toString() : '-',
      Severity.parse(json['severity']),
      readText(json['deviceModel'], 'Unknown'),
      readText(json['osVersion'], '-'),
      millis != null && millis.abs() <= 8640000000000000 ? millis : null,
      AlertStatus.parse(json['status']),
      Map.unmodifiable(json),
    );
  }

  final String id;
  final String appId;
  final String threatCode;
  final Severity severity;
  final String device;
  final String os;
  final int? reportedAt;
  final AlertStatus status;
  final Map<String, Object?> raw;

  Alert resolved() => Alert._(
    id,
    appId,
    threatCode,
    severity,
    device,
    os,
    reportedAt,
    AlertStatus.resolved,
    raw,
  );
}
