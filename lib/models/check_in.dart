/// 打卡数据模型
class CheckIn {
  final int? id;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  CheckIn({
    this.id,
    required this.date,
    this.note,
    required this.createdAt,
  });

  /// 从数据库映射创建对象
  factory CheckIn.fromMap(Map<String, dynamic> map) {
    return CheckIn(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 转换为数据库映射
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': _formatDate(date),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 格式化日期为 YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 复制对象并修改部分字段
  CheckIn copyWith({
    int? id,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return CheckIn(
      id: id ?? this.id,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

