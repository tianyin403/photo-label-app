@echo off
REM ============================================
REM PhotoLabelApp - Android APK 构建脚本 (Windows)
REM ============================================
echo === 摄影标签管理 APK 构建 (Windows) ===

cd /d "%~dp0"

echo [1/4] 初始化原生平台文件...
call flutter create --platforms android .
if %ERRORLEVEL% neq 0 (
    echo 错误: flutter create 失败
    pause
    exit /b 1
)

echo [2/4] 安装 Flutter 依赖...
call flutter pub get
if %ERRORLEVEL% neq 0 (
    echo 错误: flutter pub get 失败
    pause
    exit /b 1
)

echo.
echo [3/4] 构建 Release APK...
call flutter build apk --release
if %ERRORLEVEL% neq 0 (
    echo 错误: APK 构建失败
    pause
    exit /b 1
)

echo.
echo [4/4] 复制产物...
if not exist "..\build_output" mkdir "..\build_output"
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "..\build_output\PhotoLabelApp.apk"

echo.
echo === 构建完成! ===
echo APK 位置: build_output\PhotoLabelApp.apk
echo.
pause
