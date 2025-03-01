import 'package:get/get.dart';
import 'package:billing_application/data/database_helper.dart';

import '../utils/date_time_helpers.dart';

class CreateInvoiceController extends GetxController {
  var selectedCustomer = Rxn<int>();
  var selectedCustomerDetails = Rxn<Map<String, dynamic>>();
  var invoiceDate = Rx<DateTime>(DateTime.now());
  var items = <Map<String, dynamic>>[].obs;
  var invoiceNumber = Rxn<String>();
  var paidAmount = 0.0.obs;
  var totalAmount = 0.0.obs; // Change to RxDouble
  var pendingAmount = 0.0.obs; // Change to RxDouble

  /// Adds a new invoice item.
  void addItem(Map<String, dynamic> item) {
    items.add(item);
    updateTotal(); // Update totalAmount whenever an item is added
  }

  /// Updates the total and pending amounts.
  void updateTotal() {
    totalAmount.value = items.fold(0.0, (sum, item) => sum + (item['total'] ?? 0.0));
    pendingAmount.value = totalAmount.value - paidAmount.value;
  }

  /// Updates pending amount when paid amount changes.
  void updatePaidAmount(double amount) {
    paidAmount.value = amount;
    pendingAmount.value = totalAmount.value - paidAmount.value;
  }

  /// Saves the invoice and returns a copy of the saved invoice data,
  /// including the generated invoice number.
  Future<Map<String, dynamic>> saveInvoice() async {
    String financialYear = getFinancialYear(invoiceDate.value);
    final saleData = {
      'financial_year': financialYear,
      'customer_id': selectedCustomer.value,
      'sale_date': invoiceDate.value.toIso8601String(),
      'total_amount': totalAmount.value,
    };

    // Insert the sale and its items.
    int saleId =
        await DatabaseHelper.instance.insertSaleWithItems(saleData, items, paidAmount.value);
    String newInvoiceNumber = "$saleId/$financialYear";
    invoiceNumber.value = newInvoiceNumber;

    // Prepare a copy of the invoice data.
    final savedData = {
      'selectedCustomerDetails': selectedCustomerDetails.value != null
          ? Map<String, dynamic>.from(selectedCustomerDetails.value!)
          : {},
      'invoiceDate': invoiceDate.value,
      'items': List<Map<String, dynamic>>.from(items),
      'totalAmount': totalAmount.value,
      'invoiceNumber': newInvoiceNumber,
    };

    // Clear the controller data.
    selectedCustomer.value = null;
    selectedCustomerDetails.value = null;
    invoiceDate.value = DateTime.now();
    items.clear();
    invoiceNumber.value = null;

    return savedData;
  }
}
