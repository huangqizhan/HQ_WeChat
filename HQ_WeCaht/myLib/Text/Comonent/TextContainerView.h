//
//  TextContainerView.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/8.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextDebugOption.h"
#import "TextLayout.h"

///display layoyt
@interface TextContainerView : UIView

/// First responder's aciton will forward to this view.
@property (nullable, nonatomic, weak) UIView *hostView;

/// Debug option for layout debug. Set this property will let the view redraw it's contents.
@property (nullable, nonatomic, copy) TextDebugOption *debugOption;

/// Text vertical alignment.
@property (nonatomic) TextVerticalAlignment textVerticalAlignment;

/// Text layout. Set this property will let the view redraw it's contents.
@property (nullable, nonatomic, strong) TextLayout *layout;

/// The contents fade animation duration when the layout's contents changed. Default is 0 (no animation).
@property (nonatomic) NSTimeInterval contentsFadeDuration;

/// Convenience method to set `layout` and `contentsFadeDuration`.
/// @param layout  Same as `layout` property.
/// @param fadeDuration  Same as `contentsFadeDuration` property.
- (void)setLayout:(nullable TextLayout *)layout withFadeDuration:(NSTimeInterval)fadeDuration;


@end
