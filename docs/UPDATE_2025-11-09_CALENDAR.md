# 2025-11-09 日历功能更新说明

## 📝 本次更新概览

本次更新完成了日历视图的核心功能开发，实现了多种视图模式、代码重构、跨平台支持等重要特性。

---

## ✨ 新增功能

### 1. 日历多视图系统

仿照 Apple 日历系统，实现了四种日历显示方案：

#### 1.1 紧凑视图（Compact View）
- **月份网格显示**：纵向滚动查看多个月份
- **事件圆点标记**：不同颜色表示不同事件类型
  - 🟢 绿色：打卡事件
  - 🟠 橙色：番茄钟事件
  - 🔵 蓝色：待办事项
- **展开详情功能**：点击日期展开显示24小时时间轴
  - 显示全天事件（打卡）
  - 显示具体时间段事件（番茄钟、待办事项）
  - 包含迷你周视图导航

#### 1.2 叠放视图（Stacked View）
- **横向事件条**：直观显示事件的连续性和分布
- **多事件类型展示**：同时显示打卡、番茄钟、待办事项
- **点击进入详情**：点击日期自动切换到紧凑视图的详情页
- **图例说明**：顶部显示颜色图例

#### 1.3 详细信息视图（占位）
- 预留了视图接口和菜单入口
- 待后续开发实现

#### 1.4 列表视图（占位）
- 预留了视图接口和菜单入口
- 待后续开发实现

### 2. 视图切换系统

- **下拉菜单**：右上角图标点击展开视图选择菜单
- **状态保持**：从叠放视图进入详情后，返回时回到叠放视图
- **平滑过渡**：使用 `AnimatedSwitcher` 实现视图切换动画

### 3. 测试数据系统

为便于开发和演示，实现了完整的测试数据生成：

```dart
// 生成前后15天的测试数据
- 打卡记录：随机分布
- 番茄钟记录：每天1-3个随机时段
- 待办事项：每天0-2个随机任务
```

**事件颜色配置**：
- 打卡：绿色 (`Colors.green`)
- 番茄钟：橙色 (`Colors.orange`)
- 待办：蓝色 (`Colors.blue`)

---

## ⚡ 优化改进

### 1. 滚动体验优化

#### 问题 1：滚动范围受限
**现象**：只能上滑到8月，下滑到2月  
**原因**：月份列表生成范围过小（-3 到 +3）  
**解决**：扩展到 -12 到 +12，共25个月

#### 问题 2：初始显示位置错误
**现象**：首次打开显示去年11月  
**原因**：滚动位置未初始化到当前月  
**解决**：
- 实现 `_scrollToCurrentMonth()` 方法
- 在 `didChangeDependencies()` 中自动滚动
- 使用 `addPostFrameCallback` 确保布局完成后滚动

```dart
void _scrollToCurrentMonth() {
  if (!mounted || _hasScrolledToCurrentMonth) return;
  _scrollToMonth(_selectedMonth);
  _hasScrolledToCurrentMonth = true;
}
```

#### 问题 3：视图切换后无法定位
**现象**：从叠放切换到紧凑时，位置偏移  
**原因**：不同视图的月份高度不同  
**解决**：
- 紧凑视图：约400px/月
- 叠放视图：约460px/月
- 根据视图模式动态计算滚动偏移

### 2. 年份显示动态更新

#### 问题：年份不随滚动更新
**现象**：滚动到去年或明年，顶部仍显示2025年  
**解决方案**：
- 分离状态变量：
  - `_selectedMonth`：固定为当前月，用于生成列表
  - `_displayedMonth`：动态更新，用于顶部显示
- 添加滚动监听器，实时计算显示月份

```dart
void _onScroll() {
  final offset = _scrollController.offset;
  final monthHeight = _viewMode == CalendarViewMode.stacked ? 460.0 : 400.0;
  final currentIndex = (offset / monthHeight + 0.3).floor();
  
  final newMonth = DateTime(currentMonth.year, currentMonth.month + currentIndex - 12, 1);
  
  if (newMonth != _displayedMonth) {
    setState(() => _displayedMonth = newMonth);
  }
}
```

