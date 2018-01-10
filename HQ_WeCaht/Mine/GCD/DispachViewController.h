//
//  DispachViewController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/16.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQBaseViewController.h"

@interface DispachViewController : HQBaseViewController

@end






@interface MyOperation : NSOperation

@property (nonatomic,copy) NSString *title;

- (void)operationAction;

@end
