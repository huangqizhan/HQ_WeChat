//
//  ImageControll.h
//  YYStudyDemo
//
//  Created by hqz on 2018/9/28.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageControll : UIView
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) void (^touchBlock)(ImageControll *view, UIGestureRecognizerState state, NSSet *touches, UIEvent *event);
@property (nonatomic, copy) void (^longPressBlock)(ImageControll *view, CGPoint point);
@end

NS_ASSUME_NONNULL_END
