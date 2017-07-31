//
//  HQFaceTools.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/28.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HQFaceTools.h"



@interface HQFaceTools : NSObject


+ (NSArray *)getNormalEmotions;

+ (NSArray *)getCustomerEmotions;

+ (NSArray *)getGifEmotions;

+ (NSArray *)getMoreFaceItems;

+ (NSMutableAttributedString *)transferMessageString:(NSString *)message
                                                font:(UIFont *)font
                                          lineHeight:(CGFloat)lineHeight;

////超链接高亮显示
+ (NSMutableAttributedString *)highlightDefaultDataTypes:(NSMutableAttributedString *)attributedString ;
@end
