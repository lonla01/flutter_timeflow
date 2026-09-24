import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/category_store.dart';
import 'services/time_store.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = TimeStore();
  final categories = CategoryStore();
  await Future.wait([store.load(), categories.load()]);
  runApp(TimeFlowApp(store: store, categories: categories));
}

class TimeFlowApp extends StatelessWidget {
  const TimeFlowApp({super.key, required this.store, required this.categories});
  final TimeStore store;
  final CategoryStore categories;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'TimeFlow',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: HomeScreen(store: store, categories: categories),
      );
}

String formatDuration(Duration d) {
  final h = d.inMinutes ~/ 60;
  final m = d.inMinutes % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}
