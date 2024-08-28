import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:shopping_cart/modules/products_model.dart';

class DbHelper {
  static Database? _db;

  Future<Database?> get DB async {
    if (_db != null) {
      print("database is already created");
      return _db!;
    }
    _db = await initDataBase();
    return _db;
  }

  initDataBase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'cart.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    print("database is created");
    await db.execute(
        'CREATE TABLE cart ('
            'id INTEGER, '
            'title VARCHAR, '
            'image TEXT, '
            'price INTEGER, '
            'description VARCHAR, '
            'brand VARCHAR, '
            'model VARCHAR, '
            'color VARCHAR, '
            'category VARCHAR, '
            'discount INTEGER, '
            'quantity INTEGER)'
    );
  }

  Future<Products> insert(Products products) async {
    var dbClient = await DB;
    if (dbClient == null) {
      throw Exception("Database is not initialized");
    }
    await dbClient.insert('cart', products.toMap());
    return products;
  }
  Future<List<Products>> getCartList()async{
    var dbClient = await DB;
    if (dbClient == null) {
      throw Exception("Database is not initialized");
    }
    final List<Map<String, Object?>> queryResult = await dbClient.query("cart");
    return queryResult.map((e)=> Products.fromMap(e)).toList();
  }

  Future<int> delete(String image) async {
    try {
      var dbClient = await DB;
      if (dbClient == null) {
        throw Exception("Database is not initialized");
      }
      return await dbClient.delete(
        'cart',
        where: 'image = ?',
        whereArgs: [image],
      );
    } catch (e) {
      print("Error deleting item: $e");
      rethrow; // Optionally rethrow to let the caller handle it
    }
  }
  Future<void> reduceRow(String image) async {
    try {
      var dbClient = await DB;
      if (dbClient == null) {
        throw Exception("Database is not initialized");
      }

      // Start a transaction to ensure atomicity
      await dbClient.transaction((txn) async {
        // Find the rowid of the row to delete
        var rowidResult = await txn.rawQuery(
          'SELECT rowid FROM cart WHERE image = ? LIMIT 1',
          [image],
        );

        if (rowidResult.isNotEmpty) {
          // Delete the row with the found rowid
          await txn.delete(
            'cart',
            where: 'rowid = ?',
            whereArgs: [rowidResult.first['rowid']],
          );
        }
      });
    } catch (e) {
      print("Error deleting item: $e");
      rethrow; // Optionally rethrow to let the caller handle it
    }
  }
  Future<int> updateQuantity(Products product) async {
    try {
      var dbClient = await DB;
      if (dbClient == null) {
        throw Exception("Database is not initialized");
      }
      return await dbClient.update(
        'cart',
       product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id]
      );
    } catch (e) {
      print("Error deleting item: $e");
      rethrow; // Optionally rethrow to let the caller handle it
    }
  }

}
