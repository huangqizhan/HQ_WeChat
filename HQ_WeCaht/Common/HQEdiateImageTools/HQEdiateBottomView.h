//
//  HQEdiateBottomView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/31.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQEdiateBottomView : UIView

- (instancetype)initWithFrame:(CGRect)frame andClickButtonIndex:(void(^)(NSInteger index))callClickButtonIndex;

@property (nonatomic,copy)  void (^bottomEdiateViewClick)(NSInteger index);

@end







@interface HQEdiateItem :   UIControl


@property (nonatomic,copy)  void (^clickBackAction)(NSInteger index);

- (instancetype)initWithFram:(CGRect)frame ImageName:(NSString *)imageName andClickCallBackAction:(void (^)(NSInteger index))clickCallBackAction;


@end
