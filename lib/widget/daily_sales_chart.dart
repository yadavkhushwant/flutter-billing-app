import 'package:billing_application/utils/date_time_helpers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/dashboard_controller.dart';

class DailySalesChart extends StatelessWidget {
  const DailySalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();

    return Obx(() {
      if (dashboardController.dailySales.isEmpty) {
        return const Center(child: Text("No sales data available"));
      }

      final data = dashboardController.dailySales;

      List<BarChartGroupData> barGroups = data.asMap().entries.map((entry) {
        int index = entry.key; // Use consecutive index (0,1,2,...)
        var item = entry.value;

        return BarChartGroupData(
          x: index, // X-axis uses consecutive numbers (0,1,2,...)
          barRods: [
            BarChartRodData(
              toY: item['total_sales'], // Sales amount
              color: Colors.blue, // Customize color
              width: 10,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      }).toList();



      return SizedBox(
        height: 300,
        width: 500,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: Padding(
            padding: const EdgeInsets.only(top: 32.0, bottom: 12.0, left: 12.0, right: 12.0),
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)
                  ),
                  topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              getFormattedDate(data[index]['sale_date'].toString()), // Show actual sale date
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),

                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false),
              ),
            ),
          ),
        ),
      );
    });
  }
}
