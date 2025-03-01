import 'package:billing_application/data/db_crud.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class CustomerDetailsController extends GetxController {
  var customerData = {}.obs;
  var isSalesLoading = false.obs;
  var sales = <Map<String, dynamic>>[].obs;
  var salesGridStateManager = Rxn<PlutoGridStateManager>();

  var isPaymentsLoading = false.obs;
  var payments = <Map<String, dynamic>>[].obs;
  var paymentsGridStateManager = Rxn<PlutoGridStateManager>();

  final salesRepo = SalesReportRepository();
  final paymentsRepo = PaymentRepository();

  // Correct initialization using Rxn
  final Rxn<int> selectedMonth = Rxn<int>();
  final Rxn<int> selectedYear = Rxn<int>();

  Future<void> loadSalesData() async {
    isSalesLoading.value = true;
    final data = await salesRepo.getSalesForCustomer(
        customerId: customerData['id'],
        month: selectedMonth.value,
        year: selectedYear.value);
    sales.assignAll(data);
    isSalesLoading.value = false;
  }

  Future<void> loadPaymentsData() async {
    isPaymentsLoading.value = true;
    final data = await paymentsRepo.getPaymentsForCustomer(
        customerId: customerData['id'],
        month: selectedMonth.value,
        year: selectedYear.value);
    payments.assignAll(data);
    isPaymentsLoading.value = false;
  }

  void updateMonthYear({required int? month, required int? year}) {
    selectedYear.value = year;
    selectedMonth.value = month;
    loadSalesData();
    loadPaymentsData();
  }
}
