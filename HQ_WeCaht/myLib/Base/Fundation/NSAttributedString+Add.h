//
//  NSAttributedString+Add.h
//  YYStudyDemo
//
//  Created by hqz on 2018/8/7.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextAttribute.h"
#import "TextRunDelegate.h"
#import "TextRubyAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (Add)

///归档 数据
- (nullable NSData *)archiveToData;

///解归档
+ (nullable instancetype)unarchiveFromData:(NSData *)data;

////属性值 属性名 
@property (nullable, nonatomic,strong,readonly) NSDictionary <NSString *,id>*attributes;


- (id)attribut:(NSString *)attributeName atIndex:(NSUInteger)index;

- (nullable NSDictionary<NSString *,id> *)attributesAtIndex:(NSUInteger)index;

////font 
@property (nullable, nonatomic, strong, readonly) UIFont *font;
- (nullable UIFont *)fontAtIndex:(NSUInteger)index;


////斜体
@property (nullable, nonatomic, strong , readonly) NSNumber *kern;
- (nullable NSNumber *)kernAtIndex:(NSUInteger)index;

////字体颜色
@property (nullable, nonatomic, strong, readonly) UIColor *foreColor;
- (nullable UIColor *)foreColorAtIndex:(NSUInteger)index;


///背景颜色
@property (nullable, nonatomic, strong , readonly ) UIColor *backGroundColor;
- (nullable UIColor *)backGroundColorAtIndex:(NSUInteger)index;

///画笔宽度
@property (nullable, nonatomic, strong, readonly) NSNumber *strokeWidth;
- (nullable NSNumber *)strokeWidthAtIndex:(NSUInteger)index;


////画笔颜色
@property (nullable, nonatomic, strong,readonly) UIColor *strokeColor;
- (nullable UIColor *)strokeColorAtIndex:(NSUInteger)index;


///阴影
@property (nonnull, nonatomic, strong, readonly) NSShadow *shadow;
- (nullable NSShadow *)shadowAtIndex:(NSUInteger)index;


///删除线
@property (nonatomic, readonly) NSUnderlineStyle strikethroughStyle;
- (NSUnderlineStyle)strikethroughStyleAtIndex:(NSUInteger)index;

///删除线颜色
@property (nullable, nonatomic,strong,readonly) UIColor *strikethroughColor;
- (UIColor *)strikethroughColorAtIndex:(NSUInteger)index;

////下划线
@property (nonatomic,readonly) NSUnderlineStyle underlineStyle;
- (NSUnderlineStyle)underlineStyleAtIndex:(NSUInteger)index;

///下划线颜色
@property (nullable,nonatomic,strong,readonly) UIColor *underLineColor;
- (UIColor *)underLineColorAtIndex:(NSUInteger)index;

///连体属性
@property (nullable,nonatomic,strong,readonly) NSNumber *ligature;
- (NSNumber *)ligatureAtIndex:(NSUInteger)index;

////设置文本特殊效果
@property (nullable,nonatomic,strong,readonly) NSString *textEffectName;
- (NSString *)textEffectNameAtIndex:(NSUInteger)index;

///设置字形倾斜度
@property (nullable,nonatomic,strong,readonly) NSNumber *obliqueness;
- (NSNumber *)obliquenessAtIndex:(NSUInteger)index;

////设置文本横向拉伸属性
@property (nullable,nonatomic,strong,readonly) NSNumber *expansion;
- (NSNumber *)expansionAtIndex:(NSUInteger)index;

////基线的相对位置
@property (nullable,nonatomic,strong,readonly) NSNumber *baseLineOffset;
- (NSNumber *)baseLineOffsetAtIndex:(NSUInteger)index;


////设置文字排版方向，取值为 NSNumber 对象(整数)，0 表示横排文本，1 表示竖排文本
@property (nonatomic,readonly) BOOL verticalGlyphForm;
- (BOOL)verticalGlyphFormAtIndex:(NSUInteger)index;


///语言
@property (nullable,nonatomic,strong,readonly) NSString *languageName;
- (NSString *)languageNameAtIndex:(NSUInteger)index;


///书写方向
@property (nullable,nonatomic,strong,readonly) NSArray <NSNumber *>*writingDirection;
- (NSArray <NSNumber *>*)writingDirectionAtIndex:(NSUInteger)index;


///段落
@property (nullable,nonatomic,strong,readonly) NSParagraphStyle *paragraphStyle;
- (NSParagraphStyle *)paragraphStyleAtIndex:(NSUInteger)index;


/****  段落属性    ***/

