import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:security_alerts_dashboard/app.dart';
import 'package:security_alerts_dashboard/data/alert_repository.dart';
import 'package:security_alerts_dashboard/providers/alerts_provider.dart';
import 'package:security_alerts_dashboard/screens/dashboard_screen.dart';
import 'package:security_alerts_dashboard/widgets/alert_card.dart';
import 'package:security_alerts_dashboard/widgets/alert_inspector.dart';
import 'package:security_alerts_dashboard/widgets/alerts_table.dart';

void main() {
  final source = File('assets/alerts.json').readAsStringSync();
  final repository = AlertRepository(assetLoader: () async => source);
  for (final width in [400, 500, 600, 768, 799, 800, 1024, 1280]) {
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

  for (final width in [400, 500, 600, 768, 799, 800, 1024, 1280]) {
    for (final (route, marker) in [
      ('/', 'Latest open'),
      ('/alerts/al_105', 'Every field'),
    ]) {
      testWidgets('$route layout at ${width}px', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width.toDouble(), 1050);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          SecurityAlertsApp(initialLocation: route, repository: repository),
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(find.text(marker), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'Overview derives metrics, refreshes when resolved, and links to Open',
    (tester) async {
      await tester.pumpWidget(SecurityAlertsApp(repository: repository));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(
        find.text(
          '5 high-severity threats are still open on your apps.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('14'), findsOneWidget);
      expect(find.text('11 open'), findsOneWidget);
      for (final label in ['7 High', '4 Medium', '3 Low']) {
        expect(find.text(label), findsOneWidget);
      }
      final context = tester.element(find.byType(DashboardScreen));
      final provider = context.read<AlertsProvider>();
      final router = GoRouter.of(context);
      provider.resolveAlert('al_105');
      await tester.pumpAndSettle();
      expect(
        find.text(
          '4 high-severity threats are still open on your apps.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('14'), findsOneWidget);
      expect(find.text('10 open'), findsOneWidget);
      await tester.ensureVisible(find.text('Review open alerts'));
      await tester.tap(find.text('Review open alerts'));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.queryParameters['status'],
        'open',
      );
      expect(find.text('10 alerts · filtered'), findsOneWidget);
      expect(find.text('Page 1 of 2'), findsOneWidget);
    },
  );

  testWidgets(
    'raw inspector displays original casing and null, with real annotations',
    (tester) async {
      await tester.pumpWidget(
        SecurityAlertsApp(
          initialLocation: '/alerts/al_103',
          repository: repository,
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      final rawText = tester.widget<SelectableText>(
        find.descendant(
          of: find.byType(RawAlertPanel),
          matching: find.byType(SelectableText),
        ),
      );
      final raw = jsonDecode(rawText.textSpan?.toPlainText() ?? '') as Map;
      final asset = jsonDecode(source) as Map;
      final original = (asset['alerts'] as List).singleWhere(
        (row) => row['id'] == 'al_103',
      );
      expect(raw, original);
      expect(find.text('"HIGH" is shown as High'), findsOneWidget);
      expect(
        find.text('Missing device model is shown as Unknown'),
        findsOneWidget,
      );
      expect(find.text('Missing OS version is shown as -'), findsNothing);
    },
  );

  for (final (route, title) in [
    ('/', 'Latest open'),
    ('/alerts', 'Every alert, one place.'),
    ('/alerts/al_105', 'Every field'),
  ]) {
    testWidgets('$route fits a short 400×667 viewport', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 667);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        SecurityAlertsApp(initialLocation: route, repository: repository),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
      if (route == '/alerts') {
        expect(
          tester.getBottomLeft(find.byType(AlertCard).first).dy,
          lessThan(667),
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'mobile filter sheet applies selections and preserves the route',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 667);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        SecurityAlertsApp(initialLocation: '/alerts', repository: repository),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();
      final sheet = find.byType(BottomSheet);
      Finder inSheet(String text) =>
          find.descendant(of: sheet, matching: find.text(text));
      await tester.tap(inSheet('All apps'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('QuickPay (iOS)').last);
      await tester.pumpAndSettle();
      await tester.tap(inSheet('High'));
      await tester.pumpAndSettle();
      await tester.tap(inSheet('Open'));
      await tester.pumpAndSettle();
      expect(sheet, findsOneWidget);
      await tester.tap(inSheet('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Filters · 3'), findsOneWidget);
      expect(find.text('2 alerts · filtered'), findsOneWidget);
      final router = GoRouter.of(tester.element(find.byType(AlertCard).first));
      expect(router.routeInformationProvider.value.uri.queryParameters, {
        'app': 'app_2',
        'status': 'open',
      });
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(find.text('14 alerts · no filters applied'), findsOneWidget);
    },
  );

  testWidgets('desktop metadata and timeline align for all 14 alert records', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 960);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      SecurityAlertsApp(
        initialLocation: '/alerts/al_105',
        repository: repository,
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    final router = GoRouter.of(tester.element(find.byType(FieldsPanel)));
    final records = (jsonDecode(source) as Map)['alerts'] as List;
    expect(records, hasLength(14));
    for (final record in records) {
      router.go('/alerts/${record['id']}');
      await tester.pumpAndSettle();
      final fields = tester.getRect(find.byType(FieldsPanel));
      final raw = tester.getRect(find.byType(RawAlertPanel));
      final timeline = tester.getRect(find.byType(AlertTimeline));
      expect(raw.top, closeTo(fields.top, .5), reason: record['id'] as String);
      expect(
        timeline.bottom,
        closeTo(fields.bottom, .5),
        reason: record['id'] as String,
      );
      expect(timeline.top - raw.bottom, closeTo(16, .5));
      expect(tester.takeException(), isNull);
    }
  });

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
    expect(find.text('App was modified'), findsWidgets);
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
    expect(find.text('Resolved'), findsNWidgets(2));
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
      expect(find.text('Apps'), findsOneWidget);
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
    expect(find.text('App was modified'), findsWidgets);
  });
}
