import 'package:sqflite/sqflite.dart';
import '../core/database/database_service.dart';
import '../models/check_in.dart';

/// 打卡数据仓库
class CheckInRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  /// 创建打卡记录
  Future<CheckIn> create(CheckIn checkIn) async {
    final db = await _databaseService.database;
    final id = await db.insert('check_ins', checkIn.toMap());
    return checkIn.copyWith(id: id);
  }

  /// 获取指定日期的打卡记录
  Future<CheckIn?> getByDate(DateTime date) async {
    final db = await _databaseService.database;
    final dateStr = _formatDate(date);
    
    final maps = await db.query(
      'check_ins',
      where: 'date = ?',
      whereArgs: [dateStr],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return CheckIn.fromMap(maps.first);
  }

  /// 获取所有打卡记录
  Future<List<CheckIn>> getAll() async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'check_ins',
      orderBy: 'date DESC',
    );

    return maps.map((map) => CheckIn.fromMap(map)).toList();
  }

  /// 获取指定日期范围的打卡记录
  Future<List<CheckIn>> getByDateRange(DateTime start, DateTime end) async {
    final db = await _databaseService.database;
    final startStr = _formatDate(start);
    final endStr = _formatDate(end);

    final maps = await db.query(
      'check_ins',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date DESC',
    );

    return maps.map((map) => CheckIn.fromMap(map)).toList();
  }

  /// 更新打卡记录
  Future<int> update(CheckIn checkIn) async {
    final db = await _databaseService.database;
    return await db.update(
      'check_ins',
      checkIn.toMap(),
      where: 'id = ?',
      whereArgs: [checkIn.id],
    );
  }

  /// 删除打卡记录
  Future<int> delete(int id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'check_ins',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取打卡总数
  Future<int> getCount() async {
    final db = await _databaseService.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM check_ins');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取连续打卡天数（从今天往前推）
  Future<int> getStreakDays() async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'check_ins',
      columns: ['date'],
      orderBy: 'date DESC',
    );

    if (maps.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (var map in maps) {
      final checkInDate = DateTime.parse(map['date'] as String);
      final expectedDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );
      final checkDate = DateTime(
        checkInDate.year,
        checkInDate.month,
        checkInDate.day,
      );

      if (checkDate.isAtSameMomentAs(expectedDate)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// 格式化日期为 YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

