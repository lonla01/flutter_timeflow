import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_store.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_widgets.dart';

/// Removing a category or subcategory here never touches existing entries:
/// it is archived so past days and reports keep showing its name.
class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key, required this.store});
  final CategoryStore store;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const GradientAppBar(title: 'Categories'),
        floatingActionButton: GradientFab(
            onPressed: () => _editCategory(context), label: 'New category'),
        body: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final categories = store.active;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (final c in categories) _CategoryCard(
                  category: c,
                  onEdit: () => _editCategory(context, c),
                  onDelete: () => _deleteCategory(context, c, categories.length),
                  onAddSub: () => _addSubcategory(context, c),
                  onRenameSub: (s) => _renameSubcategory(context, c, s),
                  onDeleteSub: (s) => _deleteSubcategory(context, c, s),
                ),
              ],
            );
          },
        ),
      );

  Future<void> _editCategory(BuildContext context, [ActivityCategory? existing]) async {
    final result = await showDialog<(String, String)>(
        context: context, builder: (_) => _CategoryDialog(existing: existing));
    if (result == null) return;
    final (name, emoji) = result;
    if (existing == null) {
      await store.addCategory(name, emoji);
    } else {
      await store.updateCategory(existing.id, name: name, emoji: emoji);
    }
  }

  Future<void> _deleteCategory(BuildContext context, ActivityCategory c, int activeCount) async {
    if (activeCount <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('At least one category must remain.')));
      return;
    }
    if (await _confirm(context, 'Delete this category?',
        '"${c.name}" and its subcategories will no longer be offered. '
        'Activities already logged in it are kept.')) {
      await store.deleteCategory(c.id);
    }
  }

  Future<void> _addSubcategory(BuildContext context, ActivityCategory c) async {
    final name = await _promptName(context, 'New subcategory of ${c.name}');
    if (name != null) await store.addSubcategory(c.id, name);
  }

  Future<void> _renameSubcategory(BuildContext context, ActivityCategory c, Subcategory s) async {
    final name = await _promptName(context, 'Rename subcategory', initial: s.name);
    if (name != null) await store.renameSubcategory(c.id, s.id, name);
  }

  Future<void> _deleteSubcategory(BuildContext context, ActivityCategory c, Subcategory s) async {
    if (await _confirm(context, 'Delete this subcategory?',
        '"${s.name}" will no longer be offered. '
        'Activities already logged in it are kept.')) {
      await store.deleteSubcategory(c.id, s.id);
    }
  }

  Future<String?> _promptName(BuildContext context, String title, {String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Name'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    final trimmed = name?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  Future<bool> _confirm(BuildContext context, String title, String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete')),
          ],
        ),
      ) ?? false;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onEdit,
      required this.onDelete, required this.onAddSub, required this.onRenameSub,
      required this.onDeleteSub});

  final ActivityCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddSub;
  final ValueChanged<Subcategory> onRenameSub;
  final ValueChanged<Subcategory> onDeleteSub;

  @override
  Widget build(BuildContext context) {
    final subs = category.activeSubcategories;
    return Card(clipBehavior: Clip.antiAlias, child: ExpansionTile(
      key: PageStorageKey(category.id),
      shape: const Border(),
      collapsedShape: const Border(),
      iconColor: AppColors.navy700,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.navy700.withValues(alpha: 0.08),
        child: Text(category.emoji, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subs.isEmpty ? 'No subcategories'
            : subs.map((s) => s.name).join(' · '),
        maxLines: 1, overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      children: [
        for (final s in subs) ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 40),
          leading: const Icon(Icons.subdirectory_arrow_right, size: 18),
          title: Text(s.name, style: const TextStyle(fontSize: 15)),
          onTap: () => onRenameSub(s),
          trailing: IconButton(
            tooltip: 'Delete subcategory',
            icon: Icon(Icons.close, size: 20, color: Colors.grey.shade500),
            onPressed: () => onDeleteSub(s),
          ),
        ),
        Row(children: [
          TextButton.icon(onPressed: onAddSub, icon: const Icon(Icons.add),
              label: const Text('Subcategory')),
          const Spacer(),
          IconButton(tooltip: 'Edit category', onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, color: AppColors.navy700)),
          IconButton(tooltip: 'Delete category', onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400)),
        ]),
      ],
    ));
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.existing});
  final ActivityCategory? existing;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final name = TextEditingController(text: widget.existing?.name ?? '');
  late final emoji = TextEditingController(text: widget.existing?.emoji ?? '📌');

  @override
  void dispose() {
    name.dispose(); emoji.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.existing == null ? 'New category' : 'Edit category'),
        content: Row(children: [
          SizedBox(width: 72, child: TextField(
            controller: emoji,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22),
            decoration: const InputDecoration(labelText: 'Icon'),
          )),
          const SizedBox(width: 12),
          Expanded(child: TextField(
            controller: name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (_) => setState(() {}),
          )),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: name.text.trim().isEmpty ? null : () => Navigator.pop(context, (
              name.text.trim(),
              emoji.text.trim().isEmpty ? '📌' : emoji.text.trim(),
            )),
            child: const Text('Save'),
          ),
        ],
      );
}
