import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/time_entry.dart';

class TimeStore {
  static const _key = 'time_entries_v1';
  static const _runningKey = 'running_activity_v1';
  final List<TimeEntry> _entries = [];
  RunningActivity? _running;
  SharedPreferencesAsync? _prefs;
  int _idCounter = 0;

  List<TimeEntry> get entries => List.unmodifiable(_entries);

  RunningActivity? get running => _running;

  Future<void> load() async {
    _prefs = SharedPreferencesAsync();
    final running = await _prefs!.getString(_runningKey);
    if (running != null) {
      _running = RunningActivity.fromJson(jsonDecode(running) as Map<String, dynamic>);
    }
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

  Future<void> update(TimeEntry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index < 0) return add(entry);
    _entries[index] = entry;
    _sort();
    await _save();
  }

  Future<void> delete(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _save();
  }

  /// Closes the running activity (if any) and starts [next] now. Returns
  /// the entries that were closed, so the caller can [undoSwitch].
  Future<List<TimeEntry>> switchTo(String categoryId, String? subcategoryId) =>
      _closeRunning(RunningActivity(categoryId: categoryId,
          subcategoryId: subcategoryId, start: DateTime.now()));

  Future<List<TimeEntry>> stop() => _closeRunning(null);

  /// Restores [previous] as the running activity and drops the entries a
  /// switch or stop produced.
  Future<void> undoSwitch(RunningActivity? previous, List<TimeEntry> closed) async {
    final ids = closed.map((e) => e.id).toSet();
    _entries.removeWhere((e) => ids.contains(e.id));
    await _setRunning(previous);
    await _save();
  }

  /// Corrects the start of the running activity, e.g. when the user forgot
  /// to switch on time.
  Future<void> setRunningStart(DateTime start) async {
    if (_running != null) await _setRunning(_running!.withStart(start));
  }

  Future<List<TimeEntry>> _closeRunning(RunningActivity? next) async {
    final now = next?.start ?? DateTime.now();
    // Anything under a minute is almost certainly a mis-tap being corrected.
    final closed = _running == null ? <TimeEntry>[]
        : _running!.close(now, _newId)
            .where((e) => e.duration >= const Duration(minutes: 1)).toList();
    _entries.addAll(closed);
    _sort();
    await _setRunning(next);
    await _save();
    return closed;
  }

  Future<void> _setRunning(RunningActivity? running) async {
    _running = running;
    if (running == null) {
      await _prefs!.remove(_runningKey);
    } else {
      await _prefs!.setString(_runningKey, jsonEncode(running.toJson()));
    }
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

  List<TimeEntry> forDay(DateTime day) => _entries.where((e) =>
      e.start.year == day.year &&
      e.start.month == day.month &&
      e.start.day == day.day).toList();

  Map<String, CategorySummary> summaryForMonth(DateTime month) {
    final result = <String, CategorySummary>{};
    for (final entry in _entries.where((e) =>
        e.start.year == month.year && e.start.month == month.month)) {
      result.putIfAbsent(entry.categoryId, CategorySummary.new).add(entry);
    }
    return result;
  }

  void _sort() => _entries.sort((a, b) => b.start.compareTo(a.start));

  Future<void> _save() async {
    final raw = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await _prefs!.setString(_key, raw);
  }
}