/*
 
 NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
 
 paragraphStyle.lineSpacing = 20.;// 行间距
 paragraphStyle.lineHeightMultiple = 1.5;// 行高倍数（1.5倍行高）
 paragraphStyle.firstLineHeadIndent = 30.0f;//首行缩进
 paragraphStyle.minimumLineHeight = 10;//最低行高
 paragraphStyle.maximumLineHeight = 20;//最大行高(会影响字体)
 
 paragraphStyle.alignment = NSTextAlignmentLeft;// 对齐方式
 paragraphStyle.defaultTabInterval = 144;// 默认Tab 宽度
 paragraphStyle.headIndent = 20;// 起始 x位置
 paragraphStyle.tailIndent = 320;// 结束 x位置（不是右边间距，与inset 不一样）
 
 paragraphStyle.paragraphSpacing = 44.;// 段落间距
 paragraphStyle.paragraphSpacingBefore = 44.;// 段落头部空白(实测与上边的没差啊？)
 
 
 paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;// 分割模式

 NSLineBreakByWordWrapping = 0,      // Wrap at word boundaries, default
 NSLineBreakByCharWrapping,  // Wrap at character boundaries
 NSLineBreakByClipping,  // Simply clip
 NSLineBreakByTruncatingHead, // Truncate at head of line: "...wxyz"
 NSLineBreakByTruncatingTail, // Truncate at tail of line: "abcd..."
 NSLineBreakByTruncatingMiddle // Truncate middle of line:  "ab...yz"


paragraphStyle.baseWritingDirection = NSWritingDirectionRightToLeft;// 段落方向
 NSWritingDirectionNatural       = -1,    // Determines direction using the Unicode Bidi Algorithm rules P2 and P3
 NSWritingDirectionLeftToRight   =  0,    // Left to right writing direction
 NSWritingDirectionRightToLeft   =  1
 */

///对齐方式
@property (nonatomic,readonly) NSTextAlignment aligenment;
- (NSTextAlignment)aligenmentAtIndex:(NSUInteger)index;

///换行
@property (nonatomic,readonly) NSLineBreakMode lineBreakMode;
- (NSLineBreakMode)lineBreakModelAtIndex:(NSUInteger)index;

///行间距
@property (nonatomic,readonly) CGFloat linespace;
- (CGFloat)linespaceAtIndex:(NSUInteger)index;

///段间距
@property (nonatomic,readonly) CGFloat paraGraphSpace;
- (CGFloat)paraGraphSpaceAtIndex:(NSUInteger)index;

///段头
@property (nonatomic,readonly) CGFloat paraGraphHead;
- (CGFloat)paraGraphHeadAtIndex:(CGFloat)index;

////首行缩进
@property (nonatomic,readonly)CGFloat firstLineHeadIndent;
- (CGFloat)firstLineHeadIndentAtIndex:(NSUInteger)index;


///起始位置
@property (nonatomic,readonly) CGFloat headIndent;
- (CGFloat)headIndentAtIndex:(NSUInteger)index;

///结束位置
@property (nonatomic,readonly) CGFloat tailIndent;
- (CGFloat)tailIndentAtIndex:(NSUInteger)index;

///最小行高
@property (nonatomic,readonly) CGFloat minLineHeight;
- (CGFloat)minLineHeightAtIndex:(NSUInteger)index;

///最大行高
@property (nonatomic,readonly) CGFloat maxLineHeight;
- (CGFloat)maxLineHeightAtIndex:(NSUInteger)index;


///行高倍数 
@property (nonatomic,readonly) CGFloat lineHeightMultiple;
- (CGFloat)lineHeightMultipleAtIndex:(NSUInteger)index;

///段落方向
@property (nonatomic,readonly) NSWritingDirection baseWritingDirection;
- (NSWritingDirection)baseWritingDirectionAtIndex:(NSUInteger)index;
///连字符属性，取值 0 到 1 之间，开启断词功能
@property (nonatomic, readonly) float hyphenationFactor;
- (float)hyphenationFactorAtIndex:(NSUInteger)index;

////tab 的宽度
@property (nonatomic,readonly) CGFloat defaultTabInterval;
- (CGFloat)defaultTabIntervalAtIndex:(NSUInteger)index;


#warning ======需要测试 =====
///
@property (nullable,nonatomic,strong,readonly) NSArray <NSTextTab *>*textStops;
- (NSArray <NSTextTab *> *)textStopsAtIndex:(NSUInteger)index;


#warning 需要测试自定义的属性
#pragma mark ------ 自定义的属性 --------
/// 文字阴影
@property (nullable,nonatomic,strong,readonly) TextShadow *textShadow;
- (TextShadow *)textShadowAtIndex:(NSUInteger)index;


