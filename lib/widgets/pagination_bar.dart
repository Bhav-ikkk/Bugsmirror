import 'package:material_ui/material_ui.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onPage,
  });
  final int page;
  final int totalPages;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.end,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 10,
    runSpacing: 8,
    children: [
      OutlinedButton(
        onPressed: page > 1 ? () => onPage(page - 1) : null,
        child: const Text('Previous'),
      ),
      Text('Page $page of $totalPages'),
      OutlinedButton(
        onPressed: page < totalPages ? () => onPage(page + 1) : null,
        child: const Text('Next'),
      ),
    ],
  );
}
