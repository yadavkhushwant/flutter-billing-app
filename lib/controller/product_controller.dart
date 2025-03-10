import 'package:billing_application/data/db_crud.dart';
import 'package:billing_application/utils/toasts.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ProductController extends GetxController {
  var isLoading = false.obs;
  var gridStateManager = Rxn<PlutoGridStateManager>();
  var products = <Map<String, dynamic>>[].obs;
  final ProductRepository productRepo = ProductRepository();

  @override
  void onInit() {
    super.onInit();
    isLoading(true);
    loadProducts().then((value) {
      isLoading(false);
    }).catchError((e) {
      debugPrint(e.toString());
      isLoading(false);
    });
  }

  /// Loads all products from the database.
  Future<void> loadProducts() async {
    var data = await productRepo.getAllProducts();
    products.assignAll(data);
  }

  /// Adds a new product.
  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> product) async {
    final newProduct = await productRepo.insertProduct(product);
    loadProducts();
    return newProduct;
  }

  /// Updates an existing product.
  Future<void> updateProduct(int id, Map<String, dynamic> product) async {
    await productRepo.updateProduct(id, product);
    loadProducts();
  }

  /// Deletes a product.
  Future<void> deleteProduct(int id) async {
    try{
      await productRepo.deleteProduct(id);
      loadProducts();
    } catch(e){
      if (e.toString().contains("FOREIGN KEY constraint failed")) {
        warningToast("Product in use, can not be deleted");
      }else{
        debugPrint(e.toString());
        errorToast("Failed to delete product");
      }
    }
  }
}
