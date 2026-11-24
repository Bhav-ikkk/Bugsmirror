enum Severity {
  high('High'),
  medium('Medium'),
  low('Low');

  const Severity(this.label);
  final String label;

  static Severity parse(Object? value) =>
      switch (value.toString().trim().toLowerCase()) {
        'high' => high,
        'medium' => medium,
        _ => low,
      };
}

enum AlertStatus {
  open('Open'),
  resolved('Resolved');

  const AlertStatus(this.label);
  final String label;

  static AlertStatus parse(Object? value) =>
      value.toString().trim().toLowerCase() == 'resolved' ? resolved : open;
}

enum AlertSort {
  newest('Newest first'),
  severity('Severity');

  const AlertSort(this.label);
  final String label;
}
