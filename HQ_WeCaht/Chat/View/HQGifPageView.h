//
//  HQGifPageView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/4.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQFaceModel;

@interface HQGifPageView : UIView

@property (nonatomic,strong) NSArray *emojArray;

@property (nonatomic,copy) void (^clickGifClickCallBack)(HQFaceModel *model);

@end



@interface HQGifButton :UIButton

@property (nonatomic,strong) HQFaceModel *faceModel;


@property (nonatomic, assign) CGRect imageRect;

@property (nonatomic, assign) CGRect titleRect;

@end
