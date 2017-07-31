//
//  MessageRectModel+Action.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/9.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "MessageRectModel+Action.h"

@implementation MessageRectModel (Action)

+ (instancetype)customerInita{
    return [[MessageRectModel alloc] initWithContext:[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext];
}

- (CGRect)cacuLateCgrect{
    return CGRectMake(self.xx, self.yy, self.width, self.height);
}



@end
