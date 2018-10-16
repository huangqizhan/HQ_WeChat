//
//  TextAttribute.h
//  YYStudyDemo
//
//  Created by hqz on 2018/7/20.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

////富文本类型
typedef NS_OPTIONS(NSInteger, TextAttributeType) {
    TextAttributeTypeNone = 0,          ///
    TextAttributeTypeUIKit = 1 << 0,    ///< UIKit attributes, such as UILabel/UITextField/drawInRect.
    TextAttributeTypeCoreText = 1 << 1, ///< CoreText attributes, used by CoreText.
    TextAttributeTypeText = 1 << 2      ///< YYText attributes, used by YYText.
};

/// 获取AttributeType
extern TextAttributeType TextAttributeGetType(NSString *name);

///下划线类型
typedef NS_OPTIONS(NSInteger, TextLineStyle) {
    // basic style (bitmask:0xFF)
    TextLineStyleNone       = 0x00, ///< (        ) Do not draw a line (Default).
    TextLineStyleSingle     = 0x01, ///< (──────) Draw a single line.
    TextLineStyleThick      = 0x02, ///< (━━━━━━━) Draw a thick line.
    TextLineStyleDouble     = 0x09, ///< (══════) Draw a double line.
    
    // style pattern (bitmask:0xF00)
    TextLineStylePatternSolid      = 0x000, ///< (────────) Draw a solid line (Default).
    TextLineStylePatternDot        = 0x100, ///< (‑ ‑ ‑ ‑ ‑ ‑) Draw a line of dots.
    TextLineStylePatternDash       = 0x200, ///< (— — — —) Draw a line of dashes.
    TextLineStylePatternDashDot    = 0x300, ///< (— ‑ — ‑ — ‑) Draw a line of alternating dashes and dots.
    TextLineStylePatternDashDotDot = 0x400, ///< (— ‑ ‑ — ‑ ‑) Draw a line of alternating dashes and two dots.
    TextLineStylePatternCircleDot  = 0x900, ///< (••••••••••••) Draw a line of small circle dots.
};
///垂直方向对齐方式
typedef NS_ENUM(NSInteger, TextVerticalAlignment) {
    TextVerticalAlignmentTop =    0, ///< Top alignment.
    TextVerticalAlignmentCenter = 1, ///< Center alignment.
    TextVerticalAlignmentBottom = 2, ///< Bottom alignment.
};
/**
 排版方向
 */
typedef NS_OPTIONS(NSUInteger, TextDirection) {
    TextDirectionNone   = 0,
    TextDirectionTop    = 1 << 0,
    TextDirectionRight  = 1 << 1,
    TextDirectionBottom = 1 << 2,
    TextDirectionLeft   = 1 << 3,
};

/**
 截断类型
 */
typedef NS_ENUM (NSUInteger, TextTruncationType) {
    /// No truncate.
    TextTruncationTypeNone   = 0,
    
    /// Truncate at the beginning of the line, leaving the end portion visible.
    TextTruncationTypeStart  = 1,
    
    /// Truncate at the end of the line, leaving the start portion visible.
    TextTruncationTypeEnd    = 2,
    
    /// Truncate in the middle of the line, leaving both the start and the end portions visible.
    TextTruncationTypeMiddle = 3,
};

#pragma mark - Attribute Name Defined in YYText

///备份支持的属性名
UIKIT_EXTERN NSString *const TextBackedStringAttributeName;

///绑定的字符串属性名
UIKIT_EXTERN NSString *const TextBindingAttributeName;

///阴影属性名
UIKIT_EXTERN NSString *const TextShadowAttributeName;

///内联属性名
UIKIT_EXTERN NSString *const TextInnerShadowAttributeName;

///下划线属性名
UIKIT_EXTERN NSString *const TextUnderlineAttributeName;

///中划线属性名
UIKIT_EXTERN NSString *const TextStrikethroughAttributeName;

////边线属性名
UIKIT_EXTERN NSString *const TextBorderAttributeName;

///边线背景
UIKIT_EXTERN NSString *const TextBackgroundBorderAttributeName;

///某一块的边线
UIKIT_EXTERN NSString *const TextBlockBorderAttributeName;

//// attachment
UIKIT_EXTERN NSString *const TextAttachmentAttributeName;

///行高
UIKIT_EXTERN NSString *const TextHighlightAttributeName;

///transform
UIKIT_EXTERN NSString *const TextGlyphTransformAttributeName;



#pragma mark - String Token Define

UIKIT_EXTERN NSString *const TextAttachmentToken; ///< Object replacement character (U+FFFC), used for text attachment.
UIKIT_EXTERN NSString *const TextTruncationToken; ///< Horizontal ellipsis (U+2026), used for text truncation  "…".



typedef void(^TextAction)(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect);




