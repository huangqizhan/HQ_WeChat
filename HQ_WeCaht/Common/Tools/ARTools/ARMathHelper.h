//
//  ARMathHelper.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/10/19.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface ARMathHelper : NSObject

//// 三维空间中的某店到坐标原点的距离
+ (CGFloat )GetVetorLentghWith:(SCNVector3 )vactor;

/////获取三维空间中的两点之间的距离
+ (CGFloat )getDistanceBetween:(SCNVector3)vactor1 and:(SCNVector3 )vactor2;

@end
