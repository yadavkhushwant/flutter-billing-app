import 'package:billing_application/controller/uom_controller.dart';
import 'package:billing_application/utils/data_helpers.dart';
import 'package:billing_application/utils/print_invoice.dart';
import 'package:billing_application/widget/create_product_dialog.dart';
import 'package:billing_application/widget/info_text.dart';
import 'package:billing_application/widget/input_decoration.dart';
import 'package:billing_application/widget/main_scaffold.dart';
import 'package:billing_application/widget/table_column.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:billing_application/controller/create_invoice_controller.dart';
import 'package:billing_application/controller/customer_controller.dart';
import 'package:billing_application/controller/product_controller.dart';
import 'package:billing_application/widget/create_customer_dialog.dart';

class CreateInvoiceScreen extends StatelessWidget {
  const CreateInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are available.
    final CreateInvoiceController invoiceController =
    Get.put(CreateInvoiceController());
    final CustomerController customerController = Get.put(CustomerController());
    final ProductController productController = Get.put(ProductController());
    final UomController uomController = Get.put(UomController());

    // Controllers for inline invoice item form.
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController rateController = TextEditingController();

    // Reactive variables for selected product in the invoice item form.
    final Rxn<int> selectedProductId = Rxn<int>();
    final Rxn<String> selectedProductName = Rxn<String>();

