#!/bin/bash
# ============================================
# PhotoLabelApp - iOS IPA 构建脚本
# 环境: macOS + Xcode 15+ + Flutter
# 分发方式: 企业签名 / Ad-Hoc（手动信任安装）
# ============================================

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "=== 摄影标签管理 iOS IPA 构建 ==="
echo "项目目录: $PROJECT_DIR"

# 配置参数（根据实际情况修改）
BUNDLE_ID="com.photoapp.photo_label_app"
TEAM_ID="YOUR_TEAM_ID"       # Apple Developer Team ID
PROVISIONING_PROFILE=""       # 描述文件路径（可选）

echo ""
echo "请确认以下配置:"
echo "  Bundle ID: $BUNDLE_ID"
echo "  Team ID:   $TEAM_ID"
echo "  分发方式:  enterprise / ad-hoc"
echo ""

# 1. 获取依赖
echo "[1/6] 安装 Flutter 依赖..."
cd "$PROJECT_DIR"
flutter pub get

# 2. iOS pods
echo ""
echo "[2/6] 安装 CocoaPods 依赖..."
cd "$PROJECT_DIR/ios"
pod install --repo-update
cd "$PROJECT_DIR"

# 3. 构建 iOS App
echo ""
echo "[3/6] 构建 Release iOS App..."
flutter build ios --release --no-codesign

# 4. 归档
echo ""
echo "[4/6] 创建 xcarchive..."
cd "$PROJECT_DIR/ios"
xcodebuild -workspace Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -archivePath "$PROJECT_DIR/build/ios/archive/Runner.xcarchive" \
    archive \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    PROVISIONING_PROFILE_SPECIFIER="" \
    -allowProvisioningUpdates

# 5. 导出 IPA (企业分发 - 手动信任安装)
echo ""
echo "[5/6] 导出 IPA..."

# 企业分发方式 (手动信任安装)
if [ -f "$PROJECT_DIR/ios/ExportOptions.plist" ]; then
    EXPORT_PLIST="$PROJECT_DIR/ios/ExportOptions.plist"
else
    EXPORT_PLIST="$PROJECT_DIR/ios/ExportOptions_adhoc.plist"
fi

xcodebuild -exportArchive \
    -archivePath "$PROJECT_DIR/build/ios/archive/Runner.xcarchive" \
    -exportPath "$PROJECT_DIR/build/ios/ipa" \
    -exportOptionsPlist "$EXPORT_PLIST" \
    -allowProvisioningUpdates

# 6. 复制产物
echo ""
echo "[6/6] 复制产物..."
OUTPUT_DIR="$PROJECT_DIR/../build_output"
mkdir -p "$OUTPUT_DIR"

IPA_PATH="$PROJECT_DIR/build/ios/ipa/photo_label_app.ipa"
if [ -f "$IPA_PATH" ]; then
    cp "$IPA_PATH" "$OUTPUT_DIR/PhotoLabelApp.ipa"
    echo "IPA 已输出至: $OUTPUT_DIR/PhotoLabelApp.ipa"
    echo ""
    echo "=== iOS 安装说明 (手动信任) ==="
    echo "1. 将 IPA 文件通过以下方式安装到 iPhone:"
    echo "   - Apple Configurator 2 (Mac)"
    echo "   - Xcode → Window → Devices and Simulators → 拖入 IPA"
    echo "   - 第三方工具: iMazing / 爱思助手"
    echo "2. 安装后在 iPhone 上:"
    echo "   设置 → 通用 → VPN与设备管理"
    echo "   → 找到你的企业证书 → 点击信任"
    echo "3. 信任后即可正常打开 App"
else
    echo "错误: IPA 导出失败"
    exit 1
fi

echo ""
echo "=== 构建完成 ==="
