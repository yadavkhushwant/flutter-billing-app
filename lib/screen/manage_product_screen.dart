import 'package:billing_application/controller/product_controller.dart';
import 'package:billing_application/controller/uom_controller.dart';
import 'package:billing_application/widget/button.dart';
import 'package:billing_application/widget/create_product_dialog.dart';
import 'package:billing_application/widget/edit_product_dialog.dart';
import 'package:billing_application/widget/main_scaffold.dart';
import 'package:billing_application/widget/pluto_columns.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ManageProductScreen extends StatelessWidget {
  const ManageProductScreen({super.key});

  // Helper method to lookup UOM name from uomId.
  String _getUomName(dynamic uomId, List<dynamic> uoms) {
    if (uomId == null) return '';
    try {
      final uom = uoms.firstWhere((element) => element['id'] == uomId);
      return uom['name'] ?? '';
    } catch (e) {
      return '';
    }
  }

  List<PlutoRow> _buildRows(
      ProductController controller, UomController uomController) {
    return controller.products.map((product) {
      return PlutoRow(cells: {
        'srNo': PlutoCell(value: ''),
        'name': PlutoCell(value: product['name'] ?? ''),
        'uom': PlutoCell(
            value: _getUomName(product['uom_id'], uomController.uoms)),
        'rate': PlutoCell(value: product['rate']?.toString() ?? ''),
        'actions': PlutoCell(value: ''),
        'data': PlutoCell(value: product),
      });
    }).toList();
  }

  // Displays a confirmation dialog before deleting a product.
  void _showDeleteConfirmation(ProductController controller, int productId) {
    Get.defaultDialog(
      title: 'Delete Product',
      middleText: 'Are you sure you want to delete this product?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteProduct(productId);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.put(ProductController());
    final UomController uomController = Get.put(UomController());

    final columns = <PlutoColumn>[
      getPlutoSrNoColumn(),
      PlutoColumn(
        title: 'Product Name',
        field: 'name',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'UOM',
        field: 'uom',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Rate',
        field: 'rate',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
      getPlutoActionColumn(
        onEdit: (rowData) =>
            Get.dialog(EditProductDialog(product: rowData)),
        onDelete: (rowData) => _showDeleteConfirmation(
            productController, rowData['id']),
      ),
    ];

    return MainScaffold(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Add Product" Button.
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Button(
                  onPressed: () {
                    Get.dialog(const CreateProductDialog());
                  },
                  leadingIcon: Icons.add,
                  text: "Add Product",
                ),
              ],
            ),
            const SizedBox(height: 16),
            // PlutoGrid displaying the product data.
            Expanded(
              child: Obx(() {
                if (productController.isLoading.isTrue ||
                    uomController.isLoading.isTrue) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productController.products.isEmpty) {
                  return const Center(child: Text("No products found"));
                }

                // Build PlutoGrid rows.
                final rows = _buildRows(productController, uomController);

                if (productController.gridStateManager.value != null) {
                  productController.gridStateManager.value!.removeAllRows();
                  productController.gridStateManager.value!.appendRows(rows);
                  productController.gridStateManager.value!.notifyListeners();
                }

                return PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    productController.gridStateManager.value =
                        event.stateManager;
                    productController.gridStateManager.value!
                        .setShowColumnFilter(true);
                    productController.gridStateManager.value!
                        .setPageSize(10, notify: false);
                    productController.gridStateManager.value!
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
