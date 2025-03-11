import 'package:billing_application/controller/dashboard_controller.dart';
import 'package:billing_application/widget/daily_sales_chart.dart';
import 'package:billing_application/widget/main_scaffold.dart';
import 'package:billing_application/widget/monthly_sales_graph.dart';
import 'package:billing_application/widget/top_selling_items_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DashboardController());

    return MainScaffold(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Responsive Layout for Charts
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isWideScreen = constraints.maxWidth > 800;
                  return isWideScreen
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded( child: _buildChartWithTitle( "Daily Sales", const DailySalesChart())),
                            const SizedBox(width: 16),
                            Expanded( child: _buildChartWithTitle( "Top Selling Products", const TopSellingProductsChart())),
                          ],
                        )
                      : Column(
                          children: [
                            _buildChartWithTitle(
                                "Daily Sales", const DailySalesChart()),
                            const SizedBox(height: 16),
                            _buildChartWithTitle("Top Selling Products",
                                const TopSellingProductsChart()),
                          ],
                        );
                },
              ),

              const SizedBox(height: 8),

              // Title for Monthly Sales Graph
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  "Last 6 Months Sales",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const MonthlySalesGraph(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to wrap chart with title
  Widget _buildChartWithTitle(String title, Widget chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 300,
          child: chart,
        ),
      ],
    );
  }
}
