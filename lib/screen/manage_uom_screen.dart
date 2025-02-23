import 'package:billing_application/controller/uom_controller.dart';
import 'package:billing_application/utils/ui_utils.dart';
import 'package:billing_application/widget/create_uom_dialog.dart';
import 'package:billing_application/widget/edit_uom_dialog.dart';
import 'package:billing_application/widget/main_scaffold.dart';
import 'package:billing_application/widget/pluto_columns.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ManageUomScreen extends StatelessWidget {
  const ManageUomScreen({super.key});

  List<PlutoRow> _buildRows(UomController controller) {
    return controller.uoms.map((uom) {
      return PlutoRow(cells: {
        'srNo': PlutoCell(value: ''),
        'name': PlutoCell(value: uom['name'] ?? ''),
        'actions': PlutoCell(value: ''),
        'data': PlutoCell(value: uom),
      });
    }).toList();
  }

  void _showDeleteConfirmation(UomController controller, int uomId) {
    Get.defaultDialog(
      title: 'Delete UOM',
      middleText: 'Are you sure you want to delete this UOM?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteUom(uomId);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UomController uomController = Get.put(UomController());

    final List<PlutoColumn> columns = [
      getPlutoSrNoColumn(),
      PlutoColumn(
        title: 'Name',
        field: 'name',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      getPlutoActionColumn(
          onEdit: (rowData) => Get.dialog(EditUomDialog(uom: rowData)),
          onDelete: (rowData) =>
              _showDeleteConfirmation(uomController, rowData['id'])),
    ];

    return MainScaffold(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New UOM Button.
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await Get.dialog(const CreateUomDialog());
                    uomController.loadUoms();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add UOM"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // If data is not loaded, show a loader.
            Expanded(
              child: Obx(() {
                if (uomController.isLoading.isTrue) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (uomController.uoms.isEmpty) {
                  return const Center(child: Text("No Uoms found"));
                }

                // Build rows from controller data.
                final rows = _buildRows(uomController);
                // Update grid rows if grid is loaded.
                if (uomController.gridStateManager.value != null) {
                  uomController.gridStateManager.value!.removeAllRows();
                  uomController.gridStateManager.value!.appendRows(rows);
                  uomController.gridStateManager.value!.notifyListeners();
                }
                return PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    uomController.gridStateManager.value = event.stateManager;
                    uomController.gridStateManager.value!.setShowColumnFilter(true);
                    uomController.gridStateManager.value!
                        .setPageSize(10, notify: false);
                    uomController.gridStateManager.value!
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
