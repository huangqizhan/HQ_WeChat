//
//  HQRQCodeView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/30.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQRQCodeView : UIView

@property (nonatomic,assign) CGRect ScanRect;

- (void)startRecodeWithContent:(NSString *)content;

- (void)beginRecodeWhenDidEndAnimation;


- (void)dismissReCodeView;


@end










@interface ReCodeIndicatorView : UIView

- (void)startRecodeWithContent:(NSString *)content;

- (void)stopReCode;

@end


