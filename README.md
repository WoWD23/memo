# Memo - 效率管理应用

一个简洁优雅的效率管理应用，集成打卡、番茄钟和待办事项管理，帮助你养成良好的时间管理习惯，提升工作效率。

## ✨ 功能特性

### 📍 打卡功能
- ✅ 每日打卡记录
- ✅ 打卡备注功能
- ✅ 打卡历史查看
- ✅ 连续打卡统计
- ✅ 本地数据存储

### ⏰ 番茄钟功能
- ✅ 自定义时长的工作计时器（0-120分钟）
- ✅ 精美的时钟选择器界面
- ✅ 进度条可视化显示
- ✅ 可视化倒计时显示
- ✅ 暂停/继续/取消功能
- ✅ 番茄钟历史统计
- ✅ 倒计时结束提醒
- ✅ Tab 锁定功能（专注模式）
- ✅ 智能旋转边界限制

### ✅ 待办事项功能
- ✅ 添加/编辑/删除待办事项
- ✅ 优先级设置（低/中/高）
- ✅ 到期日期设置
- ✅ 完成状态切换
- ✅ 智能过滤（全部/今天/逾期/高优先级）
- ✅ 多种排序方式
- ✅ 滑动删除交互
- ✅ 逾期提醒

### 📅 日历视图
- ✅ 月份日历展示
- ✅ 打卡记录可视化
- ✅ 番茄钟记录统计
- ✅ 日期详情查看

### 🏠 首页概览
- ✅ 今日打卡状态
- ✅ 连续打卡天数
- ✅ 今日番茄钟统计
- ✅ 专注时长统计

### ⚙️ 设置功能
- ✅ 主题模式切换
- ✅ 番茄钟默认时长设置
- ✅ 使用统计查看
- ✅ 系统日历同步（iOS/macOS）

## 🏗️ 项目架构

- **架构模式**: MVVM (Model-View-ViewModel)
- **状态管理**: Provider + ChangeNotifier
- **数据存储**: SQLite (sqflite) + SharedPreferences
- **UI框架**: Flutter Material Design 3

## 📁 项目结构

```
lib/
├── core/           # 核心功能（主题、常量、数据库等）
├── models/         # 数据模型
├── services/       # 业务逻辑服务
├── repositories/   # 数据仓库
├── view_models/    # ViewModel（状态管理）
├── views/          # 页面视图
├── widgets/        # 可复用组件
└── utils/          # 工具函数
```

## 🚀 快速开始

### 环境要求

- Flutter SDK: >=3.9.2
- Dart SDK: >=3.9.2

### 安装依赖

#### 国内开发环境配置

**重要**: 如果你在国内开发，请先配置Flutter镜像源，详见 [FLUTTER_ENV_SETUP.md](./docs/FLUTTER_ENV_SETUP.md)

快速设置（PowerShell）:
```powershell
.\setup_flutter_env.ps1
flutter pub get
```

或手动设置:
```powershell
$env:PUB_HOSTED_URL="https://mirrors.tuna.tsinghua.edu.cn/dart-pub"
$env:FLUTTER_STORAGE_BASE_URL="https://mirrors.tuna.tsinghua.edu.cn/flutter"
flutter pub get
```

#### 安装依赖包

```bash
flutter pub get
```

### 运行应用

```bash
flutter run
```

## 📱 支持的平台

- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ Web

## 🛠️ 开发规范

项目遵循严格的开发规范，详见 [rules/.rules](./rules/.rules)

### 代码风格
- 使用 `dart format` 自动格式化
- 单引号优先
- snake_case 文件命名
- PascalCase 类命名
- camelCase 变量和函数命名

### Git 提交规范
```
<type>(<scope>): <subject>

示例:
feat(checkin): 添加每日打卡功能
fix(pomodoro): 修复番茄钟暂停后恢复时间错误
```

## 📚 文档

> 📖 **[查看完整文档索引](./docs/README.md)** - 包含所有文档的详细说明和快速导航

### 核心文档
- [开发里程碑](./docs/MILESTONE.md) - 版本规划和开发进度
- [更新日志](./docs/CHANGELOG.md) - 版本更新历史
- [功能特性](./docs/FEATURES.md) - 详细功能说明和使用指南
- [设计规范](./docs/DESIGN.md) - UI/UX 设计规范
- [实现计划](./docs/IMPLEMENTATION_PLAN.md) - 技术实现计划

### 快速开始
- [Flutter 环境配置](./docs/FLUTTER_ENV_SETUP.md) - 国内镜像源配置
- [Git 配置指南](./docs/GIT_SETUP.md) - Git 提交规范和配置

## 📝 许可证

本项目为私有项目。

## 👥 贡献

欢迎提交 Issue 和 Pull Request！

---

**最后更新**: 2025-11-09  
**版本**: v1.0.0 (开发中)  
**状态**: ✅ 核心功能已完成
