import 'package:sqflite/sqflite.dart';
import '../core/database/database_service.dart';
import '../models/pomodoro_record.dart';

/// 番茄钟记录数据仓库
class PomodoroRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  /// 创建番茄钟记录
  Future<PomodoroRecord> create(PomodoroRecord record) async {
    final db = await _databaseService.database;
    final id = await db.insert('pomodoro_records', record.toMap());
    return record.copyWith(id: id);
  }

  /// 获取所有番茄钟记录
  Future<List<PomodoroRecord>> getAll() async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'pomodoro_records',
      orderBy: 'started_at DESC',
    );

    return maps.map((map) => PomodoroRecord.fromMap(map)).toList();
  }

  /// 获取指定日期的番茄钟记录
  Future<List<PomodoroRecord>> getByDate(DateTime date) async {
    final db = await _databaseService.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final maps = await db.query(
      'pomodoro_records',
      where: 'started_at >= ? AND started_at < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'started_at DESC',
    );

    return maps.map((map) => PomodoroRecord.fromMap(map)).toList();
  }

  /// 获取指定日期范围的番茄钟记录
  Future<List<PomodoroRecord>> getByDateRange(DateTime start, DateTime end) async {
    final db = await _databaseService.database;
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day).add(const Duration(days: 1));

    final maps = await db.query(
      'pomodoro_records',
      where: 'started_at >= ? AND started_at < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'started_at DESC',
    );

    return maps.map((map) => PomodoroRecord.fromMap(map)).toList();
  }

  /// 更新番茄钟记录
  Future<int> update(PomodoroRecord record) async {
    final db = await _databaseService.database;
    return await db.update(
      'pomodoro_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// 删除番茄钟记录
  Future<int> delete(int id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'pomodoro_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取今日完成的番茄钟数量
  Future<int> getTodayCompletedCount() async {
    final db = await _databaseService.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM pomodoro_records WHERE completed = 1 AND mode = ? AND started_at >= ? AND started_at < ?',
      ['work', startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取总完成番茄钟数量
  Future<int> getTotalCompletedCount() async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM pomodoro_records WHERE completed = 1 AND mode = ?',
      ['work'],
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取今日专注时长（分钟）
  Future<int> getTodayFocusMinutes() async {
    final db = await _databaseService.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT SUM(duration_minutes) as total FROM pomodoro_records WHERE completed = 1 AND mode = ? AND started_at >= ? AND started_at < ?',
      ['work', startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

