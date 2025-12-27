# 技术实现说明

## iOS 控制中心架构

### 控制中心模块类型

iOS 控制中心支持多种模块类型：

1. **Toggle Module（开关模块）**
   - 简单的开/关状态
   - 单次点击切换
   - 示例：WiFi、蓝牙、飞行模式

2. **Slider Module（滑块模块）**
   - 连续值调节
   - 示例：亮度、音量

3. **Custom Module（自定义模块）**
   - 完全自定义 UI
   - 可展开为详细视图
   - 本项目采用此类型

### 模块生命周期

```
1. SpringBoard 启动
   ↓
2. 扫描 /Library/ControlCenter/Bundles/
   ↓
3. 读取 Info.plist 注册模块
   ↓
4. 用户添加模块到控制中心
   ↓
5. 调用 ModuleCreate() 函数
   ↓
6. 创建 ViewController
   ↓
7. 显示在控制中心
```

## 关键 API 说明

### CCUIContentModule 协议

这是所有控制中心模块必须实现的核心协议：

```objc
@protocol CCUIContentModule <NSObject>
@required
- (UIViewController *)contentViewController;

@optional
- (CGFloat)preferredExpandedContentHeight;
- (CGFloat)preferredExpandedContentWidth;
- (BOOL)providesOwnPlatter;
- (void)setContentModuleContext:(id<CCUIContentModuleContext>)context;
@end
```

**关键方法解释：**

- `contentViewController`: 返回模块的视图控制器
- `preferredExpandedContentHeight`: 展开时的高度（返回 0 表示不展开）
- `providesOwnPlatter`: 是否提供自定义背景（通常返回 NO）
- `setContentModuleContext`: 接收控制中心上下文对象

### CCUIContentModuleContext 协议

控制中心提供给模块的上下文接口：

```objc
@protocol CCUIContentModuleContext <NSObject>
- (void)enqueueStatusUpdate:(id)update;
- (void)dismissModule;
- (void)requestExpandModule;
- (void)requestAuthenticationWithCompletionHandler:(void (^)(BOOL))completion;
@end
```

**用途：**

- `enqueueStatusUpdate`: 更新模块状态（如图标、颜色）
- `dismissModule`: 关闭控制中心
- `requestExpandModule`: 请求展开模块
- `requestAuthenticationWithCompletionHandler`: 请求用户认证（Face ID/Touch ID）

## 照片应用设置机制

### 设置存储位置

```
/var/mobile/Library/Preferences/com.apple.mobileslideshow.plist
```

### 关键设置项

```xml
<key>HiddenAlbumVisible</key>
<true/> 或 <false/>
```

### 读取设置

```objc
CFPreferencesAppSynchronize(CFSTR("com.apple.mobileslideshow"));

Boolean keyExists = false;
Boolean value = CFPreferencesGetAppBooleanValue(
    CFSTR("HiddenAlbumVisible"),
    CFSTR("com.apple.mobileslideshow"),
    &keyExists
);

// 默认值处理
BOOL isVisible = keyExists ? (BOOL)value : YES;
```

### 写入设置

```objc
CFPreferencesSetAppValue(
    CFSTR("HiddenAlbumVisible"),
    (__bridge CFTypeRef)@(YES),  // 或 @(NO)
    CFSTR("com.apple.mobileslideshow")
);

// 立即同步到磁盘
CFPreferencesAppSynchronize(CFSTR("com.apple.mobileslideshow"));
```

### 通知机制

照片应用使用 Darwin Notification 监听设置变化：

```objc
CFNotificationCenterPostNotification(
    CFNotificationCenterGetDarwinNotifyCenter(),
    CFSTR("com.apple.mobileslideshow.PreferenceChanged"),
    NULL,
    NULL,
    YES  // deliverImmediately
);
```

## RootHide 兼容性

### RootHide 简介

RootHide 是一种新型越狱方案，特点：
- 隐藏越狱文件系统
- 路径重定向
- 更好的安全性

### 兼容要点

1. **依赖声明**
   ```
   Depends: com.roothide.loader
   ```

2. **标准路径使用**
   - 使用系统标准路径：`/Library/ControlCenter/Bundles/`
   - RootHide 会自动处理路径重定向

3. **API 使用**
   - 使用系统 API（CFPreferences）而非直接文件操作
   - 避免硬编码路径

## UI 实现细节

### 按钮设计

```objc
_toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
_toggleButton.frame = self.view.bounds;
_toggleButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
_toggleButton.layer.cornerRadius = 16.0;
_toggleButton.clipsToBounds = YES;
```

### 状态颜色

- **启用状态**: `systemGreenColor` (绿色)
- **禁用状态**: `systemGrayColor` (灰色)

可自定义为其他颜色：
```objc
[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]  // 自定义蓝色
```

### SF Symbols 图标

iOS 13+ 支持 SF Symbols 系统图标：

