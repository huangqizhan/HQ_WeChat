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










@interface DrawPointLine : NSObject


@property (nonatomic,assign) CGFloat drawWidth;

@property (nonatomic,strong) UIColor *drawColor;

@property (nonatomic,strong) NSMutableArray *childLines;


@end





@interface DrawChildLine : NSObject

@property (nonatomic,assign) CGPoint  begPoint;
@property (nonatomic,assign) CGPoint  endPoint;
@end
