import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../data/threat_names.dart';
import '../models/alert.dart';
import '../models/alert_enums.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import 'severity_chip.dart';

class FieldValue {
  const FieldValue(this.label, this.value);

  FieldValue.text(
    this.label,
    String text, {
    bool technical = false,
    String? note,
  }) : value = Wrap(
         spacing: 7,
         runSpacing: 4,
         crossAxisAlignment: WrapCrossAlignment.center,
         children: [
           SelectableText(
             text,
             style: technical
                 ? mono(
                     size: 12,
                     color: TripwireColors.ink,
                     weight: FontWeight.w500,
                   )
                 : const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
           ),
           if (note != null) Text(note, style: mono(size: 10)),
         ],
       );

  final String label;
  final Widget value;
}

class FieldsPanel extends StatelessWidget {
  const FieldsPanel({
    super.key,
    required this.fields,
    required this.stackLabels,
  });
  final List<FieldValue> fields;
  final bool stackLabels;

  @override
  Widget build(BuildContext context) => Container(
    decoration: panelDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(19),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Every field',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${fields.length} FIELDS',
                style: mono(size: 10, spacing: .8),
              ),
            ],
          ),
        ),
        for (final field in fields) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
            child: _FieldRow(field: field, stackLabels: stackLabels),
          ),
        ],
      ],
    ),
  );
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.field, required this.stackLabels});
  final FieldValue field;
  final bool stackLabels;

  @override
  Widget build(BuildContext context) {
    final label = Text(field.label, style: mono(size: 10, spacing: .65));
    if (stackLabels) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [label, const SizedBox(height: 5), field.value],
      );
    }
    return Row(
      children: [
        SizedBox(width: 151, child: label),
        const SizedBox(width: 8),
        Expanded(
          child: Align(alignment: Alignment.centerLeft, child: field.value),
        ),
      ],
    );
  }
}

class RawAlertPanel extends StatelessWidget {
  const RawAlertPanel({
    super.key,
    required this.alert,
    required this.resolvedInSession,
  });
  final Alert alert;
  final bool resolvedInSession;

  @override
  Widget build(BuildContext context) {
    final raw = const JsonEncoder.withIndent('  ').convert(alert.raw);
    final notes = <(Color, String)>[
      if (alert.rawSeverity != null &&
          alert.rawSeverity != alert.severity.label)
        (
          severityColor(alert.severity),
          '${jsonEncode(alert.rawSeverity)} is shown as ${alert.severity.label}',
        ),
      if (alert.isDeviceModelMissing)
        (TripwireColors.medium, 'Missing device model is shown as Unknown'),
      if (alert.isOsVersionMissing)
        (TripwireColors.medium, 'Missing OS version is shown as -'),
      if (!threatDisplayNames.containsKey(alert.threatCode.trim()))
        (TripwireColors.low, 'Unmapped threat code is shown as-is'),
      if (resolvedInSession)
        (
          TripwireColors.green,
          'Source record status: ${jsonEncode(alert.rawStatus)}. Resolved in memory for this session.',
        ),
    ];
    return Container(
      decoration: panelDecoration(color: TripwireColors.ink),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'RAW RECORD · ALERTS.JSON',
                  style: mono(color: TripwireColors.darkMuted, spacing: .6),
                ),
              ),
              IconButton(
                tooltip: 'Copy raw record',
                iconSize: 16,
                color: TripwireColors.darkMuted,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: raw));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Copied')));
                  }
                },
                icon: const Icon(Icons.copy_outlined),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText.rich(
              TextSpan(
                children: [
                  for (final line in raw.split('\n')) ...[
                    _codeLine(line),
                    const TextSpan(text: '\n'),
                  ],
                ],
              ),
              style: mono(
                size: 11,
                color: TripwireColors.darkMuted,
              ).copyWith(height: 1.45),
            ),
          ),
          if (notes.isNotEmpty) ...[
            const Divider(height: 14, color: TripwireColors.darkRule),
            for (final (color, note) in notes)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: ColorDot(color, size: 5),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        note,
                        style: mono(size: 10, color: TripwireColors.darkMuted),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  TextSpan _codeLine(String line) {
    final separator = line.indexOf('":');
    if (separator < 0) return TextSpan(text: line);
    final value = line.substring(separator + 2);
    final trimmed = value.trimLeft();
    final color = trimmed.startsWith('null')
        ? TripwireColors.medium
        : line.trimLeft().startsWith('"severity"')
        ? TripwireColors.high
        : trimmed.startsWith('"')
        ? TripwireColors.syntaxString
        : TripwireColors.syntaxNumber;
    return TextSpan(
      children: [
        TextSpan(
          text: line.substring(0, separator + 2),
          style: const TextStyle(color: TripwireColors.surface),
        ),
        TextSpan(
          text: value,
          style: TextStyle(color: color),
        ),
      ],
    );
  }
}

class AlertTimeline extends StatelessWidget {
  const AlertTimeline({
    super.key,
    required this.alert,
    this.loadedAt,
    this.resolvedAt,
  });
  final Alert alert;
  final DateTime? loadedAt;
  final DateTime? resolvedAt;

  String _local(DateTime? date) => date == null
      ? 'Unavailable'
      : DateFormat('d MMM yyyy, h:mm a', 'en_US').format(date.toLocal());

  @override
  Widget build(BuildContext context) {
    final resolved = alert.status == AlertStatus.resolved;
    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _entry(
            Icons.circle,
            'Reported by the SDK',
            formatReportedAt(alert.reportedAt),
            first: true,
          ),
          _entry(Icons.circle, 'Loaded into the dashboard', _local(loadedAt)),
          _entry(
            resolved
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            'Resolution',
            resolvedAt != null
                ? 'Resolved in this session · ${_local(resolvedAt)}'
                : resolved
                ? 'Marked resolved in source data'
                : 'Pending',
            color: resolved ? TripwireColors.green : TripwireColors.muted,
            last: true,
          ),
        ],
      ),
    );
  }

  Widget _entry(
    IconData icon,
    String title,
    String caption, {
    Color color = TripwireColors.ink,
    bool first = false,
    bool last = false,
  }) => Stack(
    children: [
      Positioned(
        left: 6,
        top: first ? 10 : 0,
        bottom: last ? null : 0,
        height: last ? 10 : null,
        child: const ColoredBox(
          color: TripwireColors.border,
          child: SizedBox(width: 1),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : 17),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: ColoredBox(
                color: TripwireColors.surface,
                child: Icon(icon, size: 13, color: color),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(caption, style: mono(size: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
