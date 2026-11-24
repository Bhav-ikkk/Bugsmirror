import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.urgent = false,
  });
  final String label;
  final int value;
  final IconData icon;
  final bool urgent;

  @override
  Widget build(BuildContext context) => Container(
    decoration: panelDecoration(),
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: urgent ? ConsoleColors.redSoft : ConsoleColors.blueSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 19,
            color: urgent ? ConsoleColors.red : ConsoleColors.blue,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: ConsoleColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
