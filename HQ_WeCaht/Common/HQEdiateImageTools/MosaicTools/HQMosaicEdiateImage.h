//
//  HQMosaicEdiateImage.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQEdiateImageBaseTools.h"

@interface HQMosaicEdiateImage : HQEdiateImageBaseTools

@end





@interface MosaicView : UIView

//马赛克图片
@property (nonatomic, strong) UIImage *image;

//涂层图片.
@property (nonatomic, strong) UIImage *surfaceImage;

@property (nonatomic,assign) CGFloat drawWidth;


@property (nonatomic) NSMutableArray *linesArray;

@property (nonatomic,copy) void (^refershBackButtonCallBack)(BOOL isActive);

- (void)drawOndo;

@end




@interface MosaicLine : NSObject

@property (nonatomic,assign) CGPoint begPoint;
@property (nonatomic,strong) NSMutableArray *endDrawPoints;




@end
