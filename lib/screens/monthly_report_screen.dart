import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/time_entry.dart';
import '../services/time_store.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_widgets.dart';

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
      appBar: const GradientAppBar(title: 'Monthly report'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        PeriodSelector(
          label: DateFormat('MMMM yyyy').format(month),
          onPrevious: () => setState(() =>
              month = DateTime(month.year, month.month - 1)),
          onNext: () => setState(() =>
              month = DateTime(month.year, month.month + 1)),
        ),
        const SizedBox(height: 16),
        GradientHeroCard(child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recorded this month',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            Text(formatDuration(total), style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24)),
          ],
        )),
        const SizedBox(height: 24),
        if (summary.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(32),
              child: Center(child: Text('No records for this month.'))))
        else ...[
          Text('Breakdown by category',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            SizedBox(height: 240, child: Stack(alignment: Alignment.center, children: [
              // fl_chart can't fill the centre with a gradient, so draw the
              // disc ourselves behind the transparent donut hole.
              Container(width: 100, height: 100, decoration: const BoxDecoration(
                  shape: BoxShape.circle, gradient: AppGradients.primary)),
              PieChart(PieChartData(
                sectionsSpace: 2, centerSpaceRadius: 50,
                centerSpaceColor: Colors.transparent,
                sections: [
                  for (final item in sorted)
                    PieChartSectionData(
                      value: item.value.inMinutes.toDouble(),
                      color: _colorFor(item.key),
                      title: '${(item.value.inMinutes / total.inMinutes * 100).round()}%',
                      radius: 70,
                      titleStyle: const TextStyle(fontWeight: FontWeight.bold,
                          color: Colors.white, fontSize: 12),
                    ),
                ],
              )),
            ])),
            const SizedBox(height: 8),
            ...sorted.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: _colorFor(item.key).withValues(alpha: 0.15),
                child: Text(item.key.emoji, style: const TextStyle(fontSize: 20)),
              ),
              title: Text(item.key.label,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    color: _colorFor(item.key),
                    value: total.inMinutes == 0 ? 0 :
                        item.value.inMinutes / total.inMinutes),
                ),
              ),
              trailing: Text(formatDuration(item.value),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            )),
          ]))),
        ],
      ]),
    );
  }

  Color _colorFor(ActivityCategory c) =>
      categoryChartColors[c.index % categoryChartColors.length];
}
