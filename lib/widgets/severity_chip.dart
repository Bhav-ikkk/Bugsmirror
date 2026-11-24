import 'package:material_ui/material_ui.dart';

import '../models/alert_enums.dart';
import '../theme/app_theme.dart';

class SeverityChip extends StatelessWidget {
  const SeverityChip(this.severity, {super.key});
  final Severity severity;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (severity) {
      Severity.high => (
        ConsoleColors.redSoft,
        ConsoleColors.red,
        Icons.priority_high_rounded,
      ),
      Severity.medium => (
        ConsoleColors.orangeSoft,
        ConsoleColors.orange,
        Icons.remove_rounded,
      ),
      Severity.low => (
        ConsoleColors.greySoft,
        ConsoleColors.grey,
        Icons.arrow_downward_rounded,
      ),
    };
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 14),
          const SizedBox(width: 4),
          Text(
            severity.label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
