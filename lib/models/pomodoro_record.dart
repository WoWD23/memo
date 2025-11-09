/// 番茄钟记录数据模型
class PomodoroRecord {
  final int? id;
  final int durationMinutes;
  final String mode; // 'work', 'shortBreak', 'longBreak'
  final bool completed;
  final DateTime startedAt;
  final DateTime? endedAt;

  PomodoroRecord({
    this.id,
    required this.durationMinutes,
    required this.mode,
    required this.completed,
    required this.startedAt,
    this.endedAt,
  });

  /// 从数据库映射创建对象
  factory PomodoroRecord.fromMap(Map<String, dynamic> map) {
    return PomodoroRecord(
      id: map['id'] as int?,
      durationMinutes: map['duration_minutes'] as int,
      mode: map['mode'] as String,
      completed: (map['completed'] as int) == 1,
      startedAt: DateTime.parse(map['started_at'] as String),
      endedAt: map['ended_at'] != null 
          ? DateTime.parse(map['ended_at'] as String) 
          : null,
    );
  }

  /// 转换为数据库映射
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'duration_minutes': durationMinutes,
      'mode': mode,
      'completed': completed ? 1 : 0,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
    };
  }

  /// 复制对象并修改部分字段
  PomodoroRecord copyWith({
    int? id,
    int? durationMinutes,
    String? mode,
    bool? completed,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return PomodoroRecord(
      id: id ?? this.id,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      mode: mode ?? this.mode,
      completed: completed ?? this.completed,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}