///文字内部阴影
@property (nullable,nonatomic,strong,readonly) TextShadow *textInnerShadow;
- (TextShadow *)textInnerShadowAtIndex:(NSUInteger)index;

////文字下划线
@property (nullable,nonatomic,strong,readonly) TextDecoration *textUnderLine;
- (TextDecoration *)textUnderLineAtIndex:(NSUInteger)index;


////中划线
@property (nullable,nonatomic,strong,readonly)TextDecoration *strikeThrough;
- (TextDecoration *)strikeThroughAtIndex:(NSUInteger)index;


///文字边框
@property (nullable,nonatomic,strong,readonly) TextBorder *textBorder;
- (TextBorder *)textBorderAtIndex:(NSUInteger)index;

///文字边框背景
@property (nullable,nonatomic,strong,readonly) TextBorder *textBackgroundBorder;
- (TextBorder *)textBackgroundBorderAtIndex:(NSUInteger)index;

///字形的位置变换
@property (nonatomic,readonly) CGAffineTransform textGlyphTransform;
- (CGAffineTransform)textGlyphTransformAtIndex:(NSUInteger)index;


///获取 TextBackedStringAttributeName
- (nullable NSString *)plainTextForRange:(NSRange)range;


#pragma mark    attachment
///创建一个带有attachment 的属性字符串
+ (NSMutableAttributedString *)h_attachmentStringWithContent:(id)content
                                                 contentMode:(UIViewContentMode)contentMode
                                                       width:(CGFloat)width
                                                      ascent:(CGFloat)ascent
                                                     descent:(CGFloat)descent ;

+ (NSMutableAttributedString *)h_attachmentStringWithContent:(id)content
                                                 contentMode:(UIViewContentMode)contentMode
                                              attachmentSize:(CGSize)attachmentSize alignToFont:(UIFont *)font alignment:(TextVerticalAlignment)alignment;
+ (NSMutableAttributedString *)h_attachmentStringWithEmojiImage:(UIImage *)image
                                                        fontSize:(CGFloat)fontSize;

///self range
- (NSRange)rangeOfAll;

///是否可以支持所有的范围内 
- (BOOL)isSharedAttributesInAllRange;
///是否支持UIKIT 
- (BOOL)canDrawWithUIKit ;
@end



@interface NSMutableAttributedString (Add)


#pragma mark  ---- 设置属性  ------
- (void)h_setAttribute:(NSString *)key value:(id)value range:(NSRange)range;
- (void)h_setAttribute:(NSString *)key value:(id)value;
- (void)h_setAttributes:(NSDictionary<NSString * ,id> *)attributes;

#pragma mark ---- 移除属性 -----
- (void)h_removeAttributesInRange:(NSRange)range;

////设置字体
@property (nullable,nonatomic,strong,readwrite) UIFont *font;
- (void)h_setFont:(UIFont *)font range:(NSRange)range;

///设置斜体
@property (nullable,nonatomic,strong,readwrite) NSNumber *kern;
- (void)h_setKern:(NSNumber *)kern range:(NSRange)range;

///设置前景色
@property (nullable,nonatomic,strong,readwrite) UIColor  *foreColor;
- (void)h_setForeColor:(UIColor *)color range:(NSRange)range;

///设置背景色
@property (nullable, nonatomic, strong , readwrite) UIColor *backGroundColor;
- (void)h_setBackGroungColor:(UIColor *)color range:(NSRange)range;

///画笔宽度
@property (nullable, nonatomic, strong, readwrite) NSNumber *strokeWidth;
- (void)h_setStrokeWidth:(NSNumber *)width range:(NSRange)range;

////画笔颜色
@property (nullable, nonatomic, strong,readwrite) UIColor *strokeColor;
- (void)h_setStrokeColor:(UIColor *)color range:(NSRange)range;


///阴影
@property (nonnull, nonatomic, strong, readwrite) NSShadow *shadow;
- (void)h_setShadow:(NSShadow *)shadow range:(NSRange)range;


///删除线
@property (nonatomic, readwrite) NSUnderlineStyle strikethroughStyle;
- (void)h_setStrikethroughStyle:(NSUnderlineStyle )strikethroughStyle range:(NSRange)range;

///删除线颜色
@property (nullable, nonatomic,strong,readwrite) UIColor *strikethroughColor;
- (void)h_setStrikethroughColor:(UIColor *)color range:(NSRange)range;


////下划线
@property (nonatomic,readwrite) NSUnderlineStyle underlineStyle;
- (void)h_setUnderlineStyle:(NSUnderlineStyle )underline range:(NSRange)range;

