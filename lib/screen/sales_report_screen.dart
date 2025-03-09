import 'package:billing_application/controller/customer_controller.dart';
import 'package:billing_application/controller/sales_report_controller.dart';
import 'package:billing_application/utils/date_time_helpers.dart';
import 'package:billing_application/utils/print_invoice.dart';
import 'package:billing_application/widget/input_decoration.dart';
import 'package:billing_application/widget/pluto_columns.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:billing_application/widget/main_scaffold.dart';

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  // Displays a confirmation dialog before deleting a product.
  void _showDeleteConfirmation(
      SalesReportController controller, int productId) {
    Get.defaultDialog(
      title: 'Delete Product',
      middleText: 'Are you sure you want to delete this sale entry?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteSale(productId);
        Get.back();
      },
    );
  }

  dynamic _getCustomerDetails(dynamic customerId, List<dynamic> customerList) {
    if (customerId == null) return {};
    try {
      return customerList.firstWhere((element) => element['id'] == customerId);
    } catch (e) {
      return {};
    }
  }

  // Build PlutoGrid rows from sales data.
  List<PlutoRow> _buildRows(
      SalesReportController controller, CustomerController customerController) {
    return controller.sales.map((sale) {
      var customer = _getCustomerDetails(sale['customer_id'], customerController.customers);
      return PlutoRow(cells: {
        'action': PlutoCell(value: ''),
        'srNo': PlutoCell(value: ''),
        'invoiceNumber': PlutoCell(value: sale['invoice_number'] ?? ''),
        'saleDate': PlutoCell(value: sale['sale_date'] ?? ''),
        'totalAmount': PlutoCell(value: sale['total_amount']?.toString() ?? ''),
        'customerName': PlutoCell(value: customer['name']?.toString() ?? ''),
        'customerLocality': PlutoCell(value: customer['locality']?.toString() ?? ''),
        'customerMobile': PlutoCell(value: customer['phone']?.toString() ?? ''),
        'actions': PlutoCell(value: ''),
        'data': PlutoCell(value: sale),
      });
    }).toList();
  }

  Future<void> printInvoice(dynamic rowData,SalesReportController salesController, CustomerController customerController) async {

    var customer = _getCustomerDetails( rowData['customer_id'], customerController.customers);
    var items = await salesController.getSalesItems(rowData['id']);

    var invoiceDate = rowData['sale_date'] ?? "";
    var invoiceNumber = rowData['invoice_number'] ?? "";
    var totalAmount = rowData['total_amount'] ?? "";

    final printData = {
      'selectedCustomerDetails': Map<String, dynamic>.from(customer),
      'invoiceDate': invoiceDate,
      'items': List<Map<String, dynamic>>.from(items),
      'totalAmount': totalAmount,
      'invoiceNumber': invoiceNumber,
    };
    await generateInvoicePdf(printData);

  }

  @override
  Widget build(BuildContext context) {
    final salesReportController = Get.put(SalesReportController());
    final customerController = Get.put(CustomerController());

    final List<PlutoColumn> columns = [
      PlutoColumn(
        title: 'Action',
        field: 'action',
        width: 120,
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        renderer: (PlutoColumnRendererContext context) {
          final Map<String, dynamic>? rowData =
              context.row.cells['data']?.value as Map<String, dynamic>?;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.print, color: Colors.blue, size: 16),
                onPressed: () {
                  if (rowData != null) {
                    printInvoice(rowData, salesReportController, customerController);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue, size: 16),
                onPressed: () {
                  if (rowData != null) {
                    Get.toNamed('/invoice-details', arguments: rowData);
                  }
                },
              ),
            ],
          );
        },
      ),
      getPlutoSrNoColumn(),
      PlutoColumn(
        title: 'Invoice No',
        field: 'invoiceNumber',
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
        field: 'totalAmount',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Customer Name',
        field: 'customerName',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Customer Locality',
        field: 'customerLocality',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Customer Mobile',
        field: 'customerMobile',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      getPlutoActionColumn(
        onDelete: (rowData) =>
            _showDeleteConfirmation(salesReportController, rowData['id']),
      ),
    ];

    return MainScaffold(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for month and year dropdowns.
            Row(
              children: [
                // Month Dropdown with InputDecoration
                Expanded(
                  child: Obx(() {
                    return DropdownButtonFormField<int>(
                      value: salesReportController.selectedMonth.value,
                      decoration: getInputDecoration("Month"),
                      items: monthNames.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value), // Show month name instead of number
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          salesReportController.updateMonthYear(
                            month: value,
                            year: salesReportController.selectedYear.value,
                          );
                        }
                      },
                    );
                  }),
                ),
                const SizedBox(width: 16),
                // Year Dropdown with InputDecoration
                Expanded(
                  child: Obx(() {
                    return DropdownButtonFormField<int>(
                      value: salesReportController.selectedYear.value,
                      decoration: getInputDecoration("Year"),
                      items: yearList.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()), // Show year as text
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          salesReportController.updateMonthYear(
                            month: salesReportController.selectedMonth.value,
                            year: value,
                          );
                        }
                      },
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 16),
            // PlutoGrid to display sales data.
            Expanded(
              child: Obx(() {
                if (salesReportController.isLoading.value ||
                    customerController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (salesReportController.sales.isEmpty) {
                  return const Center(child: Text("No sales found"));
                }
                final rows =
                    _buildRows(salesReportController, customerController);
                return PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    salesReportController.gridStateManager.value =
                        event.stateManager;
                    salesReportController.gridStateManager.value!
                        .setShowColumnFilter(true);
                    salesReportController.gridStateManager.value!
                        .setPageSize(10, notify: false);
                    salesReportController.gridStateManager.value!
                        .setPage(1, notify: false);
                  },
                  configuration: const PlutoGridConfiguration(),
                  createFooter: (PlutoGridStateManager stateManager) {
                    return PlutoPagination(stateManager);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
