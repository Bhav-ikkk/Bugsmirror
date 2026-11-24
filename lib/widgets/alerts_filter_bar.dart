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
  });
  final AlertsProvider provider;
  final int matching;
  final ValueChanged<String?> onSelectApp;
  final ValueChanged<AlertStatus?> onSelectStatus;
  final VoidCallback onClear;

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

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final isFiltered =
        p.appId != null ||
        p.severity != null ||
        p.status != null ||
        p.deviceSearch.trim().isNotEmpty;
    return Container(
      decoration: panelDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            child: LayoutBuilder(
              builder: (_, bounds) => Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 11,
                runSpacing: 9,
                children: [
                  SizedBox(
                    width: 188,
                    child: _Select<String>(
                      label: 'APP',
                      value: p.appId,
                      choices: [
                        (null, 'All apps'),
                        for (final app in p.apps) (app.id, app.label),
                      ],
                      onChanged: widget.onSelectApp,
                    ),
                  ),
                  _Segments<Severity>(
                    label: 'SEVERITY',
                    value: p.severity,
                    onChanged: p.selectSeverity,
                    choices: [
                      (null, 'All', null),
                      for (final s in Severity.values)
                        (s, s.label, severityColor(s)),
                    ],
                  ),
                  _Segments<AlertStatus>(
                    label: 'STATUS',
                    value: p.status,
                    onChanged: widget.onSelectStatus,
                    choices: [
                      (null, 'All', null),
                      for (final s in AlertStatus.values) (s, s.label, null),
                    ],
                  ),
                  SizedBox(
                    width: bounds.maxWidth < 550 ? bounds.maxWidth : 225,
                    child: TextField(
                      controller: search,
                      onChanged: p.search,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search device model',
                        labelStyle: const TextStyle(fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 11,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 17),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 32,
                        ),
                        suffixIcon: p.deviceSearch.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear device search',
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  search.clear();
                                  p.search('');
                                },
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          ColoredBox(
            color: TripwireColors.tint,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 5, 8, 5),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 5,
                children: [
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(
                        Icons.filter_list,
                        size: 16,
                        color: TripwireColors.muted,
                      ),
                      Text(
                        '${widget.matching} ${widget.matching == 1 ? 'alert' : 'alerts'} · '
                        '${isFiltered ? 'filtered' : 'no filters applied'}',
                        style: mono(size: 10),
                      ),
                      if (isFiltered || p.sort != AlertSort.newest)
                        TextButton(
                          onPressed: widget.onClear,
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Clear filters'),
                        ),
                    ],
                  ),
                  SizedBox(
                    width: 188,
                    child: _Select<AlertSort>(
                      label: 'SORT',
                      value: p.sort,
                      choices: [
                        (AlertSort.newest, 'Newest first'),
                        (AlertSort.severity, 'Severity (High to Low)'),
                      ],
                      onChanged: (sort) {
                        if (sort != null) p.selectSort(sort);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Select<T> extends StatelessWidget {
  const _Select({
    required this.label,
    required this.value,
    required this.choices,
    required this.onChanged,
  });
  final String label;
  final T? value;
  final List<(T?, String)> choices;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: TripwireColors.surface,
      border: Border.all(color: TripwireColors.border),
      borderRadius: BorderRadius.circular(tripwire.controlRadius),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(
      children: [
        Text(label, style: mono(size: 9, spacing: .45)),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: choices.any((choice) => choice.$1 == value) ? value : null,
              hint: Text(choices.first.$2, overflow: TextOverflow.ellipsis),
              isExpanded: true,
              isDense: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 13,
                color: TripwireColors.ink,
              ),
              icon: const Icon(Icons.expand_more_rounded, size: 15),
              items: [
                for (final (key, label) in choices)
                  DropdownMenuItem<T>(
                    value: key,
                    child: Text(label, overflow: TextOverflow.ellipsis),
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
    required this.value,
    required this.choices,
    required this.onChanged,
  });
  final String label;
  final T? value;
  final List<(T?, String, Color?)> choices;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 7,
    runSpacing: 4,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(label, style: mono(size: 9, spacing: .45)),
      Container(
        decoration: BoxDecoration(
          color: TripwireColors.track,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(3),
        child: Wrap(
          spacing: 2,
          runSpacing: 2,
          children: [
            for (final (key, label, color) in choices)
              Semantics(
                selected: key == value,
                label: '${this.label.toLowerCase()}: $label',
                child: TextButton(
                  onPressed: () => onChanged(key),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 31),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    foregroundColor: value == key
                        ? TripwireColors.ink
                        : TripwireColors.secondary,
                    backgroundColor: value == key
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
                        const SizedBox(width: 5),
                      ],
                      Text(label, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
