import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;

/// 数据库服务
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('memo.db');
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDB(String filePath) async {
    String path;
    
    // 桌面平台使用不同的路径获取方式
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final dbPath = await databaseFactory.getDatabasesPath();
      path = join(dbPath, filePath);
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      ),
    );
  }

  /// 创建数据表
  Future<void> _createDB(Database db, int version) async {
    // 打卡表
    await db.execute('''
      CREATE TABLE check_ins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 番茄钟记录表
    await db.execute('''
      CREATE TABLE pomodoro_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        duration_minutes INTEGER NOT NULL,
        mode TEXT NOT NULL,
        completed INTEGER NOT NULL,
        started_at TEXT NOT NULL,
        ended_at TEXT
      )
    ''');

    // 待办事项表
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        completed INTEGER NOT NULL DEFAULT 0,
        due_date TEXT,
        priority INTEGER NOT NULL DEFAULT 2,
        created_at TEXT NOT NULL,
        completed_at TEXT
      )
    ''');

    // 为日期字段创建索引，提高查询性能
    await db.execute('CREATE INDEX idx_check_ins_date ON check_ins(date)');
    await db.execute('CREATE INDEX idx_pomodoro_started_at ON pomodoro_records(started_at)');
    await db.execute('CREATE INDEX idx_todos_completed ON todos(completed)');
    await db.execute('CREATE INDEX idx_todos_due_date ON todos(due_date)');
  }

  /// 数据库升级
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 添加待办事项表
      await db.execute('''
        CREATE TABLE todos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          completed INTEGER NOT NULL DEFAULT 0,
          due_date TEXT,
          priority INTEGER NOT NULL DEFAULT 2,
          created_at TEXT NOT NULL,
          completed_at TEXT
        )
      ''');
      await db.execute('CREATE INDEX idx_todos_completed ON todos(completed)');
      await db.execute('CREATE INDEX idx_todos_due_date ON todos(due_date)');
    }
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

