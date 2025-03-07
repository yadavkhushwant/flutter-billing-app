import 'package:billing_application/controller/payment_controller.dart';
import 'package:billing_application/widget/create_payment_dialog.dart';
import 'package:billing_application/widget/edit_payment_dialog.dart';
import 'package:billing_application/widget/input_decoration.dart';
import 'package:billing_application/widget/main_scaffold.dart';
import 'package:billing_application/widget/pluto_columns.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ManagePaymentScreen extends StatelessWidget {
  const ManagePaymentScreen({super.key});

  dynamic _getCustomerDetails(dynamic customerId, List<dynamic> customerList) {
    if (customerId == null) return {};
    try {
      return customerList.firstWhere((element) => element['id'] == customerId);
    } catch (e) {
      return {};
    }
  }

  List<PlutoRow> _buildRows(PaymentController controller) {
    return controller.payments.map((payment) {
      var customer =
      _getCustomerDetails(payment['customer_id'], controller.customers);
      return PlutoRow(cells: {
        'srNo': PlutoCell(value: ''),
        'customerName': PlutoCell(value: customer['name']?.toString() ?? ''),
        'customerLocality':
        PlutoCell(value: customer['locality']?.toString() ?? ''),
        'customerMobile': PlutoCell(value: customer['phone']?.toString() ?? ''),
        'paymentDate': PlutoCell(value: payment['payment_date'] ?? ''),
        'amount': PlutoCell(value: payment['amount']?.toString() ?? ''),
        'paymentReference':
        PlutoCell(value: payment['payment_reference'] ?? ''),
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
        title: 'Customer Name',
        field: 'customerName',
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
            // Filters row: customer (using DropdownSearch), month, year, and a toggle for "show all" payments.
            Obx(() {
              var selectedCustomer = paymentController.selectedCustomerId.value == null
                  ? null
                  : _getCustomerDetails(paymentController.selectedCustomerId.value, paymentController.customers);
              return Row(
                children: [
                  // Customer Dropdown using search.
                  Expanded(
                    child: DropdownSearch<Map<String, dynamic>>(
                      selectedItem: selectedCustomer,
                      items: (filter, sortOption) => paymentController.customers.toList(),
                      compareFn: (item1, item2) => item1['id'] == item2['id'],
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                      ),
                      decoratorProps: DropDownDecoratorProps(
                          decoration: getInputDecoration('Customer', IconButton(onPressed: (){
                            paymentController.selectedCustomerId.value = null;
                            paymentController.loadPayments();
                          }, icon:Icon(Icons.clear)))
                      ),
                      onChanged: (customer) {
                        if (customer != null) {
                          paymentController.selectedCustomerId.value = customer['id'];
                        } else {
                          paymentController.selectedCustomerId.value = null;
                        }
                        paymentController.loadPayments();
                      },
                      itemAsString: (customer) {
                        return "${customer['name']} - ${customer['locality'] ?? ''}";
                      },
                    ),
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
                            paymentController.showAllForCustomer.value =
                            val!;
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
                    paymentController.gridStateManager.value =
                        event.stateManager;
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
