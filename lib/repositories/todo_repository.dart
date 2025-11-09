import '../core/database/database_service.dart';
import '../models/todo.dart';

/// 待办事项数据仓库
class TodoRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  /// 添加待办事项
  Future<int> insert(Todo todo) async {
    final db = await _dbService.database;
    return await db.insert('todos', todo.toMap());
  }

  /// 更新待办事项
  Future<int> update(Todo todo) async {
    final db = await _dbService.database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  /// 删除待办事项
  Future<int> delete(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 根据ID获取待办事项
  Future<Todo?> getById(int id) async {
    final db = await _dbService.database;
    final results = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return Todo.fromMap(results.first);
  }

  /// 获取所有待办事项
  Future<List<Todo>> getAll({
    bool? completed,
    String orderBy = 'created_at DESC',
  }) async {
    final db = await _dbService.database;
    final results = await db.query(
      'todos',
      where: completed != null ? 'completed = ?' : null,
      whereArgs: completed != null ? [completed ? 1 : 0] : null,
      orderBy: orderBy,
    );

    return results.map((map) => Todo.fromMap(map)).toList();
  }

  /// 获取未完成的待办事项
  Future<List<Todo>> getIncomplete() async {
    return await getAll(
      completed: false,
      orderBy: 'priority DESC, due_date ASC, created_at DESC',
    );
  }

  /// 获取已完成的待办事项
  Future<List<Todo>> getCompleted() async {
    return await getAll(
      completed: true,
      orderBy: 'completed_at DESC',
    );
  }

  /// 获取今天到期的待办事项
  Future<List<Todo>> getDueToday() async {
    final db = await _dbService.database;
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final results = await db.query(
      'todos',
      where: 'completed = 0 AND due_date LIKE ?',
      whereArgs: ['$todayStr%'],
      orderBy: 'priority DESC, created_at DESC',
    );

    return results.map((map) => Todo.fromMap(map)).toList();
  }

  /// 获取逾期的待办事项
  Future<List<Todo>> getOverdue() async {
    final db = await _dbService.database;
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final results = await db.query(
      'todos',
      where: 'completed = 0 AND due_date IS NOT NULL AND due_date < ?',
      whereArgs: [todayStr],
      orderBy: 'due_date ASC',
    );

    return results.map((map) => Todo.fromMap(map)).toList();
  }

  /// 标记为完成
  Future<int> markAsCompleted(int id) async {
    final db = await _dbService.database;
    return await db.update(
      'todos',
      {
        'completed': 1,
        'completed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 标记为未完成
  Future<int> markAsIncomplete(int id) async {
    final db = await _dbService.database;
    return await db.update(
      'todos',
      {
        'completed': 0,
        'completed_at': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取待办事项总数
  Future<int> getCount({bool? completed}) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM todos ${completed != null ? 'WHERE completed = ?' : ''}',
      completed != null ? [completed ? 1 : 0] : null,
    );
    return result.first['count'] as int;
  }

  /// 获取未完成待办事项数量
  Future<int> getIncompleteCount() async {
    return await getCount(completed: false);
  }

  /// 获取已完成待办事项数量
  Future<int> getCompletedCount() async {
    return await getCount(completed: true);
  }

  /// 清空所有已完成的待办事项
  Future<int> deleteAllCompleted() async {
    final db = await _dbService.database;
    return await db.delete(
      'todos',
      where: 'completed = 1',
    );
  }
}

