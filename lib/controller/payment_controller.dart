import 'package:billing_application/data/db_crud.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PaymentController extends GetxController {
  var isLoading = false.obs;
  Rxn<PlutoGridStateManager> gridStateManager = Rxn<PlutoGridStateManager>();
  var payments = <Map<String, dynamic>>[].obs;

  // Filter observables.
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;
  var selectedCustomerId = Rxn<int>(); // null means no customer filter
  var selectedCustomerDetails = Rxn<Map<String, dynamic>>();
  var showAllForCustomer = false.obs; // if true, show all payments for the selected customer

  // For customer dropdown – in a real app you might fetch this from a repository.
  var customers = <Map<String, dynamic>>[].obs;

  final PaymentRepository paymentRepo = PaymentRepository();
  final CustomerRepository customerRepo = CustomerRepository();

  @override
  void onInit() {
    super.onInit();
    loadCustomers(); // load available customers
    loadPayments();
  }

  Future<void> loadCustomers() async {
    var data = await customerRepo.getAllCustomers();
    customers.assignAll(data);
  }

  Future<void> loadPayments() async {
    isLoading(true);
    try {
      List<Map<String, dynamic>> data;
      if (selectedCustomerId.value != null) {
        // If a customer is selected…
        if (showAllForCustomer.value) {
          data = await paymentRepo.getPaymentsForCustomer(
            customerId: selectedCustomerId.value!,
          );
        } else {
          data = await paymentRepo.getPaymentsForCustomer(
            customerId: selectedCustomerId.value!,
            month: selectedMonth.value,
            year: selectedYear.value,
          );
        }
      } else {
        // No customer filter – show payments for the current month/year.
        data = await paymentRepo.getPayments(
          month: selectedMonth.value,
          year: selectedYear.value,
        );
      }
      payments.assignAll(data);
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading(false);
  }

  Future<void> addPayment(Map<String, dynamic> payment) async {
    await paymentRepo.addPayment(payment);
    loadPayments();
  }

  Future<void> updatePayment(int id, Map<String, dynamic> payment) async {
    await paymentRepo.updatePayment(id, payment);
    loadPayments();
  }

  Future<void> deletePayment(int id) async {
    try {
      await paymentRepo.deletePayment(id);
      loadPayments();
    } catch (e) {
      debugPrint(e.toString());
      Get.snackbar(
        "Deletion Error",
        "Failed to delete Payment",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
