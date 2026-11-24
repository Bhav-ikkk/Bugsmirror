import 'package:material_ui/material_ui.dart';

import '../models/alert_enums.dart';
import '../providers/alerts_provider.dart';
import '../theme/app_theme.dart';
import 'severity_chip.dart';

class AlertsFilterBar extends StatefulWidget {
  const AlertsFilterBar({
    super.key,
    required this.provider,
    required this.matching,
    required this.onSelectApp,
    required this.onSelectStatus,
    required this.onClear,
    required this.onExport,
  });
  final AlertsProvider provider;
  final int matching;
  final ValueChanged<String?> onSelectApp;
  final ValueChanged<AlertStatus?> onSelectStatus;
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

  Future<void> _showFilters() async {
    final p = widget.provider;
    final previousRoute = (p.appId, p.status);
    FocusScope.of(context).unfocus();
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: TripwireColors.surface,
      builder: (sheet) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: ListenableBuilder(
            listenable: p,
            builder: (_, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filter alerts',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 15),
                _AppSelect(
                  provider: p,
                  height: 44,
                  onChanged: (app) => p.selectRouteFilters(app, p.status),
                ),
                const SizedBox(height: 12),
                _SeveritySelect(provider: p, height: 48),
                const SizedBox(height: 12),
                _StatusSelect(
                  provider: p,
                  height: 48,
                  onChanged: (status) => p.selectRouteFilters(p.appId, status),
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    TextButton(
                      onPressed: p.clearFilters,
                      child: const Text('Clear filters'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(sheet),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // Keep the sheet open while filters update, then reflect the route once.
    if (mounted && previousRoute != (p.appId, p.status)) {
      widget.onSelectApp(p.appId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final width = MediaQuery.sizeOf(context).width;
    final active = [
      p.appId,
      p.severity,
      p.status,
    ].where((value) => value != null).length;
    final filtered = active > 0 || p.deviceSearch.trim().isNotEmpty;
    final canClear = filtered || p.sort != AlertSort.newest;
    final summary = Wrap(
      spacing: 7,
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Icon(Icons.filter_list, size: 15, color: TripwireColors.muted),
        Text(
          '${widget.matching} ${widget.matching == 1 ? 'alert' : 'alerts'} · '
          '${filtered ? 'filtered' : 'no filters applied'}',
          style: mono(size: 11),
        ),
        if (canClear)
          TextButton(
            onPressed: widget.onClear,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 7),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(width < 800 ? 'Clear' : 'Clear filters'),
          ),
      ],
    );
    if (width < 800) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _searchField(40),
          const SizedBox(height: 9),
          Row(
            spacing: 7,
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: _showFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor: active > 0
                          ? TripwireColors.track
                          : TripwireColors.surface,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(active > 0 ? 'Filters · $active' : 'Filters'),
                    ),
                  ),
                ),
              ),
              Expanded(child: _sort(p, mobile: true)),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: widget.onExport,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Export CSV'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          summary,
        ],
      );
    }
    final controls = <Widget>[
      SizedBox(
        width: 176,
        child: _AppSelect(
          provider: p,
          height: 38,
          onChanged: widget.onSelectApp,
        ),
      ),
      SizedBox(width: 270, child: _SeveritySelect(provider: p, height: 38)),
      SizedBox(
        width: 214,
        child: _StatusSelect(
          provider: p,
          height: 38,
          onChanged: widget.onSelectStatus,
        ),
      ),
    ];
    return Container(
      decoration: panelDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            child: width >= 1040
                ? Row(
                    spacing: 10,
                    children: [
                      ...controls,
                      Expanded(child: _searchField(38)),
                    ],
                  )
                : Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ...controls,
                      SizedBox(width: 230, child: _searchField(38)),
                    ],
                  ),
          ),
          const Divider(height: 1),
          ColoredBox(
            color: TripwireColors.tint,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 5, 8, 5),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 9,
                runSpacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  summary,
                  SizedBox(width: 194, child: _sort(p)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField(double height) => SizedBox(
    height: height,
    child: TextField(
      controller: search,
      onChanged: widget.provider.search,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Search device model',
        constraints: BoxConstraints.tightFor(height: height),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        prefixIcon: const Icon(Icons.search, size: 16),
        prefixIconConstraints: BoxConstraints.tightFor(
          width: 32,
          height: height,
        ),
        suffixIconConstraints: BoxConstraints.tightFor(
          width: 40,
          height: height,
        ),
        suffixIcon: widget.provider.deviceSearch.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear device search',
                icon: const Icon(Icons.close, size: 16),
                onPressed: () {
                  search.clear();
                  widget.provider.search('');
                },
              ),
      ),
    ),
  );

  Widget _sort(AlertsProvider p, {bool mobile = false}) => _Select<AlertSort>(
    label: 'SORT',
    height: mobile ? 44 : 34,
    value: p.sort,
    choices: [
      (AlertSort.newest, mobile ? 'Newest' : 'Newest first'),
      (AlertSort.severity, mobile ? 'Severity' : 'Severity (High to Low)'),
    ],
    onChanged: (sort) {
      if (sort != null) p.selectSort(sort);
    },
  );
}

