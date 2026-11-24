import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/alerts_provider.dart';
import '../theme/app_theme.dart';
import 'severity_chip.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.alertsActive, required this.child});
  final bool alertsActive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 640;
    return Scaffold(
      body: Column(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: TripwireColors.border)),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: contentWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 16 : 22,
                    vertical: compact ? 4 : 8,
                  ),
                  child: LayoutBuilder(
                    builder: (context, bounds) {
                      final nav = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _NavLink(
                            'Overview',
                            !alertsActive,
                            () => context.go('/'),
                          ),
                          SizedBox(width: compact ? 6 : 13),
                          _NavLink('Alerts', alertsActive, () {
                            if (!alertsActive) {
                              context.read<AlertsProvider>().clearFilters();
                            }
                            context.go('/alerts');
                          }),
                        ],
                      );
                      final logo = _BrandLogo(width: compact ? 132 : 154);
                      if (compact) {
                        return Row(children: [logo, const Spacer(), nav]);
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 20,
                          runSpacing: 6,
                          children: [
                            Wrap(
                              spacing: 24,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [logo, nav],
                            ),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _SourcePill(),
                                SizedBox(width: 12),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: TripwireColors.ink,
                                  foregroundColor: TripwireColors.surface,
                                  child: Text(
                                    'BJ',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Bugsmirror',
    image: true,
    child: SizedBox(
      width: width,
      height: 46,
      child: ClipRect(
        child: OverflowBox(
          minHeight: width,
          maxHeight: width,
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              TripwireColors.canvas,
              BlendMode.multiply,
            ),
            child: Image.asset(
              'assets/bugsmirror-logo.png',
              width: width,
              height: width,
              excludeFromSemantics: true,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    ),
  );
}

class _NavLink extends StatelessWidget {
  const _NavLink(this.label, this.selected, this.onPressed);
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: TextButton(
      style: TextButton.styleFrom(
        foregroundColor: selected
            ? TripwireColors.ink
            : TripwireColors.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        minimumSize: const Size(0, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? TripwireColors.ink : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
      ),
    ),
  );
}

class _SourcePill extends StatelessWidget {
  const _SourcePill();

  @override
  Widget build(BuildContext context) {
    final (state, loaded) = context.select(
      (AlertsProvider p) => (p.state, p.lastLoadedAt),
    );
    final label = switch (state) {
      LoadState.loaded =>
        loaded == null
            ? 'loaded'
            : 'loaded ${DateFormat('h:mm a').format(loaded)}',
      LoadState.error => 'error',
      LoadState.loading => 'loading…',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: TripwireColors.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: TripwireColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorDot(switch (state) {
            LoadState.loaded => TripwireColors.green,
            LoadState.error => TripwireColors.high,
            LoadState.loading => TripwireColors.low,
          }, radius: 4),
          const SizedBox(width: 6),
          Text('alerts.json · $label', style: mono(size: 10)),
        ],
      ),
    );
  }
}

String localOffset() {
  final mins = DateTime.now().timeZoneOffset.inMinutes;
  final hours = mins.abs() ~/ 60;
  final remainder = mins.abs() % 60;
  return 'UTC${mins < 0 ? '-' : '+'}$hours:${remainder.toString().padLeft(2, '0')}';
}

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, bounds) {
      final compact = bounds.maxWidth < 640;
      final gutter = compact ? 16.0 : 30.0;
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: bounds.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: contentWidth),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      compact ? 22 : 35,
                      gutter,
                      42,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: TripwireColors.border)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: contentWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: gutter,
                        vertical: 18,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 20,
                          runSpacing: 7,
                          children: [
                            Text(
                              'BUGSMIRROR · SECURITY ALERTS FROM YOUR SDK',
                              style: mono(size: 10, spacing: .45),
                            ),
                            Text(
                              'ALL TIMES IN YOUR LOCAL TIME · ${localOffset()}',
                              style: mono(size: 10, spacing: .45),
                            ),
                            if (compact) const _SourcePill(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
