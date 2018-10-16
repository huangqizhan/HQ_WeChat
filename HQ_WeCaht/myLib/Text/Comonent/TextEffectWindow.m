//
//  TextEffectWindow.m
//  YYStudyDemo
//
//  Created by hqz on 2018/8/18.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "TextEffectWindow.h"
#import "TextUtilites.h"
#import "TextKeybordManager.h"
#import "UIView+Add.h"


@implementation TextEffectWindow

+ (instancetype)sharedWindow {
    static TextEffectWindow *one = nil;
    if (one == nil) {
        // iOS 9 compatible
        NSString *mode = [NSRunLoop currentRunLoop].currentMode;
        if (mode.length == 27 &&
            [mode hasPrefix:@"UI"] &&
            [mode hasSuffix:@"InitializationRunLoopMode"]) {
            return nil;
        }
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!TextIsAppExtension()) {
            one = [self new];
            one.frame = (CGRect){.size = TextScreenSize()};
            one.userInteractionEnabled = NO;
            one.windowLevel = UIWindowLevelStatusBar + 1;
            one.hidden = NO;
            one.opaque = NO;
            one.backgroundColor = [UIColor clearColor];
            one.layer.backgroundColor = [UIColor clearColor].CGColor;
        }
    });
    return one;
}
///停止自己响应  app 主窗口响应
- (void)becomeKeyWindow{
    [[TextSharedApplication().delegate window] makeKeyAndVisible];
}

