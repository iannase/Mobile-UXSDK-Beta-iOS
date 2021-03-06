//
//  DUXBetaSystemStatusStatusWidget.m
//  DJIUXSDK
//
//  MIT License
//  
//  Copyright © 2018-2020 DJI
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//  

#import "DUXBetaSystemStatusWidget.h"
#import "DUXMarqueeLabel.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIFont+DUXBetaFonts.h"
#import "DUXStateChangeBroadcaster.h"

@import DJIUXSDKCore;

static const CGSize kDesignSize = {297.0, 32.0};
static const CGFloat kDesignFontSize = 27.0;
static NSString * const kInitialText = @"Disconnected";

/**
 * DUXSystemStatusWidgetModelState contains the model hooks for the DUXSystemStatusWidget.
 * It implements the hooks:
 *
 * Key: productConnected    Type: NSNumber - Sends a boolean value as an NSNumber indicating if an aircraft is connected.
 *
 * Key: systemStatusUpdated Type: NSString - The current system status message is sent whenever it changes.
*/
@interface DUXSystemStatusWidgetModelState : DUXStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;
+ (instancetype)systemStatusUpdated:(NSString *)systemStatusMessage;

@end

/**
 * DUXStatusWidgetUIState contains the hooks for UI changes in the widget class DUXSystemStatusWidget.
 * It implements the hook:
 *
 * Key: onWidgetTap    Type: NSNumber - Sends a boolean YES value as an NSNumber indicating the widget was tapped.
*/
@interface DUXSystemStatusWidgetUIState : DUXStateChangeBaseData

+ (instancetype)onWidgetTap;

@end

@interface DUXBetaSystemStatusWidget ()

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIColor *> *backgroundColorForWarningLevel;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIColor *> *textColorForWarningLevel;
@property (nonatomic, strong) DUXMarqueeLabel *horizontalScrollingLabel;
@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation DUXBetaSystemStatusWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupInstanceVariables];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupInstanceVariables];
    }
    return self;
}

