//
//  NSParagraphStyle+Add.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/8/8.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSParagraphStyle (Add)

//// coreText CTParaGraphaRef 转成 NSParaGraphaStyle
+ (NSParagraphStyle *)paragraphStyleWithCTStyle:(CTParagraphStyleRef)CTStyle;

- (CTParagraphStyleRef)CTStyle;

@end


NS_ASSUME_NONNULL_END
