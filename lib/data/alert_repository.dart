import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/alert.dart';
import '../models/app_summary.dart';

const bool simulateError = false;

typedef AlertData = ({List<Alert> alerts, List<MonitoredApp> apps});

class AlertRepository {
  const AlertRepository({
    this.assetLoader,
    this.simulateErrorOverride,
    this.delay = const Duration(seconds: 1),
  });

  final Future<String> Function()? assetLoader;
  final bool? simulateErrorOverride;
  final Duration delay;

  Future<AlertData> load() async {
    await Future<void>.delayed(delay);
    if (simulateErrorOverride ?? simulateError) {
      throw const FormatException(
        'Simulated failure while loading security alerts.',
      );
    }
    return parse(
      await (assetLoader?.call() ??
          rootBundle.loadString('assets/alerts.json')),
    );
  }

  static AlertData parse(String source) {
    final root = jsonDecode(source);
    if (root is! Map<String, dynamic> || root['alerts'] is! List) {
      throw const FormatException(
        'The alerts file does not have the expected structure.',
      );
    }
    final records = (root['alerts'] as List).whereType<Map<String, dynamic>>();
    final rawApps = root['apps'];
    final apps = <String, MonitoredApp>{};
    if (rawApps is List) {
      for (final row in rawApps.whereType<Map<String, dynamic>>()) {
        final id = readText(row['id'], '');
        if (id.isEmpty) continue;
        final platform = switch (readText(row['platform'], '').toLowerCase()) {
          'android' => 'Android',
          'ios' => 'iOS',
          _ => 'Unknown',
        };
        apps[id] = MonitoredApp(
          id,
          readText(row['name'], 'Unknown app'),
          platform,
        );
      }
    }
    final alerts = <Alert>[];
    final usedIds = <String>{};
    for (final row in records) {
      final id = 'alert-${alerts.length + 1}';
      final alert = Alert.fromJson(row, fallbackId: id);
      if (!usedIds.add(alert.id)) continue;
      alerts.add(alert);
      apps.putIfAbsent(
        alert.appId,
        () => MonitoredApp(alert.appId, 'Unknown app', 'Unknown'),
      );
    }
    return (
      apps: List.unmodifiable(apps.values),
      alerts: List.unmodifiable(alerts),
    );
  }
}
