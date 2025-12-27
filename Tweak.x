#import "ControlCenterUI.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Photos Settings Domain
#define kPhotosSettingsDomain @"com.apple.mobileslideshow"
#define kHiddenAlbumKey @"HiddenAlbumVisible"

// Custom Control Center Module for Hidden Album Toggle
@interface HiddenAlbumToggleModule : NSObject <CCUIContentModule>
@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, weak) id<CCUIContentModuleContext> contentModuleContext;
@end

@interface HiddenAlbumToggleViewController : UIViewController
@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, weak) HiddenAlbumToggleModule *module;
- (void)updateState;
- (void)toggleButtonTapped;
@end

// Implementation of the Toggle Module
@implementation HiddenAlbumToggleModule

- (instancetype)init {
    if (self = [super init]) {
        _contentViewController = [[HiddenAlbumToggleViewController alloc] init];
        ((HiddenAlbumToggleViewController *)_contentViewController).module = self;
    }
    return self;
}

- (UIViewController *)contentViewController {
    return _contentViewController;
}

- (CGFloat)preferredExpandedContentHeight {
    return 0.0; // Compact module only
}

- (CGFloat)preferredExpandedContentWidth {
    return 0.0; // Compact module only
}

- (BOOL)providesOwnPlatter {
    return NO;
}

- (void)setContentModuleContext:(id<CCUIContentModuleContext>)context {
    _contentModuleContext = context;
}

@end

// Implementation of the Toggle View Controller
@implementation HiddenAlbumToggleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set preferred content size for compact module
    self.preferredContentSize = CGSizeMake(0, 0);
    
    // Create toggle button
    _toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _toggleButton.frame = self.view.bounds;
    _toggleButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_toggleButton addTarget:self action:@selector(toggleButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // Configure button appearance
    _toggleButton.layer.cornerRadius = 16.0;
    _toggleButton.clipsToBounds = YES;
    
    [self.view addSubview:_toggleButton];
    
    // Update initial state
    [self updateState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateState];
}

- (void)updateState {
    // Read current state from Photos settings
    CFPreferencesAppSynchronize((__bridge CFStringRef)kPhotosSettingsDomain);
    
    Boolean keyExists = false;
    Boolean isVisible = CFPreferencesGetAppBooleanValue(
        (__bridge CFStringRef)kHiddenAlbumKey,
        (__bridge CFStringRef)kPhotosSettingsDomain,
        &keyExists
    );
    
    // Default is YES (visible) if key doesn't exist
    _isEnabled = keyExists ? (BOOL)isVisible : YES;
    
    // Update button appearance
    if (_isEnabled) {
        _toggleButton.backgroundColor = [UIColor systemGreenColor];
        [_toggleButton setImage:[self createEyeIcon:YES] forState:UIControlStateNormal];
    } else {
        _toggleButton.backgroundColor = [UIColor systemGrayColor];
        [_toggleButton setImage:[self createEyeIcon:NO] forState:UIControlStateNormal];
    }
}

- (void)toggleButtonTapped {
    // Toggle state
    _isEnabled = !_isEnabled;
    
    // Save to preferences
    CFPreferencesSetAppValue(
        (__bridge CFStringRef)kHiddenAlbumKey,
        (__bridge CFTypeRef)@(_isEnabled),
        (__bridge CFStringRef)kPhotosSettingsDomain
    );
    CFPreferencesAppSynchronize((__bridge CFStringRef)kPhotosSettingsDomain);
    
    // Notify Photos app to reload settings
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("com.apple.mobileslideshow.PreferenceChanged"),
        NULL,
        NULL,
        YES
    );
    
    // Update UI
    [self updateState];
    
    // Provide haptic feedback
    UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [feedback impactOccurred];
}

- (UIImage *)createEyeIcon:(BOOL)visible {
    // Create eye icon using SF Symbols
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:24 weight:UIImageSymbolWeightMedium];
    NSString *symbolName = visible ? @"eye.fill" : @"eye.slash.fill";
    UIImage *image = [UIImage systemImageNamed:symbolName withConfiguration:config];
    return [image imageWithTintColor:[UIColor whiteColor] renderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end

// Module entry point - Required for Control Center to load the module
extern "C" id<CCUIContentModule> HiddenAlbumToggleModuleCreate(void) {
    return [[HiddenAlbumToggleModule alloc] init];
}

// Constructor to register the module
%ctor {
    NSLog(@"[HiddenAlbumToggle] Module loaded successfully");
}