- (UIViewController *)rootViewController{
    for (UIWindow *win in [TextSharedApplication() windows]) {
        if(win == self) continue;
        if (win.hidden) continue;
        UIViewController *root = win.rootViewController;
        if (root) {
            return root;
        }
    }
    UIViewController *viewController = [super rootViewController];
    if (!viewController) {
        viewController = [UIViewController new];
        [super setRootViewController:viewController];
    }
    return viewController;
}
- (void)_updateWindowLevel{
    UIApplication *app = TextSharedApplication();
    if (!app) return;
    UIWindow *topWin = app.windows.lastObject;
    UIWindow *keyWin = app.keyWindow;
    if (topWin && keyWin.windowLevel > topWin.windowLevel) {
        topWin = keyWin;
    }
    if(topWin == self) return;
    self.windowLevel = topWin.windowLevel + 1;
}
- (TextDirection)_keyboardDirection {
    CGRect keyboardFrame = [TextKeybordManager defaultManager].keyboardFrame;
    keyboardFrame = [[TextKeybordManager defaultManager] convertRect:keyboardFrame toView:self];
    if (CGRectIsNull(keyboardFrame) || CGRectIsEmpty(keyboardFrame)) return TextDirectionNone;
    
    if (CGRectGetMinY(keyboardFrame) == 0 &&
        CGRectGetMinX(keyboardFrame) == 0 &&
        CGRectGetMaxX(keyboardFrame) == CGRectGetWidth(self.frame))
        return TextDirectionTop;
    
    if (CGRectGetMaxX(keyboardFrame) == CGRectGetWidth(self.frame) &&
        CGRectGetMinY(keyboardFrame) == 0 &&
        CGRectGetMaxY(keyboardFrame) == CGRectGetHeight(self.frame))
        return TextDirectionRight;
    
    if (CGRectGetMaxY(keyboardFrame) == CGRectGetHeight(self.frame) &&
        CGRectGetMinX(keyboardFrame) == 0 &&
        CGRectGetMaxX(keyboardFrame) == CGRectGetWidth(self.frame))
        return TextDirectionBottom;
    
    if (CGRectGetMinX(keyboardFrame) == 0 &&
        CGRectGetMinY(keyboardFrame) == 0 &&
        CGRectGetMaxY(keyboardFrame) == CGRectGetHeight(self.frame))
        return TextDirectionLeft;
    
    return TextDirectionNone;
}
- (CGPoint)_correctedCaptureCenter:(CGPoint)center{
    CGRect keyboardFrame = [TextKeybordManager defaultManager].keyboardFrame;
    keyboardFrame = [[TextKeybordManager defaultManager] convertRect:keyboardFrame toView:self];
    if (!CGRectIsNull(keyboardFrame) && !CGRectIsEmpty(keyboardFrame)) {
        TextDirection direction = [self _keyboardDirection];
        switch (direction) {
            case TextDirectionTop: {
                if (center.y < CGRectGetMaxY(keyboardFrame)) center.y = CGRectGetMaxY(keyboardFrame);
            } break;
            case TextDirectionRight: {
                if (center.x > CGRectGetMinX(keyboardFrame)) center.x = CGRectGetMinX(keyboardFrame);
            } break;
            case TextDirectionBottom: {
                if (center.y > CGRectGetMinY(keyboardFrame)) center.y = CGRectGetMinY(keyboardFrame);
            } break;
            case TextDirectionLeft: {
                if (center.x < CGRectGetMaxX(keyboardFrame)) center.x = CGRectGetMaxX(keyboardFrame);
            } break;
            default: break;
        }
    }
    return center;
}
- (CGPoint)_correctedCenter:(CGPoint)center forMagnifier:(TextMagnifierView *)mag rotation:(CGFloat)rotation {
    CGFloat degree = TextRadiansToDegrees(rotation);
    
    degree /= 45.0;
    if (degree < 0) degree += (int)(-degree/8.0 + 1) * 8;
    if (degree > 8) degree -= (int)(degree/8.0) * 8;
    
    CGFloat caretExt = 10;
    if (degree <= 1 || degree >= 7) { //top
        if (mag.type == TextMagnifierTypeCaret) {
            if (center.y < caretExt)
                center.y = caretExt;
        } else if (mag.type == TextMagnifierTypeRanged) {
            if (center.y < mag.bounds.size.height)
                center.y = mag.bounds.size.height;
        }
    } else if (1 < degree && degree < 3) { // right
        if (mag.type == TextMagnifierTypeCaret) {
            if (center.x > self.bounds.size.width - caretExt)
                center.x = self.bounds.size.width - caretExt;
        } else if (mag.type == TextMagnifierTypeRanged) {
            if (center.x > self.bounds.size.width - mag.bounds.size.height)
                center.x = self.bounds.size.width - mag.bounds.size.height;
        }
    } else if (3 <= degree && degree <= 5) { // bottom
        if (mag.type == TextMagnifierTypeCaret) {
            if (center.y > self.bounds.size.height - caretExt)
                center.y = self.bounds.size.height - caretExt;
        } else if (mag.type == TextMagnifierTypeRanged) {
            if (center.y > mag.bounds.size.height)
                center.y = mag.bounds.size.height;
        }
    } else if (5 < degree && degree < 7) { // left
        if (mag.type == TextMagnifierTypeCaret) {
            if (center.x < caretExt)
                center.x = caretExt;
        } else if (mag.type == TextMagnifierTypeRanged) {
            if (center.x < mag.bounds.size.height)
                center.x = mag.bounds.size.height;
        }
    }
    
    
    CGRect keyboardFrame = [TextKeybordManager defaultManager].keyboardFrame;
    keyboardFrame = [[TextKeybordManager defaultManager] convertRect:keyboardFrame toView:self];
    if (!CGRectIsNull(keyboardFrame) && !CGRectIsEmpty(keyboardFrame)) {
        TextDirection direction = [self _keyboardDirection];
        switch (direction) {
            case TextDirectionTop: {
                if (mag.type == TextMagnifierTypeCaret) {
                    if (center.y - mag.bounds.size.height / 2 < CGRectGetMaxY(keyboardFrame))
                        center.y = CGRectGetMaxY(keyboardFrame) + mag.bounds.size.height / 2;
                } else if (mag.type == TextMagnifierTypeRanged) {
                    if (center.y < CGRectGetMaxY(keyboardFrame)) center.y = CGRectGetMaxY(keyboardFrame);
                }
            } break;
            case TextDirectionRight: {
                if (mag.type == TextMagnifierTypeCaret) {
                    if (center.x + mag.bounds.size.height / 2 > CGRectGetMinX(keyboardFrame))
                        center.x = CGRectGetMinX(keyboardFrame) - mag.bounds.size.width / 2;
                } else if (mag.type == TextMagnifierTypeRanged) {
                    if (center.x > CGRectGetMinX(keyboardFrame)) center.x = CGRectGetMinX(keyboardFrame);
                }
            } break;
            case TextDirectionBottom: {
                if (mag.type == TextMagnifierTypeCaret) {
                    if (center.y + mag.bounds.size.height / 2 > CGRectGetMinY(keyboardFrame))
                        center.y = CGRectGetMinY(keyboardFrame) - mag.bounds.size.height / 2;
                } else if (mag.type == TextMagnifierTypeRanged) {
                    if (center.y > CGRectGetMinY(keyboardFrame)) center.y = CGRectGetMinY(keyboardFrame);
                }
            } break;
            case TextDirectionLeft: {
                if (mag.type == TextMagnifierTypeCaret) {
                    if (center.x - mag.bounds.size.height / 2 < CGRectGetMaxX(keyboardFrame))
                        center.x = CGRectGetMaxX(keyboardFrame) + mag.bounds.size.width / 2;
                } else if (mag.type == TextMagnifierTypeRanged) {
                    if (center.x < CGRectGetMaxX(keyboardFrame)) center.x = CGRectGetMaxX(keyboardFrame);
                }
            } break;
            default: break;
        }
    }
    return center;
}
///捕获放大的区域
- (CGFloat)_updateMagnifier:(TextMagnifierView *)mag {
    UIApplication *app = TextSharedApplication();
    if (!app) return 0;
    
    UIView *hostView = mag.hostView;
    UIWindow *hostWindow = [hostView isKindOfClass:[UIWindow class]] ? (id)hostView : hostView.window;
    if (!hostView || !hostWindow) return 0;
    CGPoint captureCenter = [self convertPoint:mag.hostCaptureCenter fromViewOrWindow:hostView];
    captureCenter = [self _correctedCaptureCenter:captureCenter];
    CGRect captureRect = {.size = mag.snapshotSize};
    captureRect.origin.x = captureCenter.x - captureRect.size.width / 2;
    captureRect.origin.y = captureCenter.y - captureRect.size.height / 2;
    
    CGAffineTransform trans = TextCGAffineTransformGetFromViews(hostView, self);
    CGFloat rotation = TextCGAffineTransformGetRotation(trans);
    
    if (mag.captureDisabled) {
        if (!mag.snapshot || mag.snapshot.size.width > 1) {
            static UIImage *placeholder;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                CGRect rect = mag.bounds;
                rect.origin = CGPointZero;
                UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                [[UIColor colorWithWhite:1 alpha:0.8] set];
                CGContextFillRect(context, rect);
                placeholder = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            });
            mag.captureFadeAnimation = YES;
            mag.snapshot = placeholder;
            mag.captureFadeAnimation = NO;
        }
        return rotation;
    }
    
    UIGraphicsBeginImageContextWithOptions(captureRect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return rotation;
    
    CGPoint tp = CGPointMake(captureRect.size.width / 2, captureRect.size.height / 2);
    tp = CGPointApplyAffineTransform(tp, CGAffineTransformMakeRotation(rotation));
    CGContextRotateCTM(context, -rotation);
    CGContextTranslateCTM(context, tp.x - captureCenter.x, tp.y - captureCenter.y);
    
    NSMutableArray *windows = app.windows.mutableCopy;
    UIWindow *keyWindow = app.keyWindow;
    if (![windows containsObject:keyWindow]) [windows addObject:keyWindow];
    [windows sortUsingComparator:^NSComparisonResult(UIWindow *w1, UIWindow *w2) {
        if (w1.windowLevel < w2.windowLevel) return NSOrderedAscending;
        else if (w1.windowLevel > w2.windowLevel) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    UIScreen *mainScreen = [UIScreen mainScreen];
    for (UIWindow *window in windows) {
        if (window.hidden || window.alpha <= 0.01) continue;
        if (window.screen != mainScreen) continue;
        if ([window isKindOfClass:self.class]) break; //don't capture window above self
        CGContextSaveGState(context);
        CGContextConcatCTM(context, TextCGAffineTransformGetFromViews(window, self));
        [window.layer renderInContext:context]; //render
        //[window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO]; //slower when capture whole window
        CGContextRestoreGState(context);
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (mag.snapshot.size.width == 1) {
        mag.captureFadeAnimation = YES;
    }
    mag.snapshot = image;
    mag.captureFadeAnimation = NO;
    return rotation;
}
- (void)showMagnifier:(TextMagnifierView *)mag {
    if (!mag) return;
    if (mag.superview != self) [self addSubview:mag];
    [self _updateWindowLevel];
    CGFloat rotation = [self _updateMagnifier:mag];
    CGPoint center = [self convertPoint:mag.hostPopoverCenter fromViewOrWindow:mag.hostView];
    CGAffineTransform trans = CGAffineTransformMakeRotation(rotation);
    trans = CGAffineTransformScale(trans, 0.3, 0.3);
    mag.transform = trans;
    mag.center = center;
    if (mag.type == TextMagnifierTypeRanged) {
        mag.alpha = 0;
    }
    NSTimeInterval time = mag.type == TextMagnifierTypeCaret ? 0.08 : 0.1;
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (mag.type == TextMagnifierTypeCaret) {
            CGPoint newCenter = CGPointMake(0, -mag.fitSize.height / 2);
            newCenter = CGPointApplyAffineTransform(newCenter, CGAffineTransformMakeRotation(rotation));
            newCenter.x += center.x;
            newCenter.y += center.y;
            mag.center = [self _correctedCenter:newCenter forMagnifier:mag rotation:rotation];
        } else {
            mag.center = [self _correctedCenter:center forMagnifier:mag rotation:rotation];
        }
        mag.transform = CGAffineTransformMakeRotation(rotation);
        mag.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}
- (void)moveMagnifier:(TextMagnifierView *)mag {
    if (!mag) return;
    [self _updateWindowLevel];
    CGFloat rotation = [self _updateMagnifier:mag];
    CGPoint center = [self convertPoint:mag.hostPopoverCenter fromViewOrWindow:mag.hostView];
    if (mag.type == TextMagnifierTypeCaret) {
        CGPoint newCenter = CGPointMake(0, -mag.fitSize.height / 2);
        newCenter = CGPointApplyAffineTransform(newCenter, CGAffineTransformMakeRotation(rotation));
        newCenter.x += center.x;
        newCenter.y += center.y;
        mag.center = [self _correctedCenter:newCenter forMagnifier:mag rotation:rotation];
    } else {
        mag.center = [self _correctedCenter:center forMagnifier:mag rotation:rotation];
    }
    mag.transform = CGAffineTransformMakeRotation(rotation);
}

- (void)hideMagnifier:(TextMagnifierView *)mag {
    if (!mag) return;
    if (mag.superview != self) return;
    CGFloat rotation = [self _updateMagnifier:mag];
    CGPoint center = [self convertPoint:mag.hostPopoverCenter fromViewOrWindow:mag.hostView];
    NSTimeInterval time = mag.type == TextMagnifierTypeCaret ? 0.20 : 0.15;
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        CGAffineTransform trans = CGAffineTransformMakeRotation(rotation);
        trans = CGAffineTransformScale(trans, 0.01, 0.01);
        mag.transform = trans;
        
        if (mag.type == TextMagnifierTypeCaret) {
            CGPoint newCenter = CGPointMake(0, -mag.fitSize.height / 2);
            newCenter = CGPointApplyAffineTransform(newCenter, CGAffineTransformMakeRotation(rotation));
            newCenter.x += center.x;
            newCenter.y += center.y;
            mag.center = [self _correctedCenter:newCenter forMagnifier:mag rotation:rotation];
        } else {
            mag.center = [self _correctedCenter:center forMagnifier:mag rotation:rotation];
            mag.alpha = 0;
        }
        
    } completion:^(BOOL finished) {
        if (finished) {
            [mag removeFromSuperview];
            mag.transform = CGAffineTransformIdentity;
            mag.alpha = 1;
        }
    }];
}

- (void)showSelectionDot:(TextSelecttionView *)selection {
    if (!selection) return;
    [self _updateWindowLevel];
    [self insertSubview:selection.startGrabber.dot.mirror atIndex:0];
    [self insertSubview:selection.endGrabber.dot.mirror atIndex:0];
    [self _updateSelectionGrabberDot:selection.startGrabber.dot selection:selection];
    [self _updateSelectionGrabberDot:selection.endGrabber.dot selection:selection];
}
- (void)_updateSelectionGrabberDot:(TextSelecttionGrabberDot *)dot selection:(TextSelecttionView *)selection{
    dot.mirror.hidden = YES;
    if (selection.hostView.clipsToBounds == YES && dot.visibleAlpha > 0.1) {
        CGRect dotRect = [dot convertRect:dot.bounds toViewOrWindow:self];
        BOOL dotInKeyboard = NO;
        
        CGRect keyboardFrame = [TextKeybordManager defaultManager].keyboardFrame;
        keyboardFrame = [[TextKeybordManager defaultManager] convertRect:keyboardFrame toView:self];
        if (!CGRectIsNull(keyboardFrame) && !CGRectIsEmpty(keyboardFrame)) {
            CGRect inter = CGRectIntersection(dotRect, keyboardFrame);
            if (!CGRectIsNull(inter) && (inter.size.width > 1 || inter.size.height > 1)) {
                dotInKeyboard = YES;
            }
        }
        if (!dotInKeyboard) {
            CGRect hostRect = [selection.hostView convertRect:selection.hostView.bounds toView:self];
            CGRect intersection = CGRectIntersection(dotRect, hostRect);
            if (TextCGRectGetArea(intersection) < TextCGRectGetArea(dotRect)) {
                CGFloat dist = TextCGPointGetDistanceToRect(TextCGRectGetCenter(dotRect), hostRect);
                if (dist < CGRectGetWidth(dot.frame) * 0.55) {
                    dot.mirror.hidden = NO;
                }
            }
        }
    }
    CGPoint center = [dot convertPoint:CGPointMake(CGRectGetWidth(dot.frame) / 2, CGRectGetHeight(dot.frame) / 2) toViewOrWindow:self];
    if (isnan(center.x) || isnan(center.y) || isinf(center.x) || isinf(center.y)) {
        dot.mirror.hidden = YES;
    } else {
        dot.mirror.center = center;
    }
}

- (void)hideSelectionDot:(TextSelecttionView *)selection {
    if (!selection) return;
    [selection.startGrabber.dot.mirror removeFromSuperview];
    [selection.endGrabber.dot.mirror removeFromSuperview];
}
@end
