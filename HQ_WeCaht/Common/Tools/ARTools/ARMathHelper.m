//
//  ARMathHelper.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/10/19.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "ARMathHelper.h"

@implementation ARMathHelper


+ (CGFloat)GetVetorLentghWith:(SCNVector3 )vactor{
    return sqrtf(vactor.x*vactor.x + vactor.y*vactor.y + vactor.z*vactor.z);
}


+ (CGFloat )getDistanceBetween:(SCNVector3)vactor1 and:(SCNVector3 )vactor2{
    return [self GetVetorLentghWith:SCNVector3Make(vactor1.x-vactor2.x, vactor1.y-vactor1.y, vactor1.z-vactor2.z)];
}

@end