    return MainScaffold(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Invoice Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Invoice Details",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  // Invoice Date Picker
                  Obx(() {
                    return Row(
                      children: [
                        const Text("Invoice Date: "),
                        Text(
                          "${invoiceController.invoiceDate.value.toLocal()}"
                              .split(' ')[0],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: invoiceController.invoiceDate.value,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              invoiceController.invoiceDate.value = picked;
                            }
                          },
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
              // Customer Selection Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Obx(() {
                    return Expanded(
                        child: DropdownSearch<Map<String, dynamic>>(
                          selectedItem:
                          invoiceController.selectedCustomerDetails.value,
                          items: (filter, sortOption) {
                            return customerController.customers.toList();
                          },
                          compareFn: (item1, item2) => item1['id'] == item2['id'],
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                          ),
                          decoratorProps: DropDownDecoratorProps(
                              decoration: getInputDecoration('Customer')),
                          onChanged: (customer) {
                            if (customer != null) {
                              invoiceController.selectedCustomer.value =
                              customer['id'] as int;
                              invoiceController.selectedCustomerDetails.value =
                                  customer;
                            }
                          },
                          itemAsString: (customer) {
                            return "${customer['name']} - ${customer['phone'] ?? 'No Phone'} - ${customer['locality'] ?? 'No Locality'}";
                          },
                        ));
                  }),
                  const SizedBox(width: 16),
                  // New Customer Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Open the create customer dialog.
                      // Assume the dialog returns the newly created customer data.
                      final newCustomer =
                      await Get.dialog<Map<String, dynamic>>(
                          const CreateCustomerDialog());
                      if (newCustomer != null) {
                        // Refresh the customer list. (Do not await if loadCustomers returns void.)
                        await customerController.loadCustomers();
                        invoiceController.selectedCustomer.value =
                        newCustomer['id'] as int;
                        invoiceController.selectedCustomerDetails.value =
                            newCustomer;
                      }
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text("New Customer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[900],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Show all details of the selected customer
              Obx(() {
                final customer = invoiceController.selectedCustomerDetails.value;
                if (customer == null) return const SizedBox();
                return Container(
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                );
              }),

              const SizedBox(height: 24),
              // Section: Add Invoice Item
              const Text(
                "Add Invoice Item",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Inside your "Add Invoice Item" Container in CreateInvoiceScreen
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Row containing the Product Dropdown and the New Product button.
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            if (productController.products.isEmpty) {
                              return const Text("No products available");
                            }
                            var selectedProduct =
                            selectedProductId.value == null
                                ? null
                                : getProductDetails(selectedProductId.value,
                                productController.products.toList());
                            return DropdownSearch<Map<String, dynamic>>(
                              selectedItem: selectedProduct,
                              items: (filter, sortOption) =>
                                  productController.products.toList(),
                              compareFn: (item1, item2) =>
                              item1['id'] == item2['id'],
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                              ),
                              decoratorProps: DropDownDecoratorProps(
                                  decoration: getInputDecoration('Product')),
                              onChanged: (product) {
                                if (product != null) {
                                  selectedProductId.value =
                                  product['id'] as int;
                                  selectedProductName.value =
                                      product['name'] ?? '';
                                  rateController.text =
                                      (product['rate'] ?? '').toString();
                                }
                              },
                              itemAsString: (product) {
                                return product['name'] ?? "";
                              },
                            );
                          }),
                        ),
                        const SizedBox(width: 16),
                        // New Product Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Open the create product dialog.
                            final newProduct =
                            await Get.dialog<Map<String, dynamic>>(
                              const CreateProductDialog(),
                            );
                            if (newProduct != null) {
                              // Refresh the product list.
                              await productController.loadProducts();
                              // Automatically select the newly created product.
                              selectedProductId.value = newProduct['id'] as int;
                              selectedProductName.value =
                              newProduct['name'] as String;
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("New Product"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo[900],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Quantity and Rate fields in a Row
                    Row(
                      children: [
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
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Button to add invoice item
                    ElevatedButton(
                      onPressed: () {
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
                          invoiceController.addItem(newItem);
                          // Clear inline form fields for next entry.
                          selectedProductId.value = null;
                          selectedProductName.value = null;
                          quantityController.clear();
                          rateController.clear();
                        } else {
                          Get.snackbar("Error",
                              "Please fill in all invoice item details correctly.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                      ),
                      child: const Text("Add Item"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // List of Invoice Items
              const Text(
                "Invoice Items:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Obx(() {
                if (invoiceController.items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        "No items added.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                            columnSpacing: 24,
                            horizontalMargin: 12,
                            headingRowHeight: 48,
                            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                            dividerThickness: 0.5,
                            columns: [
                              buildTableColumn('S.No'),
                              buildTableColumn('Product'),
                              buildTableColumn('Quantity'),
                              buildTableColumn('Rate'),
                              buildTableColumn('Total'),
                              DataColumn( label: SizedBox(width: 48)),
                            ],
                            rows: List<DataRow>.generate(
                              invoiceController.items.length,
                                  (index) {
                                final item = invoiceController.items[index];
                                return DataRow(
                                  color: WidgetStateProperty.resolveWith<Color?>(
                                        (Set<WidgetState> states) {
                                      if (index.isEven) {
                                        return Colors.grey.shade50;
                                      }
                                      return null;
                                    },
                                  ),
                                  cells: [
                                    DataCell(Text('${index + 1}')),
                                    DataCell(Text(item['product_name'] ?? '-')),
                                    DataCell(Text('${item['quantity']}')),
                                    DataCell(Text('${item['rate']}')),
                                    DataCell(Text('${item['total']}')),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          invoiceController.items.removeAt(index);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),


              const SizedBox(height: 24),
              // Total Amount display
              Row(
                children: [
                  Expanded(
                    child: Obx(() => TextFormField(
                      decoration: getInputDecoration("Total Amount"),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                          text: invoiceController.totalAmount.value
                              .toStringAsFixed(2)),
                      enabled: false,
                    )),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: getInputDecoration("Paid Amount"),
                      keyboardType: TextInputType.number,
                      controller: invoiceController.paidAmountController,
                      onChanged: (value) {
                        int paid = int.tryParse(value) ?? 0;
                        invoiceController.updatePaidAmount(paid);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => TextFormField(
                      decoration: getInputDecoration("Pending Amount"),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                          text: invoiceController.pendingAmount.value
                              .toStringAsFixed(2)),
                      enabled: false,
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Save Invoice Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (invoiceController.selectedCustomer.value == null ||
                        invoiceController.items.isEmpty) {
                      Get.snackbar(
                        "Error",
                        "Please select a customer and add at least one invoice item.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    await invoiceController.saveInvoice();
                    Get.snackbar(
                      "Success",
                      "Invoice created successfully!",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                    // Optionally, navigate back or clear the form.
                  },
                  style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Save Invoice"),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (invoiceController.selectedCustomer.value == null ||
                        invoiceController.items.isEmpty) {
                      Get.snackbar(
                        "Error",
                        "Please select a customer and add at least one invoice item.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    // Save the invoice and capture the returned data.
                    final savedInvoiceData =
                    await invoiceController.saveInvoice();

                    Get.snackbar(
                      "Success",
                      "Invoice created successfully!",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );

                    // Now print the invoice using the saved data copy.
                    await generateInvoicePdf(savedInvoiceData);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("Save & Print Invoice"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