#pragma mark ------- 自定义的属性对象 ------
////粘贴复制时用的组合的字符串
@interface TextBackedString : NSObject <NSCopying,NSCoding>
+ (instancetype)stringWithString:(nullable NSString *)string;
@property (nullable, nonatomic, copy) NSString *string; ///< backed string
@end

////用关光标删除时 一次连续可以删除多个字符的  组合对象 
@interface TextBingString : NSObject<NSCopying,NSCoding>
+ (instancetype)bindingWithDeleteConfirm:(BOOL)deleteConfirm;
@property (nonatomic) BOOL deleteConfirm; ///< confirm the range when delete in YYTextView

@end


@interface TextShadow : NSObject <NSCoding, NSCopying>

+ (instancetype)shadowWithColor:(nullable UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius;

@property (nullable, nonatomic, strong) UIColor *color; ///< shadow color
@property (nonatomic) CGSize offset;                    ///< shadow offset
@property (nonatomic) CGFloat radius;                   ///< shadow blur radius
@property (nonatomic) CGBlendMode blendMode;            ///< shadow blend mode
@property (nullable, nonatomic, strong) TextShadow *subShadow;  ///< a sub shadow which will be added above the parent shadow

+ (instancetype)shadowWithNSShadow:(NSShadow *)nsShadow; ///< convert NSShadow to YYTextShadow
- (NSShadow *)nsShadow; ///< convert YYTextShadow to NSShadow

@end


@interface TextDecoration : NSObject <NSCoding, NSCopying>
+ (instancetype)decorationWithStyle:(TextLineStyle)style;
+ (instancetype)decorationWithStyle:(TextLineStyle)style width:(nullable NSNumber *)width color:(nullable UIColor *)color;
@property (nonatomic) TextLineStyle style;                   ///< line style
@property (nullable, nonatomic, strong) NSNumber *width;       ///< line width (nil means automatic width)
@property (nullable, nonatomic, strong) UIColor *color;        ///< line color (nil means automatic color)
@property (nullable, nonatomic, strong) TextShadow *shadow;  ///< line shadow
@end


@interface TextBorder : NSObject <NSCoding, NSCopying>
+ (instancetype)borderWithLineStyle:(TextLineStyle)lineStyle lineWidth:(CGFloat)width strokeColor:(nullable UIColor *)color;
+ (instancetype)borderWithFillColor:(nullable UIColor *)color cornerRadius:(CGFloat)cornerRadius;
@property (nonatomic) TextLineStyle lineStyle;              ///< border line style
@property (nonatomic) CGFloat strokeWidth;                    ///< border line width
@property (nullable, nonatomic, strong) UIColor *strokeColor; ///< border line color
@property (nonatomic) CGLineJoin lineJoin;                    ///< border line join
@property (nonatomic) UIEdgeInsets insets;                    ///< border insets for text bounds
@property (nonatomic) CGFloat cornerRadius;                   ///< border corder radius
@property (nullable, nonatomic, strong) TextShadow *shadow; ///< border shadow
@property (nullable, nonatomic, strong) UIColor *fillColor;   ///< inner fill color
@end



@interface TextAttachment : NSObject<NSCoding, NSCopying>
+ (instancetype)attachmentWithContent:(nullable id)content;
@property (nullable, nonatomic, strong) id content;             ///< Supported type: UIImage, UIView, CALayer
@property (nonatomic) UIViewContentMode contentMode;            ///< Content display mode.
@property (nonatomic) UIEdgeInsets contentInsets;               ///< The insets when drawing content.
@property (nullable, nonatomic, strong) NSDictionary *userInfo; ///< The user information dictionary.
@end



@interface TextHeightLight : NSObject <NSCopying,NSCoding>

@property (nullable, nonatomic, strong) NSDictionary <NSString *,id> *attributes;

+ (instancetype)highlightWithAttributes:(nullable NSDictionary <NSString *,id> *)attributes;

+ (instancetype)highlightWithBackgroundColor:(nullable UIColor *)color;


// Convenience methods below to set the `attributes`.
- (void)setFont:(nullable UIFont *)font;
- (void)setColor:(nullable UIColor *)color;
- (void)setStrokeWidth:(nullable NSNumber *)width;
- (void)setStrokeColor:(nullable UIColor *)color;
- (void)setShadow:(nullable TextShadow *)shadow;
- (void)setInnerShadow:(nullable TextShadow *)shadow;
- (void)setUnderline:(nullable TextDecoration *)underline;
- (void)setStrikethrough:(nullable TextDecoration *)strikethrough;
- (void)setBackgroundBorder:(nullable TextBorder *)border;
- (void)setBorder:(nullable TextBorder *)border;
- (void)setAttachment:(nullable TextAttachment *)attachment;

@property (nullable, nonatomic, copy) NSDictionary *userInfo;

@property (nullable, nonatomic, copy) TextAction tapAction;

@property (nullable, nonatomic, copy) TextAction longPressAction;

@end

NS_ASSUME_NONNULL_END
