import 'package:billing_application/controller/customer_controller.dart';
import 'package:billing_application/utils/toasts.dart';
import 'package:billing_application/widget/create_customer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:billing_application/data/database_helper.dart';

import '../utils/date_time_helpers.dart';
import '../utils/print_invoice.dart';

class CreateInvoiceController extends GetxController {
  var selectedCustomer = Rxn<int>();
  var selectedCustomerDetails = Rxn<Map<String, dynamic>>();
  var invoiceDate = Rx<DateTime>(DateTime.now());
  var items = <Map<String, dynamic>>[].obs;
  var invoiceNumber = Rxn<String>();
  var paidAmount = Rxn<int>();
  var totalAmount = 0.0.obs;
  var pendingAmount = 0.0.obs;

  final Rxn<int> selectedProductId = Rxn<int>();
  final Rxn<String> selectedProductName = Rxn<String>();

  final TextEditingController paidAmountController = TextEditingController(text: "0");
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    ever(paidAmount, (int? value) {
      if (paidAmountController.text != (value?.toString() ?? "0")) {
        paidAmountController.text = (value?.toString() ?? "0");
        paidAmountController.selection = TextSelection.fromPosition(
          TextPosition(offset: paidAmountController.text.length),
        );
      }
    });
  }

  /// Adds a new invoice item.
  void _addItem(Map<String, dynamic> item) {
    items.add(item);
    updateTotal(); // Update totalAmount whenever an item is added
  }

  void addItem(){
    double quantity =
        double.tryParse(quantityController.text) ?? 0.0;
    double rate =
        double.tryParse(rateController.text) ?? 0.0;
    if (selectedProductId.value != null &&
        quantity > 0 &&
        rate > 0) {
      double total = quantity * rate;
      final newItem = {
        'product_id': selectedProductId.value,
        'product_name': selectedProductName.value,
        'quantity': quantity,
        'rate': rate,
        'total': total,
      };
      _addItem(newItem);
      // Clear inline form fields for next entry.
      selectedProductId.value = null;
      selectedProductName.value = null;
      quantityController.clear();
      rateController.clear();
    } else {
      errorToast("Please fill in all invoice item details correctly");
    }
  }

  /// Updates the total and pending amounts.
  void updateTotal() {
    totalAmount.value = items.fold(0.0, (sum, item) => sum + (item['total'] ?? 0.0));
    pendingAmount.value = totalAmount.value - (paidAmount.value ?? 0);
  }

  /// Updates pending amount when paid amount changes.
  void updatePaidAmount(int amount) {
    paidAmount.value = amount;
    pendingAmount.value = totalAmount.value - (paidAmount.value ?? 0);
  }

  void createNewCustomer(CustomerController customerController) async {
    final newCustomer =
        await Get.dialog<Map<String, dynamic>>(
        const CreateCustomerDialog());
    if (newCustomer != null) {
      // Refresh the customer list. (Do not await if loadCustomers returns void.)
      await customerController.loadCustomers();
      selectedCustomer.value = newCustomer['id'] as int;
      selectedCustomerDetails.value = newCustomer;
    }
  }

  /// Saves the invoice and returns a copy of the saved invoice data,
  /// including the generated invoice number.
  Future<Map<String, dynamic>> _saveInvoice() async {
    String financialYear = getFinancialYear(invoiceDate.value);
    final saleData = {
      'financial_year': financialYear,
      'customer_id': selectedCustomer.value,
      'sale_date': invoiceDate.value.toIso8601String(),
      'total_amount': totalAmount.value,
    };

    // Insert the sale and its items.
    int saleId = await DatabaseHelper.instance
        .insertSaleWithItems(saleData, items, (paidAmount.value ?? 0));
    String newInvoiceNumber = "$saleId/$financialYear";
    invoiceNumber.value = newInvoiceNumber;

    // Prepare a copy of the invoice data.
    final savedData = {
      'selectedCustomerDetails': selectedCustomerDetails.value != null
          ? Map<String, dynamic>.from(selectedCustomerDetails.value!)
          : {},
      'invoiceDate': getFormattedDate(invoiceDate.value.toString()),
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
    paidAmount.value = 0;
    totalAmount.value = 0.0;
    pendingAmount.value = 0.0;
    return savedData;
  }

  Future<void> saveInvoice() async {
    if (selectedCustomer.value == null || items.isEmpty) {
      errorToast("Please select a customer and add at least one invoice item");
      return;
    }
    await _saveInvoice();
    successToast("Invoice created successfully!");
  }

  Future<void> saveAndPrintInvoice() async {
    if (selectedCustomer.value == null || items.isEmpty) {
      errorToast("Please select a customer and add at least one invoice item");
      return;
    }

    // Save the invoice and capture the returned data.
    final savedInvoiceData = await _saveInvoice();

    successToast("Invoice created successfully!");
    // Now print the invoice using the saved data copy.
    await generateInvoicePdf(savedInvoiceData);
  }
}
