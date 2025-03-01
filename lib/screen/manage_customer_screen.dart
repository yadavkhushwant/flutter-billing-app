import 'package:billing_application/controller/customer_controller.dart';
import 'package:billing_application/widget/create_customer_dialog.dart';
import 'package:billing_application/widget/edit_customer_dialog.dart';
import 'package:billing_application/widget/main_scaffold.dart';
import 'package:billing_application/widget/pluto_columns.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ManageCustomerScreen extends StatelessWidget {
  final CustomerController customerController = Get.put(CustomerController());

  ManageCustomerScreen({super.key});

  List<PlutoRow> _buildRows() {
    return customerController.customers.map((customer) {
      return PlutoRow(cells: {
        'action': PlutoCell(value: ''),
        'srNo': PlutoCell(value: ''),
        'name': PlutoCell(value: customer['name'] ?? ''),
        'locality': PlutoCell(value: customer['locality'] ?? ''),
        'city': PlutoCell(value: customer['city'] ?? ''),
        'state': PlutoCell(value: customer['state'] ?? ''),
        'pin': PlutoCell(value: customer['pin'] ?? ''),
        'phone': PlutoCell(value: customer['phone'] ?? ''),
        'email': PlutoCell(value: customer['email'] ?? ''),
        'actions': PlutoCell(value: ''),
        'data': PlutoCell(value: customer),
      });
    }).toList();
  }

  void _showDeleteConfirmation(CustomerController controller, int customerId) {
    Get.defaultDialog(
      title: 'Delete Customer',
      middleText: 'Are you sure you want to delete this customer?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteCustomer(customerId);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<PlutoColumn> columns = [
      PlutoColumn(
        title: 'Action',
        field: 'action',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        renderer: (PlutoColumnRendererContext context) {
          final Map<String, dynamic>? rowData =
          context.row.cells['data']?.value as Map<String, dynamic>?;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue, size: 16),
                onPressed: () {
                  if (rowData != null) {
                    Get.toNamed('/customer-details', arguments: rowData);
                  }
                },
              ),
            ],
          );
        },
      ),
      getPlutoSrNoColumn(),
      PlutoColumn(
        title: 'Name',
        field: 'name',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Locality',
        field: 'locality',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'City',
        field: 'city',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'State',
        field: 'state',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Pin',
        field: 'pin',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Phone',
        field: 'phone',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Email',
        field: 'email',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      getPlutoActionColumn(
        onEdit: (rowData) =>
            Get.dialog(EditCustomerDialog(customer: rowData)),
        onDelete: (rowData) => _showDeleteConfirmation(
            customerController, rowData['id']),
      ),
    ];

    return MainScaffold(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await Get.dialog(const CreateCustomerDialog());
                    customerController.loadCustomers();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Customer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (customerController.isLoading.isTrue) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (customerController.customers.isEmpty) {
                  return const Center(child: Text("No customers found"));
                }

                final rows = _buildRows();
                if (customerController.gridStateManager.value != null) {
                  customerController.gridStateManager.value!.removeAllRows();
                  customerController.gridStateManager.value!.appendRows(rows);
                  customerController.gridStateManager.value!.notifyListeners();
                }
                return PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    customerController.gridStateManager.value = event.stateManager;
                    customerController.gridStateManager.value!
                        .setShowColumnFilter(true);
                    customerController.gridStateManager.value!
                        .setPageSize(10, notify: false);
                    customerController.gridStateManager.value!
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