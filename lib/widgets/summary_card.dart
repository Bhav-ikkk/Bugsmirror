import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.detail,
    this.urgent = false,
  });
  final String label;
  final int value;
  final String caption;
  final IconData icon;
  final Widget detail;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final ink = urgent ? TripwireColors.surface : TripwireColors.ink;
    final muted = urgent ? TripwireColors.darkMuted : TripwireColors.secondary;
    return Container(
      decoration: panelDecoration(
        color: urgent ? TripwireColors.ink : TripwireColors.surface,
      ),
      padding: const EdgeInsets.all(22),
      constraints: const BoxConstraints(minHeight: 218),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(label, style: mono(color: muted, spacing: .65)),
                  ),
                  Icon(
                    icon,
                    size: 18,
                    color: urgent ? TripwireColors.high : muted,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 62,
                      height: 1.02,
                      letterSpacing: -3.3,
                      color: ink,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      caption,
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(padding: const EdgeInsets.only(top: 13), child: detail),
        ],
      ),
    );
  }
}

class MetricBar extends StatelessWidget {
  const MetricBar(this.segments, {super.key});
  final List<(int, Color)> segments;

  @override
  Widget build(BuildContext context) {
    final visible = segments.where((part) => part.$1 > 0);
    return SizedBox(
      height: 6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: visible.isEmpty
            ? const ColoredBox(color: TripwireColors.track)
            : Row(
                spacing: 3,
                children: [
                  for (final (value, color) in visible)
                    Expanded(
                      flex: value,
                      child: ColoredBox(
                        color: color,
                        child: const SizedBox.expand(),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
