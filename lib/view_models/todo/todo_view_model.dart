import 'package:flutter/foundation.dart';
import '../../models/todo.dart';
import '../../repositories/todo_repository.dart';

/// 待办事项视图模型
class TodoViewModel extends ChangeNotifier {
  final TodoRepository _repository = TodoRepository();

  List<Todo> _incompleteTodos = [];
  List<Todo> _completedTodos = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 过滤器
  TodoFilter _currentFilter = TodoFilter.all;
  TodoSortBy _currentSort = TodoSortBy.priority;

  // Getters
  List<Todo> get incompleteTodos => _incompleteTodos;
  List<Todo> get completedTodos => _completedTodos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TodoFilter get currentFilter => _currentFilter;
  TodoSortBy get currentSort => _currentSort;

  int get incompleteCount => _incompleteTodos.length;
  int get completedCount => _completedTodos.length;
  int get totalCount => incompleteCount + completedCount;

  /// 获取过滤后的未完成待办事项
  List<Todo> get filteredIncompleteTodos {
    List<Todo> filtered = List.from(_incompleteTodos);

    // 应用过滤器
    switch (_currentFilter) {
      case TodoFilter.today:
        filtered = filtered.where((todo) => todo.isDueToday).toList();
        break;
      case TodoFilter.overdue:
        filtered = filtered.where((todo) => todo.isOverdue).toList();
        break;
      case TodoFilter.highPriority:
        filtered = filtered.where((todo) => todo.priority == 3).toList();
        break;
      case TodoFilter.all:
        break;
    }

    // 应用排序
    switch (_currentSort) {
      case TodoSortBy.priority:
        filtered.sort((a, b) {
          final priorityCompare = b.priority.compareTo(a.priority);
          if (priorityCompare != 0) return priorityCompare;
          if (a.dueDate != null && b.dueDate != null) {
            return a.dueDate!.compareTo(b.dueDate!);
          }
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
      case TodoSortBy.dueDate:
        filtered.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) {
            return b.createdAt.compareTo(a.createdAt);
          }
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TodoSortBy.createdDate:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
  }

  /// 初始化并加载数据
  Future<void> initialize() async {
    await loadTodos();
  }

  /// 加载所有待办事项
  Future<void> loadTodos() async {
    _setLoading(true);
    _clearError();

    try {
      _incompleteTodos = await _repository.getIncomplete();
      _completedTodos = await _repository.getCompleted();
      notifyListeners();
    } catch (e) {
      _setError('加载待办事项失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 添加待办事项
  Future<bool> addTodo({
    required String title,
    String? description,
    DateTime? dueDate,
    int priority = 2,
  }) async {
    _clearError();

    try {
      final todo = Todo(
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        createdAt: DateTime.now(),
      );

      final id = await _repository.insert(todo);
      if (id > 0) {
        await loadTodos();
        return true;
      }
      return false;
    } catch (e) {
      _setError('添加待办事项失败: $e');
      return false;
    }
  }

  /// 更新待办事项
  Future<bool> updateTodo(Todo todo) async {
    _clearError();

    try {
      final count = await _repository.update(todo);
      if (count > 0) {
        await loadTodos();
        return true;
      }
      return false;
    } catch (e) {
      _setError('更新待办事项失败: $e');
      return false;
    }
  }

  /// 删除待办事项
  Future<bool> deleteTodo(int id) async {
    _clearError();

    try {
      final count = await _repository.delete(id);
      if (count > 0) {
        await loadTodos();
        return true;
      }
      return false;
    } catch (e) {
      _setError('删除待办事项失败: $e');
      return false;
    }
  }

  /// 切换完成状态
  Future<bool> toggleComplete(Todo todo) async {
    _clearError();

    try {
      int count;
      if (todo.completed) {
        count = await _repository.markAsIncomplete(todo.id!);
      } else {
        count = await _repository.markAsCompleted(todo.id!);
      }

      if (count > 0) {
        await loadTodos();
        return true;
      }
      return false;
    } catch (e) {
      _setError('更新状态失败: $e');
      return false;
    }
  }

  /// 清空所有已完成的待办事项
  Future<bool> clearCompleted() async {
    _clearError();

    try {
      final count = await _repository.deleteAllCompleted();
      if (count > 0) {
        await loadTodos();
        return true;
      }
      return false;
    } catch (e) {
      _setError('清空失败: $e');
      return false;
    }
  }

  /// 设置过滤器
  void setFilter(TodoFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// 设置排序方式
  void setSort(TodoSortBy sort) {
    _currentSort = sort;
    notifyListeners();
  }

  // 私有方法
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

/// 待办事项过滤器
enum TodoFilter {
  all,        // 全部
  today,      // 今天到期
  overdue,    // 逾期
  highPriority, // 高优先级
}

/// 待办事项排序方式
enum TodoSortBy {
  priority,    // 优先级
  dueDate,     // 到期日期
  createdDate, // 创建日期
}

