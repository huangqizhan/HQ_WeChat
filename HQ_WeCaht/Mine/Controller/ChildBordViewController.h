//
//  ChildBordViewController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/19.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQBaseViewController.h"

@interface ChildBordViewController : HQBaseViewController

@end




@class  BordViewController;

@protocol BordViewControllerDelegate <NSObject>

- (void) BordViewController :(BordViewController *)controller andHeight:(CGFloat )height;

@end

@interface BordViewController : UIViewController

@property (nonatomic,assign) id <BordViewControllerDelegate>delegate;

@end
