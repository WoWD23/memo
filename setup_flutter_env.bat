@echo off
REM Flutter 国内开发环境配置脚本（批处理版本）
REM 使用方法: 双击运行或在命令行中执行 setup_flutter_env.bat

REM 设置Flutter国内镜像源（清华大学镜像）
set PUB_HOSTED_URL=https://mirrors.tuna.tsinghua.edu.cn/dart-pub
set FLUTTER_STORAGE_BASE_URL=https://mirrors.tuna.tsinghua.edu.cn/flutter

REM 或者使用上海交大镜像（备选）
REM set PUB_HOSTED_URL=https://mirror.sjtu.edu.cn/dart-pub
REM set FLUTTER_STORAGE_BASE_URL=https://mirror.sjtu.edu.cn/flutter

echo Flutter环境变量已设置:
echo PUB_HOSTED_URL = %PUB_HOSTED_URL%
echo FLUTTER_STORAGE_BASE_URL = %FLUTTER_STORAGE_BASE_URL%
echo.
echo 现在可以运行: flutter pub get
pause

