//
//  TextLine.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/8/13.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "TextAttribute.h"


NS_ASSUME_NONNULL_BEGIN
@class TextRunGlyphRange;

///每一个CTLine 封装成TextLine 对象

@interface TextLine : NSObject

+ (instancetype)lineWithCTLine:(CTLineRef)CTLine position:(CGPoint)position vertical:(BOOL)isVertical;

@property (nonatomic) NSUInteger index;     ///< line index
@property (nonatomic) NSUInteger row;       ///< line row
@property (nullable, nonatomic, strong) NSArray<NSArray<TextRunGlyphRange *> *> *verticalRotateRange; ///< Run rotate range

@property (nonatomic, readonly) CTLineRef CTLine;   ///< CoreText line
@property (nonatomic, readonly) NSRange range;      ///< string range
@property (nonatomic, readonly) BOOL vertical;      ///< vertical form

@property (nonatomic, readonly) CGRect bounds;      ///< bounds (ascent + descent)
@property (nonatomic, readonly) CGSize size;        ///< bounds.size
@property (nonatomic, readonly) CGFloat width;      ///< bounds.size.width
@property (nonatomic, readonly) CGFloat height;     ///< bounds.size.height
@property (nonatomic, readonly) CGFloat top;        ///< bounds.origin.y
@property (nonatomic, readonly) CGFloat bottom;     ///< bounds.origin.y + bounds.size.height
@property (nonatomic, readonly) CGFloat left;       ///< bounds.origin.x
@property (nonatomic, readonly) CGFloat right;      ///< bounds.origin.x + bounds.size.width

@property (nonatomic)   CGPoint position;   ///< baseline position
@property (nonatomic, readonly) CGFloat ascent;     ///< line ascent
@property (nonatomic, readonly) CGFloat descent;    ///< line descent
@property (nonatomic, readonly) CGFloat leading;    ///< line leading
@property (nonatomic, readonly) CGFloat lineWidth;  ///< line width
@property (nonatomic, readonly) CGFloat trailingWhitespaceWidth;

@property (nullable, nonatomic, readonly) NSArray<TextAttachment *> *attachments; ///< YYTextAttachment
@property (nullable, nonatomic, readonly) NSArray<NSValue *> *attachmentRanges;     ///< NSRange(NSValue)
@property (nullable, nonatomic, readonly) NSArray<NSValue *> *attachmentRects;      ///< CGRect(NSValue)

@end

///文本最小单元的绘制方向
typedef NS_ENUM(NSUInteger, TextRunGlyphDrawMode) {
    /// No rotate.
    TextRunGlyphDrawModeHorizontal = 0,
    
    /// Rotate vertical for single glyph.
    TextRunGlyphDrawModeVerticalRotate = 1,
    
    /// Rotate vertical for single glyph, and move the glyph to a better position,
    /// such as fullwidth punctuation.
    TextRunGlyphDrawModeVerticalRotateMove = 2,
};

///字形绘制的最小单元的范围
@interface TextRunGlyphRange : NSObject

@property (nonatomic) NSRange glyphRangeInRun;
@property (nonatomic) TextRunGlyphDrawMode drawMode;
+ (instancetype)rangeWithRange:(NSRange)range drawMode:(TextRunGlyphDrawMode)mode;

@end


NS_ASSUME_NONNULL_END