class _AppSelect extends StatelessWidget {
  const _AppSelect({
    required this.provider,
    required this.height,
    required this.onChanged,
  });
  final AlertsProvider provider;
  final double height;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => _Select<String>(
    label: 'APP',
    height: height,
    value: provider.appId,
    choices: [
      (null, 'All apps'),
      for (final app in provider.apps) (app.id, app.label),
    ],
    onChanged: onChanged,
  );
}

class _SeveritySelect extends StatelessWidget {
  const _SeveritySelect({required this.provider, required this.height});
  final AlertsProvider provider;
  final double height;

  @override
  Widget build(BuildContext context) => _Segments<Severity>(
    label: 'SEVERITY',
    height: height,
    value: provider.severity,
    onChanged: provider.selectSeverity,
    choices: [
      (null, 'All', null),
      for (final s in Severity.values) (s, s.label, severityColor(s)),
    ],
  );
}

class _StatusSelect extends StatelessWidget {
  const _StatusSelect({
    required this.provider,
    required this.height,
    required this.onChanged,
  });
  final AlertsProvider provider;
  final double height;
  final ValueChanged<AlertStatus?> onChanged;

  @override
  Widget build(BuildContext context) => _Segments<AlertStatus>(
    label: 'STATUS',
    height: height,
    value: provider.status,
    onChanged: onChanged,
    choices: [
      (null, 'All', null),
      for (final s in AlertStatus.values) (s, s.label, null),
    ],
  );
}

class _Select<T> extends StatelessWidget {
  const _Select({
    required this.label,
    required this.height,
    required this.value,
    required this.choices,
    required this.onChanged,
  });
  final String label;
  final double height;
  final T? value;
  final List<(T?, String)> choices;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: TripwireColors.surface,
      border: Border.all(color: TripwireColors.border),
      borderRadius: BorderRadius.circular(tripwire.controlRadius),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      children: [
        Text(label, style: mono(size: 9, spacing: .35)),
        const SizedBox(width: 6),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: choices.any((choice) => choice.$1 == value) ? value : null,
              hint: Text(choices.first.$2, overflow: TextOverflow.ellipsis),
              isExpanded: true,
              isDense: true,
              menuWidth: 235,
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 13,
                color: TripwireColors.ink,
              ),
              icon: const Icon(Icons.expand_more_rounded, size: 15),
              items: [
                for (final (key, text) in choices)
                  DropdownMenuItem<T>(
                    value: key,
                    child: Text(text, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Segments<T> extends StatelessWidget {
  const _Segments({
    required this.label,
    required this.height,
    required this.value,
    required this.choices,
    required this.onChanged,
  });
  final String label;
  final double height;
  final T? value;
  final List<(T?, String, Color?)> choices;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(label, style: mono(size: 9, spacing: .35)),
      const SizedBox(width: 7),
      Expanded(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: TripwireColors.track,
            borderRadius: BorderRadius.circular(tripwire.controlRadius),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            spacing: 2,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (key, option, color) in choices)
                Expanded(
                  flex: key == null
                      ? 3
                      : option == 'Medium' || option == 'Resolved'
                      ? 6
                      : 5,
                  child: Semantics(
                    selected: key == value,
                    label: '${label.toLowerCase()}: $option',
                    child: TextButton(
                      onPressed: () => onChanged(key),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        foregroundColor: key == value
                            ? TripwireColors.ink
                            : TripwireColors.secondary,
                        backgroundColor: key == value
                            ? TripwireColors.surface
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (color != null) ...[
                            ColorDot(color, size: 5),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                              option,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}
