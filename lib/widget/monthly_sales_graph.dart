import 'package:billing_application/controller/dashboard_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MonthlySalesGraph extends StatelessWidget {
  const MonthlySalesGraph({super.key});

  /// Returns abbreviated month name from month number.
  String getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
      default:
        return "";
    }
  }

  /// Combines month abbreviation and year for display.
  String getMonthLabel(DateTime date) {
    return "${getMonthAbbreviation(date.month)}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();

    return Obx(() {
      if (dashboardController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (dashboardController.monthlySales.isEmpty) {
        return const Center(child: Text("No sales data available"));
      }

      // Build a list for the last 6 months.
      final now = DateTime.now();
      List<Map<String, dynamic>> lastSixMonthsData = [];
      for (int i = 5; i >= 0; i--) {
        // DateTime constructor auto-adjusts the year if month goes below 1.
        final date = DateTime(now.year, now.month - i, 1);
        // Use the controller’s data if available; otherwise default to 0.
        double salesValue = dashboardController.monthlySales[date.month] ?? 0.0;
        lastSixMonthsData.add({
          'date': date,
          'sales': salesValue,
        });
      }

      // Create chart spots: x-axis as indices (0 to 5), y-axis as sales.
      final spots = <FlSpot>[];
      for (int i = 0; i < lastSixMonthsData.length; i++) {
        spots.add(
          FlSpot(i.toDouble(), lastSixMonthsData[i]['sales']),
        );
      }

      // Dynamically compute maxY based on sales values with a minimum of 50.
      final double maxSales = spots.isEmpty
          ? 100
          : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
      final double computedMaxY = (maxSales * 1.2) < 50 ? 50 : maxSales * 1.2;

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  // Show the sales amount on the left.
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (computedMaxY / 5).ceilToDouble(),
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            meta.formattedValue,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                          ),
                        );
                      },
                    ),
                  ),

                  // Hide the right titles.
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  // Bottom axis: force an interval of 1 so all indices are labeled.
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= lastSixMonthsData.length) {
                          return const SizedBox();
                        }
                        final date = lastSixMonthsData[index]['date'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            getMonthLabel(date),
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Colors.black54),
                    bottom: BorderSide(color: Colors.black54),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.blue,
                    dotData: FlDotData(show: true),
                  ),
                ],
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: computedMaxY,
              ),
            ),
          ),
        ),
      );
    });
  }
}
