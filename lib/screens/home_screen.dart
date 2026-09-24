import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/category.dart';
import '../models/time_entry.dart';
import '../services/category_store.dart';
import '../services/time_store.dart';
import '../theme/app_theme.dart';
import '../widgets/entry_dialog.dart';
import '../widgets/gradient_widgets.dart';
import 'monthly_report_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store, required this.categories});
  final TimeStore store;
  final CategoryStore categories;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  DateTime selectedDay = DateTime.now();
  Timer? _ticker;

  TimeStore get store => widget.store;
  CategoryStore get categories => widget.categories;

  @override
  void initState() {
    super.initState();
    // Keeps the elapsed time of the running activity ticking.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (store.running != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: GradientAppBar(
          title: 'TimeFlow',
          actions: [
            IconButton(
              tooltip: 'Monthly report',
              icon: const Icon(Icons.bar_chart),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
                  MonthlyReportScreen(store: store, categories: categories))),
            ),
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(
                    builder: (_) => SettingsScreen(categories: categories)));
                setState(() {});
              },
            ),
          ],
        ),
        floatingActionButton: tab == 1
            ? GradientFab(onPressed: () => _editEntry(), label: 'Add activity')
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.timer_outlined),
                selectedIcon: Icon(Icons.timer), label: 'Now'),
            NavigationDestination(icon: Icon(Icons.view_list_outlined),
                selectedIcon: Icon(Icons.view_list), label: 'Day'),
          ],
        ),
        body: tab == 0 ? _nowView() : _dayView(),
      );

  // ---------------------------------------------------------------- Now tab

  Widget _nowView() {
    final running = store.running;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _nowCard(running),
        const SizedBox(height: 20),
        Text(running == null ? 'Start an activity' : 'Switch to',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
          children: [
            for (final c in categories.active)
              _ActivityTile(
                category: c,
                current: running?.categoryId == c.id,
                onTap: () => _pick(c),
              ),
          ],
        ),
      ],
    );
  }

  Widget _nowCard(RunningActivity? running) {
    if (running == null) {
      return GradientHeroCard(child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
          child: const Icon(Icons.play_arrow_rounded, size: 30, color: Colors.white),
        ),
        const SizedBox(width: 16),
        const Expanded(child: Text(
          'Nothing running.\nTap an activity below to start timing it.',
          style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4))),
      ]));
    }
    return GradientHeroCard(child: Row(children: [
      Container(
        width: 56, height: 56,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
        child: Text(categories.byId(running.categoryId).emoji,
            style: const TextStyle(fontSize: 28)),
      ),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NOW', style: TextStyle(color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        const SizedBox(height: 2),
        Text(categories.label(running.categoryId, running.subcategoryId),
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 17,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(_elapsed(DateTime.now().difference(running.start)),
            style: const TextStyle(color: Colors.white, fontSize: 30,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()])),
        InkWell(
          onTap: _editRunningStart,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('since ${DateFormat.Hm().format(running.start)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 13, color: Colors.white70),
            ]),
          ),
        ),
      ])),
      IconButton(
        tooltip: 'Stop',
        onPressed: _stop,
        iconSize: 30,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.navy800,
          shape: const CircleBorder(),
        ),
        icon: const Icon(Icons.stop_rounded),
      ),
    ]));
  }

  Future<void> _pick(ActivityCategory category) async {
    final running = store.running;
    final subs = category.activeSubcategories;
    String? subId;
    if (subs.isNotEmpty) {
      final choice = await showModalBottomSheet<(String?,)>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => SafeArea(child: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('${category.emoji} ${category.name}',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final s in subs) ListTile(
              leading: const Icon(Icons.subdirectory_arrow_right),
              title: Text(s.name),
              onTap: () => Navigator.pop(context, (s.id,)),
            ),
            ListTile(
              leading: const Icon(Icons.remove),
              title: Text('Just ${category.name}',
                  style: TextStyle(color: Colors.grey.shade700)),
              onTap: () => Navigator.pop(context, (null,)),
            ),
          ],
        ))),
      );
      if (choice == null) return;
      subId = choice.$1;
    }
    if (running != null && running.categoryId == category.id &&
        running.subcategoryId == subId) {
      return;
    }
    final closed = await store.switchTo(category.id, subId);
    setState(() {});
    _showUndo('Now: ${categories.label(category.id, subId)}', running, closed);
  }

  Future<void> _stop() async {
    final running = store.running!;
    final closed = await store.stop();
    setState(() {});
    _showUndo('Stopped ${categories.label(running.categoryId, running.subcategoryId)}',
        running, closed);
  }

  void _showUndo(String message, RunningActivity? previous, List<TimeEntry> closed) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () async {
            await store.undoSwitch(previous, closed);
            if (mounted) setState(() {});
          },
        ),
      ));
  }

  Future<void> _editRunningStart() async {
    final running = store.running;
    if (running == null) return;
    final t = await showTimePicker(context: context,
        initialTime: TimeOfDay.fromDateTime(running.start));
    if (t == null) return;
    final now = DateTime.now();
    var start = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    // A time later than now means the activity started yesterday.
    if (start.isAfter(now)) start = start.subtract(const Duration(days: 1));
    await store.setRunningStart(start);
    setState(() {});
  }

  // ---------------------------------------------------------------- Day tab

  Widget _dayView() {
    // Chronological, like a diary of the day.
    final entries = store.forDay(selectedDay).reversed.toList();
    final now = DateTime.now();
    final running = store.running;
    final showRunning = running != null && _isSameDay(selectedDay, now);
    final runningToday = showRunning
        ? now.difference(running.start.isAfter(_startOfDay(now))
            ? running.start : _startOfDay(now))
        : Duration.zero;
    final total = entries.fold<Duration>(runningToday, (s, e) => s + e.duration);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        PeriodSelector(
          label: DateFormat('EEE, d MMM yyyy').format(selectedDay),
          onPrevious: () => setState(() =>
              selectedDay = selectedDay.subtract(const Duration(days: 1))),
          onNext: () => setState(() =>
              selectedDay = selectedDay.add(const Duration(days: 1))),
          onLabelTap: () async {
            final d = await showDatePicker(
              context: context, firstDate: DateTime(2020),
              lastDate: DateTime(2100), initialDate: selectedDay);
            if (d != null) setState(() => selectedDay = d);
          },
        ),
        const SizedBox(height: 16),
        Row(children: [
          Text('${entries.length + (showRunning ? 1 : 0)} activities',
              style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Text('Total ${formatDuration(total)}',
              style: const TextStyle(fontWeight: FontWeight.w600,
                  color: AppColors.navy700)),
        ]),
        const SizedBox(height: 8),
        if (entries.isEmpty && !showRunning)
          Card(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text('No activities for this day.',
                style: TextStyle(color: Colors.grey.shade600))),
          )),
        for (final e in entries) _entryTile(
          categoryId: e.categoryId,
          label: e.title.isEmpty
              ? categories.label(e.categoryId, e.subcategoryId) : e.title,
          detail: e.title.isEmpty ? null : categories.label(e.categoryId, e.subcategoryId),
          times: '${DateFormat.Hm().format(e.start)} – ${DateFormat.Hm().format(e.end)}',
          duration: formatDuration(e.duration),
          onTap: () => _editEntry(e),
        ),
        if (showRunning) _entryTile(
          categoryId: running.categoryId,
          label: categories.label(running.categoryId, running.subcategoryId),
          times: '${DateFormat.Hm().format(running.start)} – now',
          duration: formatDuration(now.difference(running.start)),
          running: true,
          onTap: _editRunningStart,
        ),
      ],
    );
  }

  Widget _entryTile({required String categoryId, required String label,
      String? detail, required String times, required String duration,
      bool running = false, required VoidCallback onTap}) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: running
              ? const BorderSide(color: AppColors.navy600, width: 1.4)
              : BorderSide.none,
        ),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.navy700.withValues(alpha: 0.08),
            child: Text(categories.byId(categoryId).emoji,
                style: const TextStyle(fontSize: 22)),
          ),
          title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${detail == null ? '' : '$detail\n'}$times',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(duration, style: const TextStyle(fontWeight: FontWeight.w700,
                  color: AppColors.navy800)),
              if (running)
                const Text('in progress', style: TextStyle(fontSize: 11,
                    color: AppColors.navy600, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );

  Future<void> _editEntry([TimeEntry? existing]) async {
    // A new activity starts where the day's last one ended.
    final dayEntries = store.forDay(selectedDay);
    final result = await showDialog<EntryDialogResult>(
      context: context,
      builder: (_) => EntryDialog(
        day: selectedDay,
        categories: categories,
        existing: existing,
        suggestedStart: existing == null && dayEntries.isNotEmpty
            ? dayEntries.first.end : null,
      ),
    );
    if (result == null) return;
    if (result.deleted) {
      await store.delete(result.entry.id);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: const Text('Activity deleted'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () async {
              await store.add(result.entry);
              if (mounted) setState(() {});
            },
          ),
        ));
    } else {
      await store.update(result.entry);
      setState(() {});
    }
  }

  // ---------------------------------------------------------------- helpers

  String _elapsed(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.inHours}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  static DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.category, required this.current,
      required this.onTap});

  final ActivityCategory category;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: current ? null : Colors.white,
          gradient: current ? AppGradients.primary : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: current ? AppColors.navy700.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: current ? 10 : 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(category.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(category.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: current ? Colors.white : AppColors.navy900)),
                if (category.activeSubcategories.isNotEmpty)
                  Icon(Icons.more_horiz, size: 14,
                      color: current ? Colors.white70 : Colors.grey.shade400),
              ]),
            ),
          ),
        ),
      );
}
