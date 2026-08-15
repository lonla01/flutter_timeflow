enum ActivityCategory {
  work, sleep, exercise, hobby, entertainment, cleaning,
  visit, meeting, meal, travel, personal, other,
}

extension ActivityCategoryX on ActivityCategory {
  String get label => switch (this) {
        ActivityCategory.work => 'Work',
        ActivityCategory.sleep => 'Sleep',
        ActivityCategory.exercise => 'Exercise',
        ActivityCategory.hobby => 'Hobby',
        ActivityCategory.entertainment => 'Entertainment',
        ActivityCategory.cleaning => 'Cleaning',
        ActivityCategory.visit => 'Visits',
        ActivityCategory.meeting => 'Meetings',
        ActivityCategory.meal => 'Meals',
        ActivityCategory.travel => 'Travel',
        ActivityCategory.personal => 'Personal',
        ActivityCategory.other => 'Other',
      };

  String get emoji => switch (this) {
        ActivityCategory.work => '💼',
        ActivityCategory.sleep => '😴',
        ActivityCategory.exercise => '🏃',
        ActivityCategory.hobby => '🎨',
        ActivityCategory.entertainment => '🎬',
        ActivityCategory.cleaning => '🧹',
        ActivityCategory.visit => '🤝',
        ActivityCategory.meeting => '📅',
        ActivityCategory.meal => '🍽️',
        ActivityCategory.travel => '🚗',
        ActivityCategory.personal => '🧘',
        ActivityCategory.other => '📌',
      };
}

class TimeEntry {
  const TimeEntry({
    required this.id,
    required this.start,
    required this.end,
    required this.category,
    this.title = '',
    this.note = '',
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final ActivityCategory category;
  final String title;
  final String note;

  Duration get duration => end.difference(start);

  Map<String, dynamic> toJson() => {
        'id': id,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'category': category.name,
        'title': title,
        'note': note,
      };

  factory TimeEntry.fromJson(Map<String, dynamic> json) => TimeEntry(
        id: json['id'] as String,
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
        category: ActivityCategory.values.byName(json['category'] as String),
        title: json['title'] as String? ?? '',
        note: json['note'] as String? ?? '',
      );
}
