import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/time_entry.dart';

class TimeStore {
  static const _key = 'time_entries_v1';
  final List<TimeEntry> _entries = [];
  SharedPreferencesAsync? _prefs;

  List<TimeEntry> get entries => List.unmodifiable(_entries);

  Future<void> load() async {
    _prefs = SharedPreferencesAsync();
    final raw = await _prefs!.getString(_key);
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw) as List<dynamic>;
    _entries
      ..clear()
      ..addAll(decoded.map((e) => TimeEntry.fromJson(e as Map<String, dynamic>)));
    _sort();
  }

  Future<void> add(TimeEntry entry) async {
    _entries.add(entry);
    _sort();
    await _save();
  }

  Future<void> delete(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _save();
  }

  List<TimeEntry> forDay(DateTime day) => _entries.where((e) =>
      e.start.year == day.year &&
      e.start.month == day.month &&
      e.start.day == day.day).toList();

  Map<ActivityCategory, Duration> summaryForMonth(DateTime month) {
    final result = <ActivityCategory, Duration>{};
    for (final entry in _entries.where((e) =>
        e.start.year == month.year && e.start.month == month.month)) {
      result.update(entry.category, (d) => d + entry.duration,
          ifAbsent: () => entry.duration);
    }
    return result;
  }

  void _sort() => _entries.sort((a, b) => b.start.compareTo(a.start));

  Future<void> _save() async {
    final raw = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await _prefs!.setString(_key, raw);
  }
}
