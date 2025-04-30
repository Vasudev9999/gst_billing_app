import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/invoice.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gst_billing.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Products table - for saved products catalog
    await db.execute('''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      price REAL NOT NULL,
      gstRate REAL NOT NULL
    )
    ''');

    // Invoices table - for transaction history
    await db.execute('''
    CREATE TABLE invoices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoiceNumber TEXT NOT NULL,
      dateTime TEXT NOT NULL,
      products TEXT NOT NULL,
      subtotal REAL NOT NULL,
      totalCGST REAL NOT NULL,
      totalSGST REAL NOT NULL,
      totalAmount REAL NOT NULL
    )
    ''');
  }

  // Product Operations
  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    return await db.insert('products', {
      'name': product.name,
      'price': product.price,
      'gstRate': product.gstRate,
    });
  }

  Future<List<Product>> getProducts() async {
    final db = await instance.database;
    final results = await db.query('products', orderBy: 'name');
    return results.map((map) => Product.fromMap(map)).toList();
  }

  // Invoice Operations
  Future<int> insertInvoice(Invoice invoice) async {
    final db = await instance.database;
    return await db.insert('invoices', invoice.toMap());
  }

  Future<List<Invoice>> getInvoices() async {
    final db = await instance.database;
    final results = await db.query('invoices', orderBy: 'dateTime DESC');
    return results.map((map) => Invoice.fromMap(map)).toList();
  }

  Future<Invoice?> getInvoiceById(int id) async {
    final db = await instance.database;
    final results = await db.query(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return Invoice.fromMap(results.first);
    }
    return null;
  }

  Future<Invoice?> getInvoiceByNumber(String invoiceNumber) async {
    final db = await instance.database;
    final results = await db.query(
      'invoices',
      where: 'invoiceNumber = ?',
      whereArgs: [invoiceNumber],
    );
    if (results.isNotEmpty) {
      return Invoice.fromMap(results.first);
    }
    return null;
  }
}
