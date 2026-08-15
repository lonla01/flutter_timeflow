import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/models/time_entry.dart';

void main() {
  test('duration is calculated from start and end', () {
    final start = DateTime(2026, 8, 15, 9);
    final entry = TimeEntry(
      id: '1',
      start: start,
      end: start.add(const Duration(hours: 2, minutes: 30)),
      category: ActivityCategory.work,
    );
    expect(entry.duration, const Duration(hours: 2, minutes: 30));
  });

  test('category labels are human readable', () {
    expect(ActivityCategory.hobby.label, 'Hobby');
    expect(ActivityCategory.entertainment.label, 'Entertainment');
  });
}
