//
//  HQMosaicEdiateImage.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEdiateImageBaseTools.h"

@interface HQMosaicEdiateImage : HQEdiateImageBaseTools

@end





@interface MosaicView : UIView

//马赛克图片
@property (nonatomic, strong) UIImage *image;

//涂层图片.
@property (nonatomic, strong) UIImage *surfaceImage;


@property (nonatomic) NSMutableArray *linesArray;

- (void)drawOndo;

@end




@interface MosaicLine : NSObject

@property (nonatomic,assign) CGPoint begPoint;
@property (nonatomic,strong) NSMutableArray *endDrawPoints;




@end
