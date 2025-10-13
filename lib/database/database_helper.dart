import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/product_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    developer.log('DatabaseHelper initialized', name: 'DatabaseHelper');
  }

  Future<void> clearDatabase() async {
    try {
      final db = await database;
      developer.log('Clearing all data from the database',
          name: 'DatabaseHelper');
      await db.delete('products');
      developer.log('Database cleared successfully', name: 'DatabaseHelper');
    } catch (e) {
      developer.log('Error clearing database: $e',
          name: 'DatabaseHelper', error: e);
      rethrow;
    }
  }

  Future<Database> get database async {
    try {
      if (_database != null) {
        developer.log('Returning existing database instance',
            name: 'DatabaseHelper');
        return _database!;
      }
      developer.log('Creating new database instance', name: 'DatabaseHelper');
      _database = await _initDB('products.db');
      return _database!;
    } catch (e) {
      developer.log('Error getting database: $e',
          name: 'DatabaseHelper', error: e);
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    try {
      // Get the application documents directory
      final Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      final String path = join(documentsDirectory.path, filePath);
      developer.log('Full database path: $path', name: 'DatabaseHelper');

      // Ensure the directory exists
      await Directory(dirname(path)).create(recursive: true);

      // Open the database with write permissions
      return await openDatabase(
        path,
        version: 3,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
        onOpen: (db) {
          developer.log('Database opened successfully', name: 'DatabaseHelper');
        },
      );
    } catch (e) {
      developer.log('Error initializing database: $e',
          name: 'DatabaseHelper', error: e);
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      developer.log('Creating database tables, version: $version',
          name: 'DatabaseHelper');

      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL,
          price REAL NOT NULL,
          image TEXT,
          user_email TEXT NOT NULL
        )
      ''');

      developer.log('Database tables created successfully',
          name: 'DatabaseHelper');
    } catch (e) {
      developer.log('Error creating database tables: $e',
          name: 'DatabaseHelper', error: e);
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      developer.log('Upgrading database from $oldVersion to $newVersion',
          name: 'DatabaseHelper');

      if (oldVersion < 3) {
        // Backup existing data
        final List<Map<String, dynamic>> oldData = await db.query('products');

        // Drop the old table
        await db.execute('DROP TABLE IF EXISTS products');

        // Create the new table with user_email
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT NOT NULL,
            price REAL NOT NULL,
            image TEXT,
            user_email TEXT NOT NULL
          )
        ''');

        // Migrate existing data with a default user email
        for (var product in oldData) {
          product['user_email'] =
              'default@user.com'; // Default for existing data
          await db.insert('products', product);
        }
      }

      developer.log('Database upgrade completed successfully',
          name: 'DatabaseHelper');
    } catch (e) {
      developer.log('Error upgrading database: $e',
          name: 'DatabaseHelper', error: e);
      rethrow;
    }
  }

  Future<int> insertProduct(Product product, String userEmail) async {
    try {
      developer.log('Inserting product for user: $userEmail',
          name: 'DatabaseHelper');
      final db = await database;
      final Map<String, dynamic> productMap = product.toMap();
      productMap['user_email'] = userEmail;

      final id = await db.insert('products', productMap);
      developer.log('Product inserted successfully with id: $id',
          name: 'DatabaseHelper');
      return id;
    } catch (e) {
      developer.log('Error inserting product: $e',
          name: 'DatabaseHelper', error: e);
      rethrow;
    }
  }

  Future<List<Product>> getAllProductsForUser(String userEmail) async {
    try {
      developer.log('Fetching products for user: $userEmail',
          name: 'DatabaseHelper');
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'user_email = ?',
        whereArgs: [userEmail],
      );
      developer.log('Retrieved ${maps.length} products for user',
          name: 'DatabaseHelper');

      return List.generate(maps.length, (i) {
        try {
          return Product.fromMap(maps[i]);
        } catch (e) {
          developer.log(
            'Error converting map to product at index $i: ${maps[i]}',
            name: 'DatabaseHelper',
            error: e,
          );
          rethrow;
        }
      });
    } catch (e) {
      developer.log('Error getting products for user: $e',
          name: 'DatabaseHelper', error: e);
      rethrow;
    }
  }

  Future<int> deleteProduct(int id, String userEmail) async {
    try {
      developer.log('Deleting product with id: $id for user: $userEmail',
          name: 'DatabaseHelper');
      final db = await database;
      final result = await db.delete(
        'products',
        where: 'id = ? AND user_email = ?',
        whereArgs: [id, userEmail],
      );
      developer.log('Delete operation completed. Rows affected: $result',
          name: 'DatabaseHelper');
      return result;
    } catch (e) {
      developer.log('Error deleting product: $e',
          name: 'DatabaseHelper', error: e);
      rethrow;
    }
  }

  Future<int> updateProduct(Product product, String userEmail) async {
    try {
      developer.log('Updating product for user: $userEmail',
          name: 'DatabaseHelper');
      final db = await database;
      final Map<String, dynamic> productMap = product.toMap();
      productMap['user_email'] = userEmail;

      final result = await db.update(
        'products',
        productMap,
        where: 'id = ? AND user_email = ?',
        whereArgs: [product.id, userEmail],
      );
      developer.log('Update operation completed. Rows affected: $result',
          name: 'DatabaseHelper');
      return result;
    } catch (e) {
      developer.log('Error updating product: $e',
          name: 'DatabaseHelper', error: e);
      rethrow;
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
