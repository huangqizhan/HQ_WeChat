//
//  HQCutImageController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/14.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HQCutImageController : UIViewController

@property (nonatomic) UIScrollView *scrollView;

////要编辑的image
@property (nonatomic,strong) UIImage *originalImage;

////结束编辑
@property (nonatomic,copy) void (^endEdiateImageCallBack)();

////完成编辑
@property (nonatomic,copy) void (^ediateCompliteCallBack)(UIImage *image);

@end






@interface CoverView : UIView

@end
