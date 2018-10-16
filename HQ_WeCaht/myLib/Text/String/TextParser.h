//
//  TextParser.h
//  YYStudyDemo
//
//  Created by hqz on 2018/8/4.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol  TextParser <NSObject>

///当text 内容修改后 会调用此方法 
- (BOOL)parseText:(nullable NSMutableAttributedString *)text selectedRange:(nullable NSRangePointer)selectedRange;

@end


@interface TextMarkDownParser : NSObject<TextParser>
@property (nonatomic) CGFloat fontSize;         ///< default is 14
@property (nonatomic) CGFloat headerFontSize;   ///< default is 20

@property (nullable, nonatomic, strong) UIColor *textColor;
@property (nullable, nonatomic, strong) UIColor *controlTextColor;
@property (nullable, nonatomic, strong) UIColor *headerTextColor;
@property (nullable, nonatomic, strong) UIColor *inlineTextColor;
@property (nullable, nonatomic, strong) UIColor *codeTextColor;
@property (nullable, nonatomic, strong) UIColor *linkTextColor;

- (void)setColorWithBrightTheme; ///< reset the color properties to pre-defined value.
- (void)setColorWithDarkTheme;   ///< reset the color properties to pre-defined value.


@end



@interface TextSimpleEmoticonParser : NSObject<TextParser>


////表情对应的 字符   
@property (nullable ,copy) NSDictionary <NSString *,__kindof UIImage *> *emoticonMapper;

@end



NS_ASSUME_NONNULL_END 
