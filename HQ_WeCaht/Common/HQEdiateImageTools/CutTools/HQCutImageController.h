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

@end