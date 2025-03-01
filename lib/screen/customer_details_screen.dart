import 'package:billing_application/controller/customer_details_controller.dart';
import 'package:billing_application/widget/main_scaffold.dart';
import 'package:billing_application/widget/pluto_columns.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class CustomerDetailsScreen extends StatelessWidget {
  const CustomerDetailsScreen({super.key});

  // Build PlutoGrid rows for Sales.
  List<PlutoRow> _buildSalesRows(CustomerDetailsController controller) {
    return controller.sales.map((sale) {
      return PlutoRow(cells: {
        'srNo': PlutoCell(value: ''),
        'invoice': PlutoCell(value: sale['invoice_number'] ?? ''),
        'saleDate': PlutoCell(value: sale['sale_date'] ?? ''),
        'total': PlutoCell(value: sale['total_amount']?.toString() ?? ''),
        'financialYear': PlutoCell(value: sale['financial_year'] ?? ''),
      });
    }).toList();
  }

  // Build PlutoGrid rows for Payments.
  List<PlutoRow> _buildPaymentsRows(CustomerDetailsController controller) {
    return controller.payments.map((payment) {
      return PlutoRow(cells: {
        'srNo': PlutoCell(value: ''),
        'paymentDate': PlutoCell(value: payment['payment_date'] ?? ''),
        'amount': PlutoCell(value: payment['amount']?.toString() ?? ''),
        'paymentRef': PlutoCell(value: payment['payment_reference'] ?? ''),
        'notes': PlutoCell(value: payment['notes'] ?? ''),
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get customer details passed as arguments.
    final Map<String, dynamic> customerData =
        Get.arguments as Map<String, dynamic>;
    final CustomerDetailsController controller =
        Get.put(CustomerDetailsController());
    controller.customerData.value = customerData;

    // Load the sales and payments data.
    controller.loadSalesData();
    controller.loadPaymentsData();

    // Create lists for month and year dropdowns.
    final List<int> months = List.generate(12, (index) => index + 1);
    final List<int> years =
        List.generate(10, (index) => DateTime.now().year - 5 + index);

    // Define Sales table columns.
    final List<PlutoColumn> salesColumns = [
      getPlutoSrNoColumn(),
      PlutoColumn(
        title: 'Invoice Number',
        field: 'invoice',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Sale Date',
        field: 'saleDate',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Total Amount',
        field: 'total',
        type: PlutoColumnType.number(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Financial Year',
        field: 'financialYear',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
    ];

    // Define Payments table columns.
    final List<PlutoColumn> paymentsColumns = [
      getPlutoSrNoColumn(),
      PlutoColumn(
        title: 'Payment Date',
        field: 'paymentDate',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Amount',
        field: 'amount',
        type: PlutoColumnType.number(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Payment Reference',
        field: 'paymentRef',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Notes',
        field: 'notes',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
    ];

    return MainScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Row: Year dropdown and (conditionally) Month dropdown.
            Row(
              children: [
                // Year Dropdown with "All" option.
                Obx(() {
                  return DropdownButton<int?>(
                    value: controller.selectedYear.value,
                    hint: const Text("Select Year"),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text("All"),
                      ),
                      ...years.map((year) => DropdownMenuItem<int?>(
                            value: year,
                            child: Text(year.toString()),
                          ))
                    ],
                    onChanged: (value) {
                      // When year changes, update and reload data.
                      controller.updateMonthYear(
                        month: value == null
                            ? null
                            : controller.selectedMonth.value,
                        year: value,
                      );
                    },
                  );
                }),
                const SizedBox(width: 16),
                // Only show Month dropdown if a specific year is selected.
                Obx(() {
                  if (controller.selectedYear.value == null) return Container();
                  return DropdownButton<int?>(
                    value: controller.selectedMonth.value,
                    hint: const Text("Select Month"),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text("All"),
                      ),
                      ...months.map((month) => DropdownMenuItem<int?>(
                            value: month,
                            child: Text("Month $month"),
                          ))
                    ],
                    onChanged: (value) {
                      controller.updateMonthYear(
                        month: value,
                        year: controller.selectedYear.value,
                      );
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),
            // Elegant Customer Details Card.
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Customer basic info.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerData['name'] ?? 'Customer Name',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          customerData['phone'] ?? '',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        // Additional details can be added here.
                      ],
                    ),
                    // Sales & Payments Totals.
                    Obx(() {
                      double totalSales = controller.sales.fold(0.0,
                          (prev, sale) => prev + (sale['total_amount'] ?? 0.0));
                      double totalPayments = controller.payments.fold(0.0,
                          (prev, payment) => prev + (payment['amount'] ?? 0.0));
                      double pendingAmount = totalSales - totalPayments;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Total Sales: \$${totalSales.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Total Payments: \$${totalPayments.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Pending Amount",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "\$${pendingAmount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color:
                                  pendingAmount > 0 ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Sales Table.
            Text(
              "Sales",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.isSalesLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.sales.isEmpty) {
                return const Center(
                    child:
                        Text("No sales data found for the selected period."));
              }
              final salesRows = _buildSalesRows(controller);
              if (controller.salesGridStateManager.value != null) {
                controller.salesGridStateManager.value!.removeAllRows();
                controller.salesGridStateManager.value!.appendRows(salesRows);
                controller.salesGridStateManager.value!.notifyListeners();
              }
              return SizedBox(
                height: 300,
                child: PlutoGrid(
                  columns: salesColumns,
                  rows: salesRows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    controller.salesGridStateManager.value = event.stateManager;
                    controller.salesGridStateManager.value!
                        .setShowColumnFilter(true);
                    controller.salesGridStateManager.value!
                        .setPageSize(10, notify: false);
                    controller.salesGridStateManager.value!
                        .setPage(1, notify: false);
                  },
                  configuration: const PlutoGridConfiguration(),
                  createFooter: (stateManager) {
                    return PlutoPagination(stateManager);
                  },
                ),
              );
            }),
            const SizedBox(height: 24),
            // Payments Table.
            Text(
              "Payments",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.isPaymentsLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.payments.isEmpty) {
                return const Center(
                    child: Text(
                        "No payments data found for the selected period."));
              }
              final paymentsRows = _buildPaymentsRows(controller);
              if (controller.paymentsGridStateManager.value != null) {
                controller.paymentsGridStateManager.value!.removeAllRows();
                controller.paymentsGridStateManager.value!
                    .appendRows(paymentsRows);
                controller.paymentsGridStateManager.value!.notifyListeners();
              }
              return SizedBox(
                height: 300,
                child: PlutoGrid(
                  columns: paymentsColumns,
                  rows: paymentsRows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    controller.paymentsGridStateManager.value =
                        event.stateManager;
                    controller.paymentsGridStateManager.value!
                        .setShowColumnFilter(true);
                    controller.paymentsGridStateManager.value!
                        .setPageSize(10, notify: false);
                    controller.paymentsGridStateManager.value!
                        .setPage(1, notify: false);
                  },
                  configuration: const PlutoGridConfiguration(),
                  createFooter: (stateManager) {
                    return PlutoPagination(stateManager);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
