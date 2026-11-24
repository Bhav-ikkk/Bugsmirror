import 'package:material_ui/material_ui.dart';

import '../models/alert_enums.dart';
import '../theme/app_theme.dart';
import 'severity_chip.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final AlertStatus status;

  @override
  Widget build(BuildContext context) {
    final resolved = status == AlertStatus.resolved;
    final color = resolved ? TripwireColors.green : TripwireColors.ink;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: resolved ? TripwireColors.greenSoft : TripwireColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: resolved ? TripwireColors.greenBorder : TripwireColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (resolved)
            Icon(Icons.check_circle_outline, color: color, size: 13)
          else
            ColorDot(color, radius: 4),
          const SizedBox(width: 5),
          Text(status.label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
