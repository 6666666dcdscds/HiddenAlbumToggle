# Hidden Album Toggle - iOS 控制中心模块

一个用于在控制中心快速切换"已隐藏"相簿显示状态的 iOS 越狱插件。

## 功能特性

- ✅ 在控制中心添加自定义模块
- ✅ 一键切换照片应用中"已隐藏"相簿的显示状态
- ✅ 实时同步系统设置（设置 → 照片 → 显示"已隐藏"相簿）
- ✅ 支持 iOS 16
- ✅ 兼容 RootHide 越狱框架
- ✅ 使用 SF Symbols 图标（眼睛图标）
- ✅ 触觉反馈支持

## 系统要求

- iOS 16.0 或更高版本
- RootHide 越狱环境
- Theos 开发环境（用于编译）

## 编译说明

### 1. 安装 Theos

如果你还没有安装 Theos，请按照以下步骤操作：

```bash
# macOS/Linux
export THEOS=/opt/theos
git clone --recursive https://github.com/theos/theos.git $THEOS

# 设置环境变量（添加到 ~/.bash_profile 或 ~/.zshrc）
export THEOS=/opt/theos
export PATH=$THEOS/bin:$PATH
```

### 2. 配置 iOS SDK

确保你有 iOS 16 SDK。可以从 Xcode 中提取或下载预编译的 SDK。

```bash
# 将 SDK 放置在以下位置
$THEOS/sdks/iPhoneOS16.5.sdk
```

### 3. 编译项目

```bash
# 进入项目目录
cd /path/to/HiddenAlbumToggle

# 清理之前的编译
make clean

# 编译项目
make

# 打包为 deb 文件
make package
```

编译成功后，会在 `packages` 目录下生成 `.deb` 安装包。

### 4. 安装到设备

#### 方法一：使用 Theos 直接安装（需要 SSH 连接）

```bash
# 设置设备 IP
export THEOS_DEVICE_IP=192.168.1.xxx
export THEOS_DEVICE_PORT=22

# 安装到设备
make package install
```

#### 方法二：手动安装

1. 将生成的 `.deb` 文件传输到 iOS 设备
2. 使用 Filza 或终端安装：

```bash
# SSH 到设备后执行
dpkg -i com.yourname.hiddenalbumtoggle_1.0.0_iphoneos-arm64.deb

# 重启 SpringBoard
killall -9 SpringBoard
```

## 使用说明

### 1. 添加模块到控制中心

安装完成并重启 SpringBoard 后：

1. 打开 **设置** → **控制中心**
2. 在 **更多控制** 列表中找到 **"已隐藏相簿"**
3. 点击左侧的 **绿色加号** 添加到控制中心

### 2. 使用模块

1. 从屏幕右上角下拉打开控制中心
2. 找到 **已隐藏相簿** 模块（眼睛图标）
3. 点击切换状态：
   - **绿色 + 眼睛图标**：已隐藏相簿可见
   - **灰色 + 斜线眼睛图标**：已隐藏相簿隐藏

### 3. 验证效果

打开 **照片** 应用，检查 **相簿** 标签页中是否显示 **"已隐藏"** 相簿。

## 技术实现细节

### 核心组件

1. **HiddenAlbumToggleModule**：实现 `CCUIContentModule` 协议的控制中心模块
2. **HiddenAlbumToggleViewController**：管理模块的 UI 和交互逻辑
3. **偏好设置同步**：使用 `CFPreferences` API 读写照片应用设置

### 关键技术点

- **设置域**：`com.apple.mobileslideshow`
- **设置键**：`HiddenAlbumVisible`（Boolean 类型）
- **通知机制**：使用 Darwin Notification 通知照片应用刷新设置
- **模块大小**：1x1 紧凑型模块

### 文件结构

```
HiddenAlbumToggle/
├── Makefile                    # Theos 编译配置
├── control                     # Debian 包元数据
├── Info.plist                  # Bundle 信息
├── Tweak.x                     # 主要实现代码
├── ControlCenterUI.h           # 控制中心私有 API 头文件
├── Resources/
│   └── Info.plist             # 本地化资源
└── README.md                   # 本文档
```

## RootHide 兼容性

本插件已针对 RootHide 越狱环境进行优化：

- 使用标准的 Bundle 安装路径：`/Library/ControlCenter/Bundles`
- 依赖项包含 `com.roothide.loader`
- 使用系统 API 进行设置读写，无需特殊路径处理

## 故障排除

### 模块未出现在控制中心设置中

1. 确认插件已正确安装：`dpkg -l | grep hiddenalbumtoggle`
2. 检查 Bundle 是否存在：`ls /Library/ControlCenter/Bundles/HiddenAlbumToggle.bundle`
3. 重启 SpringBoard：`killall -9 SpringBoard`
4. 查看系统日志：`log stream --predicate 'processImagePath contains "SpringBoard"' --level debug`

### 切换无效

1. 检查照片应用权限
2. 手动验证设置：打开 **设置** → **照片** → **显示"已隐藏"相簿**
3. 查看偏好设置文件：`plutil -p /var/mobile/Library/Preferences/com.apple.mobileslideshow.plist`

### 编译错误

1. 确认 Theos 环境变量已正确设置
2. 检查 iOS SDK 版本是否匹配
3. 清理并重新编译：`make clean && make`

## 自定义修改

### 修改模块显示名称

编辑 `Info.plist` 中的 `SBIconDisplayName` 和 `CFBundleDisplayName` 键。

### 修改模块图标

在 `Tweak.x` 的 `createEyeIcon:` 方法中更改 SF Symbol 名称。

可用的图标示例：
- `photo.fill`
- `lock.fill`
- `eye.circle.fill`
- `photo.on.rectangle.angled`

### 修改模块颜色

在 `updateState` 方法中修改 `backgroundColor` 属性。

## 许可证

本项目仅供学习和研究使用。

## 作者

Your Name - 请在 `control` 文件中修改为你的信息

## 致谢

- Theos 开发团队
- iOS 越狱社区
- RootHide 开发者

