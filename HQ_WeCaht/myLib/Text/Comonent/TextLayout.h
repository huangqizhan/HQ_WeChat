//
//  TextLayout.h
//  YYStudyDemo
//
//  Created by hqz on 2018/8/18.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextLine.h"
#import "TextAttribute.h"
#import "TextInput.h"
#import "TextDebugOption.h"

NS_ASSUME_NONNULL_BEGIN

extern const CGSize textContainerMaxSize;

@class TextContainer;
@protocol TextLinePositionModifier <NSObject>

@required
////在layout  完成之前调用
- (void)modifyLines:(NSArray<TextLine *> *)lines fromText:(NSAttributedString *)text inContainer:(TextContainer *)container;

@end


///行文本   调节器
@interface TextLinePositionSimpleModifier : NSObject<TextLinePositionModifier,NSCopying>
///行高
@property (assign) CGFloat fixedLineHeight;

@end


@interface TextContainer : NSObject <NSCopying,NSCoding>

+ (instancetype)containerWithSize:(CGSize)size;

+ (instancetype)containerWithSize:(CGSize)size insets:(UIEdgeInsets)insets;

+ (instancetype)containerWithPath:(nullable UIBezierPath *)path;

@property (nullable, copy) UIBezierPath *path;
///排除的路径
@property (nullable, copy) NSArray<UIBezierPath *> *exclusionPaths;
///线宽
@property CGFloat pathLineWidth;
/*
 CGContextFillPath:使用的是非零绕组规则，Non-Zero Winding Number Rule。
 即选一个点，画一条射线，该射线与图形会交于几个点。如果射线穿过的path是从
 左到右的，加1，从右到左就减1，结果的值为非0，就填充,为0，就不填充。
 画图时候选择的方向(顺时针或者逆时针)会影响结果，
 例：一个环形(大圆套小圆)，如果画大圆和小圆时候选择方向一致，就全部填充，
 方向不一致，中间那块就不填写。
 
 CGContextEOFillPath：使用的是奇偶规则，even-odd rule。这个比较简单了，
 也是选一个点，画射线，看与图形交点的数目，是奇数就填充，偶数就不填
 */
////线的填充效果
@property (getter=isPathFillEvenOdd) BOOL pathFillEvenOdd;
@property NSUInteger maximumNumberOfRows;
////截断类型
@property TextTruncationType truncationType;
///截断类型的显示  default ...
@property (nullable, copy) NSAttributedString *truncationToken;

///// 是否是垂直排布   default NO 
@property (getter=isVerticalForm) BOOL verticalForm;

@property CGSize size;

@property UIEdgeInsets insets;

////在完成之前可做修改的回调
@property (nullable, copy) id<TextLinePositionModifier> linePositionModifier;


@end


@interface TextLayout : NSObject <NSCoding,NSCopying>

#pragma mark ---- generic  layout

+ (nullable TextLayout *)layoutWithContainerSize:(CGSize)size text:(NSAttributedString *)text;


+ (nullable TextLayout *)layoutWithContainer:(TextContainer *)container text:(NSAttributedString *)text;


+ (nullable TextLayout *)layoutWithContainer:(TextContainer *)container text:(NSAttributedString *)text range:(NSRange)range;


+ (NSArray <TextContainer *> *)layoutWithContainers:(NSArray<TextContainer *> *)containers text:(NSAttributedString *)text;


+ (NSArray<TextContainer *> *)layoutWithContainers:(NSArray<TextContainer *> *)containers text:(NSAttributedString *)text range:(NSRange)range;


- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

#pragma mark ------ attributes

