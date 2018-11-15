//
//  HQEdiateImageTextView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/18.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQTextEdiateImageTools;

@interface HQEdiateImageTextView : UIView

@property (nonatomic,copy) NSAttributedString *attrubuteString;

@property (nonatomic,weak) HQTextEdiateImageTools *textTool;

- (instancetype)initWithTextTool:(HQTextEdiateImageTools *)textTool  withSuperView:(UIView *)superView andAttrubuteString:(NSAttributedString *)attrubute andWithColor:(UIColor *)color;


@property (nonatomic,copy) void (^tapCallBack)(HQEdiateImageTextView *rextView);

@property (nonatomic,copy) void (^deleteTextViewCallBack)(HQEdiateImageTextView *rextView);


- (void)refreshContentViewWith:(NSAttributedString *)attStr;

- (void)hiddenCurrentViewLayerIsBegin:(BOOL)isBegin;

@end




