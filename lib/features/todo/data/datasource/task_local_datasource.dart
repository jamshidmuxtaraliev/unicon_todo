import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unicon_todo/features/todo/domain/entities/task.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskEntity>> getTasks();

  Future<int> addTask(String title);

  Future<void> toggleTask(int id, bool done);

  Future<void> deleteTask(int id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static const _dbName = 'todo_clean.db';
  static const _dbVersion = 1;
  static const _table = 'tasks';

  Database? _db;

  Future<Database> get _database async => _db ??= await _initDB();

  Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            done INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL
          );
        ''');
      },
    );
  }

  @override
  Future<List<TaskEntity>> getTasks() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'created_at DESC');
    return rows.map((e) => TaskEntity.fromMap(e)).toList();
  }

  @override
  Future<int> addTask(String title) async {
    final db = await _database;
    final model = TaskEntity(title: title, done: false, created_at: DateTime.now());
    return await db.insert(_table, model.toMap());
  }

  @override
  Future<void> toggleTask(int id, bool done) async {
    final db = await _database;
    await db.update(_table, {'done': done ? 1 : 0}, where: 'id=?', whereArgs: [id]);
  }

  @override
  Future<void> deleteTask(int id) async {
    final db = await _database;
    await db.delete(_table, where: 'id=?', whereArgs: [id]);
  }
}
