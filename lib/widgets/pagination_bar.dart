import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import '../utils/alert_query_engine.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.totalItems,
    required this.itemCount,
    required this.onPage,
  });
  final int page;
  final int totalPages;
  final int totalItems;
  final int itemCount;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    final first = (page - 1) * pageSize + 1;
    final last = first + itemCount - 1;
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 7,
          children: [
            if (itemCount > 0)
              Text(
                'Showing $first–$last of $totalItems',
                style: mono(size: 10),
              ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                _button(
                  context,
                  'Previous',
                  page > 1 ? () => onPage(page - 1) : null,
                ),
                Text(
                  'Page $page of $totalPages',
                  style: mono(color: TripwireColors.ink),
                ),
                _button(
                  context,
                  'Next',
                  page < totalPages ? () => onPage(page + 1) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _button(BuildContext context, String label, VoidCallback? onPressed) =>
      SizedBox(
        height: MediaQuery.sizeOf(context).width < 800 ? 44 : 34,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            disabledForegroundColor: TripwireColors.muted,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(label),
        ),
      );
}
