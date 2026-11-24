import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:security_alerts_dashboard/app.dart';
import 'package:security_alerts_dashboard/data/alert_repository.dart';
import 'package:security_alerts_dashboard/widgets/alert_card.dart';
import 'package:security_alerts_dashboard/widgets/alerts_table.dart';

void main() {
  final source = File('assets/alerts.json').readAsStringSync();
  final repository = AlertRepository(assetLoader: () async => source);
  for (final width in [400, 500, 768, 799, 800, 1024, 1280]) {
    testWidgets('alerts layout at ${width}px', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width.toDouble(), 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        SecurityAlertsApp(initialLocation: '/alerts', repository: repository),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Page 1 of 3'), findsOneWidget);
      expect(
        find.byType(AlertsTable),
        width >= 800 ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(AlertCard),
        width < 800 ? findsNWidgets(5) : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('cold detail loads, then cancel and confirm resolution', (
    tester,
  ) async {
    await tester.pumpWidget(
      SecurityAlertsApp(
        initialLocation: '/alerts/al_105',
        repository: repository,
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Alert not found'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('App was modified'), findsOneWidget);
    await tester.ensureVisible(find.text('Mark as resolved'));
    await tester.tap(find.text('Mark as resolved'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Mark as resolved'), findsOneWidget);
    await tester.tap(find.text('Mark as resolved'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Resolved'), findsOneWidget);
    expect(find.text('Mark as resolved'), findsNothing);
  });

  testWidgets('repository source flag controls loading and Retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      SecurityAlertsApp(
        repository: AlertRepository(assetLoader: () async => source),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    if (simulateError) {
      expect(find.text('Could not load security alerts'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Could not load security alerts'), findsOneWidget);
    } else {
      expect(find.text('Monitored apps'), findsOneWidget);
    }
  });

  testWidgets('repository error shows Retry and can recover', (tester) async {
    var attempts = 0;
    final flaky = AlertRepository(
      assetLoader: () async {
        if (++attempts == 1) throw StateError('fixture omitted');
        return source;
      },
    );
    await tester.pumpWidget(
      SecurityAlertsApp(initialLocation: '/alerts/al_105', repository: flaky),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Could not load security alerts'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('App was modified'), findsOneWidget);
  });
}
