import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = 'invoicing.db';
    return await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async {
          // Enable foreign key constraints
          await db.execute("PRAGMA foreign_keys = ON");
        },
        onCreate: _onCreate,
      ),
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create master tables.

    // Customer table (with address details broken into columns)
    await db.execute('''
    CREATE TABLE customer (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      locality TEXT,
      city TEXT,
      state TEXT,
      pin TEXT,
      phone TEXT UNIQUE,
      email TEXT
    )
  ''');

    // UOM table
    await db.execute('''
    CREATE TABLE uom (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');

    // Products table with a reference to uom.
    await db.execute('''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      uom_id INTEGER,
      rate REAL,
      FOREIGN KEY (uom_id) REFERENCES uom (id) ON DELETE RESTRICT
    )
  ''');

    // Sales table (Invoice Master) with overall invoice details.
    await db.execute('''
    CREATE TABLE sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_number TEXT,   -- New column to store the invoice number
      financial_year TEXT NOT NULL,
      customer_id INTEGER,
      sale_date TEXT,
      total_amount REAL,
      FOREIGN KEY (customer_id) REFERENCES customer (id)
  )
''');

    // Sale Items table (Line Items) to store multiple products per sale.
    await db.execute('''
    CREATE TABLE sale_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sale_id INTEGER,
      product_id INTEGER,
      product_name TEXT, 
      quantity REAL,
      rate REAL,
      total REAL,
      FOREIGN KEY (sale_id) REFERENCES sales (id),
      FOREIGN KEY (product_id) REFERENCES products (id)
    )
  ''');

    // Settings table (only one record is expected)
    await db.execute('''
    CREATE TABLE settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      business_name TEXT,
      email TEXT,
      contact_number TEXT,
      logo TEXT,
      address TEXT
    )
  ''');

    await db.execute('''
  CREATE TABLE customer_payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    payment_date TEXT,
    amount REAL,
    payment_reference TEXT, -- Text field for any reference (e.g., invoice number or manual reference)
    notes TEXT,
    FOREIGN KEY (customer_id) REFERENCES customer (id)
  )
''');

  }

  /// Inserts a complete sale (invoice) along with its line items in a transaction.
  Future<int> insertSaleWithItems(
      Map<String, dynamic> sale, List<Map<String, dynamic>> saleItems, [int paidAmount = 0]) async {
    final db = await database;
    return await db.transaction((txn) async {
      // Insert the master sale record.
      int saleId = await txn.insert('sales', sale);
      // Compute invoice number from saleId and financial year.
      String financialYear = sale['financial_year'];
      String invoiceNumber = "$saleId/$financialYear";
      // Update the sale record with the invoice number.
      await txn.update(
        'sales',
        {'invoice_number': invoiceNumber},
        where: 'id = ?',
        whereArgs: [saleId],
      );
      // Insert each sale item.
      for (var item in saleItems) {
        item['sale_id'] = saleId;
        await txn.insert('sale_items', item);
      }

      if(paidAmount > 0){
        var payment = {
          'customer_id': sale['customer_id'],
          'payment_date': DateTime.now().toIso8601String(),
          'amount': paidAmount,
          'payment_reference': invoiceNumber,
        };

        await txn.insert('customer_payments', payment);
      }

      return saleId;
    });
  }

// Additional methods to query, update, or delete data can be added here.
}
