//
//  SetViewController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/11/16.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetViewController : UIViewController

@end



@interface LoacalNotificationCell :UITableViewCell

@property (nonatomic,assign) BOOL isOn;
@property (nonatomic,copy) void (^switchButAction)(BOOL);

@end
