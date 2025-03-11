import 'package:billing_application/data/db_crud.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  var isLoading = false.obs;
  var monthlySales = <int, double>{}.obs; // {month: salesAmount}
  var topSellingProducts = <Map<String, dynamic>>[].obs;
  var dailySales = <Map<String, dynamic>>[].obs; // Observable list

  final SalesReportRepository salesRepo = SalesReportRepository();

  /// Loads sales data for the last 6 months.
  Future<void> loadLastSixMonthsSales() async {
    try {
      isLoading.value = true;
      var now = DateTime.now();
      Map<int, double> salesData = {};

      for (int i = 5; i >= 0; i--) {
        var date = DateTime(now.year, now.month - i, 1);
        double totalSales = await salesRepo.getTotalSalesByMonthYear(
          month: date.month,
          year: date.year,
        );
        salesData[date.month] = totalSales;
      }

      monthlySales.value = salesData;
    } catch (e) {
      debugPrint("Error loading sales graph data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchTopSellingProducts() async {
    topSellingProducts.value = await salesRepo.getTopSellingProducts();
  }

  Future<void> fetchDailySales() async {
    dailySales.value = await salesRepo.fetchDailySales();
    print(dailySales);
  }

  @override
  void onInit() {
    super.onInit();
    loadLastSixMonthsSales();
    fetchTopSellingProducts();
    fetchDailySales();
  }
}
