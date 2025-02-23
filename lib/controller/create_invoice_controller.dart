import 'package:get/get.dart';
import 'package:billing_application/data/database_helper.dart';

import '../utils/date_time_helpers.dart';

class CreateInvoiceController extends GetxController {
  var selectedCustomer = Rxn<int>();
  var selectedCustomerDetails = Rxn<Map<String, dynamic>>();
  var invoiceDate = Rx<DateTime>(DateTime.now());
  var items = <Map<String, dynamic>>[].obs;
  var invoiceNumber = Rxn<String>();

  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + (item['total'] ?? 0.0));

  /// Adds a new invoice item.
  void addItem(Map<String, dynamic> item) {
    items.add(item);
  }

  /// Saves the invoice and returns a copy of the saved invoice data,
  /// including the generated invoice number.
  Future<Map<String, dynamic>> saveInvoice() async {
    String financialYear = getFinancialYear(invoiceDate.value);
    final saleData = {
      'financial_year': financialYear,
      'customer_id': selectedCustomer.value,
      'sale_date': invoiceDate.value.toIso8601String(),
      'total_amount': totalAmount,
    };

    // Insert the sale and its items.
    int saleId =
        await DatabaseHelper.instance.insertSaleWithItems(saleData, items);
    String newInvoiceNumber = "$saleId/$financialYear";
    invoiceNumber.value = newInvoiceNumber;

    // Prepare a copy of the invoice data.
    final savedData = {
      'selectedCustomerDetails': selectedCustomerDetails.value != null
          ? Map<String, dynamic>.from(selectedCustomerDetails.value!)
          : {},
      'invoiceDate': invoiceDate.value,
      'items': List<Map<String, dynamic>>.from(items),
      'totalAmount': totalAmount,
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
