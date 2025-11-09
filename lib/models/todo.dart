/// 待办事项数据模型
class Todo {
  final int? id;
  final String title;
  final String? description;
  final bool completed;
  final DateTime? dueDate;
  final int priority; // 1=低, 2=中, 3=高
  final DateTime createdAt;
  final DateTime? completedAt;

  Todo({
    this.id,
    required this.title,
    this.description,
    this.completed = false,
    this.dueDate,
    this.priority = 2,
    required this.createdAt,
    this.completedAt,
  });

  /// 从数据库映射创建对象
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      completed: (map['completed'] as int) == 1,
      dueDate: map['due_date'] != null 
          ? DateTime.parse(map['due_date'] as String)
          : null,
      priority: map['priority'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  /// 转换为数据库映射
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed ? 1 : 0,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// 复制对象并修改部分字段
  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? dueDate,
    int? priority,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// 是否已逾期
  bool get isOverdue {
    if (completed || dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  /// 是否今天到期
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }
}

