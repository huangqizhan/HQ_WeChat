//
//  TextEffectWindow.h
//  YYStudyDemo
//
//  Created by hqz on 2018/8/18.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextSelecttionView.h"
#import "TextMagnifierView.h"


NS_ASSUME_NONNULL_BEGIN
@interface TextEffectWindow : UIWindow

/// Returns the shared instance (returns nil in App Extension).
+ (nullable instancetype)sharedWindow;

/// Show the magnifier in this window with a 'popup' animation. @param mag A magnifier.
- (void)showMagnifier:(TextMagnifierView *)mag;
/// Update the magnifier content and position. @param mag A magnifier.
- (void)moveMagnifier:(TextMagnifierView *)mag;
/// Remove the magnifier from this window with a 'shrink' animation. @param mag A magnifier.
- (void)hideMagnifier:(TextMagnifierView *)mag;


/// Show the selection dot in this window if the dot is clipped by the selection view.
/// @param selection A selection view.
- (void)showSelectionDot:(TextSelecttionView *)selection;
/// Remove the selection dot from this window.
/// @param selection A selection view.
- (void)hideSelectionDot:(TextSelecttionView *)selection;

@end

NS_ASSUME_NONNULL_END 
