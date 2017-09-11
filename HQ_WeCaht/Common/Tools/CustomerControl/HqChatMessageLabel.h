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

@interface HqChatMessageLabel : UILabel


/**
 *  属性字符串 (表情已匹配)
 */
@property (nonatomic,copy)NSMutableAttributedString *attrubuteString;

/**
 *  可点击link的文本颜色 default blue
 */
@property (nonatomic, strong) UIColor *selectedLinkTextColor;

/**
 *  可点击link背景色  default  gray
 */
@property (nonatomic, strong) UIColor *selectedLinkBackGroudColor;


/**
 *  自定义link文字
 */
@property (nonatomic,strong)NSArray *linkTextArray;

/**
 *  link 类型 default ALL
 */
@property (nonatomic,assign)ChatLabelLinkStyle labelLinkStyle;

@end
