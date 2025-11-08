# Flutter 国内开发环境配置指南

由于网络原因，在国内开发Flutter应用时，建议使用国内镜像源来加速依赖包的下载。

## 🚀 快速开始

### 方法1: 使用配置脚本（推荐）

#### Windows PowerShell
```powershell
# 运行配置脚本
.\setup_flutter_env.ps1

# 然后运行
flutter pub get
```

#### Windows 命令行（CMD）
```cmd
# 运行配置脚本
setup_flutter_env.bat

# 然后运行
flutter pub get
```

### 方法2: 手动设置环境变量（当前会话）

#### PowerShell
```powershell
$env:PUB_HOSTED_URL="https://mirrors.tuna.tsinghua.edu.cn/dart-pub"
$env:FLUTTER_STORAGE_BASE_URL="https://mirrors.tuna.tsinghua.edu.cn/flutter"
flutter pub get
```

#### CMD
```cmd
set PUB_HOSTED_URL=https://mirrors.tuna.tsinghua.edu.cn/dart-pub
set FLUTTER_STORAGE_BASE_URL=https://mirrors.tuna.tsinghua.edu.cn/flutter
flutter pub get
```

### 方法3: 永久设置环境变量（推荐用于长期开发）

#### Windows 10/11 图形界面
1. 右键点击"此电脑" → "属性"
2. 点击"高级系统设置"
3. 点击"环境变量"
4. 在"用户变量"或"系统变量"中点击"新建"
5. 添加以下两个变量：
   - 变量名: `PUB_HOSTED_URL`
   - 变量值: `https://mirrors.tuna.tsinghua.edu.cn/dart-pub`
   
   - 变量名: `FLUTTER_STORAGE_BASE_URL`
   - 变量值: `https://mirrors.tuna.tsinghua.edu.cn/flutter`
6. 点击"确定"保存
7. 重启终端或IDE

#### PowerShell（永久设置）
```powershell
# 设置用户环境变量（永久）
[System.Environment]::SetEnvironmentVariable('PUB_HOSTED_URL', 'https://mirrors.tuna.tsinghua.edu.cn/dart-pub', 'User')
[System.Environment]::SetEnvironmentVariable('FLUTTER_STORAGE_BASE_URL', 'https://mirrors.tuna.tsinghua.edu.cn/flutter', 'User')
```

## 📦 可用的镜像源

### 清华大学镜像（推荐）
```powershell
PUB_HOSTED_URL=https://mirrors.tuna.tsinghua.edu.cn/dart-pub
FLUTTER_STORAGE_BASE_URL=https://mirrors.tuna.tsinghua.edu.cn/flutter
```

### 上海交大镜像（备选）
```powershell
PUB_HOSTED_URL=https://mirror.sjtu.edu.cn/dart-pub
FLUTTER_STORAGE_BASE_URL=https://mirror.sjtu.edu.cn/flutter
```

### 官方中国镜像（如果可用）
```powershell
PUB_HOSTED_URL=https://pub.flutter-io.cn
FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

## ✅ 验证配置

运行以下命令验证环境变量是否设置成功：

```powershell
# PowerShell
echo $env:PUB_HOSTED_URL
echo $env:FLUTTER_STORAGE_BASE_URL

# CMD
echo %PUB_HOSTED_URL%
echo %FLUTTER_STORAGE_BASE_URL%
```

## 🔧 取消镜像源（恢复官方源）

如果需要恢复使用官方源：

```powershell
# PowerShell
Remove-Item Env:\PUB_HOSTED_URL
Remove-Item Env:\FLUTTER_STORAGE_BASE_URL

# CMD
set PUB_HOSTED_URL=
set FLUTTER_STORAGE_BASE_URL=
```

## 📝 注意事项

1. **当前会话设置**: 使用 `$env:` 或 `set` 设置的变量只在当前终端会话有效
2. **永久设置**: 使用环境变量设置界面或 `SetEnvironmentVariable` 可以永久设置
3. **IDE设置**: 如果使用IDE（如VS Code、Android Studio），可能需要重启IDE才能生效
4. **镜像源选择**: 如果某个镜像源不稳定，可以尝试切换到其他镜像源

## 🐛 常见问题

### 问题1: 仍然无法下载依赖
- 检查网络连接
- 尝试切换到其他镜像源
- 检查防火墙设置

### 问题2: TLS/SSL错误
- 某些镜像源可能暂时不可用
- 尝试使用其他镜像源
- 检查系统时间是否正确

### 问题3: IDE中不生效
- 重启IDE
- 检查IDE是否读取了环境变量
- 在IDE的终端中手动设置环境变量

## 📚 参考资源

- [Flutter中文网](https://flutter.cn/)
- [清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/)
- [Flutter官方文档](https://docs.flutter.dev/)

