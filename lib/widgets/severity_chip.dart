import 'package:material_ui/material_ui.dart';

import '../models/alert_enums.dart';
import '../theme/app_theme.dart';

Color severityColor(Severity severity) => switch (severity) {
  Severity.high => TripwireColors.high,
  Severity.medium => TripwireColors.medium,
  Severity.low => TripwireColors.low,
};

class SeverityChip extends StatelessWidget {
  const SeverityChip(this.severity, {super.key});
  final Severity severity;

  @override
  Widget build(BuildContext context) {
    final (bg, ink) = switch (severity) {
      Severity.high => (TripwireColors.highSoft, TripwireColors.highInk),
      Severity.medium => (TripwireColors.mediumSoft, TripwireColors.mediumInk),
      Severity.low => (TripwireColors.lowSoft, TripwireColors.lowInk),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorDot(severityColor(severity)),
            const SizedBox(width: 5),
            Text(
              severity.label,
              style: TextStyle(
                color: ink,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorDot extends StatelessWidget {
  const ColorDot(this.color, {super.key, this.size = 6, this.radius = 2});
  final Color color;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
