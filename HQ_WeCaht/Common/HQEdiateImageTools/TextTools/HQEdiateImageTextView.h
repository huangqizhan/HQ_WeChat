//
//  HQEdiateImageTextView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/18.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQTextEdiateImageTools;

@interface HQEdiateImageTextView : UIView

@property (nonatomic,weak) HQTextEdiateImageTools *textTool;

- (instancetype)initWithTextTool:(HQTextEdiateImageTools *)textTool  withSuperView:(UIView *)superView andAttrubuteString:(NSAttributedString *)attrubute;


- (void)setUpGesture;


- (void)refreshContentImageView;

@end