```objc
UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration 
    configurationWithPointSize:24 
    weight:UIImageSymbolWeightMedium];

UIImage *image = [UIImage systemImageNamed:@"eye.fill" 
                          withConfiguration:config];
```

**常用图标：**
- `eye.fill` - 眼睛（可见）
- `eye.slash.fill` - 斜线眼睛（隐藏）
- `photo.fill` - 照片
- `lock.fill` - 锁
- `checkmark.circle.fill` - 勾选

### 触觉反馈

```objc
UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] 
    initWithStyle:UIImpactFeedbackStyleMedium];
[feedback impactOccurred];
```

**反馈样式：**
- `UIImpactFeedbackStyleLight` - 轻
- `UIImpactFeedbackStyleMedium` - 中
- `UIImpactFeedbackStyleHeavy` - 重

## 编译优化

### ARC 支持

```makefile
HiddenAlbumToggle_CFLAGS = -fobjc-arc
```

启用自动引用计数，无需手动管理内存。

### 架构支持

```makefile
ARCHS = arm64 arm64e
```

- `arm64`: A7-A11 芯片（iPhone 5s - iPhone X）
- `arm64e`: A12+ 芯片（iPhone XS 及更新）

### 最小系统版本

```makefile
TARGET := iphone:clang:16.5:16.0
```

格式：`平台:编译器:SDK版本:最小系统版本`

## 调试技巧

### 添加日志

```objc
NSLog(@"[HiddenAlbumToggle] Current state: %d", _isEnabled);
NSLog(@"[HiddenAlbumToggle] Button tapped");
```

### 查看日志

```bash
# 实时日志
log stream --predicate 'eventMessage contains "HiddenAlbumToggle"' --level debug

# 过滤 SpringBoard
log stream --predicate 'processImagePath contains "SpringBoard"' --level debug
```

### 断点调试

```bash
# 附加到 SpringBoard
lldb -p $(pgrep SpringBoard)

# 设置断点
(lldb) br set -n "-[HiddenAlbumToggleViewController toggleButtonTapped]"

# 继续执行
(lldb) c
```

### 检查内存

```bash
# 查看 SpringBoard 内存使用
top -pid $(pgrep SpringBoard)

# 使用 Instruments
instruments -t Leaks -p SpringBoard
```

## 性能优化

### 懒加载

```objc
- (UIButton *)toggleButton {
    if (!_toggleButton) {
        _toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        // 配置...
    }
    return _toggleButton;
}
```

### 缓存图标

```objc
@property (nonatomic, strong) UIImage *enabledIcon;
@property (nonatomic, strong) UIImage *disabledIcon;

- (void)viewDidLoad {
    self.enabledIcon = [self createEyeIcon:YES];
    self.disabledIcon = [self createEyeIcon:NO];
}
```

### 异步操作

```objc
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 耗时操作
    BOOL state = [self readState];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新 UI
        [self updateUIWithState:state];
    });
});
```

## 安全考虑

### 权限检查

```objc
// 检查是否有权限访问照片设置
if (access("/var/mobile/Library/Preferences/com.apple.mobileslideshow.plist", R_OK | W_OK) != 0) {
    NSLog(@"[HiddenAlbumToggle] No permission to access Photos settings");
    return;
}
```

### 错误处理

```objc
@try {
    CFPreferencesSetAppValue(...);
} @catch (NSException *exception) {
    NSLog(@"[HiddenAlbumToggle] Error: %@", exception);
}
```

## 扩展功能建议

### 1. 添加长按菜单

```objc
- (UIContextMenuConfiguration *)contextMenuConfiguration {
    return [UIContextMenuConfiguration configurationWithIdentifier:nil
        previewProvider:nil
        actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions) {
            UIAction *openSettings = [UIAction actionWithTitle:@"打开照片设置"
                image:[UIImage systemImageNamed:@"gear"]
                identifier:nil
                handler:^(__kindof UIAction *action) {
                    [[UIApplication sharedApplication] openURL:
                        [NSURL URLWithString:@"prefs:root=PHOTOS"]
                        options:@{} completionHandler:nil];
                }];
            return [UIMenu menuWithTitle:@"" children:@[openSettings]];
        }];
}
```

### 2. 添加状态指示器

```objc
UILabel *statusLabel = [[UILabel alloc] init];
statusLabel.text = _isEnabled ? @"可见" : @"隐藏";
statusLabel.textColor = [UIColor whiteColor];
statusLabel.font = [UIFont systemFontOfSize:12];
[self.view addSubview:statusLabel];
```

### 3. 添加动画效果

```objc
[UIView animateWithDuration:0.3 animations:^{
    self.toggleButton.transform = CGAffineTransformMakeScale(0.9, 0.9);
} completion:^(BOOL finished) {
    [UIView animateWithDuration:0.3 animations:^{
        self.toggleButton.transform = CGAffineTransformIdentity;
    }];
}];
```

