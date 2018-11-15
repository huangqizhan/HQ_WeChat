//
//  UIMenuController+LongPress.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/30.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "UIMenuController+LongPress.h"
#import <objc/runtime.h>


@implementation UIMenuController (LongPress)

- (NSIndexPath *)indexPath{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setIndexPath:(NSIndexPath *)indexPath{
    objc_setAssociatedObject(self, @selector(indexPath), indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (ChatMessageModel *)messageMdeol{
    return objc_getAssociatedObject(self, _cmd);
}


- (void)setMessageMdeol:(ChatMessageModel *)messageMdeol{
    objc_setAssociatedObject(self, @selector(messageMdeol), messageMdeol, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)setMenuView:(UIView *)menuView{
    objc_setAssociatedObject(self, @selector(menuView), menuView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (UIView *)menuView{
    return objc_getAssociatedObject(self, _cmd);
}
@end
