# 项目结构说明

## 文件清单

```
HiddenAlbumToggle/
│
├── Makefile                          # Theos 编译配置文件
├── control                           # Debian 包元数据（包名、版本、依赖等）
├── Info.plist                        # Bundle 主配置文件
├── Tweak.x                           # 主要实现代码（Objective-C++）
├── ControlCenterUI.h                 # 控制中心私有 API 头文件声明
│
├── Resources/                        # 资源文件夹
│   └── Info.plist                   # 本地化资源配置
│
├── .theos/                          # Theos 构建目录（自动生成）
│   └── package/DEBIAN/
│       ├── postinst                 # 安装后脚本
│       └── postrm                   # 卸载后脚本
│
├── README.md                         # 完整文档
├── QUICKSTART.md                     # 快速开始指南
└── PROJECT_STRUCTURE.md              # 本文件
```

## 核心文件说明

### 1. Makefile

定义编译配置：
- **TARGET**: iOS 版本和架构
- **BUNDLE_NAME**: Bundle 名称
- **FRAMEWORKS**: 链接的系统框架
- **INSTALL_PATH**: 安装路径

### 2. control

Debian 包元数据：
- **Package**: 唯一包标识符
- **Name**: 显示名称
- **Version**: 版本号
- **Depends**: 依赖项（包括 RootHide）
- **Section**: 分类

### 3. Info.plist

Bundle 配置：
- **CFBundleIdentifier**: Bundle ID
- **CCUIModuleIdentifier**: 控制中心模块 ID
- **CCUIModuleSize**: 模块尺寸（1x1）
- **SBIconDisplayName**: 显示名称

### 4. Tweak.x

主要实现代码，包含：

#### 类定义

- **HiddenAlbumToggleModule**: 实现 `CCUIContentModule` 协议
  - 控制中心模块的主类
  - 提供视图控制器
  - 定义模块属性

- **HiddenAlbumToggleViewController**: 继承 `UIViewController`
  - 管理 UI 界面
  - 处理用户交互
  - 读写系统设置

#### 关键方法

- `init`: 初始化模块
- `viewDidLoad`: 创建 UI 界面
- `updateState`: 读取并更新当前状态
- `toggleButtonTapped`: 处理点击事件
- `createEyeIcon:`: 创建图标

#### 入口函数

- `HiddenAlbumToggleModuleCreate()`: 模块创建函数
- `%ctor`: 构造函数（模块加载时执行）

### 5. ControlCenterUI.h

私有 API 声明：
- `CCUIContentModule` 协议
- `CCUIContentModuleContext` 协议
- 相关类和方法声明

## 编译流程

```
源代码 (Tweak.x)
    ↓
Theos 预处理 (logos)
    ↓
编译为动态库 (.dylib)
    ↓
创建 Bundle (.bundle)
    ↓
打包为 Debian 包 (.deb)
    ↓
安装到设备
```

## 安装后的文件位置

```
iOS 设备文件系统：

/Library/ControlCenter/Bundles/
└── HiddenAlbumToggle.bundle/
    ├── HiddenAlbumToggle          # 可执行文件（动态库）
    ├── Info.plist                 # Bundle 配置
    └── Resources/
        └── Info.plist             # 本地化资源

/var/mobile/Library/Preferences/
└── com.apple.mobileslideshow.plist  # 照片应用设置（读写目标）
```

## 工作原理

### 1. 模块注册

- SpringBoard 启动时扫描 `/Library/ControlCenter/Bundles/`
- 读取 `Info.plist` 中的 `CCUIModuleIdentifier`
- 调用 `HiddenAlbumToggleModuleCreate()` 创建模块实例

### 2. 用户添加模块

- 用户在 **设置 → 控制中心** 中添加模块
- SpringBoard 加载模块的视图控制器
- 显示在控制中心界面

### 3. 状态读取

```objc
CFPreferencesGetAppBooleanValue(
    "HiddenAlbumVisible",
    "com.apple.mobileslideshow",
    &keyExists
)
```

### 4. 状态写入

```objc
CFPreferencesSetAppValue(
    "HiddenAlbumVisible",
    @(newValue),
    "com.apple.mobileslideshow"
)
CFPreferencesAppSynchronize("com.apple.mobileslideshow")
```

### 5. 通知照片应用

```objc
CFNotificationCenterPostNotification(
    CFNotificationCenterGetDarwinNotifyCenter(),
    "com.apple.mobileslideshow.PreferenceChanged",
    NULL, NULL, YES
)
```

## 依赖关系

```
HiddenAlbumToggle
    ├── mobilesubstrate (Cydia Substrate)
    ├── firmware >= 16.0 (iOS 16+)
    ├── com.roothide.loader (RootHide)
    │
    └── 系统框架
        ├── UIKit.framework
        ├── CoreFoundation.framework
        └── ControlCenterUIKit.framework (私有)
```

## 调试信息

### 日志输出

模块加载时会输出：
```
[HiddenAlbumToggle] Module loaded successfully
```

### 查看日志命令

```bash
log stream --predicate 'eventMessage contains "HiddenAlbumToggle"'
```

### 验证安装

```bash
# 检查 Bundle 是否存在
ls -la /Library/ControlCenter/Bundles/HiddenAlbumToggle.bundle/

# 检查可执行文件
file /Library/ControlCenter/Bundles/HiddenAlbumToggle.bundle/HiddenAlbumToggle

# 检查包是否安装
dpkg -l | grep hiddenalbumtoggle
```

## 自定义开发指南

### 修改功能

1. **更改控制的设置项**：修改 `kPhotosSettingsDomain` 和 `kHiddenAlbumKey`
2. **更改模块尺寸**：修改 `Info.plist` 中的 `CCUIModuleSize`
3. **添加展开视图**：实现 `preferredExpandedContentHeight` 返回非零值

### 添加新功能

1. 在 `HiddenAlbumToggleViewController` 中添加新方法
2. 在 `viewDidLoad` 中初始化新 UI 元素
3. 在 `updateState` 中更新新状态

### 调试技巧

1. 使用 `NSLog()` 输出调试信息
2. 使用 `log stream` 实时查看日志
3. 使用 `lldb` 附加到 SpringBoard 进程调试

## 常见修改场景

### 场景 1：更改为 2x2 模块

修改 `Info.plist`：
```xml
<key>CCUIModuleSize</key>
<dict>
    <key>Portrait</key>
    <dict>
        <key>Height</key>
        <integer>2</integer>
        <key>Width</key>
        <integer>2</integer>
    </dict>
</dict>
```

### 场景 2：添加长按菜单

在 `Tweak.x` 中添加：
```objc
- (UIContextMenuConfiguration *)contextMenuConfiguration {
    // 实现上下文菜单
}
```

### 场景 3：控制其他应用设置

修改：
```objc
#define kPhotosSettingsDomain @"com.other.app"
#define kHiddenAlbumKey @"OtherSettingKey"
```

## 版本历史

- **v1.0.0**: 初始版本
  - 基础切换功能
  - iOS 16 支持
  - RootHide 兼容

