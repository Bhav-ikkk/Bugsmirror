import 'package:material_ui/material_ui.dart';

import '../models/alert_enums.dart';
import '../providers/alerts_provider.dart';
import '../theme/app_theme.dart';

class AlertsFilterBar extends StatefulWidget {
  const AlertsFilterBar({
    super.key,
    required this.provider,
    required this.onSelectApp,
    required this.onClear,
    required this.onExport,
  });
  final AlertsProvider provider;
  final ValueChanged<String?> onSelectApp;
  final VoidCallback onClear;
  final VoidCallback? onExport;

  @override
  State<AlertsFilterBar> createState() => _AlertsFilterBarState();
}

class _AlertsFilterBarState extends State<AlertsFilterBar> {
  late final TextEditingController search = TextEditingController(
    text: widget.provider.deviceSearch,
  );

  @override
  void didUpdateWidget(covariant AlertsFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (search.text != widget.provider.deviceSearch) {
      search.text = widget.provider.deviceSearch;
    }
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Widget filter<T>(
    String label,
    T? value,
    List<(T?, String)> options,
    ValueChanged<T?> onChanged,
  ) => InputDecorator(
    decoration: InputDecoration(labelText: label),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: options.any((option) => option.$1 == value) ? value : null,
        hint: Text(options.first.$2),
        icon: const Icon(Icons.expand_more_rounded, size: 18),
        isExpanded: true,
        isDense: true,
        items: [
          for (final (key, label) in options)
            DropdownMenuItem<T>(
              value: key,
              child: Text(label, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: onChanged,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final width = constraints.maxWidth < 450
              ? (constraints.maxWidth - 12) / 2
              : 164.0;
          return Wrap(
            spacing: 12,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: width,
                child: filter<String>('App', provider.appId, [
                  (null, 'All apps'),
                  for (final app in provider.apps) (app.id, app.label),
                ], widget.onSelectApp),
              ),
              SizedBox(
                width: width,
                child: filter<Severity>('Severity', provider.severity, [
                  (null, 'All severities'),
                  for (final s in Severity.values) (s, s.label),
                ], provider.selectSeverity),
              ),
              SizedBox(
                width: width,
                child: filter<AlertStatus>('Status', provider.status, [
                  (null, 'All statuses'),
                  for (final s in AlertStatus.values) (s, s.label),
                ], provider.selectStatus),
              ),
              SizedBox(
                width: width,
                child: filter<AlertSort>(
                  'Sort by',
                  provider.sort,
                  [for (final s in AlertSort.values) (s, s.label)],
                  (s) {
                    if (s != null) provider.selectSort(s);
                  },
                ),
              ),
              SizedBox(
                width: constraints.maxWidth < 450 ? constraints.maxWidth : 220,
                child: TextField(
                  controller: search,
                  onChanged: provider.search,
                  decoration: InputDecoration(
                    labelText: 'Device search',
                    prefixIcon: const Icon(Icons.search, size: 19),
                    suffixIcon: provider.deviceSearch.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear device search',
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              search.clear();
                              provider.search('');
                            },
                          ),
                  ),
                ),
              ),
              TextButton(
                onPressed: widget.onClear,
                child: const Text('Clear filters'),
              ),
              OutlinedButton.icon(
                onPressed: widget.onExport,
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Export CSV'),
              ),
            ],
          );
        },
      ),
    );
  }
}
