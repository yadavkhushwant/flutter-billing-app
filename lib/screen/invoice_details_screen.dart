import 'package:billing_application/controller/customer_controller.dart';
import 'package:billing_application/controller/invoice_details_controller.dart';
import 'package:billing_application/controller/product_controller.dart';
import 'package:billing_application/widget/input_decoration.dart';
import 'package:billing_application/widget/main_scaffold.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key});

  // Helper method to extract customer details.
  dynamic _getCustomerDetails(dynamic customerId, List<dynamic> customerList) {
    if (customerId == null) return {};
    try {
      return customerList.firstWhere((element) => element['id'] == customerId);
    } catch (e) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve invoice data passed via Get.arguments.
    final Map<String, dynamic> invoiceData =
    Get.arguments as Map<String, dynamic>;

    // Initialize controllers.
    final InvoiceDetailController invoiceDetailController =
    Get.put(InvoiceDetailController());
    final CustomerController customerController = Get.put(CustomerController());
    final ProductController productController = Get.put(ProductController());

    // Set the invoice data and load its items.
    invoiceDetailController.invoice.value = invoiceData;
    invoiceDetailController.loadInvoiceDetails(invoiceData['id']);

    // Controllers for inline form fields.
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController rateController = TextEditingController();
    final Rxn<int> selectedProductId = Rxn<int>();
    final Rxn<String> selectedProductName = Rxn<String>();
    final selectedItemMap = RxMap<String, dynamic>();

    // Retrieve customer details.
    final customer = _getCustomerDetails(
        invoiceData['customer_id'], customerController.customers);

    return MainScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Invoice and Customer Details side by side.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Invoice Details Card.
                  Expanded(
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Obx(() {
                          double totalAmount = invoiceDetailController.items.fold(
                              0.0,
                                  (sum, item) =>
                              sum +
                                  (item['total'] is num
                                      ? (item['total'] as num).toDouble()
                                      : 0.0));
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Invoice Number: ${invoiceData['invoice_number']}",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Sale Date: ${invoiceData['sale_date']}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Total Amount: \$${totalAmount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Customer Details Card.
                  Expanded(
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Customer Details",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text("Name: ${customer['name'] ?? ''}",
                                style: const TextStyle(fontSize: 16)),
                            Text("Locality: ${customer['locality'] ?? ''}",
                                style: const TextStyle(fontSize: 16)),
                            Text("City: ${customer['city'] ?? ''}",
                                style: const TextStyle(fontSize: 16)),
                            Text("State: ${customer['state'] ?? ''}",
                                style: const TextStyle(fontSize: 16)),
                            Text("Email: ${customer['email'] ?? ''}",
                                style: const TextStyle(fontSize: 16)),
                            Text("Phone: ${customer['phone'] ?? ''}",
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Add Product Section: placed below the header cards.
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        if (productController.products.isEmpty) {
                          return const Text("No products available.");
                        }
                        return DropdownSearch<Map<String, dynamic>>(
                          selectedItem: selectedItemMap.isNotEmpty ? selectedItemMap : null,
                          items: (filter, sortOption) =>
                              productController.products.toList(),
                          compareFn: (item1, item2) => item1['id'] == item2['id'],
                            decoratorProps:DropDownDecoratorProps(
                              decoration: getInputDecoration('Product' )
                            ),
                          popupProps: PopupProps.menu(showSearchBox: true),
                          onChanged: (product) {
                            if (product != null) {
                              selectedItemMap.value = product;
                              selectedProductId.value = product['id'] as int;
                              selectedProductName.value =
                              product['name'] as String;
                            }
                          },
                          itemAsString: (product) => product?['name'] ?? '',
                        );
                      }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: quantityController,
                        decoration: getInputDecoration("Quantity"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: rateController,
                        decoration: getInputDecoration("Rate"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: Colors.green, size: 32),
                      onPressed: () {
                        double quantity =
                            double.tryParse(quantityController.text) ?? 0;
                        double rate =
                            double.tryParse(rateController.text) ?? 0;
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
                          invoiceDetailController.addItem(newItem);
                          // Clear fields for next entry.
                          selectedItemMap.value = {};
                          selectedProductId.value = null;
                          selectedProductName.value = null;
                          quantityController.clear();
                          rateController.clear();
                        } else {
                          Get.snackbar("Error", "Invalid item details",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Invoice Items List.
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  if (invoiceDetailController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (invoiceDetailController.items.isEmpty) {
                    return const Text("No items added.");
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: invoiceDetailController.items.length,
                    separatorBuilder: (context, index) =>
                    const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = invoiceDetailController.items[index];
                      return ListTile(
                        title: Text(item['product_name'] ?? '',
                            style: const TextStyle(fontSize: 16)),
                        subtitle: Text(
                            "Qty: ${item['quantity']}  Rate: ${item['rate']}  Total: ${item['total']}",
                            style: const TextStyle(fontSize: 14)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            invoiceDetailController.removeItemAt(index);
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            // Save Changes Button.
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                  backgroundColor: Colors.green,
                ),
                onPressed: () async {
                  await invoiceDetailController.saveChanges();
                  Get.snackbar("Success", "Invoice updated",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
