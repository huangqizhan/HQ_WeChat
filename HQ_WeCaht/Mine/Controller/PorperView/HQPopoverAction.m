//
//  HQPopoverAction.m
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2017/8/27.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQPopoverAction.h"


@interface HQPopoverAction ()

@property (nonatomic,strong,readwrite) UIImage *image;  ////图标 (60px X 60px)
@property (nonatomic,copy,readwrite) NSString *title;   ///标题
@property (nonatomic,copy,readwrite) void (^hander)(HQPopoverAction *action);


@end

@implementation HQPopoverAction

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(HQPopoverAction *action))handler{
    return [self actionWithImage:nil title:title handler:handler];
}

+ (instancetype)actionWithImage:(UIImage *)image title:(NSString *)title handler:(void (^)(HQPopoverAction *action))handler{
    HQPopoverAction *action = [[self alloc] init];
    action.image = image ? : NULL;
    action.title = title ? : @"";
    action.hander = handler ? :NULL;
    return action;
}

@end
