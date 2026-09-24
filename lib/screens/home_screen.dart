import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/time_entry.dart';
import '../services/time_store.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_widgets.dart';
import 'monthly_report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});
  final TimeStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final entries = widget.store.forDay(selectedDay);
    final total = entries.fold<Duration>(Duration.zero, (s, e) => s + e.duration);

    return Scaffold(
      appBar: GradientAppBar(
        title: 'TimeFlow',
        actions: [
          IconButton(
            tooltip: 'Monthly report',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => MonthlyReportScreen(store: widget.store))),
          ),
        ],
      ),
      floatingActionButton: GradientFab(onPressed: _addEntry, label: 'Log time'),
      body: ListView(
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
          GradientHeroCard(child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Colors.white12, shape: BoxShape.circle),
              child: const Icon(Icons.timelapse, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Recorded today',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(formatDuration(total), style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28)),
            ]),
            const Spacer(),
            Text('${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ])),
          const SizedBox(height: 20),
          if (entries.isEmpty)
            const Card(child: Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: Text(
                'No activities recorded for this day.\nTap “Log time” to start.',
                textAlign: TextAlign.center)),
            ))
          else ...[
            Text('Activities', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...entries.map((e) => Card(child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.navy700.withValues(alpha: 0.08),
                child: Text(e.category.emoji, style: const TextStyle(fontSize: 22)),
              ),
              title: Text(e.title.isEmpty ? e.category.label : e.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${DateFormat.Hm().format(e.start)} – '
                  '${DateFormat.Hm().format(e.end)}  •  ${formatDuration(e.duration)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.grey.shade500),
                onPressed: () async {
                  await widget.store.delete(e.id);
                  setState(() {});
                },
              ),
            ))),
          ],
        ],
      ),
    );
  }

  Future<void> _addEntry() async {
    final entry = await showDialog<TimeEntry>(
      context: context, builder: (_) => EntryDialog(initialDate: selectedDay));
    if (entry != null) {
      await widget.store.add(entry);
      setState(() {});
    }
  }
}

class EntryDialog extends StatefulWidget {
  const EntryDialog({super.key, required this.initialDate});
  final DateTime initialDate;

  @override
  State<EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<EntryDialog> {
  late DateTime start, end;
  ActivityCategory category = ActivityCategory.work;
  final title = TextEditingController();
  final note = TextEditingController();

  @override
  void initState() {
    super.initState();
    start = DateTime(widget.initialDate.year, widget.initialDate.month,
        widget.initialDate.day, 9);
    end = start.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    title.dispose(); note.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Log activity'),
    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      DropdownButtonFormField<ActivityCategory>(
        initialValue: category,
        decoration: const InputDecoration(labelText: 'Category'),
        items: ActivityCategory.values.map((c) => DropdownMenuItem(
          value: c, child: Text('${c.emoji} ${c.label}'))).toList(),
        onChanged: (v) => setState(() => category = v!),
      ),
      const SizedBox(height: 12),
      TextField(controller: title,
          decoration: const InputDecoration(labelText: 'Title (optional)')),
      _timeButton('Start', start, (v) => setState(() => start = v)),
      _timeButton('End', end, (v) => setState(() => end = v)),
      const SizedBox(height: 8),
      TextField(controller: note, maxLines: 2,
          decoration: const InputDecoration(labelText: 'Note (optional)')),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(
        onPressed: end.isAfter(start) ? () => Navigator.pop(context, TimeEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          start: start, end: end, category: category,
          title: title.text.trim(), note: note.text.trim(),
        )) : null,
        child: const Text('Save'),
      ),
    ],
  );

  Widget _timeButton(String label, DateTime value, ValueChanged<DateTime> changed) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        subtitle: Text(DateFormat.Hm().format(value)),
        trailing: const Icon(Icons.schedule, color: AppColors.navy600),
        onTap: () async {
          final t = await showTimePicker(context: context,
              initialTime: TimeOfDay.fromDateTime(value));
          if (t != null) changed(DateTime(value.year, value.month, value.day,
              t.hour, t.minute));
        },
      );
}
