import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/time_store.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = TimeStore();
  await store.load();
  runApp(TimeFlowApp(store: store));
}

class TimeFlowApp extends StatelessWidget {
  const TimeFlowApp({super.key, required this.store});
  final TimeStore store;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'TimeFlow',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: HomeScreen(store: store),
      );
}

String formatDuration(Duration d) {
  final h = d.inMinutes ~/ 60;
  final m = d.inMinutes % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}