///下划线颜色
@property (nullable,nonatomic,strong,readwrite) UIColor *underLineColor;
- (void)h_setUnderLineColor:(UIColor *)color range:(NSRange)range;

///连体属性
@property (nullable,nonatomic,strong,readwrite) NSNumber *ligature;
- (void)h_setLigature:(NSNumber *)ligature range:(NSRange)range;

////设置文本特殊效果
@property (nullable,nonatomic,strong,readwrite) NSString *textEffectName;
- (void)h_setTextEffectName:(NSString *)name range:(NSRange)range;

///设置字形倾斜度
@property (nullable,nonatomic,strong,readwrite) NSNumber *obliqueness;
- (void)h_setObliqueness:(NSNumber *)obliquness range:(NSRange)range;

////设置文本横向拉伸属性
@property (nullable,nonatomic,strong,readwrite) NSNumber *expansion;
- (void)h_setExpansion:(NSNumber *)expansion range:(NSRange)range;

////基线的相对位置
@property (nullable,nonatomic,strong,readwrite) NSNumber *baseLineOffset;
- (void)h_setBaseLineOffset:(NSNumber *)baseLineOffset range:(NSRange)range;
////设置文字排版方向，取值为 NSNumber 对象(整数)，0 表示横排文本，1 表示竖排文本
@property (nonatomic,readwrite) BOOL verticalGlyphForm;
- (void)h_setVerticalGlyphForm:(BOOL)verticalGlyphForm;

///语言
@property (nullable,nonatomic,strong,readwrite) NSString *languageName;
- (void)h_setLanguageName:(NSString *)name range:(NSRange)range;

///书写方向
@property (nullable,nonatomic,strong,readwrite) NSArray <NSNumber *>*writingDirection;
- (void)h_setWritingDirection:(NSArray *)writingDirection range:(NSRange)range;

///段落
@property (nullable,nonatomic,strong,readwrite) NSParagraphStyle *paragraphStyle;

- (void)h_setParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range;

///对齐方式
@property (nonatomic,readwrite) NSTextAlignment aligenment;
- (void)h_setAligement:(NSTextAlignment)aligenment range:(NSRange)range;

///换行
@property (nonatomic,readwrite) NSLineBreakMode lineBreakMode;
- (void)h_setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range;
///行间距
@property (nonatomic,readwrite) CGFloat linespace;
- (void)h_setLinespace:(CGFloat)lineSpacing range:(NSRange)range;
///段间距
@property (nonatomic,readwrite) CGFloat paraGraphSpace;
- (void)h_setParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range;
///段头
@property (nonatomic,readwrite) CGFloat paraGraphHead;
- (void)h_setParaGraphHead:(CGFloat)paragraphSpacingBefore range:(NSRange)range;

///首行缩进
@property (nonatomic,readwrite)CGFloat firstLineHeadIndent;
- (void)h_setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range;

///起始位置
@property (nonatomic,readwrite) CGFloat headIndent;
- (void)h_setHeadIndent:(CGFloat)headIndent range:(NSRange)range;

///结束位置
@property (nonatomic,readwrite) CGFloat tailIndent;
- (void)h_setTailIndent:(CGFloat)tailIndent range:(NSRange)range;

///最小行高
@property (nonatomic,readwrite) CGFloat minLineHeight;
- (void)h_setMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range;

///最大行高
@property (nonatomic,readwrite) CGFloat maxLineHeight;
- (void)h_setMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range;

///行高倍数
@property (nonatomic,readwrite) CGFloat lineHeightMultiple;
- (void)h_setLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range;
///段落方向
@property (nonatomic,readwrite) NSWritingDirection baseWritingDirection;
- (void)h_setBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range;
////连字符属性，取值 0 到 1 之间，开启断词功能 
@property (nonatomic, readwrite) float hyphenationFactor;
- (void)h_setHyphenationFactor:(float)hyphenationFactor range:(NSRange)range;

////tab 的宽度
@property (nonatomic,readwrite) CGFloat defaultTabInterval;
- (void)h_setDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range NS_AVAILABLE_IOS(7_0);

@property (nullable,nonatomic,strong,readwrite) NSArray <NSTextTab *>*textStops;
- (void)h_setTabStops:(nullable NSArray<NSTextTab *> *)tabStops range:(NSRange)range;

/// 文字阴影
@property (nullable,nonatomic,strong,readwrite) TextShadow *textShadow;
- (void)h_setTextShadow:(TextShadow *)shadow range:(NSRange)range;

///文字内部阴影
@property (nullable,nonatomic,strong,readwrite) TextShadow *textInnerShadow;
- (void)h_setTextInnerShadow:(TextShadow *)innerShadow range:(NSRange)range;


