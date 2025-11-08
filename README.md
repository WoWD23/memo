# Memo - 打卡 & 番茄钟应用

一个简洁优雅的打卡和番茄钟管理应用，帮助你养成良好的时间管理习惯。

## ✨ 功能特性

### 打卡功能
- ✅ 每日多次打卡记录
- ✅ 打卡备注功能
- ✅ 打卡历史查看
- ✅ 本地数据存储

### 番茄钟功能
- ⏰ 25分钟工作计时器
- 🍅 5分钟短休息
- 🌙 15分钟长休息
- 📊 番茄钟历史统计
- 🔔 倒计时结束提醒

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

**重要**: 如果你在国内开发，请先配置Flutter镜像源，详见 [FLUTTER_ENV_SETUP.md](./FLUTTER_ENV_SETUP.md)

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

## 📊 开发里程碑

查看 [MILESTONE.md](./MILESTONE.md) 了解版本规划和开发进度。

## 📖 设计文档

- [设计规范](./docs/DESIGN.md)
- [实现计划](./docs/IMPLEMENTATION_PLAN.md)

## 📝 许可证

本项目为私有项目。

## 👥 贡献

欢迎提交 Issue 和 Pull Request！

---

**最后更新**: 2024-XX-XX
