import 'package:flutter/foundation.dart';
import '../../models/check_in.dart';
import '../../repositories/check_in_repository.dart';

/// 打卡ViewModel
class CheckInViewModel extends ChangeNotifier {
  final CheckInRepository _repository = CheckInRepository();

  CheckIn? _todayCheckIn;
  List<CheckIn> _recentCheckIns = [];
  int _streakDays = 0;
  int _totalCount = 0;
  bool _isLoading = false;

  // Getters
  CheckIn? get todayCheckIn => _todayCheckIn;
  List<CheckIn> get recentCheckIns => _recentCheckIns;
  int get streakDays => _streakDays;
  int get totalCount => _totalCount;
  bool get isLoading => _isLoading;
  bool get hasCheckedInToday => _todayCheckIn != null;

  /// 初始化加载数据
  Future<void> initialize() async {
    await loadTodayCheckIn();
    await loadStatistics();
  }

  /// 加载今日打卡记录
  Future<void> loadTodayCheckIn() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todayCheckIn = await _repository.getByDate(DateTime.now());
    } catch (e) {
      debugPrint('加载今日打卡记录失败: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 加载统计数据
  Future<void> loadStatistics() async {
    try {
      _streakDays = await _repository.getStreakDays();
      _totalCount = await _repository.getCount();
      notifyListeners();
    } catch (e) {
      debugPrint('加载统计数据失败: $e');
    }
  }

  /// 加载最近的打卡记录
  Future<void> loadRecentCheckIns({int limit = 30}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allCheckIns = await _repository.getAll();
      _recentCheckIns = allCheckIns.take(limit).toList();
    } catch (e) {
      debugPrint('加载打卡记录失败: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 打卡
  Future<bool> checkIn({String? note}) async {
    if (hasCheckedInToday) {
      debugPrint('今天已经打过卡了');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final checkIn = CheckIn(
        date: now,
        note: note,
        createdAt: now,
      );

      _todayCheckIn = await _repository.create(checkIn);
      await loadStatistics(); // 重新加载统计数据

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('打卡失败: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 更新打卡备注
  Future<bool> updateNote(String note) async {
    if (_todayCheckIn == null) return false;

    try {
      final updated = _todayCheckIn!.copyWith(note: note);
      await _repository.update(updated);
      _todayCheckIn = updated;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('更新备注失败: $e');
      return false;
    }
  }

  /// 删除打卡记录
  Future<bool> deleteCheckIn(int id) async {
    try {
      await _repository.delete(id);
      
      // 如果删除的是今日打卡，清空todayCheckIn
      if (_todayCheckIn?.id == id) {
        _todayCheckIn = null;
      }
      
      // 重新加载数据
      await loadRecentCheckIns();
      await loadStatistics();
      
      return true;
    } catch (e) {
      debugPrint('删除打卡记录失败: $e');
      return false;
    }
  }

  /// 获取指定日期范围的打卡记录
  Future<List<CheckIn>> getCheckInsByDateRange(DateTime start, DateTime end) async {
    try {
      return await _repository.getByDateRange(start, end);
    } catch (e) {
      debugPrint('获取打卡记录失败: $e');
      return [];
    }
  }
}

