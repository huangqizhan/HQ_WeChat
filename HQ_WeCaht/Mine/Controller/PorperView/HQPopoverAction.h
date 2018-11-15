//
//  HQPopoverAction.h
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2017/8/27.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,HQPopoverActionStyle) {
    
    HQPopoverActionDefauleStyle = 0,   ///默认风格
    HQHQPopoverActionDarkStyle,        ///黑色风格
    
};

@interface HQPopoverAction : NSObject

@property (nonatomic,strong,readonly) UIImage *image;  ////图标 (60px X 60px)
@property (nonatomic,copy,readonly) NSString *title;   ///标题
@property (nonatomic,copy,readonly) void (^hander)(HQPopoverAction *action); ///此 Blacok 不会造成内存泄漏  无需设置弱引用


+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(HQPopoverAction *action))handler;

+ (instancetype)actionWithImage:(UIImage *)image title:(NSString *)title handler:(void (^)(HQPopoverAction *action))handler;

@end








