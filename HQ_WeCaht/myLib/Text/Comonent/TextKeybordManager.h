//
//  TextKeybordManager.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/8/14.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    /// 键盘移动之前是否可见
    BOOL fromVisiable;
    /// 键盘移动之后是否可见
    BOOL toVisiable;
    /// 键盘移动之前frame
    CGRect fromFrame;
    /// 键盘移动之后frame
    CGRect toFrame;
    ///移动动画
    NSTimeInterval animationDuration;
    ///动画方式
    UIViewAnimationCurve animationCurve;
    ///动画options
    UIViewAnimationOptions animationOptions;
}TetxKeybordTransition;

@protocol TextKeybordObersive <NSObject>

- (void)textKeybordChangeWithTransition:(TetxKeybordTransition)transition;

@end



@interface TextKeybordManager : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new  UNAVAILABLE_ATTRIBUTE;


/// Get the default manager (returns nil in App Extension).
+ (nullable instancetype)defaultManager;

/// Get the keyboard window. nil if there's no keyboard window.
@property (nullable, nonatomic, readonly) UIWindow *keyboardWindow;

/// Get the keyboard view. nil if there's no keyboard view.
@property (nullable, nonatomic, readonly) UIView *keyboardView;

/// Whether the keyboard is visible.
@property (nonatomic, readonly, getter=isKeyboardVisible) BOOL keyboardVisible;

/// Get the keyboard frame. CGRectNull if there's no keyboard view.
/// Use convertRect:toView: to convert frame to specified view.
@property (nonatomic, readonly) CGRect keyboardFrame;


/**
 Add an observer to manager to get keyboard change information.
 This method makes a weak reference to the observer.
 
 @param observer An observer.
 This method will do nothing if the observer is nil, or already added.
 */
- (void)addObserver:(id<TextKeybordObersive>)observer;

/**
 Remove an observer from manager.
 
 @param observer An observer.
 This method will do nothing if the observer is nil, or not in manager.
 */
- (void)removeObserver:(id<TextKeybordObersive>)observer;

/**
 Convert rect to specified view or window.
 
 @param rect The frame rect.
 @param view A specified view or window (pass nil to convert for main window).
 @return The converted rect in specifeid view.
 */
- (CGRect)convertRect:(CGRect)rect toView:(nullable UIView *)view;

@end

NS_ASSUME_NONNULL_END