#### 问题：滚动卡顿
**现象**：滚动时月份突然跳转，不连贯  
**原因**：更新 `_selectedMonth` 导致 ListView 重建  
**解决**：仅更新 `_displayedMonth`，不触发列表重建

### 3. 视图状态保持

#### 问题：返回视图错误
**现象**：从叠放视图查看详情后，返回到紧凑视图  
**解决**：
- 引入 `_previousViewMode` 记录原视图
- 进入详情前保存当前视图
- 返回时恢复原视图

```dart
onDateSelected: (date) {
  setState(() {
    _previousViewMode = _viewMode; // 保存
    _viewMode = CalendarViewMode.compact;
  });
}

// 返回按钮
onPressed: () {
  setState(() {
    _viewMode = _previousViewMode; // 恢复
  });
}
```

---

## 🏗️ 代码重构

### 文件结构优化

#### 重构前
```
lib/views/calendar/
  └── calendar_view.dart (800+ 行)
```

#### 重构后
```
lib/views/calendar/
  ├── calendar_view.dart           (主视图，数据管理)
  ├── calendar_types.dart          (类型定义)
  ├── calendar_compact_view.dart   (紧凑视图)
  ├── calendar_stacked_view.dart   (叠放视图)
  └── calendar_placeholder_view.dart (占位视图)
```

### 各文件职责

#### `calendar_types.dart` - 公共类型
```dart
- CalendarViewMode: 视图模式枚举
- CalendarDisplayState: 显示状态枚举
- EventType: 事件类型枚举
- TodoTestData: 待办测试数据模型
- CalendarUtils: 日期工具类
```

#### `calendar_view.dart` - 主视图
- 数据加载和管理
- 视图模式切换
- 滚动控制
- 顶部导航栏

#### `calendar_compact_view.dart` - 紧凑视图
- 月份网格显示
- 日期详情展开
- 24小时时间轴
- 事件卡片渲染

#### `calendar_stacked_view.dart` - 叠放视图
- 横向事件条
- 多事件类型展示
- 图例显示

#### `calendar_placeholder_view.dart` - 占位视图
- 通用占位组件
- 用于未实现的视图

---

## 🐛 问题修复

### 1. 测试数据问题
**问题**：只显示待办数据，打卡和番茄钟不显示  
**原因**：`_loadTestData()` 逻辑错误，未正确填充列表  
**修复**：确保所有测试数据正确添加到对应列表

### 2. 数据类型错误
**问题**：数据库加载出错  
**原因**：`id` 字段类型错误（String vs int?）  
**修复**：测试数据不设置 id，保持为 null

### 3. 桌面平台数据库错误
**问题**：Windows 平台无法加载数据库  
**原因**：未初始化 `sqflite_common_ffi`  
**修复**：

#### `main.dart`
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  await NotificationService.instance.initialize();
  runApp(const MyApp());
}
```

#### `database_service.dart`
```dart
Future<Database> _initDB(String filePath) async {
  String path;
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    final dbPath = await databaseFactory.getDatabasesPath();
    path = join(dbPath, filePath);
  } else {
    final dbPath = await getDatabasesPath();
    path = join(dbPath, filePath);
  }
  
  return await databaseFactory.openDatabase(
    path,
    options: OpenDatabaseOptions(version: 2, onCreate: _createDB, onUpgrade: _upgradeDB),
  );
}
```

### 4. 叠放视图月份高度调优
**问题**：切换到叠放视图时，当前月份位置偏移  
**过程**：
- 初始 500px → 偏上
- 调整 550px → 太大，显示下一月
- 调整 480px → 接近
- 最终 460px → 准确

---

## 🔧 技术细节

### 关键算法

#### 1. 滚动位置计算
```dart
// 月份索引：0-24，其中 12 是当前月
final targetIndex = 12 + monthDiff;

