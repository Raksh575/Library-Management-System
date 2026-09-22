import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Library Insights",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text("Books Borrowed (Last 6 Months)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 4, color: Colors.indigo)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5, color: Colors.indigo)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 3, color: Colors.indigo)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 6, color: Colors.indigo)]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 7, color: Colors.indigo)]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 5, color: Colors.indigo)]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Category Breakdown",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(sections: [
                  PieChartSectionData(
                      value: 35,
                      color: Colors.indigo,
                      title: "Tech\n35%",
                      radius: 60,
                      titleStyle: const TextStyle(color: Colors.white)),
                  PieChartSectionData(
                      value: 25,
                      color: Colors.blueAccent,
                      title: "Science\n25%",
                      radius: 55,
                      titleStyle: const TextStyle(color: Colors.white)),
                  PieChartSectionData(
                      value: 20,
                      color: Colors.green,
                      title: "Fiction\n20%",
                      radius: 50,
                      titleStyle: const TextStyle(color: Colors.white)),
                  PieChartSectionData(
                      value: 20,
                      color: Colors.orange,
                      title: "Others\n20%",
                      radius: 45,
                      titleStyle: const TextStyle(color: Colors.white)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
