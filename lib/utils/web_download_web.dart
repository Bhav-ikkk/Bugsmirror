import 'dart:js_interop';

import 'package:web/web.dart' as web;

void downloadCsv(String content) {
  final file = web.Blob(
    [content.toJS].toJS,
    web.BlobPropertyBag(type: 'text/csv;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(file);
  final link = web.HTMLAnchorElement()
    ..href = url
    ..download = 'security_alerts_export.csv';
  web.document.body?.append(link);
  link.click();
  link.remove();
  Future<void>.delayed(
    const Duration(seconds: 1),
    () => web.URL.revokeObjectURL(url),
  );
}
