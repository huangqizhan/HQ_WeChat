//
//  HQActionSheet.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/26.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HQActionStyle) {
    HQActionStyleDefault = 0,
    HQActionStyleDestructive
};

@class HQActionSheetAction;

typedef void (^ACTION_BLOCK)(HQActionSheetAction *action);

extern HQActionSheetAction *LL_ActionSheetSeperator;

@interface HQActionSheetAction  : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic) HQActionStyle style;

@property (nonatomic, copy) ACTION_BLOCK handler;

+ (instancetype)actionWithTitle:(NSString *)title handler:(ACTION_BLOCK)handler;

+ (instancetype)actionWithTitle:(NSString *)title handler:(ACTION_BLOCK)handler style:(HQActionStyle)style;

@end


@interface HQActionSheet : UIView


- (instancetype)initWithTitle:(NSString *)title;

- (void)addAction:(HQActionSheetAction *)action;

- (void)addActions:(NSArray<HQActionSheetAction *> *)actions;

- (void)showInWindow:(UIWindow *)window;

- (void)hideInWindow:(UIWindow *)window;


@end
