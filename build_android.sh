#!/bin/bash
# ============================================
# PhotoLabelApp - Android APK 构建脚本
# 环境: Windows (Git Bash) / macOS / Linux
# ============================================

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "=== 摄影标签管理 APK 构建 ==="
echo "项目目录: $PROJECT_DIR"

# 1. 获取依赖
echo ""
echo "[1/3] 安装 Flutter 依赖..."
cd "$PROJECT_DIR"
flutter pub get

# 2. 构建 APK
echo ""
echo "[2/3] 构建 Release APK..."
flutter build apk --release

# 3. 复制到输出目录
echo ""
echo "[3/3] 复制产物..."
OUTPUT_DIR="$PROJECT_DIR/../build_output"
mkdir -p "$OUTPUT_DIR"

APK_PATH="$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
    cp "$APK_PATH" "$OUTPUT_DIR/PhotoLabelApp-release.apk"
    echo "APK 已输出至: $OUTPUT_DIR/PhotoLabelApp-release.apk"
else
    echo "错误: APK 构建失败"
    exit 1
fi

echo ""
echo "=== 构建完成 ==="
