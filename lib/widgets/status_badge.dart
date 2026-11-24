import 'package:material_ui/material_ui.dart';

import '../models/alert_enums.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final AlertStatus status;

  @override
  Widget build(BuildContext context) {
    final resolved = status == AlertStatus.resolved;
    final color = resolved ? ConsoleColors.green : ConsoleColors.blue;
    return Container(
      decoration: BoxDecoration(
        color: resolved ? ConsoleColors.greenSoft : ConsoleColors.blueSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
