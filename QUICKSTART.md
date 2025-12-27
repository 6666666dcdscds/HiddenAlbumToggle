# 快速开始指南

## 一、编译前准备

### 1. 确认 Theos 环境

```bash
# 检查 THEOS 环境变量
echo $THEOS

# 如果未设置，请设置：
export THEOS=/opt/theos
```

### 2. 修改个人信息

编辑 `control` 文件，修改以下字段：

```
Package: com.yourname.hiddenalbumtoggle  # 改为你的包名
Maintainer: Your Name                     # 改为你的名字
Author: Your Name                         # 改为你的名字
```

同时修改 `Info.plist` 中的 `CFBundleIdentifier`。

## 二、编译步骤

```bash
# 1. 清理旧文件
make clean

# 2. 编译
make

# 3. 打包
make package
```

## 三、安装到设备

### 方法 A：SSH 直接安装（推荐）

```bash
# 设置设备 IP（替换为你的设备 IP）
export THEOS_DEVICE_IP=192.168.1.100

# 安装
make package install
```

### 方法 B：手动安装

1. 在 `packages/` 目录找到生成的 `.deb` 文件
2. 使用 AirDrop、Filza 等工具传输到 iOS 设备
3. 使用 Filza 打开并安装，或通过 SSH：

```bash
dpkg -i com.yourname.hiddenalbumtoggle_1.0.0_iphoneos-arm64.deb
killall -9 SpringBoard
```

## 四、使用

1. **设置** → **控制中心** → 找到 **"已隐藏相簿"**
2. 点击 **+** 添加到控制中心
3. 下拉控制中心，点击模块切换状态

## 五、验证

打开 **照片** 应用 → **相簿** 标签，检查 **"已隐藏"** 相簿是否显示/隐藏。

## 常见问题

**Q: 编译时提示找不到 SDK？**

A: 下载 iOS SDK 并放置到 `$THEOS/sdks/` 目录。

**Q: 模块不显示在控制中心设置中？**

A: 
1. 检查 Bundle 是否安装：`ls /Library/ControlCenter/Bundles/`
2. 重启 SpringBoard：`killall -9 SpringBoard`
3. 查看日志：`log stream --predicate 'processImagePath contains "SpringBoard"'`

**Q: 点击模块没有反应？**

A: 检查照片应用权限，或查看系统日志排查问题。

## 调试技巧

### 查看日志

```bash
# 实时查看 SpringBoard 日志
log stream --predicate 'processImagePath contains "SpringBoard"' --level debug

# 过滤插件日志
log stream --predicate 'eventMessage contains "HiddenAlbumToggle"'
```

### 检查偏好设置

```bash
# 查看照片应用设置
plutil -p /var/mobile/Library/Preferences/com.apple.mobileslideshow.plist | grep Hidden
```

### 手动测试设置读写

```bash
# 写入设置
defaults write com.apple.mobileslideshow HiddenAlbumVisible -bool YES

# 读取设置
defaults read com.apple.mobileslideshow HiddenAlbumVisible

# 通知照片应用
killall -9 MobileSlideShow
```

## 进阶定制

### 更改图标

编辑 `Tweak.x` 第 139 行的 `createEyeIcon:` 方法：

```objc
NSString *symbolName = visible ? @"photo.fill" : @"photo.slash.fill";
```

### 更改颜色

编辑 `Tweak.x` 第 99-105 行：

```objc
_toggleButton.backgroundColor = [UIColor systemBlueColor];  // 改为你喜欢的颜色
```

### 更改模块大小

编辑 `Info.plist` 中的 `CCUIModuleSize`，可设置为 2x2 或其他尺寸。

## 卸载

```bash
# SSH 到设备
dpkg -r com.yourname.hiddenalbumtoggle
killall -9 SpringBoard
```

或使用 Cydia/Sileo 等包管理器卸载。

