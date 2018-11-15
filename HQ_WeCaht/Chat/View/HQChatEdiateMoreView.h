//
//  HQChatEdiateMoreView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/8.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQChatEdiateMoreView : UIView

@property (nonatomic,copy) void (^EdiateMoreViewClickCallBack)(NSString *titleString);

- (void)setEdiateViewActiveStatusWith:(NSInteger)seletedNum;


@end
