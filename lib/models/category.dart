/// User-editable activity category. Deleting a category or subcategory only
/// archives it: it disappears from the pickers and settings, but past
/// entries and monthly reports keep resolving its name.
class ActivityCategory {
  ActivityCategory({
    required this.id,
    required this.name,
    this.emoji = '📌',
    List<Subcategory>? subcategories,
    this.archived = false,
  }) : subcategories = subcategories ?? [];

  final String id;
  String name;
  String emoji;
  final List<Subcategory> subcategories;
  bool archived;

  List<Subcategory> get activeSubcategories =>
      subcategories.where((s) => !s.archived).toList();

  Subcategory? subcategory(String? id) {
    if (id == null) return null;
    for (final s in subcategories) {
      if (s.id == id) return s;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'subcategories': subcategories.map((s) => s.toJson()).toList(),
        'archived': archived,
      };

  factory ActivityCategory.fromJson(Map<String, dynamic> json) => ActivityCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String? ?? '📌',
        subcategories: (json['subcategories'] as List<dynamic>? ?? [])
            .map((s) => Subcategory.fromJson(s as Map<String, dynamic>))
            .toList(),
        archived: json['archived'] as bool? ?? false,
      );
}

class Subcategory {
  Subcategory({required this.id, required this.name, this.archived = false});

  final String id;
  String name;
  bool archived;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'archived': archived};

  factory Subcategory.fromJson(Map<String, dynamic> json) => Subcategory(
        id: json['id'] as String,
        name: json['name'] as String,
        archived: json['archived'] as bool? ?? false,
      );
}

/// Seeded on first launch. The ids match the names of the former
/// `ActivityCategory` enum so entries saved before categories became
/// editable still resolve.
List<ActivityCategory> defaultCategories() => [
      ActivityCategory(id: 'work', name: 'Work', emoji: '💼'),
      ActivityCategory(id: 'sleep', name: 'Sleep', emoji: '😴'),
      ActivityCategory(id: 'devotion', name: 'Devotion', emoji: '🙏', subcategories: [
        Subcategory(id: 'devotion_prayer', name: 'Prayer'),
        Subcategory(id: 'devotion_bible', name: 'Bible reading'),
      ]),
      ActivityCategory(id: 'exercise', name: 'Exercise', emoji: '🏃'),
      ActivityCategory(id: 'hobby', name: 'Hobby', emoji: '🎨'),
      ActivityCategory(id: 'entertainment', name: 'Entertainment', emoji: '🎬'),
      ActivityCategory(id: 'cleaning', name: 'Cleaning', emoji: '🧹'),
      ActivityCategory(id: 'visit', name: 'Visits', emoji: '🤝'),
      ActivityCategory(id: 'meeting', name: 'Meetings', emoji: '📅'),
      ActivityCategory(id: 'meal', name: 'Meals', emoji: '🍽️'),
      ActivityCategory(id: 'travel', name: 'Travel', emoji: '🚗'),
      ActivityCategory(id: 'personal', name: 'Personal', emoji: '🧘'),
      ActivityCategory(id: 'other', name: 'Other', emoji: '📌'),
    ];
