import 'package:billing_application/data/db_crud.dart';
import 'package:billing_application/utils/toasts.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class CustomerController extends GetxController {
  var isLoading = false.obs;
  Rxn<PlutoGridStateManager> gridStateManager = Rxn<PlutoGridStateManager>();
  var customers = <Map<String, dynamic>>[].obs;
  final CustomerRepository customerRepo = CustomerRepository();

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  /// Loads all customers from the database.
  Future<void> loadCustomers() async {
    var data = await customerRepo.getAllCustomers();
    customers.assignAll(data);
  }

  /// Searches customers using the repository function.
  Future<List<Map<String, dynamic>>> searchCustomer(String searchQuery) async {
    return await customerRepo.searchCustomer(searchQuery);
  }

  /// Adds a new customer and refreshes the list.
  Future<Map<String, dynamic>> addCustomer(Map<String, dynamic> customer) async {
    try{
      final newCustomer = await customerRepo.insertCustomer(customer);
      loadCustomers(); // Refresh customer list
      successToast("Customer created successfully");
      return newCustomer; // Return the inserted customer
    } catch(e){
      if (e.toString().contains("UNIQUE constraint failed: customer.phone")) {
        warningToast("Phone number already exists");
      }else{
        debugPrint(e.toString());
        errorToast("Failed to create customer");
      }
      return {};
    }

  }

  /// Updates an existing customer.
  Future<bool> updateCustomer(int id, Map<String, dynamic> updatedData) async {
    try{
      await customerRepo.updateCustomer(id, updatedData);
      loadCustomers();
      successToast("Customer Updated successfully");
      return true;
    } catch(e){
      if (e.toString().contains("UNIQUE constraint failed: customer.phone")) {
        warningToast("Phone number already exists");
      }else{
        debugPrint(e.toString());
        errorToast("Failed to update customer");
      }
      return false;
    }

  }

  /// Deletes a customer by id.
  Future<void> deleteCustomer(int id) async {
    try{
      await customerRepo.deleteCustomer(id);
      loadCustomers();
      successToast("Customer deleted successfully");
    } catch(e){
      if (e.toString().contains("FOREIGN KEY constraint failed")) {
        warningToast("Customer in use, can not be deleted");
      }else{
        debugPrint(e.toString());
        errorToast("Failed to delete customer");
      }
    }
  }


}
