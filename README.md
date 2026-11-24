# Security Alerts Dashboard

## How to run

Install Flutter stable with Chrome available. From the project root:

```sh
flutter pub get
flutter run -d chrome
flutter test
flutter analyze
flutter build web --release
```

Development SDK (output of `flutter --version`):

```text
Flutter 3.50.1 • channel stable • https://github.com/flutter/flutter.git
Framework • revision ae9b586f34 (5 days ago) • 2026-11-18 17:01:07 -0800
Engine • hash 51379e6df48ea8ee7205623b90fe66491cad8df3 (revision 4d35714800) (6 days ago) • 2026-11-18 01:50:07 -0800
Tools • Dart 3.14.0 • DevTools 2.61.0
```

## Project structure

- `assets/alerts.json` is the original assessment fixture.
- `lib/main.dart` starts the app, and `lib/app.dart` sets up the provider, theme, and router.
- `lib/models/` defines alert values, severity, resolution status, and per-platform app identity.
- `lib/data/` loads and validates the fixture and maps threat codes to display names.
- `lib/providers/alerts_provider.dart` owns the loaded alerts and publishes changes.
- `lib/routing/` maps the Dashboard, Alerts, and individual alert URLs to screens.
- `lib/screens/` implements the three screens and sends user actions to the provider.
- `lib/widgets/` contains shared UI, filters, table and cards, pagination, and state views.
- `lib/theme/` defines the console palette and Material theme.
- `lib/utils/` implements alert queries, local dates, and CSV generation and download.
- `test/` exercises data parsing, sorting, filters, resolution, exports, and screen behavior.

The repository loads the JSON after a one-second delay. The provider keeps the alerts in memory. The Alerts screen filters the list, sorts the matches, then takes five for the current page. When a user confirms resolution, the provider replaces that alert and notifies the screens so they recompute their counts and results.

## What works and what does not

- Dashboard totals and per-platform app counts, with links into the matching app filter.
- Combinable app, severity, status, and device filters, two sort orders, and five alerts per page.
- Table layout from 800 px and alert cards below 800 px.
- Direct alert links (for example `/#/alerts/al_105`), detail metadata, confirmation, and immediate resolution updates.
- Loading, error, Retry, unmatched filters, and missing alert states. Set `simulateError` in `lib/data/alert_repository.dart` to verify the error path.
- CSV download of every matching alert in the current sort order.
- Resolution is session-only. Refreshing the browser restores the original fixture.

## How AI helped

- Tools I used: OpenAI Codex assisted with implementation and verification. [Review and add any other tools you used.]
- Two prompts I used (paste them as you typed them): [Paste two real prompts.]
- One thing the AI got wrong, and how I found and fixed it: [Describe an issue you personally reproduced, checked, and corrected.]
- One part I wrote or changed myself without AI: [Describe your actual manual change.]

## Questions

1. **Where does your app keep the list of alerts, and how does the Dashboard find out that an alert was resolved?**  
   Draft to put in your own words. `AlertsProvider` keeps the current list in `_alerts`. `resolveAlert` replaces the existing entry with a resolved copy and calls `notifyListeners()`. The Dashboard reads the provider through `LoadGuard`, so it rebuilds with recalculated counts.

2. **What would you change to load alerts from a real API instead of the JSON file?**  
   Draft to put in your own words. Give `AlertRepository` an HTTP client and base URL, fetch the JSON over HTTP, and keep validation at the repository boundary. Add a repository method to persist resolutions and call it from `AlertsProvider.resolveAlert`, with a pending state and a recoverable error if the update fails.

## Video

[Add an anyone-with-the-link Drive or unlisted YouTube recording, up to two minutes.]

Show the Dashboard, then Alerts with no filters. Sort by Severity, go to page 2, and filter to High. Open an open alert, confirm resolution, and return to Dashboard to show the updated counts. Switch Chrome DevTools to a 400 px viewport and show the card layout.
