//
//  HQDrawEdiateImageTools.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEdiateImageBaseTools.h"

@interface HQDrawEdiateImageTools : HQEdiateImageBaseTools

@end




/////画的线   ////画的线是由 每一个很短的线段组成的

@interface DrawPointLine : NSObject


@property (nonatomic,assign) CGFloat drawWidth;

@property (nonatomic,strong) UIColor *drawColor;

@property (nonatomic,strong) NSMutableArray *childLines;


@end





/////线上的小线段

@interface DrawChildLine : NSObject

@property (nonatomic,assign) CGPoint  begPoint;
@property (nonatomic,assign) CGPoint  endPoint;
@end
