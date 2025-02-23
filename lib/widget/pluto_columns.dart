import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

PlutoColumn getPlutoSrNoColumn() {
  return PlutoColumn(
    title: 'S.No',
    field: 'srNo',
    type: PlutoColumnType.text(),
    enableEditingMode: false,
    renderer: (PlutoColumnRendererContext context) {
      final int currentPage = context.stateManager.page;
      final int pageSize = context.stateManager.pageSize;
      final int serialNumber =
          ((currentPage - 1) * pageSize) + context.rowIdx + 1;
      return Text(serialNumber.toString());
    },
  );
}

PlutoColumn getPlutoActionColumn({
  void Function(Map<String, dynamic> rowData)? onEdit,
  void Function(Map<String, dynamic> rowData)? onDelete,
}) {
  return PlutoColumn(
    title: 'Actions',
    field: 'actions',
    type: PlutoColumnType.text(),
    enableEditingMode: false,
    renderer: (PlutoColumnRendererContext context) {
      final Map<String, dynamic>? rowData =
          context.row.cells['data']?.value as Map<String, dynamic>?;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 16),
              onPressed: () {
                if (rowData != null) {
                  onEdit(rowData);
                }
              },
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 16),
              onPressed: () {
                if (rowData != null) {
                  onDelete(rowData);
                }
              },
            ),
        ],
      );
    },
  );
}
