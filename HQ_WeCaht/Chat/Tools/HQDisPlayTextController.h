//
//  HQDisPlayTextController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/31.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQAttrubuteTextLabel.h"


@class  ChatMessageModel ;

@interface HQDisPlayTextController : UIViewController

@property (nonatomic,strong) ChatMessageModel *messageModel;


- (void)showInWindownWithCallBack:(void(^)(HQAttrubuteTextData *data))tapAction;


@end
