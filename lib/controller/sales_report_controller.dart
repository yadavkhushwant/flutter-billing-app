import 'package:billing_application/data/db_crud.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class SalesReportController extends GetxController {
  var isLoading = false.obs;
  var sales = <Map<String, dynamic>>[].obs;
  var gridStateManager = Rxn<PlutoGridStateManager>();

  // Dropdown selections for month and year.
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;

  final salesRepo = SalesReportRepository();

  /// Loads sales data for the selected month and year.
  Future<void> loadSales() async {
    final data = await salesRepo.getSalesByMonthYear(
      month: selectedMonth.value,
      year: selectedYear.value,
    );
    sales.assignAll(data);
  }

  Future<List<Map<String, dynamic>>> getSalesForCustomer({ required int customerId, int? month, int? year}) async {
    return salesRepo.getSalesForCustomer(customerId: customerId, month: month, year: year);
  }

  /// Update the selected month and/or year and reload the sales.
  void updateMonthYear({required int month, required int year}) {
    selectedMonth.value = month;
    selectedYear.value = year;
    loadSales();
  }

  Future<void> deleteSale(int id) async {
    await salesRepo.deleteSale(id);
    await loadSales();
  }

  Future<List<Map<String, dynamic>>> getSalesItems(dynamic saleId){
    return salesRepo.getSalesItems(saleId);
  }

  @override
  void onInit() {
    super.onInit();
    isLoading(true);
    loadSales().then((value) {
      isLoading(false);
    }).catchError((e) {
      debugPrint(e.toString());
      isLoading(false);
    });
  }
}
