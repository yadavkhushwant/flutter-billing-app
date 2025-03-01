import 'package:billing_application/data/db_crud.dart';
import 'package:get/get.dart';

class InvoiceDetailController extends GetxController {
  var invoice = Rxn<Map<String, dynamic>>();
  var items = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  final SalesReportRepository salesRepo = SalesReportRepository();

  /// Loads the invoice items for the given invoice ID.
  Future<void> loadInvoiceDetails(int invoiceId) async {
    isLoading(true);
    var loadedItems = await salesRepo.getSalesItems(invoiceId);
    items.assignAll(loadedItems);
    isLoading(false);
  }

  /// Adds a new invoice item to the local list.
  Future<void> addItem(Map<String, dynamic> newItem) async {
    items.add(newItem);
  }

  /// Removes an item at the given index.
  Future<void> removeItemAt(int index) async {
    items.removeAt(index);
  }

  /// Saves changes to the invoice.
  ///
  /// You may implement this method to update the database.
  Future<void> saveChanges() async {
    await salesRepo.updateInvoiceItems(invoice.value!['id'], items);
  }
}
