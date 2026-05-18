import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'medical_context_provider.dart';

class DbManager {
  static final DbManager _instance = DbManager._internal();
  factory DbManager() => _instance;
  DbManager._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "GemmaCareHistory.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clinical_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        conditions TEXT NOT NULL,
        medications TEXT NOT NULL,
        reportText TEXT NOT NULL,
        healthScore INTEGER NOT NULL,
        customName TEXT
      )
    ''');
  }

  // --- CRUD Operations ---

  Future<int> insertRecord(ClinicalRecord record, {String? customName}) async {
    final db = await database;
    Map<String, dynamic> row = record.toMap();
    
    // SQFLite doesn't support List directly, need to join to string
    row['conditions'] = (row['conditions'] as List).join('|');
    row['medications'] = (row['medications'] as List).join('|');
    row['customName'] = customName;

    return await db.insert('clinical_history', row);
  }

  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clinical_history', orderBy: 'id DESC');
    return maps;
  }

  Future<int> updateRecordName(int id, String newName) async {
    final db = await database;
    return await db.update(
      'clinical_history',
      {'customName': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete(
      'clinical_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
