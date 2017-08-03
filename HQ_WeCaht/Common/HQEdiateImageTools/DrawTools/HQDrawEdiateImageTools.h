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

@property (nonatomic,assign) CGPoint  begPoint;

@property (nonatomic,strong) NSMutableArray *drawPoints;


@end
