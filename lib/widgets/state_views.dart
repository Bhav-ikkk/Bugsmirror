import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/alerts_provider.dart';
import '../theme/app_theme.dart';

class LoadGuard extends StatelessWidget {
  const LoadGuard({super.key, required this.loaded});
  final Widget Function(AlertsProvider provider) loaded;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertsProvider>();
    return switch (provider.state) {
      LoadState.loading => const Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Loading security alerts',
        ),
      ),
      LoadState.error => MessageView(
        title: 'Could not load security alerts',
        description: 'Try loading the alerts again.',
        action: 'Retry',
        icon: Icons.error_outline,
        onAction: provider.load,
      ),
      LoadState.loaded => loaded(provider),
    };
  }
}

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.title,
    this.description,
    this.action,
    this.onAction,
    this.icon = Icons.search_off_outlined,
  });
  final String title;
  final String? description;
  final String? action;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: ConsoleColors.blue),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (description case final text?) ...[
            const SizedBox(height: 6),
            Text(text, textAlign: TextAlign.center),
          ],
          if (action case final label?) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAction, child: Text(label)),
          ],
        ],
      ),
    ),
  );
}
