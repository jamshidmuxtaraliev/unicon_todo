import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unicon_todo/features/todo/domain/entities/task.dart';

/// 1 soatga teng interval default
const Duration kNotifyInterval = Duration(hours: 1);

abstract class TaskLocalDataSource {
  Future<List<TaskEntity>> getTasks();

  Future<int> addTask(String title, String description);

  Future<void> toggleTask(int id, bool done);

  Future<void> deleteTask(int id);

  /// YANGI: notif shartini qanoatlantirgan (birinchi yoki takroriy) tasklar
  Future<List<TaskEntity>> getDueTasksForNotify({Duration interval = kNotifyInterval});

  /// YANGI: task uchun oxirgi notifikatsiya vaqtini HOZIR deb belgilash
  Future<void> markNotifiedNow(int id);

  /// (ixtiyoriy) bitta taskni olish
  Future<TaskEntity?> getTaskById(int id);

  /// Taskni tahrirlash uchun yangi funksiya
  Future<void> updateTask(TaskEntity task);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static const _dbName = 'todo_clean.db';
  static const _dbVersion = 2; // <-- versiyani oshirdik (yangi ustun uchun)
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
        // created_at va last_notified_at millisekund formatida saqlanadi
        await db.execute('''
          CREATE TABLE $_table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            done INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL,
            last_notified_at INTEGER NULL
          );
        ''');

        // Tezkor qidiruv uchun indekslar (ixtiyoriy, tavsiya etiladi)
        await db.execute('CREATE INDEX IF NOT EXISTS idx_${_table}_done ON $_table(done);');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_${_table}_created ON $_table(created_at);');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_${_table}_last_notified ON $_table(last_notified_at);');
      },
    );
  }

  @override
  Future<List<TaskEntity>> getTasks() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'created_at DESC');
    return rows.map(TaskEntity.fromMap).toList();
  }

  @override
  Future<int> addTask(String title, String description) async {
    final db = await _database;
    final model = TaskEntity(
      title: title,
      description:description ,
      done: false,
      created_at: DateTime.now(), // TaskEntity.toMap() ms ga aylantiradi deb faraz qilamiz
    );

    // last_notified_at ni NULL qoldiramiz (birinchi 1 soatda trigger bo'ladi)
    final map = model.toMap();
    map['last_notified_at'] = null;

    return await db.insert(_table, map);
  }

  @override
  Future<void> toggleTask(int id, bool done) async {
    final db = await _database;

    // Agar done=true bo'lsa — shunchaki bajardi deb belgilaymiz.
    // Agar done=false bo'lsa — last_notified_at ni o'zgartirmaymiz.
    // (Xohlasangiz, done=false bo'lganda last_notified_at=NULL qilib, yana 1 soatdan keyin
    // emas, balki "yaratilganiga 1 soat" mantiqiga qaytarishingiz ham mumkin.)
    await db.update(_table, {'done': done ? 1 : 0}, where: 'id=?', whereArgs: [id]);
  }

  @override
  Future<void> deleteTask(int id) async {
    final db = await _database;
    await db.delete(_table, where: 'id=?', whereArgs: [id]);
  }

  @override
  Future<TaskEntity?> getTaskById(int id) async {
    final db = await _database;
    final rows = await db.query(_table, where: 'id=?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return TaskEntity.fromMap(rows.first);
  }

  @override
  Future<void> markNotifiedNow(int id) async {
    final db = await _database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update(_table, {'last_notified_at': now}, where: 'id=?', whereArgs: [id]);
  }

  /// Notifikatsiya sharti:
  ///  - done = 0
  ///  - created_at <= (now - interval)
  ///  - (last_notified_at IS NULL)  YOKI  (last_notified_at <= (now - interval))
  /// Bu bitta query bilan ham birinchi, ham takroriy eslatmalarni qamrab oladi.
  @override
  Future<List<TaskEntity>> getDueTasksForNotify({Duration interval = kNotifyInterval}) async {
    final db = await _database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - interval.inMilliseconds;

    final rows = await db.query(
      _table,
      where: 'done = 0 AND created_at <= ? AND (last_notified_at IS NULL OR last_notified_at <= ?)',
      whereArgs: [cutoff, cutoff],
      orderBy: 'created_at ASC',
    );

    return rows.map(TaskEntity.fromMap).toList();
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final db = await _database;
    await db.update(
      _table,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
