# Video Vocab - 看视频学英语

一款通过看英语视频来学习词汇的 App。点击字幕中的单词即可查词、保存，并通过间隔重复进行复习。

## 功能特性

- **视频播放** — 导入本地视频或通过链接下载（支持 B站、头条/抖音/西瓜视频）
- **智能字幕** — 自动生成英语字幕（基于 Whisper 语音识别），支持导入 SRT/VTT 字幕文件
- **点词查询** — 点击字幕中任意单词，即时查看释义和音标
- **生词本** — 保存单词时自动记录视频上下文、时间戳和截图
- **间隔复习** — 基于 SM-2 算法的间隔重复系统，科学记忆
- **字幕定位** — 可拖拽字幕条覆盖视频原始字幕
- **应用升级** — 检测新版本并引导下载更新

## 支持平台

| 平台 | 状态 |
|------|------|
| Android | ✅ APK 可用 |
| iOS | ✅ 需 Xcode 签名 |
| macOS | ✅ |
| Linux | ✅ |

## 截图

> 待补充

## 快速开始

### 环境要求

- Flutter SDK >= 3.4.0
- Dart SDK >= 3.4.0
- Xcode（macOS/iOS 构建）
- Android Studio（Android 构建）

### 安装与运行

```bash
# 克隆仓库
git clone <repo-url>
cd vedio_vocap_app

# 安装依赖
flutter pub get

# 生成数据库代码（修改 tables.dart 后需重新执行）
dart run build_runner build

# 运行
flutter run -d macos      # macOS
flutter run -d chrome     # Web
flutter run               # 连接的设备
```

### 打包发布

```bash
# Android APK
flutter build apk --release

# macOS App
flutter build macos --release

# iOS（需在 Xcode 中配置签名）
flutter build ios --release
```

## 技术架构

```
lib/
├── core/              # 框架层：路由、主题、工具函数
│   ├── router/        # GoRouter 路由配置 + 底部导航
│   ├── theme/         # 颜色、主题定义
│   └── utils/         # SM-2 算法、SRT 解析器
├── data/              # 数据层：数据库、模型、仓储
│   ├── database/      # Drift SQLite ORM + 代码生成
│   ├── models/        # SubtitleCue, WordDefinition
│   └── repositories/  # VideoRepository, WordRepository
├── services/          # 业务逻辑层
│   ├── player_service.dart       # 播放器状态管理
│   ├── dictionary_service.dart   # 词典查询（Free Dictionary API）
│   ├── bilibili_service.dart     # B站视频解析下载
│   ├── toutiao_service.dart      # 头条/抖音视频解析
│   ├── whisper_service.dart      # 语音识别生成字幕
│   ├── video_import_service.dart # 导入流程编排
│   └── upgrade_service.dart      # 应用更新检测
└── presentation/      # UI 层
    ├── home/          # 视频库首页
    ├── player/        # 视频播放器 + 字幕覆盖层
    ├── library/       # 生词本
    ├── review/        # 间隔复习
    ├── settings/      # 设置页面
    └── widgets/       # 共享组件
```

### 技术栈

| 类别 | 技术方案 |
|------|---------|
| 状态管理 | Riverpod |
| 路由 | GoRouter |
| 视频播放 | media_kit |
| 数据库 | Drift (SQLite) |
| 语音识别 | whisper_flutter_new (移动端) / whisper CLI (桌面端) |
| 字体 | Inter SemiBold（跨平台一致性） |

### 数据流

1. 用户导入视频 → 保存元数据到 SQLite，生成缩略图
2. 打开视频 → media_kit 加载播放，解析 SRT 字幕为 `SubtitleCue` 列表
3. 点击字幕单词 → 查询 Free Dictionary API（本地缓存优先），弹出释义
4. 保存单词 → 创建 WordCard（含释义、上下文、截图、SM-2 初始参数）
5. 复习单词 → 获取到期卡片，用户评分后 SM-2 算法更新复习间隔

## 视频导入方式

| 来源 | 方式 | 平台 |
|------|------|------|
| B站 | 粘贴分享链接，API 解析 | 全平台 |
| 头条/抖音/西瓜 | 粘贴分享链接，页面解析 | 全平台 |
| 其他平台 | yt-dlp 下载 | 仅桌面端 |
| 本地文件 | 文件选择器 | 全平台 |

## 字幕生成

- **移动端**：使用 whisper.cpp（通过 whisper_flutter_new），首次使用自动下载 tiny 模型（~75MB）
- **桌面端**：调用系统安装的 `whisper` 命令行工具

## 开发说明

- 修改数据库表结构后执行 `dart run build_runner build` 重新生成代码
- 修改 schema 需在 `app_database.dart` 中递增 `schemaVersion` 并添加迁移逻辑
- UI 语言为简体中文

## License

Private project. All rights reserved.
