import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/time_entry.dart';
import '../services/category_store.dart';
import '../theme/app_theme.dart';

/// What the user did in an [EntryDialog]: saved [entry], or deleted it.
typedef EntryDialogResult = ({TimeEntry entry, bool deleted});

/// Adds an activity on [day], or edits [existing] when given.
class EntryDialog extends StatefulWidget {
  const EntryDialog({super.key, required this.day, required this.categories,
      this.existing, this.suggestedStart});

  final DateTime day;
  final CategoryStore categories;
  final TimeEntry? existing;

  /// Start time for a new entry, e.g. the end of the day's last activity.
  final DateTime? suggestedStart;

  @override
  State<EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<EntryDialog> {
  late DateTime start, end;
  late ActivityCategory category;
  Subcategory? subcategory;
  late final title = TextEditingController(text: widget.existing?.title ?? '');
  late final note = TextEditingController(text: widget.existing?.note ?? '');

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      start = existing.start;
      end = existing.end;
      category = widget.categories.byId(existing.categoryId);
      subcategory = category.subcategory(existing.subcategoryId);
    } else {
      start = widget.suggestedStart ?? DateTime(
          widget.day.year, widget.day.month, widget.day.day, 9);
      end = start.add(const Duration(hours: 1));
      category = widget.categories.active.first;
    }
  }

  @override
  void dispose() {
    title.dispose(); note.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // An edited entry may use a category or subcategory that has since been
    // deleted; keep it selectable so saving doesn't silently change it.
    final categories = [
      ...widget.categories.active,
      if (category.archived) category,
    ];
    final subcategories = [
      ...category.activeSubcategories,
      if (subcategory?.archived ?? false) subcategory!,
    ];
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add activity' : 'Edit activity'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<ActivityCategory>(
          initialValue: category,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Category'),
          items: categories.map((c) => DropdownMenuItem(
            value: c, child: Text('${c.emoji} ${c.name}'))).toList(),
          onChanged: (v) => setState(() { category = v!; subcategory = null; }),
        ),
        if (subcategories.isNotEmpty) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<Subcategory?>(
            key: ValueKey(category.id),
            initialValue: subcategory,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Subcategory'),
            items: [
              const DropdownMenuItem(value: null, child: Text('None')),
              ...subcategories.map((s) =>
                  DropdownMenuItem(value: s, child: Text(s.name))),
            ],
            onChanged: (v) => setState(() => subcategory = v),
          ),
        ],
        const SizedBox(height: 12),
        TextField(controller: title,
            decoration: const InputDecoration(labelText: 'Title (optional)')),
        _timeButton('Start', start, (v) => setState(() => start = v)),
        _timeButton('End', end, (v) => setState(() => end = v)),
        if (!end.isAfter(start))
          Text('End must be after start.',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.5)),
        const SizedBox(height: 8),
        TextField(controller: note, maxLines: 2,
            decoration: const InputDecoration(labelText: 'Note (optional)')),
      ])),
      actions: [
        if (widget.existing != null)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
            onPressed: () => Navigator.pop(context,
                (entry: widget.existing!, deleted: true)),
            child: const Text('Delete'),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: end.isAfter(start) ? () => Navigator.pop(context, (
            entry: TimeEntry(
              id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
              start: start, end: end,
              categoryId: category.id, subcategoryId: subcategory?.id,
              title: title.text.trim(), note: note.text.trim(),
            ),
            deleted: false,
          )) : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _timeButton(String label, DateTime value, ValueChanged<DateTime> changed) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        subtitle: Text(DateFormat.Hm().format(value)),
        trailing: const Icon(Icons.schedule, color: AppColors.navy600),
        onTap: () async {
          final t = await showTimePicker(context: context,
              initialTime: TimeOfDay.fromDateTime(value));
          if (t != null) {
            changed(DateTime(value.year, value.month, value.day, t.hour, t.minute));
          }
        },
      );
}
