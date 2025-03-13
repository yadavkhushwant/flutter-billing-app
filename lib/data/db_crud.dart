import 'package:billing_application/data/database_helper.dart';
import 'package:intl/intl.dart';

/// Repository for performing CRUD operations on the Customer table.
class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Map<String, dynamic>> insertCustomer(Map<String, dynamic> customer) async {
    final db = await _dbHelper.database;
    int id = await db.insert('customer', customer);

    // Fetch the newly inserted customer using its ID
    final List<Map<String, dynamic>> result =
    await db.query('customer', where: 'id = ?', whereArgs: [id]);

    return result.isNotEmpty ? result.first : {}; // Return the new customer
  }

  /// Retrieves all customers.
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    final db = await _dbHelper.database;
    return await db.query('customer');
  }

  /// Retrieves a customer by id.
  Future<Map<String, dynamic>?> getCustomerById(int id) async {
    final db = await _dbHelper.database;
    final results =
        await db.query('customer', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  /// Updates an existing customer.
  Future<int> updateCustomer(int id, Map<String, dynamic> customer) async {
    final db = await _dbHelper.database;
    return await db
        .update('customer', customer, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes a customer by id.
  Future<int> deleteCustomer(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('customer', where: 'id = ?', whereArgs: [id]);
  }

  /// search customer on various parameters
  Future<List<Map<String, dynamic>>> searchCustomer(String searchQuery) async {
    final db = await _dbHelper.database;
    // Use the searchQuery wrapped in '%' to allow partial matches.
    final query = '%$searchQuery%';
    return await db.query(
      'customer',
      where:
          "name LIKE ? OR phone LIKE ? OR locality LIKE ? OR city LIKE ? OR state LIKE ? OR pin LIKE ? OR email LIKE ?",
      whereArgs: [query, query, query, query, query, query, query],
    );
  }
}

/// Repository for performing CRUD operations on the UOM table.
class UOMRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Inserts a new UOM record.
  Future<int> insertUOM(Map<String, dynamic> uom) async {
    final db = await _dbHelper.database;
    return await db.insert('uom', uom);
  }

  /// Retrieves all UOM records.
  Future<List<Map<String, dynamic>>> getAllUOM() async {
    final db = await _dbHelper.database;
    return await db.query('uom');
  }

  /// Retrieves a UOM by id.
  Future<Map<String, dynamic>?> getUOMById(int id) async {
    final db = await _dbHelper.database;
    final results = await db.query('uom', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  /// Updates an existing UOM record.
  Future<int> updateUOM(int id, Map<String, dynamic> uom) async {
    final db = await _dbHelper.database;
    return await db.update('uom', uom, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes a UOM record by id.
  Future<int> deleteUOM(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('uom', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isUomUsed(int uomId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT COUNT(*) as count FROM products WHERE uom_id = ?", [uomId]
    );

    int count = result.first["count"] ?? 0;
    return count > 0; // Returns true if UOM is used
  }

  Future<String> getUomName(int productId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT u.name as uom
      FROM products p
      LEFT JOIN uom u ON p.uom_id = u.id
      WHERE p.id = ?
    ''', [productId]);

    return result.isNotEmpty ? result.first['uom'] as String : 'N/A';
  }
}

/// Repository for performing CRUD operations on the Products table.
class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Inserts a new product.
  Future<Map<String, dynamic>> insertProduct(Map<String, dynamic> product) async {
    final db = await _dbHelper.database;
    int id = await db.insert('products', product);
    // Fetch the newly inserted customer using its ID
    final List<Map<String, dynamic>> result =
    await db.query('products', where: 'id = ?', whereArgs: [id]);

    return result.isNotEmpty ? result.first : {}; // Return the new customer

  }

  /// Retrieves all products.
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await _dbHelper.database;
    return await db.query('products');
  }

  /// Retrieves a product by id.
  Future<Map<String, dynamic>?> getProductById(int id) async {
    final db = await _dbHelper.database;
    final results =
        await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  /// Updates an existing product.
  Future<int> updateProduct(int id, Map<String, dynamic> product) async {
    final db = await _dbHelper.database;
    return await db
        .update('products', product, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes a product by id.
  Future<int> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}

class SalesReportRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Retrieves all sales for the given month and year.
  Future<List<Map<String, dynamic>>> getSalesByMonthYear({
    required int month,
    required int year,
  }) async {
    final db = await _dbHelper.database;
    final monthStr = month.toString().padLeft(2, '0'); // "01", "02", etc.
    final yearStr = year.toString();
    return await db.rawQuery('''
      SELECT * FROM sales 
      WHERE strftime('%m', sale_date) = ? 
      AND strftime('%Y', sale_date) = ? 
      ORDER BY sale_date DESC
    ''', [monthStr, yearStr]);
  }

  /// Retrieves all sales for a customer with optional filters for month and year.
  Future<List<Map<String, dynamic>>> getSalesForCustomer({
    required int customerId,
    int? month,
    int? year,
  }) async {
    final db = await _dbHelper.database;
    final List<String> whereClauses = ['customer_id = ?'];
    final List<dynamic> whereArgs = [customerId];

    // If month filter is provided, add it to the query.
    if (month != null) {
      String monthStr = month.toString().padLeft(2, '0');
      whereClauses.add("strftime('%m', sale_date) = ?");
      whereArgs.add(monthStr);
    }

    // If year filter is provided, add it to the query.
    if (year != null) {
      String yearStr = year.toString();
      whereClauses.add("strftime('%Y', sale_date) = ?");
      whereArgs.add(yearStr);
    }

    final String whereString = whereClauses.join(' AND ');
    return await db.query('sales', where: whereString, whereArgs: whereArgs, orderBy: 'sale_date DESC');
  }


  /// Deletes a sale by id.
  Future<int> deleteSale(int id) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      await txn.delete('sale_items', where: 'sale_id = ?', whereArgs: [id]);
      return await txn.delete('sales', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<Map<String, dynamic>>> getSalesItems(dynamic saleId) async {
    final db = await _dbHelper.database;
    return await db.query('sale_items', where: 'sale_id = ?', whereArgs: [saleId]);
  }

  /// Updates the invoice items for the given invoice ID.
  /// Deletes all existing sale_items for this invoice and then inserts the new ones.
  Future<void> updateInvoiceItems(int invoiceId, List<Map<String, dynamic>> items) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // Remove all existing sale_items for this invoice.
      await txn.delete('sale_items', where: 'sale_id = ?', whereArgs: [invoiceId]);

      double totalAmount = 0.0;

      // Insert each new item and compute total amount.
      for (var item in items) {
        final mutableItem = Map<String, dynamic>.from(item);
        mutableItem['sale_id'] = invoiceId;
        await txn.insert('sale_items', mutableItem);

        if (mutableItem['total'] != null) {
          totalAmount += (mutableItem['total'] as num).toDouble();
        }
      }

      // Update the total amount in the sales table.
      await txn.update(
        'sales',
        {'total_amount': totalAmount},
        where: 'id = ?',
        whereArgs: [invoiceId],
      );
    });
  }

  /// Retrieves the total sales amount for a given month and year.
  Future<double> getTotalSalesByMonthYear({
    required int month,
    required int year,
  }) async {
    final db = await _dbHelper.database;
    final monthStr = month.toString().padLeft(2, '0');
    final yearStr = year.toString();

    final result = await db.rawQuery('''
      SELECT SUM(total_amount) as total_sales
      FROM sales
      WHERE strftime('%m', sale_date) = ? 
      AND strftime('%Y', sale_date) = ?
    ''', [monthStr, yearStr]);

    return (result.first['total_sales'] as num?)?.toDouble() ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
    SELECT product_name, SUM(quantity) AS total_quantity
    FROM sale_items
    GROUP BY product_name
    ORDER BY total_quantity DESC
    LIMIT 10
  ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchDailySales2() async {
    final db = await DatabaseHelper.instance.database;

    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT sale_date, SUM(total_amount) AS total_sales
      FROM sales
      WHERE sale_date >= date('now', '-7 days') -- Fetch last 7 days sales
      GROUP BY sale_date
      ORDER BY sale_date;
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchDailySales() async {
    final db = await DatabaseHelper.instance.database;

    List<Map<String, dynamic>> result = await db.rawQuery('''
  SELECT DATE(sale_date) AS sale_date, COALESCE(SUM(total_amount), 0) AS total_sales
  FROM sales
  WHERE DATE(sale_date) >= DATE('now', '-6 days')
  GROUP BY DATE(sale_date)
  ORDER BY DATE(sale_date);
''');

    // Ensure we have all 7 days
    List<Map<String, dynamic>> finalSales = [];
    DateTime today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      DateTime day = today.subtract(Duration(days: i));
      String formattedDate = DateFormat('yyyy-MM-dd').format(day);

      // Find sales data for this date
      var existingData = result.firstWhere(
            (row) => row['sale_date'] == formattedDate,
        orElse: () => {'sale_date': formattedDate, 'total_sales': 0.0},
      );

      finalSales.add(existingData);
    }

    return finalSales;
  }


}

class SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Map<String, dynamic>?> getSettings() async {
    final db = await _dbHelper.database;
    final results = await db.query('settings');
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> saveSettings(Map<String, dynamic> settings) async {
    final db = await _dbHelper.database;
    final existing = await getSettings();
    if (existing != null) {
      // Update the existing record.
      return await db.update(
        'settings',
        settings,
        where: 'id = ?',
        whereArgs: [existing['id']],
      );
    } else {
      // Insert a new record.
      return await db.insert('settings', settings);
    }
  }
}

class PaymentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> addPayment(Map<String, dynamic> paymentData) async {
    final db = await _dbHelper.database;
    return await db.insert('customer_payments', paymentData);
  }

  /// Retrieves payments with optional month/year filters.
  Future<List<Map<String, dynamic>>> getPayments({
    int? month,
    int? year,
  }) async {
    final db = await _dbHelper.database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];
    if (month != null) {
      String monthStr = month.toString().padLeft(2, '0');
      whereClauses.add("strftime('%m', payment_date) = ?");
      whereArgs.add(monthStr);
    }
    if (year != null) {
      String yearStr = year.toString();
      whereClauses.add("strftime('%Y', payment_date) = ?");
      whereArgs.add(yearStr);
    }
    String? whereString =
    whereClauses.isNotEmpty ? whereClauses.join(" AND ") : null;
    return await db.query('customer_payments',
        where: whereString, whereArgs: whereArgs, orderBy: 'payment_date DESC');
  }

  /// Retrieves payments for a given customer, with optional month/year filters.
  Future<List<Map<String, dynamic>>> getPaymentsForCustomer({
    required int customerId,
    int? month,
    int? year,
  }) async {
    final db = await _dbHelper.database;
    List<String> whereClauses = ['customer_id = ?'];
    List<dynamic> whereArgs = [customerId];
    if (month != null) {
      String monthStr = month.toString().padLeft(2, '0');
      whereClauses.add("strftime('%m', payment_date) = ?");
      whereArgs.add(monthStr);
    }
    if (year != null) {
      String yearStr = year.toString();
      whereClauses.add("strftime('%Y', payment_date) = ?");
      whereArgs.add(yearStr);
    }
    String whereString = whereClauses.join(" AND ");
    return await db.query('customer_payments',
        where: whereString, whereArgs: whereArgs, orderBy: 'payment_date DESC');
  }

  Future<int> updatePayment(int id, Map<String, dynamic> payment) async {
    final db = await _dbHelper.database;
    return await db
        .update('customer_payments', payment, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePayment(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('customer_payments', where: 'id = ?', whereArgs: [id]);
  }
}

