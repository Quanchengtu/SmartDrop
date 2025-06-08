import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisPage extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyWaterData = [
    {'week': 'Week 1', 'usage': 120.0},
    {'week': 'Week 2', 'usage': 135.0},
    {'week': 'Week 3', 'usage': 90.0},
    {'week': 'Week 4', 'usage': 180.0},
  ];

  AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double avgUsage =
        weeklyWaterData
            .map((e) => e['usage'] as double)
            .reduce((a, b) => a + b) /
        weeklyWaterData.length;
    final bool isAnomaly = weeklyWaterData.any(
      (e) => (e['usage'] as double) > avgUsage,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('分析'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '長期用水趨勢圖（單位：mm）',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1.7,
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index >= 0 && index < weeklyWaterData.length) {
                          return Text(
                            weeklyWaterData[index]['week'],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  weeklyWaterData.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: weeklyWaterData[index]['usage'],
                        color: Colors.blueAccent,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: isAnomaly ? Colors.red[50] : Colors.green[50],
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAnomaly ? '🚨 異常用水警告' : '✅ 告警系統正常',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isAnomaly ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAnomaly
                        ? '某週用水量高於平均 (${avgUsage.toStringAsFixed(1)} mm)，請檢查灌溉系統或氣候因素。'
                        : '本月用水量皆在正常範圍內，無需擔心。',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '額外分析建議：',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '• 對比氣象變化：\n',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: '未來一週預測偏乾，建議密切留意土壤濕度。\n'),
              ],
            ),
          ),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '• 成本評估：\n',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: '過多灌溉可能導致成本增加，請注意資源配置。\n'),
              ],
            ),
          ),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '• 作物生長建議：\n',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: '建議選擇耐旱性作物因應氣候波動。\n'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
