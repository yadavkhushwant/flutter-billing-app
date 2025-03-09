import 'package:billing_application/controller/customer_controller.dart';
import 'package:billing_application/controller/invoice_details_controller.dart';
import 'package:billing_application/controller/product_controller.dart';
import 'package:billing_application/controller/uom_controller.dart';
import 'package:billing_application/utils/data_helpers.dart';
import 'package:billing_application/widget/button.dart';
import 'package:billing_application/widget/info_text.dart';
import 'package:billing_application/widget/input_decoration.dart';
import 'package:billing_application/widget/main_scaffold.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve invoice data passed via Get.arguments.
    final Map<String, dynamic> invoiceData = Get.arguments as Map<String, dynamic>;

    // Initialize controllers.
    final InvoiceDetailController invoiceDetailController = Get.put(InvoiceDetailController());
    final CustomerController customerController = Get.put(CustomerController());
    final ProductController productController = Get.put(ProductController());
    final UomController uomController = Get.put(UomController());

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
    final customer = getCustomerDetails(invoiceData['customer_id'], customerController.customers);

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
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
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
                          children: [
                            Text(
                              "Invoice Details",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo[900],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 32,
                              runSpacing: 8,
                              children: [
                                buildInfoText("Invoice Number",
                                    invoiceData['invoice_number']),
                                buildInfoText(
                                    "Sale Date", invoiceData['sale_date']),
                                buildInfoText("Total Amount",
                                    "₹${totalAmount.toStringAsFixed(2)}"),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer['name'] ?? '',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo[900],
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 32,
                          runSpacing: 8,
                          children: [
                            buildInfoText("Phone", customer['phone']),
                            buildInfoText("Email", customer['email']),
                            buildInfoText("Locality", customer['locality']),
                            buildInfoText("City", customer['city']),
                            buildInfoText("State", customer['state']),
                            buildInfoText("Pin", customer['pin']),
                          ],
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              "Add Invoice Item",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
              ),
            ),
            const SizedBox(height: 8),

            // Add Product Section: placed below the header cards.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      if (productController.products.isEmpty) {
                        return const Text("No products available.");
                      }
                      return DropdownSearch<Map<String, dynamic>>(
                        selectedItem: selectedItemMap.isNotEmpty
                            ? selectedItemMap
                            : null,
                        items: (filter, sortOption) =>
                            productController.products.toList(),
                        compareFn: (item1, item2) =>
                            item1['id'] == item2['id'],
                        decoratorProps: DropDownDecoratorProps(
                            decoration: getInputDecoration('Product')),
                        popupProps: PopupProps.menu(showSearchBox: true),
                        onChanged: (product) {
                          if (product != null) {
                            selectedItemMap.value = product;
                            selectedProductId.value = product['id'] as int;
                            selectedProductName.value =
                                product['name'] as String;
                            rateController.text = (product['rate'] ?? '').toString();
                          }
                        },
                        itemAsString: (product) => product['name'] ?? '',
                      );
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Obx(() {
                    var uomId = getProductDetails(selectedProductId.value,
                        productController.products.toList())?['uom_id'];
                    var uom = getUomDetails(uomId, uomController.uoms);
                    return TextFormField(
                      controller:
                      TextEditingController(text: uom?['name']),
                      decoration: getInputDecoration("UOM"),
                      keyboardType: TextInputType.number,
                      enabled: false,
                    );
                  })),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: rateController,
                      decoration: getInputDecoration("Rate"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: quantityController,
                      decoration: getInputDecoration("Quantity"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: Colors.green, size: 32),
                    onPressed: () {
                      double quantity =
                          double.tryParse(quantityController.text) ?? 0;
                      double rate = double.tryParse(rateController.text) ?? 0;
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
            const SizedBox(height: 24),
            // Invoice Items List (Styled like Customer & Invoice Details)
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Invoice Items",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                        ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (invoiceDetailController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (invoiceDetailController.items.isEmpty) {
                      return const Text("No items added.");
                    }

                    return Table(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columnWidths: const {
                        0: FlexColumnWidth(3), // Product Name
                        1: FlexColumnWidth(2), // Quantity
                        2: FlexColumnWidth(2), // Rate
                        3: FlexColumnWidth(2), // Total
                        4: FlexColumnWidth(1), // Actions
                      },
                      children: [
                        // Table Header
                        TableRow(
                          decoration:
                              BoxDecoration(color: Colors.blueGrey.shade100),
                          children: [
                            tableHeaderCell("Product"),
                            tableHeaderCell("Qty"),
                            tableHeaderCell("Rate"),
                            tableHeaderCell("Total"),
                            tableHeaderCell(""),
                          ],
                        ),
                        // Table Rows
                        ...invoiceDetailController.items.map((item) {
                          return TableRow(
                            children: [
                              tableCell(item['product_name'] ?? ''),
                              tableCell(item['quantity'].toString()),
                              tableCell("₹${item['rate']}"),
                              tableCell("₹${item['total']}"),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    invoiceDetailController.removeItemAt(invoiceDetailController.items.indexOf(item));
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Save Changes Button.
            Center(
              child: Button(
                leadingIcon: Icons.save,
                text: "Save Changes",
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

Widget tableHeaderCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
  );
}

Widget tableCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      textAlign: TextAlign.center,
    ),
  );
}
