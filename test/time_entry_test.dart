import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/models/category.dart';
import 'package:timeflow/models/time_entry.dart';

void main() {
  test('duration is calculated from start and end', () {
    final start = DateTime(2026, 8, 15, 9);
    final entry = TimeEntry(
      id: '1',
      start: start,
      end: start.add(const Duration(hours: 2, minutes: 30)),
      categoryId: 'work',
    );
    expect(entry.duration, const Duration(hours: 2, minutes: 30));
  });

  test('entries saved with the old enum category still load', () {
    final entry = TimeEntry.fromJson({
      'id': '1',
      'start': '2026-08-15T09:00:00.000',
      'end': '2026-08-15T10:00:00.000',
      'category': 'hobby',
    });
    expect(entry.categoryId, 'hobby');
    expect(entry.subcategoryId, isNull);
    expect(defaultCategories().any((c) => c.id == entry.categoryId), isTrue);
  });

  test('category round-trips through JSON with its subcategories', () {
    final devotion = defaultCategories().firstWhere((c) => c.id == 'devotion');
    devotion.subcategories.last.archived = true;
    final copy = ActivityCategory.fromJson(devotion.toJson());
    expect(copy.subcategories.map((s) => s.name), ['Prayer', 'Bible reading']);
    expect(copy.activeSubcategories.map((s) => s.name), ['Prayer']);
  });

  test('monthly summary splits time by subcategory', () {
    final start = DateTime(2026, 8, 15, 6);
    TimeEntry entry(int minutes, String? sub) => TimeEntry(
        id: '$minutes', start: start, end: start.add(Duration(minutes: minutes)),
        categoryId: 'devotion', subcategoryId: sub);
    final summary = CategorySummary()
      ..add(entry(30, 'devotion_prayer'))
      ..add(entry(20, 'devotion_bible'))
      ..add(entry(10, 'devotion_prayer'))
      ..add(entry(5, null));
    expect(summary.total, const Duration(minutes: 65));
    expect(summary.bySubcategory['devotion_prayer'], const Duration(minutes: 40));
    expect(summary.bySubcategory[null], const Duration(minutes: 5));
  });

  test('closing a running activity splits it at midnight', () {
    var id = 0;
    final sleep = RunningActivity(categoryId: 'sleep', start: DateTime(2026, 8, 15, 23));
    final entries = sleep.close(DateTime(2026, 8, 16, 7, 30), () => '${id++}');
    expect(entries.map((e) => e.duration),
        [const Duration(hours: 1), const Duration(hours: 7, minutes: 30)]);
    expect(entries.last.start, DateTime(2026, 8, 16));
    expect(entries.map((e) => e.id).toSet().length, 2);
  });

  test('running activity survives a JSON round-trip', () {
    final running = RunningActivity(categoryId: 'devotion',
        subcategoryId: 'devotion_prayer', start: DateTime(2026, 8, 15, 6, 12));
    final copy = RunningActivity.fromJson(running.toJson());
    expect(copy.subcategoryId, 'devotion_prayer');
    expect(copy.start, running.start);
  });
}
