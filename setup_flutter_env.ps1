# Flutter 国内开发环境配置脚本
# 使用方法: 在PowerShell中运行 .\setup_flutter_env.ps1

# 设置Flutter国内镜像源（清华大学镜像）
$env:PUB_HOSTED_URL = "https://mirrors.tuna.tsinghua.edu.cn/dart-pub"
$env:FLUTTER_STORAGE_BASE_URL = "https://mirrors.tuna.tsinghua.edu.cn/flutter"

# 或者使用上海交大镜像（备选）
# $env:PUB_HOSTED_URL = "https://mirror.sjtu.edu.cn/dart-pub"
# $env:FLUTTER_STORAGE_BASE_URL = "https://mirror.sjtu.edu.cn/flutter"

# 或者使用官方中国镜像（如果可用）
# $env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
# $env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"

Write-Host "Flutter环境变量已设置:" -ForegroundColor Green
Write-Host "PUB_HOSTED_URL = $env:PUB_HOSTED_URL"
Write-Host "FLUTTER_STORAGE_BASE_URL = $env:FLUTTER_STORAGE_BASE_URL"
Write-Host ""
Write-Host "现在可以运行: flutter pub get" -ForegroundColor Yellow

