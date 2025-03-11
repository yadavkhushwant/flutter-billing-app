import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/dashboard_controller.dart';

class TopSellingProductsChart extends StatelessWidget {
  const TopSellingProductsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();

    return Obx(() {
      if (dashboardController.topSellingProducts.isEmpty) {
        return const Center(child: Text("No sales data available"));
      }

      final data = dashboardController.topSellingProducts;

      // Calculate total quantity sold for percentage calculation
      double totalQuantity = data.fold(0, (sum, item) => sum + item['total_quantity']);

      // Generate unique colors for each section
      List<Color> sectionColors = List.generate(
        data.length,
        (index) => Colors.primaries[index % Colors.primaries.length].withOpacity(0.8),
      );

      // Convert data into PieChartSectionData
      List<PieChartSectionData> sections = data.asMap().entries.map((entry) {
        int index = entry.key;
        var item = entry.value;
        double percentage = (item['total_quantity'] / totalQuantity) * 100;
        return PieChartSectionData(
          color: sectionColors[index],
          value: item['total_quantity'].toDouble(),
          title: '${percentage.toStringAsFixed(1)}%', // Show percentage inside chart
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        );
      }).toList();

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              width: 250,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(width: 20), // Spacing between chart and legend
            // Legend on the right side
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: data.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: sectionColors[index],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item['product_name'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }
}
