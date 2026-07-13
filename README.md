# PhotoLabelApp - 跨平台版本

一套代码，同时产出 Android APK 和 iOS IPA。

## 项目结构

```
ios_app/
├── lib/                          # Dart 业务代码
│   ├── main.dart                 # 入口 + 主题配置
│   ├── models/
│   │   └── label_config.dart     # LabelItem / PhotoInfo 数据模型
│   ├── services/
│   │   ├── label_config_service.dart  # JSON配置读写、标签增删
│   │   └── photo_saver_service.dart   # 照片按标签子目录存储
│   └── screens/
│       ├── home_screen.dart      # 主界面（标签选择 + 导航）
│       ├── camera_screen.dart    # 相机预览 + 自动命名拍照
│       ├── config_edit_screen.dart  # 标签增删管理
│       └── photo_view_screen.dart   # 照片缩略图网格 + 全屏查看
├── assets/labels_config.json     # 默认标签配置
├── ios/                          # iOS 原生配置
├── android/                      # Android 原生配置
├── build_android.bat             # Windows 一键构建 APK
├── build_android.sh              # macOS/Linux 构建 APK
└── build_ios.sh                  # macOS 构建 IPA + 安装说明
```

## 快速开始

### 0. 初始化项目（首次必须执行）
```bash
cd ios_app
flutter create --platforms android,ios .   # 生成原生平台文件
```

### 1. 安装依赖
```bash
flutter pub get    # 或 dart pub get
```

### 2. 构建 Android APK

**Windows：** 双击 `build_android.bat`
**或命令行：**
```bash
cd ios_app
flutter build apk --release
```
输出：`../build_output/PhotoLabelApp.apk`

### 3. 构建 iOS IPA（仅 macOS）

**前置条件：**
- macOS + Xcode 15+
- Apple Developer 账号（免费或付费均可）
- CocoaPods（`sudo gem install cocoapods`）

**步骤：**
```bash
# 1. 进入项目
cd ios_app

# 2. 获取依赖
flutter pub get
cd ios && pod install && cd ..

# 3. 构建
flutter build ios --release

# 4. 导出 IPA（手动信任安装）
cd ios
xcodebuild -workspace Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -archivePath ../build/ios/archive/Runner.xcarchive \
    archive \
    CODE_SIGN_STYLE=Manual \
    DEVELOPMENT_TEAM=YOUR_TEAM_ID \
    PROVISIONING_PROFILE_SPECIFIER="" \
    -allowProvisioningUpdates

xcodebuild -exportArchive \
    -archivePath ../build/ios/archive/Runner.xcarchive \
    -exportPath ../build/ios/ipa \
    -exportOptionsPlist ExportOptions_adhoc.plist \
    -allowProvisioningUpdates
```

或直接运行：`bash build_ios.sh`（需先修改其中的 TEAM_ID）

## iOS 手动信任安装

IPA 安装到 iPhone 后：

1. **安装 IPA 到手机：**
   - 用 Xcode → Window → Devices → 拖入 IPA
   - 或用 Apple Configurator 2
   - 或用 iMazing / 爱思助手等工具

2. **手动信任开发者证书：**
   - iPhone 上：设置 → 通用 → VPN与设备管理
   - 找到你的开发证书 → 点击"信任"
   - 确认信任

3. **信任后即可正常使用 App。**

## 功能说明

| 功能 | 说明 |
|------|------|
| 标签选择 | 主界面下拉菜单选择标签 |
| 自动命名 | 拍照后命名: `标签名_自增序号.jpg` |
| 序号持久化 | 序号保存在 labels_config.json，切换标签不丢失 |
| 标签管理 | 增删改标签，实时生效 |
| 照片查看 | 按标签分目录存储，网格缩略图 + 全屏查看 |

## 与 Android 原版的差异

| 项目 | Android 原版 | Flutter 跨平台版 |
|------|------------|-----------------|
| 语言 | Kotlin | Dart |
| 相机 | 系统 Intent | camera 插件 |
| UI | XML + ViewBinding | Widget |
| iOS | 不支持 | 支持 |
