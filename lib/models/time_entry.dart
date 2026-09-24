class TimeEntry {
  const TimeEntry({
    required this.id,
    required this.start,
    required this.end,
    required this.categoryId,
    this.subcategoryId,
    this.title = '',
    this.note = '',
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final String categoryId;
  final String? subcategoryId;
  final String title;
  final String note;

  Duration get duration => end.difference(start);

  Map<String, dynamic> toJson() => {
        'id': id,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'categoryId': categoryId,
        'subcategoryId': subcategoryId,
        'title': title,
        'note': note,
      };

  factory TimeEntry.fromJson(Map<String, dynamic> json) => TimeEntry(
        id: json['id'] as String,
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
        // Entries saved before categories became editable stored the enum
        // name under 'category'; the default category ids match those names.
        categoryId: (json['categoryId'] ?? json['category']) as String,
        subcategoryId: json['subcategoryId'] as String?,
        title: json['title'] as String? ?? '',
        note: json['note'] as String? ?? '',
      );
}

/// Time spent in one category over a period, split by subcategory
/// (the `null` key holds time logged without a subcategory).
class CategorySummary {
  Duration total = Duration.zero;
  final Map<String?, Duration> bySubcategory = {};

  void add(TimeEntry entry) {
    total += entry.duration;
    bySubcategory.update(entry.subcategoryId, (d) => d + entry.duration,
        ifAbsent: () => entry.duration);
  }
}

/// The activity currently being timed. It becomes a [TimeEntry] when the
/// user switches to another activity or stops it.
class RunningActivity {
  const RunningActivity({required this.categoryId, this.subcategoryId,
      required this.start});

  final String categoryId;
  final String? subcategoryId;
  final DateTime start;

  RunningActivity withStart(DateTime start) => RunningActivity(
      categoryId: categoryId, subcategoryId: subcategoryId, start: start);

  /// Closes the activity at [end], split at midnight so each day's total
  /// only counts the time spent on that day (e.g. sleep from 23:00 to 07:00).
  List<TimeEntry> close(DateTime end, String Function() newId) {
    final entries = <TimeEntry>[];
    var from = start;
    while (from.isBefore(end)) {
      final midnight = DateTime(from.year, from.month, from.day + 1);
      final to = midnight.isBefore(end) ? midnight : end;
      entries.add(TimeEntry(id: newId(), start: from, end: to,
          categoryId: categoryId, subcategoryId: subcategoryId));
      from = to;
    }
    return entries;
  }

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'subcategoryId': subcategoryId,
        'start': start.toIso8601String(),
      };

  factory RunningActivity.fromJson(Map<String, dynamic> json) => RunningActivity(
        categoryId: json['categoryId'] as String,
        subcategoryId: json['subcategoryId'] as String?,
        start: DateTime.parse(json['start'] as String),
      );
}
