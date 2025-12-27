// ControlCenterUI Private Headers for iOS 16
// These are private APIs used for creating custom Control Center modules

#import <UIKit/UIKit.h>

@interface CCUIToggleModule : NSObject
@property (nonatomic, readonly) UIImage *iconGlyph;
@property (nonatomic, readonly) UIColor *selectedColor;
@property (nonatomic, readonly) BOOL isSelected;
- (void)setSelected:(BOOL)selected;
- (void)refreshState;
@end

@interface CCUIToggleViewController : UIViewController
@property (nonatomic, strong) CCUIToggleModule *module;
@property (nonatomic, assign) BOOL selected;
- (void)buttonTapped:(id)sender;
@end

// Control Center Module Content Protocol
@protocol CCUIContentModule <NSObject>
@optional
- (UIViewController *)contentViewController;
- (UIView *)contentView;
- (CGFloat)preferredExpandedContentHeight;
- (CGFloat)preferredExpandedContentWidth;
- (BOOL)providesOwnPlatter;
- (void)setContentModuleContext:(id)context;
@end

// Control Center Module Background Protocol  
@protocol CCUIContentModuleBackgroundViewController <NSObject>
@optional
- (void)willTransitionToExpandedContentMode:(BOOL)expanded;
@end

// Control Center Module Context
@protocol CCUIContentModuleContext <NSObject>
- (void)enqueueStatusUpdate:(id)update;
- (void)dismissModule;
- (void)requestExpandModule;
- (void)requestAuthenticationWithCompletionHandler:(void (^)(BOOL authenticated))completion;
@end

// Module Content Metrics
@interface CCUIModuleContentMetrics : NSObject
@property (nonatomic, assign) CGFloat compactContinuousCornerRadius;
@property (nonatomic, assign) CGFloat expandedContinuousCornerRadius;
@end

// Layout Options
@interface CCUILayoutOptions : NSObject
@end

// App Launch Origin
@interface CCUIAppLaunchOrigin : NSObject
@end

