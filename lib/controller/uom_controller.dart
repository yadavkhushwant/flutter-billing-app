// In file: lib/controller/uom_controller.dart
import 'package:billing_application/data/db_crud.dart';
import 'package:billing_application/utils/toasts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class UomController extends GetxController {
  var isLoading = false.obs;
  Rxn<PlutoGridStateManager> gridStateManager = Rxn<PlutoGridStateManager>();
  var uoms = <Map<String, dynamic>>[].obs;
  final UOMRepository uomRepo = UOMRepository();

  @override
  void onInit() {
    super.onInit();
    isLoading(true);
    loadUoms().then((value) {
      isLoading(false);
    }).catchError((e) {
      debugPrint(e.toString());
      isLoading(false);
    });
  }

  /// Loads all UOM records.
  Future<void> loadUoms() async {
    var data = await uomRepo.getAllUOM();
    uoms.assignAll(data);
  }

  /// Adds a new UOM and refreshes the list.
  Future<void> addUom(Map<String, dynamic> uom) async {
    await uomRepo.insertUOM(uom);
    loadUoms();
  }

  /// Updates an existing UOM record.
  Future<void> updateUom(int id, Map<String, dynamic> uom) async {
    await uomRepo.updateUOM(id, uom);
    loadUoms();
  }

  /// Deletes a UOM record, showing a friendly error message if it fails.
  Future<void> deleteUom(int id) async {
    try {
      bool isUsed = await uomRepo.isUomUsed(id);

      if (isUsed) {
        warningToast("UOM in use, can not be deleted");
        return;
      }

      await uomRepo.deleteUOM(id);
      loadUoms();
    } catch (e) {
      debugPrint(e.toString());
      errorToast("Failed to delete UOM");
    }
  }

}
