//
//  HQAttrubuteTextLabel.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/31.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HQAttrubuteTextType) {
    HQAttrubuteTextTypeURL = 0,
    HQAttrubuteTextTypePhoneNumber
};


@interface HQAttrubuteTextData : NSObject

@property (nonatomic,assign) HQAttrubuteTextType type;

@property (nonatomic) NSRange range;

@property (nonatomic) NSURL *url;

@property (nonatomic,copy) NSString *phoneNumber;

- (instancetype)initWithType:(HQAttrubuteTextType ) type;

@end


typedef void (^HQAttrubuteTextLabelTapAction)(HQAttrubuteTextData *data);

typedef void (^HQAttrubuteTextLabelLongPressAction)(HQAttrubuteTextData *data, UIGestureRecognizerState state);

@interface HQAttrubuteTextLabel : UITextView

@property (nonatomic) CGFloat longPressDuration;

@property (nonatomic, copy) HQAttrubuteTextLabelTapAction tapAction;

@property (nonatomic, copy) HQAttrubuteTextLabelLongPressAction longPressAction;

- (BOOL)shouldReceiveTouchAtPoint:(CGPoint)point;

- (void)swallowTouch;

- (void)clearLinkBackground;

+ (NSMutableAttributedString *)createAttributedStringWithEmotionString:(NSString *)emotionString font:(UIFont *)font lineSpacing:(NSInteger)lineSpacing;


@end