///< The text container
@property (nonatomic, strong, readonly) TextContainer *container;
///< The full text
@property (nonatomic, strong, readonly) NSAttributedString *text;
///< The text range in full text
@property (nonatomic, readonly) NSRange range;
///< CTFrameSetter
@property (nonatomic, readonly) CTFramesetterRef frameSetter;
///< CTFrame
@property (nonatomic, readonly) CTFrameRef frame;
///< Array of `YYTextLine`, no truncated
@property (nonatomic, strong, readonly) NSArray<TextLine *> *lines;
///< YYTextLine with truncated token, or nil
@property (nullable, nonatomic, strong, readonly) TextLine *truncatedLine;
///< Array of `YYTextAttachment`
@property (nullable, nonatomic, strong, readonly) NSArray<TextAttachment *> *attachments;
///< Array of NSRange(wrapped by NSValue) in text
@property (nullable, nonatomic, strong, readonly) NSArray<NSValue *> *attachmentRanges;
///< Array of CGRect(wrapped by NSValue) in container
@property (nullable, nonatomic, strong, readonly) NSArray<NSValue *> *attachmentRects;
///< Set of Attachment (UIImage/UIView/CALayer)
@property (nullable, nonatomic, strong, readonly) NSSet *attachmentContentsSet;
///< Number of rows
@property (nonatomic, readonly) NSUInteger rowCount;
///< Visible text range
@property (nonatomic, readonly) NSRange visibleRange;
///< Bounding rect (glyphs)
@property (nonatomic, readonly) CGRect textBoundingRect;
///< Bounding size (glyphs and insets, ceil to pixel)
@property (nonatomic, readonly) CGSize textBoundingSize;
///< Has highlight attribute
@property (nonatomic, readonly) BOOL containsHighlight;
///< Has block border attribute
@property (nonatomic, readonly) BOOL needDrawBlockBorder;
///< Has background border attribute
@property (nonatomic, readonly) BOOL needDrawBackgroundBorder;
///< Has shadow attribute
@property (nonatomic, readonly) BOOL needDrawShadow;
///< Has underline attribute
@property (nonatomic, readonly) BOOL needDrawUnderline;
///< Has visible text
@property (nonatomic, readonly) BOOL needDrawText;
///< Has attachment attribute
@property (nonatomic, readonly) BOOL needDrawAttachment;
///< Has inner shadow attribute
@property (nonatomic, readonly) BOOL needDrawInnerShadow;
///< Has strickthrough attribute
@property (nonatomic, readonly) BOOL needDrawStrikethrough;
///< Has border attribute
@property (nonatomic, readonly) BOOL needDrawBorder;


#pragma mark   --- query   ---

/// 在row里对应的line的index
- (NSUInteger)lineIndexForRow:(NSUInteger)row;

///每一个row 里面的对应的line的数量
- (NSUInteger)lineCountForRow:(NSUInteger)row;

////line 对应的row
- (NSUInteger)rowIndexForLine:(NSUInteger)line;

///point 对应的line
- (NSUInteger)lineIndexForPoint:(CGPoint)point;

///离point 最近的line的索引
- (NSUInteger)closestLineIndexForPoint:(CGPoint)point;

///位置的偏移量
- (CGFloat)offsetForTextPosition:(NSUInteger)position lineIndex:(NSUInteger)lineIndex;

////point 对应的 text的位置
- (NSUInteger)textPositionForPoint:(CGPoint)point lineIndex:(NSUInteger)lineIndex;

////point 对应的最近的position
- (nullable TextPosition *)closestPositionToPoint:(CGPoint)point;

- (nullable TextPosition *)positionForPoint:(CGPoint)point
                                  oldPosition:(TextPosition *)oldPosition
                                otherPosition:(TextPosition *)otherPosition;

- (nullable TextRange *)textRangeAtPoint:(CGPoint)point;

///最近的textRange
- (nullable TextRange *)closestTextRangeAtPoint:(CGPoint)point;

/// textposition  对应的textrrange
- (nullable TextRange *)textRangeByExtendingPosition:(TextPosition *)position;

- (nullable TextRange *)textRangeByExtendingPosition:(TextPosition *)position
                                           inDirection:(UITextLayoutDirection)direction
                                                offset:(NSInteger)offset;

///position 对应的行的索引
- (NSUInteger)lineIndexForPosition:(TextPosition *)position;

///textposition  对应的 line 的point
- (CGPoint)linePositionForPosition:(TextPosition *)position;

//// textPosition 对应的rect
- (CGRect)caretRectForPosition:(TextPosition *)position;

////textRange 的第一个 row  对应的 rect
- (CGRect)firstRectForRange:(TextRange *)rang;

////textRange 对应的selectionRect
- (CGRect)rectForRange:(TextRange *)range;

////textRange 多个rect
- (NSArray<TextSelectionRect *> *)selectionRectsForRange:(TextRange *)range;

////textRange  对应的rect 不包含 开始和结束
- (NSArray<TextSelectionRect *> *)selectionRectsWithoutStartAndEndForRange:(TextRange *)range;

////textRange  仅仅包含 开始和结束
- (NSArray<TextSelectionRect *> *)selectionRectsWithOnlyStartAndEndForRange:(TextRange *)range;


#pragma mark ----- draw  ----

///绘制
- (void)drawInContext:(nullable CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
                 view:(nullable UIView *)view
                layer:(nullable CALayer *)layer
                debug:(nullable TextDebugOption *)debug
               cancel:(nullable BOOL (^)(void))cancel;


///绘制没有view layer 的 attachments
- (void)drawInContext:(CGContextRef)context
                 size:(CGSize)size
                debug:(TextDebugOption *)debug;
///显示所有的attachment
- (void)addAttachmentToView:(UIView *)view layer:(CALayer *)layer;

///移除所有的attachment
- (void)removeAttachmentFromViewAndLayer;
@end


NS_ASSUME_NONNULL_END