- (void)setupInstanceVariables {
    _messageFont = [UIFont duxbeta_dinMediumFontWithSize:kDesignFontSize];
    _backgroundColorForWarningLevel = [@{
        @(DJIWarningStatusLevelOffline)    : [UIColor clearColor],
        @(DJIWarningStatusLevelNone)       : [UIColor clearColor],
        @(DJIWarningStatusLevelGood)       : [UIColor clearColor],
        @(DJIWarningStatusLevelWarning)    : [UIColor clearColor],
        @(DJIWarningStatusLevelError)      : [UIColor clearColor],
    } mutableCopy];
            
    _textColorForWarningLevel = [@{
        @(DJIWarningStatusLevelOffline)    : [UIColor duxbeta_disabledGrayColor],
        @(DJIWarningStatusLevelNone)       : [UIColor duxbeta_systemStatusWidgetGreenColor],
        @(DJIWarningStatusLevelGood)       : [UIColor duxbeta_systemStatusWidgetGreenColor],
        @(DJIWarningStatusLevelWarning)    : [UIColor duxbeta_systemStatusWidgetYellowColor],
        @(DJIWarningStatusLevelError)      : [UIColor duxbeta_systemStatusWidgetRedColor],
    } mutableCopy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.widgetModel = [[DUXBetaSystemStatusWidgetModel alloc] init];
    [self.widgetModel setup];
    [self setupUI];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(handleSuggestedMessageUpdate), suggestedWarningMessage);
    BindRKVOModel(self.widgetModel, @selector(updateUI), systemStatusWarningLevel);
    BindRKVOModel(self.widgetModel, @selector(updateIsCriticalWarning), isCriticalWarning);
    BindRKVOModel(self, @selector(updateLabelFont), messageFont);
    
    // Bind hooks to model updates
    BindRKVOModel(self.widgetModel, @selector(sendProductConnected), isProductConnected);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    self.backgroundView = [[UIImageView alloc] init];
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.backgroundView];

    [self.backgroundView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [self.backgroundView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.backgroundView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.backgroundView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;

    self.horizontalScrollingLabel = [[DUXMarqueeLabel alloc] initWithFrame:CGRectZero duration:12 andFadeLength:5];
    self.horizontalScrollingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.horizontalScrollingLabel.marqueeType = MLContinuous;
    self.horizontalScrollingLabel.trailingBuffer = 20.0;
    self.horizontalScrollingLabel.animationDelay = 0.0;
    self.horizontalScrollingLabel.textColor = self.textColorForWarningLevel[@(DJIWarningStatusLevelOffline)];
    self.horizontalScrollingLabel.font = self.messageFont;
    self.horizontalScrollingLabel.text = kInitialText;
    self.view.backgroundColor = self.backgroundColorForWarningLevel[@(DJIWarningStatusLevelOffline)];

    [self.view addSubview:self.horizontalScrollingLabel];

    [self.horizontalScrollingLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.horizontalScrollingLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.horizontalScrollingLabel.widthAnchor constraintEqualToAnchor:self.view.widthAnchor
                                                             multiplier:0.975].active = YES;
    [self.horizontalScrollingLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor
                                                             multiplier:0.8].active = YES;

    [self updateUI];
    [self handleSuggestedMessageUpdate];
    [self updateIsCriticalWarning];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

/*********************************************************************************/
#pragma mark - Widget Model Callbacks
/*********************************************************************************/
- (void)handleSuggestedMessageUpdate {
    self.horizontalScrollingLabel.text = self.widgetModel.suggestedWarningMessage;
    [[DUXStateChangeBroadcaster instance] send:[DUXSystemStatusWidgetModelState systemStatusUpdated:self.widgetModel.suggestedWarningMessage]];
}

- (void)updateIsCriticalWarning {
    if (self.widgetModel.isCriticalWarning) {
        if (![self.backgroundView.layer animationForKey:@"view_blink"]) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.toValue = @(0.0f);
            animation.fromValue = @(1.0f);
            animation.duration = 0.5;
            animation.fillMode = kCAFillModeForwards;
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            animation.autoreverses = YES;
            animation.repeatCount = HUGE_VAL;
            [self.backgroundView.layer addAnimation:animation forKey:@"view_blink"];
        }
    }
}

- (void)updateUI {
    self.horizontalScrollingLabel.textColor = self.textColorForWarningLevel[@(self.widgetModel.systemStatusWarningLevel)];
    self.backgroundView.backgroundColor = self.backgroundColorForWarningLevel[@(self.widgetModel.systemStatusWarningLevel)];
    CGFloat pointSize = self.messageFont.pointSize * (self.horizontalScrollingLabel.frame.size.height / self.widgetSizeHint.minimumHeight);
    self.horizontalScrollingLabel.font = [self.messageFont fontWithSize:pointSize];
}

/*********************************************************************************/
#pragma mark - UI
/*********************************************************************************/
- (void)viewDidLayoutSubviews {
    [self updateUI];
}

/*********************************************************************************/
#pragma mark - Customization
/*********************************************************************************/

- (void)setBackgroundColor:(UIColor *)color forSystemStatusWarningLevel:(DJIWarningStatusLevel)systemStatusWarningLevel {
    self.backgroundColorForWarningLevel[@(systemStatusWarningLevel)] = color;
    [self updateUI];
}

- (UIColor *)backgroundColorForSystemStatusWarningLevel:(DJIWarningStatusLevel)SystemStatusWarningLevel {
    return self.backgroundColorForWarningLevel[@(SystemStatusWarningLevel)];
}

- (void)setTextColor:(UIColor *)color forSystemStatusWarningLevel:(DJIWarningStatusLevel)systemStatusWarningLevel {
    self.textColorForWarningLevel[@(systemStatusWarningLevel)] = color;
    [self updateUI];
}

- (UIColor *)textColorForSystemStatusWarningLevel:(DJIWarningStatusLevel)systemStatusWarningLevel {
    return self.textColorForWarningLevel[@(systemStatusWarningLevel)];
}

- (void)updateLabelFont {
    self.horizontalScrollingLabel.font = self.messageFont;
    [self updateUI];
}

- (void)sendProductConnected {
    [[DUXStateChangeBroadcaster instance] send:[DUXSystemStatusWidgetModelState productConnected:self.widgetModel.isProductConnected]];
}

- (void)handleTap {
    [[DUXStateChangeBroadcaster instance] send:[DUXSystemStatusWidgetUIState onWidgetTap]];
}

@end

@implementation DUXSystemStatusWidgetModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[DUXSystemStatusWidgetModelState alloc] initWithKey:@"productConnected" number:@(isConnected)];
}

+ (instancetype)systemStatusUpdated:(NSString *)systemStatusMessage {
    return [[DUXSystemStatusWidgetModelState alloc] initWithKey:@"systemStatusMessage" string:systemStatusMessage];
}

@end

@implementation DUXSystemStatusWidgetUIState

+ (instancetype)onWidgetTap {
    return [[DUXSystemStatusWidgetUIState alloc] initWithKey:@"onWidgetTap" number:@(0)];
}

@end
