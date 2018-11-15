//
//  TextMagnifierView.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/8/13.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

///放大镜类型
typedef NS_ENUM(NSInteger, TextMagnifierType) {
    TextMagnifierTypeCaret,  ///圆形
    TextMagnifierTypeRanged, ///矩形
};


/**
 放大镜
 */
@interface TextMagnifierView : UIView

/// Create a mangifier with the specified type. @param type The magnifier type.
+ (id)magnifierWithType:(TextMagnifierType)type;

@property (nonatomic, readonly) TextMagnifierType type;  ///< Type of magnifier
@property (nonatomic, readonly) CGSize fitSize;            ///< The 'best' size for magnifier view.
@property (nonatomic, readonly) CGSize snapshotSize;       ///< The 'best' snapshot image size for magnifier.
@property (nullable, nonatomic, strong) UIImage *snapshot; ///< The image in magnifier (readwrite).

@property (nullable, nonatomic, weak) UIView *hostView;   ///< The coordinate based view.
@property (nonatomic) CGPoint hostCaptureCenter;          ///< The snapshot capture center in `hostView`.
@property (nonatomic) CGPoint hostPopoverCenter;          ///< The popover center in `hostView`.
@property (nonatomic) BOOL hostVerticalForm;              ///< The host view is vertical form.
@property (nonatomic) BOOL captureDisabled;               ///< A hint for `YYTextEffectWindow` to disable capture.
@property (nonatomic) BOOL captureFadeAnimation;          ///< Show fade animation when the snapshot image changed.
@end