////文字下划线
@property (nullable,nonatomic,strong,readwrite) TextDecoration *textUnderLine;
- (void)h_setTextUnderLine:(TextDecoration *)textUnderLine range:(NSRange)range;
////中划线
@property (nullable,nonatomic,strong,readwrite)TextDecoration *strikeThrough;
- (void)h_setStrikeThrough:(TextDecoration *)strikeThrough range:(NSRange)range;

///文字边框
@property (nullable,nonatomic,strong,readwrite) TextBorder *textBorder;
- (void)h_setTextBorder:(TextBorder *)border range:(NSRange)range;
///文字边框背景
@property (nullable,nonatomic,strong,readwrite) TextBorder *textBackgroundBorder;
- (void)h_setTextBackgroundBorder:(TextBorder *)border range:(NSRange)range;

///字形的位置变换
@property (nonatomic,readwrite) CGAffineTransform textGlyphTransform;
- (void)h_setTextGlyphTransform:(CGAffineTransform )tramsform range:(NSRange)range;




#pragma mark ------ 非连续的属性设置  ------

////文字的上下坐标    如排列组合 Cn2
- (void)h_setSuperscript:(nullable NSNumber *)superscript range:(NSRange)range;
///字形设置
- (void)h_setGlyphInfo:(nullable CTGlyphInfoRef)glyphInfo range:(NSRange)range;
///字符大小
- (void)h_setCharacterShape:(nullable NSNumber *)characterShape range:(NSRange)range;
///排版回调
- (void)h_setRunDelegate:(nullable CTRunDelegateRef)runDelegate range:(NSRange)range;
///基线
- (void)h_setBaselineClass:(nullable CFStringRef)baselineClass range:(NSRange)range;
///基线信息
- (void)h_setBaselineInfo:(nullable CFDictionaryRef)baselineInfo range:(NSRange)range;
///基线
- (void)h_setBaselineReferenceInfo:(nullable CFDictionaryRef)referenceInfo range:(NSRange)range;
///拼音
- (void)h_setRubyAnnotation:(nullable CTRubyAnnotationRef)ruby range:(NSRange)range;
///图片
- (void)h_setAttachment:(nullable NSTextAttachment *)attachment range:(NSRange)range NS_AVAILABLE_IOS(7_0);
///超链接
- (void)h_setLink:(nullable id)link range:(NSRange)range NS_AVAILABLE_IOS(7_0);
///
- (void)h_setTextBackedString:(nullable TextBackedString *)textBackedString range:(NSRange)range;
///绑定字符串
- (void)h_setTextBinding:(nullable TextBingString *)textBinding range:(NSRange)range;
///图片
- (void)h_setTextAttachment:(nullable TextAttachment *)textAttachment range:(NSRange)range;
///高亮
- (void)h_setTextHighlight:(nullable TextHeightLight *)textHighlight range:(NSRange)range;
///边框
- (void)h_setTextBlockBorder:(nullable TextBorder *)textBlockBorder range:(NSRange)range;
///拼音
- (void)h_setTextRubyAnnotation:(nullable TextRubyAnnotation *)ruby range:(NSRange)range NS_AVAILABLE_IOS(8_0);


#pragma mark ----- Action -----
- (void)h_setTextHighlightRange:(NSRange)range
                           color:(nullable UIColor *)color
                 backgroundColor:(nullable UIColor *)backgroundColor
                        userInfo:(nullable NSDictionary *)userInfo
                       tapAction:(nullable TextAction)tapAction
                 longPressAction:(nullable TextAction)longPressAction;

- (void)h_setTextHighlightRange:(NSRange)range
                          color:(UIColor *)color
                backgroundColor:(UIColor *)backgroundColor
                      tapAction:(TextAction)tapAction;

- (void)h_setTextHighlightRange:(NSRange)range
                          color:(UIColor *)color
                backgroundColor:(UIColor *)backgroundColor
                       userInfo:(NSDictionary *)userInfo;

///出入字符串  默认没有属性
- (void)h_insertString:(NSString *)string atIndex:(NSUInteger)location;
////追加字符串 默认没有属性
- (void)h_appendString:(NSString *)string;
////多个表情连接在一块的时候 会出现 不同的背景 coreText bug iOS 9之后已经修复
- (void)h_setClearColorToJoinedEmoji;
///删除所有非连续的属性
- (void)h_removeDiscontinuousAttributesInRange:(NSRange)range ;

////获取所有非连续的属性
+ (NSArray *)h_allDiscontinuousAttributeKeys ;
@end




NS_ASSUME_NONNULL_END
