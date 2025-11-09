# 📅 系统日历同步功能

Memo 应用支持将打卡和番茄钟记录自动同步到系统日历（iOS、macOS），让您在系统日历应用中查看所有活动记录。

---

## ✨ 功能特性

### 支持的平台
- ✅ **iOS** - iPhone、iPad 系统日历
- ✅ **macOS** - Mac 系统日历  
- ⏳ **Android** - 未来版本支持（技术已实现，待测试）

### 同步内容

#### 1. 打卡记录同步
- 每次打卡成功后自动创建日历事件
- 事件类型：全天事件
- 事件标题：📍 每日打卡
- 事件描述：包含打卡备注（如有）
- 显示位置：当天的日历格子中

#### 2. 番茄钟记录同步
- 每次完成番茄钟后自动创建日历事件
- 事件类型：定时事件（显示具体时间段）
- 事件标题：🍅/⚡/🔥 专注时间 (X分钟)
  - 🍅 < 60分钟
  - ⚡ 60-89分钟
  - 🔥 ≥ 90分钟
- 事件描述：包含备注和专注时长
- 显示位置：实际专注的时间段

---

## 🚀 使用指南

### 1. 开启日历同步

1. 打开 Memo 应用
2. 点击底部导航栏的 **"设置"** 标签
3. 找到 **"日历同步"** 部分
4. 打开 **"同步到系统日历"** 开关
5. 首次开启会请求日历权限，点击 **"允许"**

### 2. 权限说明

开启日历同步需要以下权限：

- **日历访问权限** (`NSCalendarsUsageDescription`)
  - 用于读取设备上的日历列表
  - 用于创建和写入日历事件
  
- **联系人访问权限** (`NSContactsUsageDescription`)  
  - 用于正确关联日历事件（系统要求）
  - 不会读取或使用您的联系人信息

### 3. 查看同步的记录

打开 **系统日历应用**：

**iOS：**
- 打开"日历" App
- 查看对应日期
- 点击事件查看详情

**macOS：**
- 打开"日历"应用
- 查看对应日期
- 点击事件查看详情

---

## 🎯 同步规则

### 自动同步
- 开启同步后，新的打卡和番茄钟记录会自动同步
- 无需手动操作

### 选择性同步
- ✅ 同步工作模式的番茄钟（已完成）
- ❌ 不同步休息时间的番茄钟
- ✅ 同步所有打卡记录

### 不重复同步
- 每条记录只会创建一次日历事件
- 关闭再开启同步不会重复创建

---

## ⚙️ 技术实现

### 使用的插件
- `device_calendar: ^4.3.2` - 系统日历集成

### 架构设计

```
CalendarService (服务层)
    ↓
CheckInViewModel / PomodoroViewModel (ViewModel 层)
    ↓
设置开关 (SharedPreferences)
```

### 核心代码

#### CalendarService

```dart
class CalendarService {
  // 请求权限
  Future<bool> requestPermissions();
  
  // 添加打卡事件
  Future<bool> addCheckInEvent(CheckIn checkIn);
  
  // 添加番茄钟事件
  Future<bool> addPomodoroEvent(PomodoroRecord record);
  
  // 获取设备日历列表
  Future<List<Calendar>> getCalendars();
}
```

#### 同步触发点

**打卡同步：**
```dart
// lib/view_models/check_in/check_in_view_model.dart
Future<bool> checkIn({String? note}) async {
  // ... 创建打卡记录 ...
  
  // 同步到系统日历
  await _syncToCalendarIfEnabled(_todayCheckIn!);
  
  return true;
}
```

**番茄钟同步：**
```dart
// lib/view_models/pomodoro/pomodoro_view_model.dart
Future<void> _saveRecord({required bool completed}) async {
  // ... 保存番茄钟记录 ...
  
  // 只同步工作模式的完成记录
  if (_mode == PomodoroMode.work && completed) {
    await _syncToCalendarIfEnabled(savedRecord);
  }
}
```

---

## 🔒 隐私与安全

### 数据隐私
- ✅ 所有数据仅存储在本地设备
- ✅ 不会上传到任何服务器
- ✅ 日历访问仅用于写入记录
- ✅ 不会读取或修改其他应用的日历事件

### 权限管理
- 用户可随时在设置中关闭同步
- 关闭后不会再创建新的日历事件
- 已同步的事件不会自动删除（可在日历 App 中手动删除）

---

## ❓ 常见问题

### Q1: 为什么需要联系人权限？
**A:** 这是 iOS/macOS 系统的要求。`device_calendar` 插件在访问日历时需要声明联系人权限，但实际上不会读取或使用您的联系人信息。

### Q2: 同步的事件会显示在哪个日历？
**A:** 默认会使用设备的第一个可写日历（通常是"iCloud"或"本地"日历）。您可以在系统日历 App 中移动这些事件到其他日历。

### Q3: 关闭同步后，之前的记录会删除吗？
**A:** 不会。关闭同步只是停止创建新的日历事件，已同步的事件会保留在系统日历中。如需删除，请在系统日历 App 中手动操作。

### Q4: 可以批量同步历史记录吗？
**A:** 目前版本不支持。只有开启同步后的新记录才会自动同步。未来版本可能会添加"导出历史记录"功能。

### Q5: Android 支持吗？
**A:** 技术上已经实现，但需要更多测试。预计在未来版本中支持 Android 系统日历。

### Q6: 同步失败怎么办？
**A:** 
1. 检查是否授予了日历权限
2. 检查设备日历 App 是否正常工作
3. 尝试关闭并重新开启同步
4. 重启应用

---

## 🔮 未来计划

### v1.1 计划功能
- [ ] 批量导出历史记录到日历
- [ ] 选择同步到指定日历
- [ ] 自定义事件标题和颜色
- [ ] Android 系统日历支持

### v1.2 计划功能
- [ ] 双向同步（从日历导入事件）
- [ ] 删除记录时同步删除日历事件
- [ ] 编辑记录时同步更新日历事件

---

## 📝 开发说明

### 添加新的同步类型

如果要为待办事项添加日历同步：

1. 在 `CalendarService` 中添加方法：
```dart
Future<bool> addTodoEvent(Todo todo) async {
  // 实现同步逻辑
}
```

2. 在 `TodoViewModel` 中集成：
```dart
import '../../services/calendar_service.dart';

class TodoViewModel extends ChangeNotifier {
  final CalendarService _calendarService = CalendarService();
  
  Future<void> addTodo(...) async {
    // 创建待办...
    
    // 同步到日历
    await _syncToCalendarIfEnabled(todo);
  }
}
```

### 测试检查清单
- [ ] 请求权限成功
- [ ] 拒绝权限后的处理
- [ ] 打卡记录正确同步
- [ ] 番茄钟记录正确同步
- [ ] 开关状态正确保存
- [ ] 关闭同步后不再创建事件
- [ ] 在系统日历中正确显示

---

## 📚 相关文档

- [device_calendar 插件文档](https://pub.dev/packages/device_calendar)
- [iOS 日历权限说明](https://developer.apple.com/documentation/eventkit)
- [项目 CHANGELOG](./CHANGELOG.md)

---

**最后更新**: 2025-11-09  
**功能状态**: ✅ 已完成（iOS/macOS）  
**维护者**: Memo 开发团队

