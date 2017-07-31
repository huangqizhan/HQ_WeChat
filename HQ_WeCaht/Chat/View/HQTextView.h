//
//  HQTextView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/13.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>



@class HQTextView , HQChatMineTextCell ,HQChatOtherBaseCell;

@protocol HQTextViewDelegate <NSObject>

@optional;

- (void)HQTextView:(HQTextView *)textView textViewHeightDidChange:(CGFloat)height;

@end


@interface HQTextView : UITextView

@property (nonatomic,assign) id <HQTextViewDelegate>cusDelegate;
@property (nonatomic,strong) UITableViewCell *textCell;

@end
