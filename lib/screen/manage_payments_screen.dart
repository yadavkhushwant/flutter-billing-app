import 'package:billing_application/controller/payment_controller.dart';
import 'package:billing_application/widget/create_payment_dialog.dart';
import 'package:billing_application/widget/edit_payment_dialog.dart';
import 'package:billing_application/widget/main_scaffold.dart';
import 'package:billing_application/widget/pluto_columns.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ManagePaymentScreen extends StatelessWidget {
  const ManagePaymentScreen({super.key});

  List<PlutoRow> _buildRows(PaymentController controller) {
    return controller.payments.map((payment) {
      return PlutoRow(cells: {
        'srNo': PlutoCell(value: ''),
        'customer': PlutoCell(value: payment['customer_id'] ?? ''),
        'paymentDate': PlutoCell(value: payment['payment_date'] ?? ''),
        'amount': PlutoCell(value: payment['amount']?.toString() ?? ''),
        'paymentReference': PlutoCell(value: payment['payment_reference'] ?? ''),
        'notes': PlutoCell(value: payment['notes'] ?? ''),
        'actions': PlutoCell(value: ''),
        'data': PlutoCell(value: payment),
      });
    }).toList();
  }

  void _showDeleteConfirmation(PaymentController controller, int paymentId) {
    Get.defaultDialog(
      title: 'Delete Payment',
      middleText: 'Are you sure you want to delete this payment?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deletePayment(paymentId);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final PaymentController paymentController = Get.put(PaymentController());

    final List<PlutoColumn> columns = [
      getPlutoSrNoColumn(),
      PlutoColumn(
        title: 'Customer',
        field: 'customer',
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
        title: 'Payment Date',
        field: 'paymentDate',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Reference',
        field: 'paymentReference',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Notes',
        field: 'notes',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      getPlutoActionColumn(
        onEdit: (rowData) => Get.dialog(EditPaymentDialog(payment: rowData)),
        onDelete: (rowData) =>
            _showDeleteConfirmation(paymentController, rowData['id']),
      ),
    ];

    return MainScaffold(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters row: customer, month, year, and a toggle for "show all" payments.
            Obx(() {
              return Row(
                children: [
                  // Customer Dropdown.
                  DropdownButton<int?>(
                    value: paymentController.selectedCustomerId.value,
                    hint: const Text("All Customers"),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text("All Customers"),
                      ),
                      ...paymentController.customers.map((customer) {
                        return DropdownMenuItem<int>(
                          value: customer['id'],
                          child: Text(customer['name']),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      paymentController.selectedCustomerId.value = value;
                      paymentController.loadPayments();
                    },
                  ),
                  const SizedBox(width: 16),
                  // Month Dropdown – show if no customer filter or when not in "show all" mode.
                  if (paymentController.selectedCustomerId.value == null ||
                      !paymentController.showAllForCustomer.value)
                    DropdownButton<int>(
                      value: paymentController.selectedMonth.value,
                      items: List.generate(12, (index) => index + 1)
                          .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text("Month: $m"),
                      ))
                          .toList(),
                      onChanged: (val) {
                        paymentController.selectedMonth.value = val!;
                        paymentController.loadPayments();
                      },
                    ),
                  const SizedBox(width: 16),
                  // Year Dropdown – show if no customer filter or when not in "show all" mode.
                  if (paymentController.selectedCustomerId.value == null ||
                      !paymentController.showAllForCustomer.value)
                    DropdownButton<int>(
                      value: paymentController.selectedYear.value,
                      items: List.generate(
                          5, (index) => DateTime.now().year - index)
                          .map((y) => DropdownMenuItem(
                        value: y,
                        child: Text("Year: $y"),
                      ))
                          .toList(),
                      onChanged: (val) {
                        paymentController.selectedYear.value = val!;
                        paymentController.loadPayments();
                      },
                    ),
                  const SizedBox(width: 16),
                  // Checkbox for "Show All" payments when a customer is selected.
                  if (paymentController.selectedCustomerId.value != null)
                    Row(
                      children: [
                        const Text("Show All"),
                        Obx(() => Checkbox(
                          value: paymentController.showAllForCustomer.value,
                          onChanged: (val) {
                            paymentController.showAllForCustomer.value = val!;
                            paymentController.loadPayments();
                          },
                        )),
                      ],
                    ),
                  const Spacer(),
                  // "Add Payment" Button.
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Get.dialog(const CreatePaymentDialog());
                      paymentController.loadPayments();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Payment"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[900],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            // PlutoGrid to display payments.
            Expanded(
              child: Obx(() {
                if (paymentController.isLoading.isTrue) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (paymentController.payments.isEmpty) {
                  return const Center(child: Text("No payments found"));
                }

                final rows = _buildRows(paymentController);
                if (paymentController.gridStateManager.value != null) {
                  paymentController.gridStateManager.value!.removeAllRows();
                  paymentController.gridStateManager.value!.appendRows(rows);
                  paymentController.gridStateManager.value!.notifyListeners();
                }
                return PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    paymentController.gridStateManager.value = event.stateManager;
                    paymentController.gridStateManager.value!
                        .setShowColumnFilter(true);
                    paymentController.gridStateManager.value!
                        .setPageSize(10, notify: false);
                    paymentController.gridStateManager.value!
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