// 根据视图计算偏移量
final monthHeight = _viewMode == CalendarViewMode.stacked ? 460.0 : 400.0;
final targetOffset = targetIndex * monthHeight;

// 执行滚动
_scrollController.jumpTo(targetOffset);
```

#### 2. 当前显示月份计算
```dart
final offset = _scrollController.offset;
final monthHeight = _viewMode == CalendarViewMode.stacked ? 460.0 : 400.0;

// +0.3 避免过于敏感
final currentIndex = (offset / monthHeight + 0.3).floor();

// 计算实际月份
final currentMonth = DateTime.now();
final displayedMonth = DateTime(
  currentMonth.year,
  currentMonth.month + currentIndex - 12,
  1,
);
```

#### 3. 事件数据分组
```dart
// 按日期键分组
final dateKey = CalendarUtils.formatDateKey(date); // "2025-11-09"

// 番茄钟计数
pomodoroCountByDate[dateKey] = (pomodoroCountByDate[dateKey] ?? 0) + 1;

// 待办计数
todoCountByDate[dateKey] = testTodos
    .where((todo) => CalendarUtils.formatDateKey(todo.startTime) == dateKey)
    .length;
```

### 性能优化

1. **避免不必要的重建**
   - 分离 `_selectedMonth` 和 `_displayedMonth`
   - 仅更新显示状态，不重建列表

2. **滚动监听节流**
   - 仅在月份真正改变时更新状态
   - 使用 `floor` + 偏移量避免频繁触发

3. **布局优化**
   - 使用 `ListView.builder` 按需构建
   - 避免一次性加载所有月份

---

## 📊 开发进度

### 日历功能完成度: 70%

**已完成**：
- ✅ 紧凑视图基础功能
- ✅ 叠放视图基础功能
- ✅ 视图切换系统
- ✅ 滚动交互优化
- ✅ 测试数据系统
- ✅ 代码重构

**进行中**：
- 🔄 详细信息视图
- 🔄 列表视图

**待完成**：
- ⏳ 事件编辑功能
- ⏳ 事件搜索功能
- ⏳ 日历设置选项
- ⏳ 性能优化
- ⏳ 单元测试

---

## 🎯 下一步计划

### 短期目标（本周）
1. 实现详细信息视图
2. 实现列表视图
3. 添加事件点击跳转功能
4. 优化事件颜色主题

### 中期目标（本月）
1. 实现事件编辑功能
2. 实现事件搜索功能
3. 添加日历设置选项
4. 完善测试覆盖

### 长期目标（下月）
1. 系统日历集成
2. 日历导出功能
3. 性能全面优化
4. 发布 v1.0

---

## 📸 效果预览

### 紧凑视图
- 月份网格显示，每个日期下方显示事件圆点
- 点击日期展开24小时详情
- 支持前后12个月滚动

### 叠放视图
- 月份网格 + 横向事件条
- 三种事件类型同时显示
- 顶部图例说明

### 视图切换
- 右上角下拉菜单
- 平滑过渡动画
- 保持滚动位置

---

## 🔍 技术亮点

1. **状态管理优化**
   - 分离显示状态和数据状态
   - 避免不必要的重建

2. **跨平台兼容**
   - Windows/Linux/macOS 数据库支持
   - 使用 `sqflite_common_ffi`

3. **代码质量**
   - 职责清晰的模块化设计
   - 详细的代码注释
   - 无 Linter 错误

4. **用户体验**
   - 平滑的滚动体验
   - 直观的视图切换
   - 准确的状态保持

---

## 🙏 总结

本次更新完成了日历功能的核心开发，实现了多视图系统、交互优化、代码重构等重要工作。通过解决滚动、显示、性能等多个关键问题，为用户提供了流畅、直观的日历使用体验。

**更新日期**: 2025-11-09  
**版本**: v1.0.0 (开发中)  
**开发者**: AI Assistant & User

