import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class CategoryStore extends ChangeNotifier {
  static const _key = 'categories_v1';
  final List<ActivityCategory> _categories = [];
  SharedPreferencesAsync? _prefs;

  /// Every category ever created, archived ones included, in display order.
  List<ActivityCategory> get all => List.unmodifiable(_categories);

  List<ActivityCategory> get active => _categories.where((c) => !c.archived).toList();

  Future<void> load() async {
    _prefs = SharedPreferencesAsync();
    final raw = await _prefs!.getString(_key);
    _categories.clear();
    if (raw == null || raw.isEmpty) {
      _categories.addAll(defaultCategories());
      await _save();
      return;
    }
    _categories.addAll((jsonDecode(raw) as List<dynamic>)
        .map((c) => ActivityCategory.fromJson(c as Map<String, dynamic>)));
  }

  /// Falls back to a placeholder so an entry whose category is missing
  /// from storage still renders.
  ActivityCategory byId(String id) => _categories.firstWhere((c) => c.id == id,
      orElse: () => ActivityCategory(id: id, name: 'Unknown', emoji: '❓'));

  /// "Category › Subcategory", or just the category name.
  String label(String categoryId, String? subcategoryId) {
    final category = byId(categoryId);
    final sub = category.subcategory(subcategoryId);
    return sub == null ? category.name : '${category.name} › ${sub.name}';
  }

  Future<void> addCategory(String name, String emoji) async {
    _categories.add(ActivityCategory(id: _newId(), name: name, emoji: emoji));
    await _save();
  }

  Future<void> updateCategory(String id, {required String name, required String emoji}) async {
    byId(id)
      ..name = name
      ..emoji = emoji;
    await _save();
  }

  Future<void> deleteCategory(String id) async {
    byId(id).archived = true;
    await _save();
  }

  Future<void> addSubcategory(String categoryId, String name) async {
    byId(categoryId).subcategories.add(Subcategory(id: _newId(), name: name));
    await _save();
  }

  Future<void> renameSubcategory(String categoryId, String subId, String name) async {
    byId(categoryId).subcategory(subId)?.name = name;
    await _save();
  }

  Future<void> deleteSubcategory(String categoryId, String subId) async {
    byId(categoryId).subcategory(subId)?.archived = true;
    await _save();
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _save() async {
    notifyListeners();
    await _prefs!.setString(_key, jsonEncode(_categories.map((c) => c.toJson()).toList()));
  }
}
