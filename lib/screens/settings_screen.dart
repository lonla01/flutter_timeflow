import 'package:flutter/material.dart';
import '../services/category_store.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_widgets.dart';
import 'category_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.categories});
  final CategoryStore categories;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const GradientAppBar(title: 'Settings'),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          _SettingsRow(
            icon: Icons.category_outlined,
            title: 'Categories',
            subtitle: 'Add, rename or remove categories and subcategories',
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => CategoryManagementScreen(store: categories))),
          ),
        ]),
      );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.icon, required this.title,
      required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.navy700.withValues(alpha: 0.1),
              child: Icon(icon, color: AppColors.navy700),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ])),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ]),
        ),
      ));
}
