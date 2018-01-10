//
//  HqChatMessageLabel.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/11.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ChatLabelLinkStyle) {
    ChatLabelLinkStyleIphoneNumber = 0,  //电话号码
    ChatLabelLinkStyleWeb,                             //网址
    ChatLabelLinkStyleUserText,                    //用户自定义文字
    ChatLabelLinkStyleOther,                          //文本中点击的文字
    ChatLabelLinkStyleALL                               //all
};

@class MessageLabelTapResult;


@interface HqChatMessageLabel : UILabel

/**
 *  属性字符串 (表情已匹配)
 */
@property (nonatomic,copy)NSMutableAttributedString *attrubuteString;

////点击手势
@property (nonatomic,strong,readonly)UITapGestureRecognizer *tapSender;

@property (nonatomic,copy) void (^tapCallBackAction)(MessageLabelTapResult *result);

@end




@interface MessageLabelTapResult : NSObject

@property (nonatomic,assign) ChatLabelLinkStyle linkStyle;
@property (nonatomic,copy) NSString *valueString;
@end
