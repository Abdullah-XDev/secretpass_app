import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/password_entry.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  Database? _db;

  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'secretpass.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE passwords (
            id TEXT PRIMARY KEY,
            username TEXT NOT NULL,
            accountName TEXT NOT NULL,
            password TEXT NOT NULL,
            website TEXT,
            notes TEXT,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Database get db {
    if (_db == null) throw Exception('Database not initialized');
    return _db!;
  }

  Future<List<PasswordEntry>> getAllEntries() async {
    final maps = await db.query('passwords', orderBy: 'username ASC, accountName ASC');
    return maps.map((m) => PasswordEntry.fromMap(m)).toList();
  }

  Future<void> insertEntry(PasswordEntry entry) async {
    await db.insert('passwords', entry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateEntry(PasswordEntry entry) async {
    await db.update('passwords', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<void> deleteEntry(String id) async {
    await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PasswordEntry>> searchEntries(String query) async {
    final maps = await db.query(
      'passwords',
      where: 'username LIKE ? OR accountName LIKE ? OR website LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'username ASC',
    );
    return maps.map((m) => PasswordEntry.fromMap(m)).toList();
  }

  /// Group entries by username
  Map<String, List<PasswordEntry>> groupByUsername(List<PasswordEntry> entries) {
    final Map<String, List<PasswordEntry>> grouped = {};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.username, () => []).add(entry);
    }
    return grouped;
  }
}
