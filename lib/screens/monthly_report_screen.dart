import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/time_entry.dart';
import '../services/time_store.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key, required this.store});
  final TimeStore store;

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final summary = widget.store.summaryForMonth(month);
    final total = summary.values.fold<Duration>(Duration.zero, (a, b) => a + b);
    final sorted = summary.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly report')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          IconButton(onPressed: () => setState(() =>
              month = DateTime(month.year, month.month - 1)),
              icon: const Icon(Icons.chevron_left)),
          Expanded(child: Center(child: Text(DateFormat('MMMM yyyy').format(month),
              style: Theme.of(context).textTheme.titleLarge))),
          IconButton(onPressed: () => setState(() =>
              month = DateTime(month.year, month.month + 1)),
              icon: const Icon(Icons.chevron_right)),
        ]),
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recorded'),
            Text(formatDuration(total),
                style: Theme.of(context).textTheme.headlineSmall),
          ],
        ))),
        const SizedBox(height: 16),
        if (summary.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(32),
              child: Center(child: Text('No records for this month.'))))
        else ...[
          SizedBox(height: 260, child: PieChart(PieChartData(
            sectionsSpace: 2, centerSpaceRadius: 45,
            sections: [
              for (final item in sorted)
                PieChartSectionData(
                  value: item.value.inMinutes.toDouble(),
                  title: '${(item.value.inMinutes / total.inMinutes * 100).round()}%',
                  radius: 90,
                  titleStyle: const TextStyle(fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
            ],
          ))),
          const SizedBox(height: 12),
          ...sorted.map((item) => ListTile(
            leading: Text(item.key.emoji,
                style: const TextStyle(fontSize: 24)),
            title: Text(item.key.label),
            subtitle: LinearProgressIndicator(
              value: total.inMinutes == 0 ? 0 :
                  item.value.inMinutes / total.inMinutes),
            trailing: Text(formatDuration(item.value)),
          )),
        ],
      ]),
    );
  }
}
