//
//  TextLayout.m
//  YYStudyDemo
//
//  Created by hqz on 2018/8/18.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "TextLayout.h"
#import <CoreText/CoreText.h>
#import "NSAttributedString+Add.h"
#import <CoreGraphics/CoreGraphics.h>
#import "TextUtilites.h"
#import "TextArchive.h"
#import "UIFont+Add.h"
#import "NSAttributedString+Add.h"


const CGSize textContainerMaxSize = (CGSize) {0x100000, 0x100000};

///行的边距
typedef struct {
    CGFloat head;
    CGFloat foot;
}TextRowEdge;

static inline CGSize TextClipCGSize(CGSize size){
    if (size.width > textContainerMaxSize.width)
        size.width = textContainerMaxSize.width;
    if (size.height > textContainerMaxSize.height)
        size.height = textContainerMaxSize.height;
    return size;
}
static inline UIEdgeInsets UIEdgeInsetRotateVertical(UIEdgeInsets insets){
    UIEdgeInsets one ;
    one.top = insets.left;
    one.left = insets.bottom;
    one.bottom = insets.right;
    one.right = insets.top;
    return one;
}
static CGColorRef TextGetCGColor(CGColorRef color) {
    static UIColor *defaultColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultColor = [UIColor blackColor];
    });
    if (!color) return defaultColor.CGColor;
    if ([((__bridge NSObject *)color) respondsToSelector:@selector(CGColor)]) {
        return ((__bridge UIColor *)color).CGColor;
    }
    return color;
}


@implementation TextLinePositionSimpleModifier

- (void)modifyLines:(NSArray<TextLine *> *)lines fromText:(NSAttributedString *)text inContainer:(TextContainer *)container{
    if (container.verticalForm) {
        for (int i = 0 , max = (int)lines.count; i < max; i++) {
            TextLine *line = lines[i];
            CGPoint pos = line.position;
            pos.x = container.size.width - container.insets.left - _fixedLineHeight * line.row - _fixedLineHeight * 0.9;
            line.position = pos;
        }
    }else{
        for (int i = 0 , max = (int)lines.count; i < max; i++) {
            TextLine *line = lines[i];
            CGPoint pos = line.position;
            pos.y = container.insets.top + _fixedLineHeight * line.row + _fixedLineHeight * 0.9;
            line.position = pos;
        }
    }
}

- (instancetype)copyWithZone:(NSZone *)zone{
    typeof(self) one = [self.class new];
    one.fixedLineHeight = _fixedLineHeight;
    return one;
}

@end


@implementation  TextContainer{
    @package
    BOOL _readonly;
    dispatch_semaphore_t _lock;
    UIBezierPath *_path;
    NSArray *_exclusionPaths;
    BOOL _pathFillEvenOdd;
    CGFloat _pathLineWidth;
    NSUInteger _maximumNumberOfRows;
    TextTruncationType _truncationType;
    NSAttributedString *_truncationToken;
    BOOL _verticalForm;
    id<TextLinePositionModifier> _linePositionModifier;
    CGSize _size;
    UIEdgeInsets _insets;
}

+ (instancetype)containerWithSize:(CGSize)size{
    return [self containerWithSize:size insets:UIEdgeInsetsZero];
}
+ (instancetype)containerWithSize:(CGSize)size insets:(UIEdgeInsets)insets{
    TextContainer *container = [TextContainer new];
    container.size = size;
    container.insets = insets;
    return container;
}

+ (instancetype)containerWithPath:(UIBezierPath *)path{
    TextContainer *one = [self new];
    one.path = path;
    return one;
}
- (instancetype)init{
    self = [super init];
    if(!self) return nil;
    _lock = dispatch_semaphore_create(1);
    _pathFillEvenOdd = YES;
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    TextContainer *one = [self.class new];
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    one->_size = _size;
    one->_insets = _insets;
    one->_path = _path;
    one->_exclusionPaths = _exclusionPaths.copy;
    one->_pathFillEvenOdd = _pathFillEvenOdd;
    one->_pathLineWidth = _pathLineWidth;
    one->_verticalForm = _verticalForm;
    one->_maximumNumberOfRows = _maximumNumberOfRows;
    one->_truncationType = _truncationType;
    one->_truncationToken = _truncationToken.copy;
    one->_linePositionModifier = [(NSObject *)_linePositionModifier copy];
    dispatch_semaphore_signal(_lock);
    return one;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [self copyWithZone:zone];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSValue valueWithCGSize:_size] forKey:@"size"];
    [aCoder encodeObject:[NSValue valueWithUIEdgeInsets:_insets] forKey:@"insets"];
    [aCoder encodeObject:_path forKey:@"path"];
    [aCoder encodeObject:_exclusionPaths forKey:@"exclusionPaths"];
    [aCoder encodeBool:_pathFillEvenOdd forKey:@"pathFillEvenOdd"];
    [aCoder encodeDouble:_pathLineWidth forKey:@"pathLineWidth"];
    [aCoder encodeBool:_verticalForm forKey:@"verticalForm"];
    [aCoder encodeInteger:_maximumNumberOfRows forKey:@"maximumNumberOfRows"];
    [aCoder encodeInteger:_truncationType forKey:@"truncationType"];
    [aCoder encodeObject:_truncationToken forKey:@"truncationToken"];
    if ([_linePositionModifier respondsToSelector:@selector(encodeWithCoder:)] &&
        [_linePositionModifier respondsToSelector:@selector(initWithCoder:)]) {
        [aCoder encodeObject:_linePositionModifier forKey:@"linePositionModifier"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    _size = ((NSValue *)[aDecoder decodeObjectForKey:@"size"]).CGSizeValue;
    _insets = ((NSValue *)[aDecoder decodeObjectForKey:@"insets"]).UIEdgeInsetsValue;
    _path = [aDecoder decodeObjectForKey:@"path"];
    _exclusionPaths = [aDecoder decodeObjectForKey:@"exclusionPaths"];
    _pathFillEvenOdd = [aDecoder decodeBoolForKey:@"pathFillEvenOdd"];
    _pathLineWidth = [aDecoder decodeDoubleForKey:@"pathLineWidth"];
    _verticalForm = [aDecoder decodeBoolForKey:@"verticalForm"];
    _maximumNumberOfRows = [aDecoder decodeIntegerForKey:@"maximumNumberOfRows"];
    _truncationType = [aDecoder decodeIntegerForKey:@"truncationType"];
    _truncationToken = [aDecoder decodeObjectForKey:@"truncationToken"];
    _linePositionModifier = [aDecoder decodeObjectForKey:@"linePositionModifier"];
    return self;
}

#define Getter(...) \
dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

#define Setter(...) \
if (_readonly) { \
@throw [NSException exceptionWithName:NSInternalInconsistencyException \
reason:@"Cannot change the property of the 'container' in 'YYTextLayout'." userInfo:nil]; \
return; \
} \
dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);


- (CGSize)size {
    Getter(CGSize size = _size) return size;
}

- (void)setSize:(CGSize)size {
    Setter(if(!_path) _size = TextClipCGSize(size));
}

- (UIEdgeInsets)insets {
    Getter(UIEdgeInsets insets = _insets) return insets;
}

- (void)setInsets:(UIEdgeInsets)insets {
    Setter(if(!_path){
        if (insets.top < 0) insets.top = 0;
        if (insets.left < 0) insets.left = 0;
        if (insets.bottom < 0) insets.bottom = 0;
        if (insets.right < 0) insets.right = 0;
        _insets = insets;
    });
}

- (UIBezierPath *)path {
    Getter(UIBezierPath *path = _path) return path;
}

- (void)setPath:(UIBezierPath *)path {
    Setter(
           _path = path.copy;
           if (_path) {
               CGRect bounds = _path.bounds;
               CGSize size = bounds.size;
               UIEdgeInsets insets = UIEdgeInsetsZero;
               if (bounds.origin.x < 0) size.width += bounds.origin.x;
               if (bounds.origin.x > 0) insets.left = bounds.origin.x;
               if (bounds.origin.y < 0) size.height += bounds.origin.y;
               if (bounds.origin.y > 0) insets.top = bounds.origin.y;
               _size = size;
               _insets = insets;
           }
           );
}

- (NSArray *)exclusionPaths {
    Getter(NSArray *paths = _exclusionPaths) return paths;
}

- (void)setExclusionPaths:(NSArray *)exclusionPaths {
    Setter(_exclusionPaths = exclusionPaths.copy);
}

- (BOOL)isPathFillEvenOdd {
    Getter(BOOL is = _pathFillEvenOdd) return is;
}

- (void)setPathFillEvenOdd:(BOOL)pathFillEvenOdd {
    Setter(_pathFillEvenOdd = pathFillEvenOdd);
}

- (CGFloat)pathLineWidth {
    Getter(CGFloat width = _pathLineWidth) return width;
}

- (void)setPathLineWidth:(CGFloat)pathLineWidth {
    Setter(_pathLineWidth = pathLineWidth);
}

- (BOOL)isVerticalForm {
    Getter(BOOL v = _verticalForm) return v;
}

- (void)setVerticalForm:(BOOL)verticalForm {
    Setter(_verticalForm = verticalForm);
}

- (NSUInteger)maximumNumberOfRows {
    Getter(NSUInteger num = _maximumNumberOfRows) return num;
}

- (void)setMaximumNumberOfRows:(NSUInteger)maximumNumberOfRows {
    Setter(_maximumNumberOfRows = maximumNumberOfRows);
}

- (TextTruncationType)truncationType {
    Getter(TextTruncationType type = _truncationType) return type;
}

- (void)setTruncationType:(TextTruncationType)truncationType {
    Setter(_truncationType = truncationType);
}

- (NSAttributedString *)truncationToken {
    Getter(NSAttributedString *token = _truncationToken) return token;
}

- (void)setTruncationToken:(NSAttributedString *)truncationToken {
    Setter(_truncationToken = truncationToken.copy);
}

- (void)setLinePositionModifier:(id<TextLinePositionModifier>)linePositionModifier {
    Setter(_linePositionModifier = [(NSObject *)linePositionModifier copy]);
}

- (id<TextLinePositionModifier>)linePositionModifier {
    Getter(id<TextLinePositionModifier> m = _linePositionModifier) return m;
}
#undef Getter
#undef Setter

@end

@interface TextLayout ()
@property (nonatomic, readwrite) TextContainer  *container;
@property (nonatomic, readwrite) NSAttributedString *text;
@property (nonatomic, readwrite) NSRange range;
///CTFramesetterRef是CTFrameRef的一个工厂
@property (nonatomic,readwrite) CTFramesetterRef frameSetter;
///每一帧
@property (nonatomic,readwrite) CTFrameRef frame;
///行
@property (nonatomic,readwrite) NSArray *lines;
///截断行
@property (nonatomic,readwrite) TextLine *truncatedLine;
///图片
@property (nonatomic,readwrite) NSArray *attachments;
///图片范围
@property (nonatomic,readwrite) NSArray *attachmentRangs;
///图片rect
@property (nonatomic,readwrite) NSArray *attachmentRects;
///图片内容
@property (nonatomic,readwrite)NSSet *attachmentContentsSet;
///行数
@property (nonatomic,readwrite) NSUInteger rowCount;
///可见范围
@property (nonatomic,readwrite) NSRange visibleRange;
///绑定范围
@property (nonatomic,readwrite) CGRect textBoundingRect;
@property (nonatomic,readwrite) CGSize textBoundingSize;
///是否包含行高
@property (nonatomic,readwrite) BOOL containsHighlight;
///是否有块的边框
@property (nonatomic,readwrite) BOOL needDrawBlockBorder;
///是否有背景的边框
@property (nonatomic,readwrite) BOOL needDrawBackgroundBorder;
///是否有阴影
@property (nonatomic,readwrite) BOOL needDrawShadow;
///是否有下划线
@property (nonatomic,readwrite) BOOL needDrawUnderline;
@property (nonatomic,readwrite) BOOL needDrawText;
@property (nonatomic,readwrite) BOOL needDrawAttachment;
@property (nonatomic,readwrite) BOOL needDrawInnerShadow;
@property (nonatomic,readwrite) BOOL needDrawStrikethrough;
@property (nonatomic,readwrite) BOOL needDrawBorder;
@property (nonatomic,readwrite) NSUInteger *lineRowsIndex;
@property (nonatomic,readwrite) TextRowEdge *lineRowEdge;
@end


@implementation TextLayout

#pragma mark ------ Init -------

- (instancetype)_init{
    self = [super init];
    if (!self) return nil;
    return self;
}
+ (nullable TextLayout *)layoutWithContainerSize:(CGSize)size text:(NSAttributedString *)text{
    TextContainer *container = [TextContainer containerWithSize:size];
    return [self layoutWithContainer:container text:text];
}
+ (nullable TextLayout *)layoutWithContainer:(TextContainer *)container text:(NSAttributedString *)text{
    return [self layoutWithContainer:container text:text range:NSMakeRange(0, text.length)];
}
+ (TextLayout *)layoutWithContainer:(TextContainer *)container text:(NSAttributedString *)text range:(NSRange)range{
    TextLayout *layout = NULL;
    CGPathRef cgpath = NULL;
    CGRect cgPathBox = {0};
    BOOL isVerticalForm = NO;
    BOOL rowMaySepreated = NO;
    NSMutableDictionary *frameAttrs = nil;
    CTFramesetterRef ctFrameSetter = NULL;
    CTFrameRef ctFrame = NULL;
    CFArrayRef ctLines = NULL;
    CGPoint *lineOrigins = NULL;
    NSUInteger lineCount = 0;
    NSMutableArray *lines = nil;
    NSMutableArray *attachments = nil;
    NSMutableArray *attachmentRanges = nil;
    NSMutableArray *attachmentRects = nil;
    NSMutableSet *attachmentContentSet = nil;
    BOOL needTruncation = NO;
    NSAttributedString *truncationToken = nil;
    TextLine *truncatedLine = nil;
    TextRowEdge *lineRowsEdge = NULL;
    NSUInteger *lineRowsIndex = NULL;
    NSRange visibleRange = {0};
    NSUInteger maximumNumberOfRows = 0;
    BOOL constraintSizeIsExtended = NO;
    CGRect constraintRectBeforeExtended = {0};
    
    text = text.mutableCopy;
    container = container.copy;
    if (!text || !container)  {
        return nil;
    }
    if (range.location + range.length > text.length)
        return nil;
    container->_readonly = YES;
    maximumNumberOfRows = container.maximumNumberOfRows;
    ///system bug
    static BOOL needFixJoinedEmojiBug = NO;
    static BOOL needFixLayoutSizeBug = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        double systemVersionDouble = [UIDevice currentDevice].systemVersion.doubleValue;
        if (8.3 <= systemVersionDouble && systemVersionDouble < 9) {
            needFixJoinedEmojiBug = YES;
        }
        if (systemVersionDouble >= 10) {
            needFixLayoutSizeBug = YES;
        }
    });
    if (needFixJoinedEmojiBug) {
        [(NSMutableAttributedString *)text h_setClearColorToJoinedEmoji];
    }
    layout = [[TextLayout alloc] _init];
    layout.container = container;
    layout.text = text;
    layout.range = range;
    isVerticalForm = container.isVerticalForm;
    
    ///cgpath && cgpathbox 路径
    if (container.path == nil && container.exclusionPaths.count == 0) {
        if(container.size.width <= 0 || container.size.height <= 0) goto faild;
        CGRect rect = {CGPointZero ,container.size};
        if (needFixLayoutSizeBug) {
            constraintSizeIsExtended = YES;
            constraintRectBeforeExtended = UIEdgeInsetsInsetRect(rect, container.insets);
            ///规范rect
            constraintRectBeforeExtended = CGRectStandardize(constraintRectBeforeExtended);
            if (container.isVerticalForm) {
                rect.size.width = textContainerMaxSize.width;
            }else{
                rect.size.height = textContainerMaxSize.height;
            }
        }
        rect = UIEdgeInsetsInsetRect(rect, container.insets);
        rect = CGRectStandardize(rect);
        cgPathBox = rect;
        ///rect 根据矩阵变换
        rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1, -1));
        cgpath = CGPathCreateWithRect(rect, NULL);
    }else if (container.path && CGPathIsRect(container.path.CGPath, &cgPathBox) && container.exclusionPaths.count == 0){
        CGRect rect = CGRectApplyAffineTransform(cgPathBox, CGAffineTransformMakeScale(1, -1));
        cgpath = CGPathCreateWithRect(rect, NULL);
    }else{
        rowMaySepreated = YES;
        CGMutablePathRef path = NULL;
        if (container.path) {
            path = CGPathCreateMutableCopy(container.path.CGPath);
        }else{
            CGRect rect = {CGPointZero,container.size};
            rect = UIEdgeInsetsInsetRect(rect, container.insets);
            CGPathRef rectPath = CGPathCreateWithRect(rect, NULL);
            if (rectPath) {
                path = CGPathCreateMutableCopy(rectPath);
                CGPathRelease(rectPath);
            }
        }
        if (path) {
            [container.exclusionPaths enumerateObjectsUsingBlock:^(UIBezierPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGPathAddPath(path, NULL, obj.CGPath);
            }];
            cgPathBox = CGPathGetBoundingBox(path);
            CGAffineTransform trans = CGAffineTransformMakeScale(1, -1);
            CGMutablePathRef transPath = CGPathCreateMutableCopyByTransformingPath(path, &trans);
            CGPathRelease(path);
            path = transPath;
        }
        cgpath = path;
    }
    if (!cgpath) goto faild;
    ////frame
    frameAttrs = [NSMutableDictionary new];
    if (container.isPathFillEvenOdd) {
        frameAttrs[(id) kCTFramePathFillRuleAttributeName] = @(kCTFramePathFillWindingNumber);
    }
    if (container.pathLineWidth > 0) {
        frameAttrs[(id) kCTFramePathWidthAttributeName] = @(container.pathLineWidth);
    }
    if (container.isVerticalForm) {
        frameAttrs[(id) kCTFrameProgressionAttributeName] = @(kCTFrameProgressionRightToLeft);
    }
    
    ////coreText objects
    ctFrameSetter = CTFramesetterCreateWithAttributedString((CFTypeRef) text);
    if(!ctFrameSetter) goto faild;
    ctFrame = CTFramesetterCreateFrame(ctFrameSetter, TextCFRangeFromNSRange(range), cgpath, (CFDictionaryRef)frameAttrs);
    if (!ctFrame) goto faild;
    lines = [NSMutableArray new];
    ctLines = CTFrameGetLines(ctFrame);
    lineCount = CFArrayGetCount(ctLines);
    if (lineCount > 0) {
        lineOrigins = malloc(lineCount * sizeof(CGPoint));
        ///每一行的位置
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, lineCount), lineOrigins);
    }
    CGRect textBoundingRect = CGRectZero;
    CGSize textBoundingSize = CGSizeZero;
    NSInteger rowIdx = -1;
    NSUInteger rowCount = 0;
    CGRect lastRect = CGRectMake(0, -FLT_MAX, 0, 0);
    CGPoint lastPosition = CGPointMake(0, -FLT_MAX);
    if (isVerticalForm) {
        lastRect = CGRectMake(FLT_MAX, 0, 0, 0);
        lastPosition = CGPointMake(FLT_MAX, 0);
    }
    ///calculate line frame
    NSUInteger lineCurrentIdx = 0;
    for (int i = 0; i < lineCount; i++) {
        CTLineRef ctline = CFArrayGetValueAtIndex(ctLines, i);
        CFArrayRef runs = CTLineGetGlyphRuns(ctline);
        if (!runs || CFArrayGetCount(runs) == 0) continue;
        /// coreText 坐标系 ---> uikit
        CGPoint ctLineOrigin = lineOrigins[i];
        CGPoint position;
        position.x = cgPathBox.origin.x + ctLineOrigin.x;
        position.y = cgPathBox.size.height + cgPathBox.origin.y - ctLineOrigin.y;
        TextLine *textLine = [TextLine lineWithCTLine:ctline position:position vertical:isVerticalForm];
        CGRect rect = textLine.bounds;
        if (constraintSizeIsExtended) {
            if (isVerticalForm) {
                if (rect.origin.x + rect.size.width >
                    constraintRectBeforeExtended.origin.x +
                    constraintRectBeforeExtended.size.width) break;
            } else {
                if (rect.origin.y + rect.size.height >
                    constraintRectBeforeExtended.origin.y +
                    constraintRectBeforeExtended.size.height) break;
            }
        }
        BOOL newRow = YES;
        if (rowMaySepreated && position.x != lastPosition.x) {
            if (isVerticalForm) {
                if (rect.size.width > lastRect.size.width) {
                    if (rect.origin.x > lastPosition.x && lastPosition.x > rect.origin.x - rect.size.width) newRow = NO;
                } else {
                    if (lastRect.origin.x > position.x && position.x > lastRect.origin.x - lastRect.size.width) newRow = NO;
                }
            } else {
                if (rect.size.height > lastRect.size.height) {
                    if (rect.origin.y < lastPosition.y && lastPosition.y < rect.origin.y + rect.size.height) newRow = NO;
                } else {
                    if (lastRect.origin.y < position.y && position.y < lastRect.origin.y + lastRect.size.height) newRow = NO;
                }
            }
        }
        
        if (newRow) rowIdx++;
        lastRect = rect;
        lastPosition = position;
        
        textLine.index = lineCurrentIdx;
        textLine.row = rowIdx;
        [lines addObject:textLine];
        rowCount = rowIdx + 1;
        lineCurrentIdx ++;
        if (i == 0) textBoundingRect = rect;
        else {
            if (maximumNumberOfRows == 0 || rowIdx < maximumNumberOfRows) {
                textBoundingRect = CGRectUnion(textBoundingRect, rect);
            }
        }
    }
    if (rowCount > 0) {
        if (maximumNumberOfRows > 0) {
            if (rowCount > maximumNumberOfRows) {
                needTruncation = YES;
                rowCount = maximumNumberOfRows;
                do {
                    TextLine *line = lines.lastObject;
                    if (!line) break;
                    if (line.row < rowCount) break;
                    [lines removeLastObject];
                } while (1);
            }
        }
        TextLine *lastLine = lines.lastObject;
        if (!needTruncation && lastLine.range.location + lastLine.range.length < text.length) {
            needTruncation = YES;
        }
        ///可自定义行的 bound
        if (container.linePositionModifier) {
            [container.linePositionModifier modifyLines:lines fromText:text inContainer:container];
            for (NSUInteger i = 0, max = lines.count; i < max; i++) {
                TextLine *line = lines[i];
                if (i == 0) textBoundingRect = line.bounds;
                else textBoundingRect = CGRectUnion(textBoundingRect, line.bounds);
            }
        }
        lineRowsEdge = malloc(rowCount* sizeof(TextRowEdge));
        if (!lineRowsEdge) goto faild;
        lineRowsIndex = malloc(rowCount *sizeof(NSUInteger));
        if (!lineRowsIndex) goto faild;
        NSInteger lastRowIdx = -1;
        CGFloat lastHead = 0;
        CGFloat lastFoot = 0;
        for (NSUInteger i = 0, max = lines.count; i < max; i++) {
            TextLine *line = lines[i];
            CGRect rect = line.bounds;
            if ((NSInteger)line.row != lastRowIdx) {
                if (lastRowIdx >= 0) {
                    lineRowsEdge[lastRowIdx] = (TextRowEdge) {.head = lastHead, .foot = lastFoot };
                }
                lastRowIdx = line.row;
                lineRowsIndex[lastRowIdx] = i;
                if (isVerticalForm) {
                    lastHead = rect.origin.x + rect.size.width;
                    lastFoot = lastHead - rect.size.width;
                } else {
                    lastHead = rect.origin.y;
                    lastFoot = lastHead + rect.size.height;
                }
            } else {
                if (isVerticalForm) {
                    lastHead = MAX(lastHead, rect.origin.x + rect.size.width);
                    lastFoot = MIN(lastFoot, rect.origin.x);
                } else {
                    lastHead = MIN(lastHead, rect.origin.y);
                    lastFoot = MAX(lastFoot, rect.origin.y + rect.size.height);
                }
            }
        }
        lineRowsEdge[lastRowIdx] = (TextRowEdge) {.head = lastHead, .foot = lastFoot };
        for (NSUInteger i = 1; i < rowCount; i++) {
            TextRowEdge v0 = lineRowsEdge[i - 1];
            TextRowEdge v1 = lineRowsEdge[i];
            lineRowsEdge[i - 1].foot = lineRowsEdge[i].head = (v0.foot + v1.head) * 0.5;
        }
    }
    
    ///计算 bounding rect
    {
        CGRect rect = textBoundingRect;
        if (container.path) {
            if (container.pathLineWidth) {
                CGFloat inset = container.pathLineWidth/2.0;
                rect = CGRectInset(rect, -inset, -inset);
            }
        }else{
            rect = UIEdgeInsetsInsetRect(rect, TextUIEdgeInsetsInvert(container.insets));
        }
        rect = CGRectStandardize(rect);
        CGSize size = rect.size;
        if (container.verticalForm) {
            size.width += container.size.width - (rect.origin.x + rect.size.width);
        } else {
            size.width += rect.origin.x;
        }
        size.height += rect.origin.y;
        if (size.width < 0) size.width = 0;
        if (size.height < 0) size.height = 0;
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        textBoundingSize = size;
    }
    
    visibleRange = TextNSRangeFromCFRange(CTFrameGetVisibleStringRange(ctFrame));
    ///打断行
    if (needTruncation) {
        TextLine *lastLine = lines.lastObject;
        NSRange lastRange = lastLine.range;
        visibleRange.length = lastRange.location + lastRange.length - visibleRange.location;
        if (container.truncationType != TextTruncationTypeNone) {
            CTLineRef truncationTokenLine = NULL;
            if (container.truncationToken) {
                truncationToken = container.truncationToken;
                truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef )truncationToken);
            }else{
                CFArrayRef runs = CTLineGetGlyphRuns(lastLine.CTLine);
                NSUInteger runCount = CFArrayGetCount(runs);
                NSMutableDictionary *attrs = nil;
                if (runCount > 0) {
                    CTRunRef run = CFArrayGetValueAtIndex(runs, runCount - 1);
                    attrs =(id) CTRunGetAttributes(run);
                    attrs = attrs ? attrs.mutableCopy : [NSMutableDictionary new];
                    [attrs removeObjectsForKeys:[NSMutableAttributedString h_allDiscontinuousAttributeKeys]];
                    CTFontRef font = (__bridge CTFontRef) attrs[(id) kCTFontAttributeName];
                    CGFloat fontSize = font ? CTFontGetSize(font) : 12.0;
                    UIFont *uifont = [UIFont systemFontOfSize:fontSize*0.9];
                    font = [uifont CTFontRef];
                    if (uifont) {
                        font = CTFontCreateWithName((__bridge CFStringRef)uifont.fontName,uifont.pointSize, NULL);
                    }else{
                        font = NULL;
                    }
                    if (font) {
                        attrs[(id)kCTFontAttributeName] = (__bridge id)font;
                        uifont = nil;
                        CFRelease(font);
                    }
                    CGColorRef color = (__bridge CGColorRef)(attrs[(id)kCTForegroundColorAttributeName]);
                    if (color && CFGetTypeID(color) == CGColorGetTypeID() && CGColorGetAlpha(color) == 0) {
                        // ignore clear color
                        [attrs removeObjectForKey:(id)kCTForegroundColorAttributeName];
                    }
                    if (!attrs) attrs = [NSMutableDictionary new];
                }
                truncationToken = [[NSAttributedString alloc] initWithString:TextTruncationToken attributes:attrs];
                truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationToken);
            }
            if (truncationToken) {
                CTLineTruncationType type = kCTLineTruncationEnd;
                if (container.truncationType == TextTruncationTypeStart) {
                    type = kCTLineTruncationStart;
                } else if (container.truncationType == TextTruncationTypeMiddle) {
                    type = kCTLineTruncationMiddle;
                }
                NSMutableAttributedString *lastLineText = [text attributedSubstringFromRange:lastLine.range].mutableCopy;
                [lastLineText appendAttributedString:truncationToken];
                CTLineRef ctLastLineExtend = CTLineCreateWithAttributedString((CFAttributedStringRef)lastLineText);
                if (ctLastLineExtend) {
                    CGFloat truncatedWidth = lastLine.width;
                    CGRect cgPathRect = CGRectZero;
                    if (CGPathIsRect(cgpath, &cgPathRect)) {
                        if (isVerticalForm) {
                            truncatedWidth = cgPathRect.size.height;
                        } else {
                            truncatedWidth = cgPathRect.size.width;
                        }
                    }
                    CTLineRef ctTruncatedLine = CTLineCreateTruncatedLine(ctLastLineExtend, truncatedWidth, type, truncationTokenLine);
                    CFRelease(ctLastLineExtend);
                    if (ctTruncatedLine) {
                        truncatedLine = [TextLine lineWithCTLine:ctTruncatedLine position:lastLine.position vertical:isVerticalForm];
                        truncatedLine.index = lastLine.index;
                        truncatedLine.row = lastLine.row;
                        CFRelease(ctTruncatedLine);
                    }
                }
                CFRelease(truncationTokenLine);
            }
        }
    }
    if (isVerticalForm) {
        NSCharacterSet *rotateCharset = TextVerticalFormRotateCharacterSet();
        NSCharacterSet *rotateMoveCharset = TextVerticalFormRotateAndMoveCharacterSet();
        void (^lineBlock)(TextLine *) = ^(TextLine *line){
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            if (!runs) return;
            NSUInteger runCount = CFArrayGetCount(runs);
            if (runCount == 0) return;
            NSMutableArray *lineRunRanges = [NSMutableArray new];
            line.verticalRotateRange = lineRunRanges;
            for (NSUInteger r = 0; r < runCount; r++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
                NSMutableArray *runRanges = [NSMutableArray new];
                [lineRunRanges addObject:runRanges];
                NSUInteger glyphCount = CTRunGetGlyphCount(run);
                if (glyphCount == 0) continue;
                
                CFIndex runStrIdx[glyphCount + 1];
                CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
                CFRange runStrRange = CTRunGetStringRange(run);
                runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
                CFDictionaryRef runAttrs = CTRunGetAttributes(run);
                CTFontRef font = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
                BOOL isColorGlyph = TextCTFontContainsColorBitmapGlyphs(font);
                
                NSUInteger prevIdx = 0;
                TextRunGlyphDrawMode prevMode = TextRunGlyphDrawModeHorizontal;
                NSString *layoutStr = layout.text.string;
                for (NSUInteger g = 0; g < glyphCount; g++) {
                    BOOL glyphRotate = 0, glyphRotateMove = NO;
                    CFIndex runStrLen = runStrIdx[g + 1] - runStrIdx[g];
                    if (isColorGlyph) {
                        glyphRotate = YES;
                    } else if (runStrLen == 1) {
                        unichar c = [layoutStr characterAtIndex:runStrIdx[g]];
                        glyphRotate = [rotateCharset characterIsMember:c];
                        if (glyphRotate) glyphRotateMove = [rotateMoveCharset characterIsMember:c];
                    } else if (runStrLen > 1){
                        NSString *glyphStr = [layoutStr substringWithRange:NSMakeRange(runStrIdx[g], runStrLen)];
                        BOOL glyphRotate = [glyphStr rangeOfCharacterFromSet:rotateCharset].location != NSNotFound;
                        if (glyphRotate) glyphRotateMove = [glyphStr rangeOfCharacterFromSet:rotateMoveCharset].location != NSNotFound;
                    }
                    
                    TextRunGlyphDrawMode mode = glyphRotateMove ? TextRunGlyphDrawModeVerticalRotateMove : (glyphRotate ? TextRunGlyphDrawModeVerticalRotate : TextRunGlyphDrawModeHorizontal);
                    if (g == 0) {
                        prevMode = mode;
                    } else if (mode != prevMode) {
                        TextRunGlyphRange *aRange = [TextRunGlyphRange rangeWithRange:NSMakeRange(prevIdx, g - prevIdx) drawMode:prevMode];
                        [runRanges addObject:aRange];
                        prevIdx = g;
                        prevMode = mode;
                    }
                }
                if (prevIdx < glyphCount) {
                    TextRunGlyphRange *aRange = [TextRunGlyphRange rangeWithRange:NSMakeRange(prevIdx, glyphCount - prevIdx) drawMode:prevMode];
                    [runRanges addObject:aRange];
                }
                
            }
        };
        for (TextLine *line in lines) {
            lineBlock(line);
        }
        if (truncatedLine) lineBlock(truncatedLine);
    }
    if (visibleRange.length > 0) {
        layout.needDrawText = YES;
        
        void (^block)(NSDictionary *attrs, NSRange range, BOOL *stop) = ^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            if (attrs[TextHighlightAttributeName]) layout.containsHighlight = YES;
            if (attrs[TextBlockBorderAttributeName]) layout.needDrawBlockBorder = YES;
            if (attrs[TextBackgroundBorderAttributeName]) layout.needDrawBackgroundBorder = YES;
            if (attrs[TextShadowAttributeName] || attrs[NSShadowAttributeName]) layout.needDrawShadow = YES;
            if (attrs[TextUnderlineAttributeName]) layout.needDrawUnderline = YES;
            if (attrs[TextAttachmentAttributeName]) layout.needDrawAttachment = YES;
            if (attrs[TextInnerShadowAttributeName]) layout.needDrawInnerShadow = YES;
            if (attrs[TextStrikethroughAttributeName]) layout.needDrawStrikethrough = YES;
            if (attrs[TextBorderAttributeName]) layout.needDrawBorder = YES;
        };
        
        [layout.text enumerateAttributesInRange:visibleRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:block];
        if (truncatedLine) {
            [truncationToken enumerateAttributesInRange:NSMakeRange(0, truncationToken.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:block];
        }
    }
    
    attachments = [NSMutableArray new];
    attachmentRanges = [NSMutableArray new];
    attachmentRects = [NSMutableArray new];
    attachmentContentSet = [NSMutableSet new];
    for (NSUInteger i = 0, max = lines.count; i < max; i++) {
        TextLine *line = lines[i];
        if (truncatedLine && line.index == truncatedLine.index) line = truncatedLine;
        if (line.attachments.count > 0) {
            [attachments addObjectsFromArray:line.attachments];
            [attachmentRanges addObjectsFromArray:line.attachmentRanges];
            [attachmentRects addObjectsFromArray:line.attachmentRects];
            for (TextAttachment *attachment in line.attachments) {
                if (attachment.content) {
                    [attachmentContentSet addObject:attachment.content];
                }
            }
        }
    }
    if (attachments.count == 0) {
        attachments = attachmentRanges = attachmentRects = nil;
    }
    layout.frameSetter = ctFrameSetter;
    layout.frame = ctFrame;
    layout.lines = lines;
    layout.truncatedLine = truncatedLine;
    layout.attachments = attachments;
    layout.attachmentRangs = attachmentRanges;
    layout.attachmentRects = attachmentRects;
    layout.attachmentContentsSet = attachmentContentSet;
    layout.rowCount = rowCount;
    layout.visibleRange = visibleRange;
    layout.textBoundingRect = textBoundingRect;
    layout.textBoundingSize = textBoundingSize;
    layout.lineRowEdge = lineRowsEdge;
    layout.lineRowsIndex = lineRowsIndex;
    CFRelease(cgpath);
    CFRelease(ctFrameSetter);
    CFRelease(ctFrame);
    if (lineOrigins) free(lineOrigins);
    return layout;
faild:
    if (cgpath) CFRelease(cgpath);
    if (ctFrameSetter) CFRelease(ctFrameSetter);
    if (ctFrame) CFRelease(ctFrame);
    if (lineOrigins) free(lineOrigins);
    if (lineRowsEdge) free(lineRowsEdge);
    if (lineRowsIndex) free(lineRowsIndex);
    return nil;
}

+ (NSArray<TextContainer *> *)layoutWithContainers:(NSArray<TextContainer *> *)containers text:(NSAttributedString *)text {
    return [self layoutWithContainers:containers text:text range:NSMakeRange(0, text.length)];
}

+ (NSArray<TextContainer *> *)layoutWithContainers:(NSArray<TextContainer *> *)containers text:(NSAttributedString *)text range:(NSRange)range {
    if (!containers || !text) return nil;
    if (range.location + range.length > text.length) return nil;
    NSMutableArray *layouts = [NSMutableArray array];
    for (NSUInteger i = 0, max = containers.count; i < max; i++) {
        TextContainer *container = containers[i];
        TextLayout *layout = [self layoutWithContainer:container text:text range:range];
        if (!layout) return nil;
        NSInteger length = (NSInteger)range.length - (NSInteger)layout.visibleRange.length;
        if (length <= 0) {
            range.length = 0;
            range.location = text.length;
        } else {
            range.length = length;
            range.location += layout.visibleRange.length;
        }
        [layouts addObject:layout];
    }
    return layouts;
}

- (void)setFrameSetter:(CTFramesetterRef)frameSetter {
    if (_frameSetter != frameSetter) {
        if (frameSetter) CFRetain(frameSetter);
        if (_frameSetter) CFRelease(_frameSetter);
        _frameSetter = frameSetter;
    }
}

- (void)setFrame:(CTFrameRef)frame {
    if (_frame != frame) {
        if (frame) CFRetain(frame);
        if (_frame) CFRelease(_frame);
        _frame = frame;
    }
}

- (void)dealloc {
    if (_frameSetter) CFRelease(_frameSetter);
    if (_frame) CFRelease(_frame);
    if (_lineRowsIndex) free(_lineRowsIndex);
    if (_lineRowEdge) free(_lineRowEdge);
}

#pragma mark --- coding  -----

- (void)encodeWithCoder:(NSCoder *)aCoder{
    NSData *textData = [TextArchive archivedDataWithRootObject:_text];
    [aCoder encodeObject:textData forKey:@"text"];
    [aCoder encodeObject:_container forKey:@"container"];
    [aCoder encodeObject:[NSValue valueWithRange:_range] forKey:@"range"];
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    NSData *data = [aDecoder decodeObjectForKey:@"text"];
    _text = [TextUnarchiver unarchiveObjectWithData:data];
    _container = [aDecoder decodeObjectForKey:@"container"];
    NSValue *value = [aDecoder decodeObjectForKey:@"range"];
    _range = value.rangeValue;
    self = [self.class layoutWithContainer:_container text:_text range:_range];
    return self;
}
- (instancetype)copyWithZone:(NSZone *)zone{
    return self;
}

#pragma mark ----- query ----
///edge 对应的row
- (NSUInteger)_rowIndexForEdge:(CGFloat)edge{
    if (_rowCount == 0) return  NSNotFound;
    BOOL isVertical = _container.isVerticalForm;
    NSUInteger lo = 0, hi = _rowCount - 1, mid = 0;
    NSUInteger rowIdx = NSNotFound;
    while (lo <= hi) {
        mid = (lo + hi) / 2;
        TextRowEdge oneEdge = _lineRowEdge[mid];
        if (isVertical ?
            (oneEdge.foot <= edge && edge <= oneEdge.head) :
            (oneEdge.head <= edge && edge <= oneEdge.foot)) {
            rowIdx = mid;
            break;
        }
        if ((isVertical ? (edge > oneEdge.head) : (edge < oneEdge.head))) {
            if (mid == 0) break;
            hi = mid - 1;
        } else {
            lo = mid + 1;
        }
    }
    return rowIdx;
}
////edge 对应最近的的一个row
- (NSUInteger)_closestRowIndexForEdge:(CGFloat)edge {
    if (_rowCount == 0) return NSNotFound;
    NSUInteger rowIdx = [self _rowIndexForEdge:edge];
    if (rowIdx == NSNotFound) {
        if (_container.verticalForm) {
            if (edge > _lineRowEdge[0].head) {
                rowIdx = 0;
            } else if (edge < _lineRowEdge[_rowCount - 1].foot) {
                rowIdx = _rowCount - 1;
            }
        } else {
            if (edge < _lineRowEdge[0].head) {
                rowIdx = 0;
            } else if (edge > _lineRowEdge[_rowCount - 1].foot) {
                rowIdx = _rowCount - 1;
            }
        }
    }
    return rowIdx;
}
- (CTRunRef)_runForLine:(TextLine *)line position:(TextPosition *)position {
    if (!line || !position) return NULL;
    CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
    for (NSUInteger i = 0, max = CFArrayGetCount(runs); i < max; i++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, i);
        CFRange range = CTRunGetStringRange(run);
        if (position.affinity == TextAffinityBackward) {
            if (range.location < position.offset && position.offset <= range.location + range.length) {
                return run;
            }
        } else {
            if (range.location <= position.offset && position.offset < range.location + range.length) {
                return run;
            }
        }
    }
    return NULL;
}
///位置是否在合成的序列里面
- (BOOL)_insideComposedCharacterSequences:(TextLine *)line position:(NSUInteger)position block:(void (^)(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next))block {
    NSRange range = line.range;
    if (range.length == 0) return NO;
    __block BOOL inside = NO;
    __block NSUInteger _prev, _next;
    [_text.string enumerateSubstringsInRange:range options:NSStringEnumerationByComposedCharacterSequences usingBlock: ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        NSUInteger prev = substringRange.location;
        NSUInteger next = substringRange.location + substringRange.length;
        if (prev == position || next == position) {
            *stop = YES;
        }
        if (prev < position && position < next) {
            inside = YES;
            _prev = prev;
            _next = next;
            *stop = YES;
        }
    }];
    if (inside && block) {
        CGFloat left = [self offsetForTextPosition:_prev lineIndex:line.index];
        CGFloat right = [self offsetForTextPosition:_next lineIndex:line.index];
        block(left, right, _prev, _next);
    }
    return inside;
}
///位置是否在表情里面
- (BOOL)_insideEmoji:(TextLine *)line position:(NSUInteger)position block:(void (^)(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next))block {
    if (!line) return NO;
    CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
    for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        NSUInteger glyphCount = CTRunGetGlyphCount(run);
        if (glyphCount == 0) continue;
        CFRange range = CTRunGetStringRange(run);
        if (range.length <= 1) continue;
        if (position <= range.location || position >= range.location + range.length) continue;
        CFDictionaryRef attrs = CTRunGetAttributes(run);
        CTFontRef font = CFDictionaryGetValue(attrs, kCTFontAttributeName);
        if (!TextCTFontContainsColorBitmapGlyphs(font)) continue;
        
        // Here's Emoji runs (larger than 1 unichar), and position is inside the range.
        CFIndex indices[glyphCount];
        CTRunGetStringIndices(run, CFRangeMake(0, glyphCount), indices);
        for (NSUInteger g = 0; g < glyphCount; g++) {
            CFIndex prev = indices[g];
            CFIndex next = g + 1 < glyphCount ? indices[g + 1] : range.location + range.length;
            if (position == prev) break; // Emoji edge
            if (prev < position && position < next) { // inside an emoji (such as National Flag Emoji)
                CGPoint pos = CGPointZero;
                CGSize adv = CGSizeZero;
                CTRunGetPositions(run, CFRangeMake(g, 1), &pos);
                CTRunGetAdvances(run, CFRangeMake(g, 1), &adv);
                if (block) {
                    block(line.position.x + pos.x,
                          line.position.x + pos.x + adv.width,
                          prev, next);
                }
                return YES;
            }
        }
    }
    return NO;
}
////书写方向是否是从左到右
- (BOOL)_isRightToLeftInLine:(TextLine *)line atPoint:(CGPoint)point {
    if (!line) return NO;
    // get write direction
    BOOL RTL = NO;
    CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
    for (NSUInteger r = 0, max = CFArrayGetCount(runs); r < max; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        CGPoint glyphPosition;
        CTRunGetPositions(run, CFRangeMake(0, 1), &glyphPosition);
        if (_container.verticalForm) {
            CGFloat runX = glyphPosition.x;
            runX += line.position.y;
            CGFloat runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), NULL, NULL, NULL);
            if (runX <= point.y && point.y <= runX + runWidth) {
                if (CTRunGetStatus(run) & kCTRunStatusRightToLeft) RTL = YES;
                break;
            }
        } else {
            CGFloat runX = glyphPosition.x;
            runX += line.position.x;
            CGFloat runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), NULL, NULL, NULL);
            if (runX <= point.x && point.x <= runX + runWidth) {
                if (CTRunGetStatus(run) & kCTRunStatusRightToLeft) RTL = YES;
                break;
            }
        }
    }
    return RTL;
}
///校正range的edge
- (TextRange *)_correctedRangeWithEdge:(TextRange *)range {
    NSRange visibleRange = self.visibleRange;
    TextPosition *start = range.start;
    TextPosition *end = range.end;
    
    if (start.offset == visibleRange.location && start.affinity == TextAffinityBackward) {
        start = [TextPosition positionWith:start.offset affinity:TextAffinityForward];
    }
    
    if (end.offset == visibleRange.location + visibleRange.length && start.affinity == TextAffinityForward) {
        end = [TextPosition positionWith:end.offset affinity:TextAffinityBackward];
    }
    
    if (start != range.start || end != range.end) {
        range = [TextRange rangeWithStart:start end:end];
    }
    return range;
}
/// 在row里对应的line的index
- (NSUInteger)lineIndexForRow:(NSUInteger)row {
    if (row >= _rowCount) return NSNotFound;
    return _lineRowsIndex[row];
}
///每一个row 里面的对应的line的数量
- (NSUInteger)lineCountForRow:(NSUInteger)row {
    if (row >= _rowCount) return NSNotFound;
    if (row == _rowCount - 1) {
        return _lines.count - _lineRowsIndex[row];
    } else {
        return _lineRowsIndex[row + 1] - _lineRowsIndex[row];
    }
}
////line 对应的row
- (NSUInteger)rowIndexForLine:(NSUInteger)line {
    if (line >= _lines.count) return NSNotFound;
    return ((TextLine *)_lines[line]).row;
}
///point 对应的line
- (NSUInteger)lineIndexForPoint:(CGPoint)point {
    if (_lines.count == 0 || _rowCount == 0) return NSNotFound;
    NSUInteger rowIdx = [self _rowIndexForEdge:_container.verticalForm ? point.x : point.y];
    if (rowIdx == NSNotFound) return NSNotFound;
    
    NSUInteger lineIdx0 = _lineRowsIndex[rowIdx];
    NSUInteger lineIdx1 = rowIdx == _rowCount - 1 ? _lines.count - 1 : _lineRowsIndex[rowIdx + 1] - 1;
    for (NSUInteger i = lineIdx0; i <= lineIdx1; i++) {
        CGRect bounds = ((TextLine *)_lines[i]).bounds;
        if (CGRectContainsPoint(bounds, point)) return i;
    }
    
    return NSNotFound;
}
///离point 最近的line的索引
- (NSUInteger)closestLineIndexForPoint:(CGPoint)point {
    BOOL isVertical = _container.verticalForm;
    if (_lines.count == 0 || _rowCount == 0) return NSNotFound;
    NSUInteger rowIdx = [self _closestRowIndexForEdge:isVertical ? point.x : point.y];
    if (rowIdx == NSNotFound) return NSNotFound;
    
    NSUInteger lineIdx0 = _lineRowsIndex[rowIdx];
    NSUInteger lineIdx1 = rowIdx == _rowCount - 1 ? _lines.count - 1 : _lineRowsIndex[rowIdx + 1] - 1;
    if (lineIdx0 == lineIdx1) return lineIdx0;
    
    CGFloat minDistance = CGFLOAT_MAX;
    NSUInteger minIndex = lineIdx0;
    for (NSUInteger i = lineIdx0; i <= lineIdx1; i++) {
        CGRect bounds = ((TextLine *)_lines[i]).bounds;
        if (isVertical) {
            if (bounds.origin.y <= point.y && point.y <= bounds.origin.y + bounds.size.height) return i;
            CGFloat distance;
            if (point.y < bounds.origin.y) {
                distance = bounds.origin.y - point.y;
            } else {
                distance = point.y - (bounds.origin.y + bounds.size.height);
            }
            if (distance < minDistance) {
                minDistance = distance;
                minIndex = i;
            }
        } else {
            if (bounds.origin.x <= point.x && point.x <= bounds.origin.x + bounds.size.width) return i;
            CGFloat distance;
            if (point.x < bounds.origin.x) {
                distance = bounds.origin.x - point.x;
            } else {
                distance = point.x - (bounds.origin.x + bounds.size.width);
            }
            if (distance < minDistance) {
                minDistance = distance;
                minIndex = i;
            }
        }
    }
    return minIndex;
}
///位置的偏移量
- (CGFloat)offsetForTextPosition:(NSUInteger)position lineIndex:(NSUInteger)lineIndex {
    if (lineIndex >= _lines.count) return CGFLOAT_MAX;
    TextLine *line = _lines[lineIndex];
    CFRange range = CTLineGetStringRange(line.CTLine);
    if (position < range.location || position > range.location + range.length) return CGFLOAT_MAX;
    
    CGFloat offset = CTLineGetOffsetForStringIndex(line.CTLine, position, NULL);
    return _container.verticalForm ? (offset + line.position.y) : (offset + line.position.x);
}
////point 对应的 text的位置
- (NSUInteger)textPositionForPoint:(CGPoint)point lineIndex:(NSUInteger)lineIndex {
    if (lineIndex >= _lines.count) return NSNotFound;
    TextLine *line = _lines[lineIndex];
    if (_container.verticalForm) {
        point.x = point.y - line.position.y;
        point.y = 0;
    } else {
        point.x -= line.position.x;
        point.y = 0;
    }
    CFIndex idx = CTLineGetStringIndexForPosition(line.CTLine, point);
    if (idx == kCFNotFound) return NSNotFound;
    
    /*
     If the emoji contains one or more variant form (such as ☔️ "\u2614\uFE0F")
     and the font size is smaller than 379/15, then each variant form ("\uFE0F")
     will rendered as a single blank glyph behind the emoji glyph. Maybe it's a
     bug in CoreText? Seems iOS8.3 fixes this problem.
     
     If the point hit the blank glyph, the CTLineGetStringIndexForPosition()
     returns the position before the emoji glyph, but it should returns the
     position after the emoji and variant form.
     
     Here's a workaround.
     */
    CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
    for (NSUInteger r = 0, max = CFArrayGetCount(runs); r < max; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        CFRange range = CTRunGetStringRange(run);
        if (range.location <= idx && idx < range.location + range.length) {
            NSUInteger glyphCount = CTRunGetGlyphCount(run);
            if (glyphCount == 0) break;
            CFDictionaryRef attrs = CTRunGetAttributes(run);
            CTFontRef font = CFDictionaryGetValue(attrs, kCTFontAttributeName);
            if (!TextCTFontContainsColorBitmapGlyphs(font)) break;
            
            CFIndex indices[glyphCount];
            CGPoint positions[glyphCount];
            CTRunGetStringIndices(run, CFRangeMake(0, glyphCount), indices);
            CTRunGetPositions(run, CFRangeMake(0, glyphCount), positions);
            for (NSUInteger g = 0; g < glyphCount; g++) {
                NSUInteger gIdx = indices[g];
                if (gIdx == idx && g + 1 < glyphCount) {
                    CGFloat right = positions[g + 1].x;
                    if (point.x < right) break;
                    NSUInteger next = indices[g + 1];
                    do {
                        if (next == range.location + range.length) break;
                        unichar c = [_text.string characterAtIndex:next];
                        if ((c == 0xFE0E || c == 0xFE0F)) { // unicode variant form for emoji style
                            next++;
                        } else break;
                    }
                    while (1);
                    if (next != indices[g + 1]) idx = next;
                    break;
                }
            }
            break;
        }
    }
    return idx;
}

////point 对应的最近的position
- (TextPosition *)closestPositionToPoint:(CGPoint)point {
    BOOL isVertical = _container.verticalForm;
    // When call CTLineGetStringIndexForPosition() on ligature such as 'fi',
    // and the point `hit` the glyph's left edge, it may get the ligature inside offset.
    // I don't know why, maybe it's a bug of CoreText. Try to avoid it.
    if (isVertical) point.y += 0.00001234;
    else point.x += 0.00001234;
    
    NSUInteger lineIndex = [self closestLineIndexForPoint:point];
    if (lineIndex == NSNotFound) return nil;
    TextLine *line = _lines[lineIndex];
    __block NSUInteger position = [self textPositionForPoint:point lineIndex:lineIndex];
    if (position == NSNotFound) position = line.range.location;
    if (position <= _visibleRange.location) {
        return [TextPosition positionWith:_visibleRange.location affinity:TextAffinityForward];
    } else if (position >= _visibleRange.location + _visibleRange.length) {
        return [TextPosition positionWith:_visibleRange.location + _visibleRange.length affinity:TextAffinityBackward];
    }
    
    TextAffinity finalAffinity = TextAffinityForward;
    BOOL finalAffinityDetected = NO;
    
    // binding range
    NSRange bindingRange;
    TextBingString *binding = [_text attribute:TextBindingAttributeName atIndex:position longestEffectiveRange:&bindingRange inRange:NSMakeRange(0, _text.length)];
    if (binding && bindingRange.length > 0) {
        NSUInteger headLineIdx = [self lineIndexForPosition:[TextPosition positionWith:bindingRange.location]];
        NSUInteger tailLineIdx = [self lineIndexForPosition:[TextPosition positionWith:bindingRange.location + bindingRange.length affinity:TextAffinityBackward]];
        if (headLineIdx == lineIndex && lineIndex == tailLineIdx) { // all in same line
            CGFloat left = [self offsetForTextPosition:bindingRange.location lineIndex:lineIndex];
            CGFloat right = [self offsetForTextPosition:bindingRange.location + bindingRange.length lineIndex:lineIndex];
            if (left != CGFLOAT_MAX && right != CGFLOAT_MAX) {
                if (_container.isVerticalForm) {
                    if (fabs(point.y - left) < fabs(point.y - right)) {
                        position = bindingRange.location;
                        finalAffinity = TextAffinityForward;
                    } else {
                        position = bindingRange.location + bindingRange.length;
                        finalAffinity = TextAffinityBackward;
                    }
                } else {
                    if (fabs(point.x - left) < fabs(point.x - right)) {
                        position = bindingRange.location;
                        finalAffinity = TextAffinityForward;
                    } else {
                        position = bindingRange.location + bindingRange.length;
                        finalAffinity = TextAffinityBackward;
                    }
                }
            } else if (left != CGFLOAT_MAX) {
                position = left;
                finalAffinity = TextAffinityForward;
            } else if (right != CGFLOAT_MAX) {
                position = right;
                finalAffinity = TextAffinityBackward;
            }
            finalAffinityDetected = YES;
        } else if (headLineIdx == lineIndex) {
            CGFloat left = [self offsetForTextPosition:bindingRange.location lineIndex:lineIndex];
            if (left != CGFLOAT_MAX) {
                position = bindingRange.location;
                finalAffinity = TextAffinityForward;
                finalAffinityDetected = YES;
            }
        } else if (tailLineIdx == lineIndex) {
            CGFloat right = [self offsetForTextPosition:bindingRange.location + bindingRange.length lineIndex:lineIndex];
            if (right != CGFLOAT_MAX) {
                position = bindingRange.location + bindingRange.length;
                finalAffinity = TextAffinityBackward;
                finalAffinityDetected = YES;
            }
        } else {
            BOOL onLeft = NO, onRight = NO;
            if (headLineIdx != NSNotFound && tailLineIdx != NSNotFound) {
                if (abs((int)headLineIdx - (int)lineIndex) < abs((int)tailLineIdx - (int)lineIndex)) onLeft = YES;
                else onRight = YES;
            } else if (headLineIdx != NSNotFound) {
                onLeft = YES;
            } else if (tailLineIdx != NSNotFound) {
                onRight = YES;
            }
            
            if (onLeft) {
                CGFloat left = [self offsetForTextPosition:bindingRange.location lineIndex:headLineIdx];
                if (left != CGFLOAT_MAX) {
                    lineIndex = headLineIdx;
                    line = _lines[headLineIdx];
                    position = bindingRange.location;
                    finalAffinity = TextAffinityForward;
                    finalAffinityDetected = YES;
                }
            } else if (onRight) {
                CGFloat right = [self offsetForTextPosition:bindingRange.location + bindingRange.length lineIndex:tailLineIdx];
                if (right != CGFLOAT_MAX) {
                    lineIndex = tailLineIdx;
                    line = _lines[tailLineIdx];
                    position = bindingRange.location + bindingRange.length;
                    finalAffinity = TextAffinityBackward;
                    finalAffinityDetected = YES;
                }
            }
        }
    }
    
    // empty line
    if (line.range.length == 0) {
        BOOL behind = (_lines.count > 1 && lineIndex == _lines.count - 1);  //end line
        return [TextPosition positionWith:line.range.location affinity:behind ? TextAffinityBackward:TextAffinityForward];
    }
    
    // detect weather the line is a linebreak token
    if (line.range.length <= 2) {
        NSString *str = [_text.string substringWithRange:line.range];
        if (TextIsLinebreakString(str)) { // an empty line ("\r", "\n", "\r\n")
            return [TextPosition positionWith:line.range.location];
        }
    }
    
    // above whole text frame
    if (lineIndex == 0 && (isVertical ? (point.x > line.right) : (point.y < line.top))) {
        position = 0;
        finalAffinity = TextAffinityForward;
        finalAffinityDetected = YES;
    }
    // below whole text frame
    if (lineIndex == _lines.count - 1 && (isVertical ? (point.x < line.left) : (point.y > line.bottom))) {
        position = line.range.location + line.range.length;
        finalAffinity = TextAffinityBackward;
        finalAffinityDetected = YES;
    }
    
    // There must be at least one non-linebreak char,
    // ignore the linebreak characters at line end if exists.
    if (position >= line.range.location + line.range.length - 1) {
        if (position > line.range.location) {
            unichar c1 = [_text.string characterAtIndex:position - 1];
            if (TextIsLinebreakChar(c1)) {
                position--;
                if (position > line.range.location) {
                    unichar c0 = [_text.string characterAtIndex:position - 1];
                    if (TextIsLinebreakChar(c0)) {
                        position--;
                    }
                }
            }
        }
    }
    if (position == line.range.location) {
        return [TextPosition positionWith:position];
    }
    if (position == line.range.location + line.range.length) {
        return [TextPosition positionWith:position affinity:TextAffinityBackward];
    }
    
    [self _insideComposedCharacterSequences:line position:position block: ^(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next) {
        if (isVertical) {
            position = fabs(left - point.y) < fabs(right - point.y) < (right ? prev : next);
        } else {
            position = fabs(left - point.x) < fabs(right - point.x) < (right ? prev : next);
        }
    }];
    
    [self _insideEmoji:line position:position block: ^(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next) {
        if (isVertical) {
            position = fabs(left - point.y) < fabs(right - point.y) < (right ? prev : next);
        } else {
            position = fabs(left - point.x) < fabs(right - point.x) < (right ? prev : next);
        }
    }];
    
    if (position < _visibleRange.location) position = _visibleRange.location;
    else if (position > _visibleRange.location + _visibleRange.length) position = _visibleRange.location + _visibleRange.length;
    
    if (!finalAffinityDetected) {
        CGFloat ofs = [self offsetForTextPosition:position lineIndex:lineIndex];
        if (ofs != CGFLOAT_MAX) {
            BOOL RTL = [self _isRightToLeftInLine:line atPoint:point];
            if (position >= line.range.location + line.range.length) {
                finalAffinity = RTL ? TextAffinityForward : TextAffinityBackward;
            } else if (position <= line.range.location) {
                finalAffinity = RTL ? TextAffinityBackward : TextAffinityForward;
            } else {
                finalAffinity = (ofs < (isVertical ? point.y : point.x) && !RTL) ? TextAffinityForward : TextAffinityBackward;
            }
        }
    }
    
    return [TextPosition positionWith:position affinity:finalAffinity];
}
- (TextPosition *)positionForPoint:(CGPoint)point
                       oldPosition:(TextPosition *)oldPosition
                     otherPosition:(TextPosition *)otherPosition {
    if (!oldPosition || !otherPosition) {
        return oldPosition;
    }
    TextPosition *newPos = [self closestPositionToPoint:point];
    if (!newPos) return oldPosition;
    if ([newPos compare:otherPosition] == [oldPosition compare:otherPosition] &&
        newPos.offset != otherPosition.offset) {
        return newPos;
    }
    NSUInteger lineIndex = [self lineIndexForPosition:otherPosition];
    if (lineIndex == NSNotFound) return oldPosition;
    TextLine *line = _lines[lineIndex];
    TextRowEdge vertical = _lineRowEdge[line.row];
    if (_container.verticalForm) {
        point.x = (vertical.head + vertical.foot) * 0.5;
    } else {
        point.y = (vertical.head + vertical.foot) * 0.5;
    }
    newPos = [self closestPositionToPoint:point];
    if ([newPos compare:otherPosition] == [oldPosition compare:otherPosition] &&
        newPos.offset != otherPosition.offset) {
        return newPos;
    }
    
    if (_container.isVerticalForm) {
        if ([oldPosition compare:otherPosition] == NSOrderedAscending) { // search backward
            TextRange *range = [self textRangeByExtendingPosition:otherPosition inDirection:UITextLayoutDirectionUp offset:1];
            if (range) return range.start;
        } else { // search forward
            TextRange *range = [self textRangeByExtendingPosition:otherPosition inDirection:UITextLayoutDirectionDown offset:1];
            if (range) return range.end;
        }
    } else {
        if ([oldPosition compare:otherPosition] == NSOrderedAscending) { // search backward
            TextRange *range = [self textRangeByExtendingPosition:otherPosition inDirection:UITextLayoutDirectionLeft offset:1];
            if (range) return range.start;
        } else { // search forward
            TextRange *range = [self textRangeByExtendingPosition:otherPosition inDirection:UITextLayoutDirectionRight offset:1];
            if (range) return range.end;
        }
    }
    return oldPosition;
}
- (TextRange *)textRangeAtPoint:(CGPoint)point {
    NSUInteger lineIndex = [self lineIndexForPoint:point];
    if (lineIndex == NSNotFound) return nil;
    NSUInteger textPosition = [self textPositionForPoint:point lineIndex:[self lineIndexForPoint:point]];
    if (textPosition == NSNotFound) return nil;
    TextPosition *pos = [self closestPositionToPoint:point];
    if (!pos) return nil;
    
    // get write direction
    BOOL RTL = [self _isRightToLeftInLine:_lines[lineIndex] atPoint:point];
    CGRect rect = [self caretRectForPosition:pos];
    if (CGRectIsNull(rect)) return nil;
    
    if (_container.verticalForm) {
        TextRange *range = [self textRangeByExtendingPosition:pos inDirection:(rect.origin.y >= point.y && !RTL) ? UITextLayoutDirectionUp:UITextLayoutDirectionDown offset:1];
        return range;
    } else {
        TextRange *range = [self textRangeByExtendingPosition:pos inDirection:(rect.origin.x >= point.x && !RTL) ? UITextLayoutDirectionLeft:UITextLayoutDirectionRight offset:1];
        return range;
    }
}
- (TextRange *)closestTextRangeAtPoint:(CGPoint)point {
    TextPosition *pos = [self closestPositionToPoint:point];
    if (!pos) return nil;
    NSUInteger lineIndex = [self lineIndexForPosition:pos];
    if (lineIndex == NSNotFound) return nil;
    TextLine *line = _lines[lineIndex];
    BOOL RTL = [self _isRightToLeftInLine:line atPoint:point];
    CGRect rect = [self caretRectForPosition:pos];
    if (CGRectIsNull(rect)) return nil;
    
    UITextLayoutDirection direction = UITextLayoutDirectionRight;
    if (pos.offset >= line.range.location + line.range.length) {
        if (direction != RTL) {
            direction = _container.verticalForm ? UITextLayoutDirectionUp : UITextLayoutDirectionLeft;
        } else {
            direction = _container.verticalForm ? UITextLayoutDirectionDown : UITextLayoutDirectionRight;
        }
    } else if (pos.offset <= line.range.location) {
        if (direction != RTL) {
            direction = _container.verticalForm ? UITextLayoutDirectionDown : UITextLayoutDirectionRight;
        } else {
            direction = _container.verticalForm ? UITextLayoutDirectionUp : UITextLayoutDirectionLeft;
        }
    } else {
        if (_container.verticalForm) {
            direction = (rect.origin.y >= point.y && !RTL) ? UITextLayoutDirectionUp:UITextLayoutDirectionDown;
        } else {
            direction = (rect.origin.x >= point.x && !RTL) ? UITextLayoutDirectionLeft:UITextLayoutDirectionRight;
        }
    }
    
    TextRange *range = [self textRangeByExtendingPosition:pos inDirection:direction offset:1];
    return range;
}
- (TextRange *)textRangeByExtendingPosition:(TextPosition *)position {
    NSUInteger visibleStart = _visibleRange.location;
    NSUInteger visibleEnd = _visibleRange.location + _visibleRange.length;
    
    if (!position) return nil;
    if (position.offset < visibleStart || position.offset > visibleEnd) return nil;
    
    // head or tail, returns immediately
    if (position.offset == visibleStart) {
        return [TextRange rangeWithRange:NSMakeRange(position.offset, 0)];
    } else if (position.offset == visibleEnd) {
        return [TextRange rangeWithRange:NSMakeRange(position.offset, 0) affinity:TextAffinityBackward];
    }
    
    // binding range
    NSRange tRange;
    TextBingString *binding = [_text attribute:TextBindingAttributeName atIndex:position.offset longestEffectiveRange:&tRange inRange:_visibleRange];
    if (binding && tRange.length > 0 && tRange.location < position.offset) {
        return [TextRange rangeWithRange:tRange];
    }
    
    // inside emoji or composed character sequences
    NSUInteger lineIndex = [self lineIndexForPosition:position];
    if (lineIndex != NSNotFound) {
        __block NSUInteger _prev, _next;
        BOOL emoji = NO, seq = NO;
        
        TextLine *line = _lines[lineIndex];
        emoji = [self _insideEmoji:line position:position.offset block: ^(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next) {
            _prev = prev;
            _next = next;
        }];
        if (!emoji) {
            seq = [self _insideComposedCharacterSequences:line position:position.offset block: ^(CGFloat left, CGFloat right, NSUInteger prev, NSUInteger next) {
                _prev = prev;
                _next = next;
            }];
        }
        if (emoji || seq) {
            return [TextRange rangeWithRange:NSMakeRange(_prev, _next - _prev)];
        }
    }
    
    // inside linebreak '\r\n'
    if (position.offset > visibleStart && position.offset < visibleEnd) {
        unichar c0 = [_text.string characterAtIndex:position.offset - 1];
        if ((c0 == '\r') && position.offset < visibleEnd) {
            unichar c1 = [_text.string characterAtIndex:position.offset];
            if (c1 == '\n') {
                return [TextRange rangeWithStart:[TextPosition positionWith:position.offset - 1] end:[TextPosition positionWith:position.offset + 1]];
            }
        }
        if (TextIsLinebreakChar(c0) && position.affinity == TextAffinityBackward) {
            NSString *str = [_text.string substringToIndex:position.offset];
            NSUInteger len = TextLinebreakTailLength(str);
            return [TextRange rangeWithStart:[TextPosition positionWith:position.offset - len] end:[TextPosition positionWith:position.offset]];
        }
    }
    
    return [TextRange rangeWithRange:NSMakeRange(position.offset, 0) affinity:position.affinity];
}
- (TextRange *)textRangeByExtendingPosition:(TextPosition *)position
                                inDirection:(UITextLayoutDirection)direction
                                     offset:(NSInteger)offset {
    NSInteger visibleStart = _visibleRange.location;
    NSInteger visibleEnd = _visibleRange.location + _visibleRange.length;
    
    if (!position) return nil;
    if (position.offset < visibleStart || position.offset > visibleEnd) return nil;
    if (offset == 0) return [self textRangeByExtendingPosition:position];
    
    BOOL isVerticalForm = _container.verticalForm;
    BOOL verticalMove, forwardMove;
    
    if (isVerticalForm) {
        verticalMove = direction == UITextLayoutDirectionLeft || direction == UITextLayoutDirectionRight;
        forwardMove = direction == UITextLayoutDirectionLeft || direction == UITextLayoutDirectionDown;
    } else {
        verticalMove = direction == UITextLayoutDirectionUp || direction == UITextLayoutDirectionDown;
        forwardMove = direction == UITextLayoutDirectionDown || direction == UITextLayoutDirectionRight;
    }
    
    if (offset < 0) {
        forwardMove = !forwardMove;
        offset = -offset;
    }
    
    // head or tail, returns immediately
    if (!forwardMove && position.offset == visibleStart) {
        return [TextRange rangeWithRange:NSMakeRange(_visibleRange.location, 0)];
    } else if (forwardMove && position.offset == visibleEnd) {
        return [TextRange rangeWithRange:NSMakeRange(position.offset, 0) affinity:TextAffinityBackward];
    }
    
    // extend from position
    TextRange *fromRange = [self textRangeByExtendingPosition:position];
    if (!fromRange) return nil;
    TextRange *allForward = [TextRange rangeWithStart:fromRange.start end:[TextPosition positionWith:visibleEnd]];
    TextRange *allBackward = [TextRange rangeWithStart:[TextPosition positionWith:visibleStart] end:fromRange.end];
    
    if (verticalMove) { // up/down in text layout
        NSInteger lineIndex = [self lineIndexForPosition:position];
        if (lineIndex == NSNotFound) return nil;
        
        TextLine *line = _lines[lineIndex];
        NSInteger moveToRowIndex = (NSInteger)line.row + (forwardMove ? offset : -offset);
        if (moveToRowIndex < 0) return allBackward;
        else if (moveToRowIndex >= (NSInteger)_rowCount) return allForward;
        
        CGFloat ofs = [self offsetForTextPosition:position.offset lineIndex:lineIndex];
        if (ofs == CGFLOAT_MAX) return nil;
        
        NSUInteger moveToLineFirstIndex = [self lineIndexForRow:moveToRowIndex];
        NSUInteger moveToLineCount = [self lineCountForRow:moveToRowIndex];
        if (moveToLineFirstIndex == NSNotFound || moveToLineCount == NSNotFound || moveToLineCount == 0) return nil;
        CGFloat mostLeft = CGFLOAT_MAX, mostRight = -CGFLOAT_MAX;
        TextLine *mostLeftLine = nil, *mostRightLine = nil;
        NSUInteger insideIndex = NSNotFound;
        for (NSUInteger i = 0; i < moveToLineCount; i++) {
            NSUInteger lineIndex = moveToLineFirstIndex + i;
            TextLine *line = _lines[lineIndex];
            if (isVerticalForm) {
                if (line.top <= ofs && ofs <= line.bottom) {
                    insideIndex = line.index;
                    break;
                }
                if (line.top < mostLeft) {
                    mostLeft = line.top;
                    mostLeftLine = line;
                }
                if (line.bottom > mostRight) {
                    mostRight = line.bottom;
                    mostRightLine = line;
                }
            } else {
                if (line.left <= ofs && ofs <= line.right) {
                    insideIndex = line.index;
                    break;
                }
                if (line.left < mostLeft) {
                    mostLeft = line.left;
                    mostLeftLine = line;
                }
                if (line.right > mostRight) {
                    mostRight = line.right;
                    mostRightLine = line;
                }
            }
        }
        BOOL afinityEdge = NO;
        if (insideIndex == NSNotFound) {
            if (ofs <= mostLeft) {
                insideIndex = mostLeftLine.index;
            } else {
                insideIndex = mostRightLine.index;
            }
            afinityEdge = YES;
        }
        TextLine *insideLine = _lines[insideIndex];
        NSUInteger pos;
        if (isVerticalForm) {
            pos = [self textPositionForPoint:CGPointMake(insideLine.position.x, ofs) lineIndex:insideIndex];
        } else {
            pos = [self textPositionForPoint:CGPointMake(ofs, insideLine.position.y) lineIndex:insideIndex];
        }
        if (pos == NSNotFound) return nil;
        TextPosition *extPos;
        if (afinityEdge) {
            if (pos == insideLine.range.location + insideLine.range.length) {
                NSString *subStr = [_text.string substringWithRange:insideLine.range];
                NSUInteger lineBreakLen = TextLinebreakTailLength(subStr);
                extPos = [TextPosition positionWith:pos - lineBreakLen];
            } else {
                extPos = [TextPosition positionWith:pos];
            }
        } else {
            extPos = [TextPosition positionWith:pos];
        }
        TextRange *ext = [self textRangeByExtendingPosition:extPos];
        if (!ext) return nil;
        if (forwardMove) {
            return [TextRange rangeWithStart:fromRange.start end:ext.end];
        } else {
            return [TextRange rangeWithStart:ext.start end:fromRange.end];
        }
        
    } else { // left/right in text layout
        TextPosition *toPosition = [TextPosition positionWith:position.offset + (forwardMove ? offset : -offset)];
        if (toPosition.offset <= visibleStart) return allBackward;
        else if (toPosition.offset >= visibleEnd) return allForward;
        
        TextRange *toRange = [self textRangeByExtendingPosition:toPosition];
        if (!toRange) return nil;
        
        NSInteger start = MIN(fromRange.start.offset, toRange.start.offset);
        NSInteger end = MAX(fromRange.end.offset, toRange.end.offset);
        return [TextRange rangeWithRange:NSMakeRange(start, end - start)];
    }
}
- (NSUInteger)lineIndexForPosition:(TextPosition *)position {
    if (!position) return NSNotFound;
    if (_lines.count == 0) return NSNotFound;
    NSUInteger location = position.offset;
    NSInteger lo = 0, hi = _lines.count - 1, mid = 0;
    if (position.affinity == TextAffinityBackward) {
        while (lo <= hi) {
            mid = (lo + hi) / 2;
            TextLine *line = _lines[mid];
            NSRange range = line.range;
            if (range.location <= location && location <= range.location + range.length) {
                return mid;
            }
            if (location <= range.location) {
                hi = mid - 1;
            } else {
                lo = mid + 1;
            }
        }
    } else {
        while (lo <= hi) {
            mid = (lo + hi) / 2;
            TextLine *line = _lines[mid];
            NSRange range = line.range;
            if (range.location <= location && location <= range.location + range.length) {
                return mid;
            }
            if (location < range.location) {
                hi = mid - 1;
            } else {
                lo = mid + 1;
            }
        }
    }
    return NSNotFound;
}
///textposition  对应的 line 的point
- (CGPoint)linePositionForPosition:(TextPosition *)position {
    NSUInteger lineIndex = [self lineIndexForPosition:position];
    if (lineIndex == NSNotFound) return CGPointZero;
    TextLine *line = _lines[lineIndex];
    CGFloat offset = [self offsetForTextPosition:position.offset lineIndex:lineIndex];
    if (offset == CGFLOAT_MAX) return CGPointZero;
    if (_container.verticalForm) {
        return CGPointMake(line.position.x, offset);
    } else {
        return CGPointMake(offset, line.position.y);
    }
}
//// textPosition 对应的rect
- (CGRect)caretRectForPosition:(TextPosition *)position {
    NSUInteger lineIndex = [self lineIndexForPosition:position];
    if (lineIndex == NSNotFound) return CGRectNull;
    TextLine *line = _lines[lineIndex];
    CGFloat offset = [self offsetForTextPosition:position.offset lineIndex:lineIndex];
    if (offset == CGFLOAT_MAX) return CGRectNull;
    if (_container.verticalForm) {
        return CGRectMake(line.bounds.origin.x, offset, line.bounds.size.width, 0);
    } else {
        return CGRectMake(offset, line.bounds.origin.y, 0, line.bounds.size.height);
    }
}
////textRange 的第一个 row  对应的 rect
- (CGRect)firstRectForRange:(TextRange *)range {
    range = [self _correctedRangeWithEdge:range];
    
    NSUInteger startLineIndex = [self lineIndexForPosition:range.start];
    NSUInteger endLineIndex = [self lineIndexForPosition:range.end];
    if (startLineIndex == NSNotFound || endLineIndex == NSNotFound) return CGRectNull;
    if (startLineIndex > endLineIndex) return CGRectNull;
    TextLine *startLine = _lines[startLineIndex];
    TextLine *endLine = _lines[endLineIndex];
    NSMutableArray *lines = [NSMutableArray new];
    for (NSUInteger i = startLineIndex; i <= startLineIndex; i++) {
        TextLine *line = _lines[i];
        if (line.row != startLine.row) break;
        [lines addObject:line];
    }
    if (_container.verticalForm) {
        if (lines.count == 1) {
            CGFloat top = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
            CGFloat bottom;
            if (startLine == endLine) {
                bottom = [self offsetForTextPosition:range.end.offset lineIndex:startLineIndex];
            } else {
                bottom = startLine.bottom;
            }
            if (top == CGFLOAT_MAX || bottom == CGFLOAT_MAX) return CGRectNull;
            if (top > bottom) YYTEXT_SWAP(top, bottom);
            return CGRectMake(startLine.left, top, startLine.width, bottom - top);
        } else {
            CGFloat top = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
            CGFloat bottom = startLine.bottom;
            if (top == CGFLOAT_MAX || bottom == CGFLOAT_MAX) return CGRectNull;
            if (top > bottom) YYTEXT_SWAP(top, bottom);
            CGRect rect = CGRectMake(startLine.left, top, startLine.width, bottom - top);
            for (NSUInteger i = 1; i < lines.count; i++) {
                TextLine *line = lines[i];
                rect = CGRectUnion(rect, line.bounds);
            }
            return rect;
        }
    } else {
        if (lines.count == 1) {
            CGFloat left = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
            CGFloat right;
            if (startLine == endLine) {
                right = [self offsetForTextPosition:range.end.offset lineIndex:startLineIndex];
            } else {
                right = startLine.right;
            }
            if (left == CGFLOAT_MAX || right == CGFLOAT_MAX) return CGRectNull;
            if (left > right) YYTEXT_SWAP(left, right);
            return CGRectMake(left, startLine.top, right - left, startLine.height);
        } else {
            CGFloat left = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
            CGFloat right = startLine.right;
            if (left == CGFLOAT_MAX || right == CGFLOAT_MAX) return CGRectNull;
            if (left > right) YYTEXT_SWAP(left, right);
            CGRect rect = CGRectMake(left, startLine.top, right - left, startLine.height);
            for (NSUInteger i = 1; i < lines.count; i++) {
                TextLine *line = lines[i];
                rect = CGRectUnion(rect, line.bounds);
            }
            return rect;
        }
    }
}
////textRange 对应的selectionRect
- (CGRect)rectForRange:(TextRange *)range {
    NSArray *rects = [self selectionRectsForRange:range];
    if (rects.count == 0) return CGRectNull;
    CGRect rectUnion = ((TextSelectionRect *)rects.firstObject).rect;
    ///合并所有的rect
    for (NSUInteger i = 1; i < rects.count; i++) {
        TextSelectionRect *rect = rects[i];
        rectUnion = CGRectUnion(rectUnion, rect.rect);
    }
    return rectUnion;
}

////textRange 多个rect
- (NSArray<TextSelectionRect *> *)selectionRectsForRange:(TextRange *)range {
    range = [self _correctedRangeWithEdge:range];
    
    BOOL isVertical = _container.verticalForm;
    NSMutableArray *rects = [NSMutableArray array];
    if (!range){
        return rects;
    }
    
    NSUInteger startLineIndex = [self lineIndexForPosition:range.start];
    NSUInteger endLineIndex = [self lineIndexForPosition:range.end];
    if (startLineIndex == NSNotFound || endLineIndex == NSNotFound){
        return rects;
    }
    if (startLineIndex > endLineIndex) YYTEXT_SWAP(startLineIndex, endLineIndex);
    TextLine *startLine = _lines[startLineIndex];
    TextLine *endLine = _lines[endLineIndex];
    CGFloat offsetStart = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
    CGFloat offsetEnd = [self offsetForTextPosition:range.end.offset lineIndex:endLineIndex];
    ///前面的dot
    TextSelectionRect *start = [TextSelectionRect new];
    if (isVertical) {
        start.rect = CGRectMake(startLine.left, offsetStart, startLine.width, 0);
    } else {
        start.rect = CGRectMake(offsetStart, startLine.top, 0, startLine.height);
    }
    start.containsStart = YES;
    start.isVertical = isVertical;
    [rects addObject:start];
    ///后面的dot
    TextSelectionRect *end = [TextSelectionRect new];
    if (isVertical) {
        end.rect = CGRectMake(endLine.left, offsetEnd, endLine.width, 0);
    } else {
        end.rect = CGRectMake(offsetEnd, endLine.top, 0, endLine.height);
    }
    end.containsEnd = YES;
    end.isVertical = isVertical;
    [rects addObject:end];
    
    ///中间的区域
    if (startLine.row == endLine.row) { // same row
        if (offsetStart > offsetEnd) YYTEXT_SWAP(offsetStart, offsetEnd);
        TextSelectionRect *rect = [TextSelectionRect new];
        if (isVertical) {
            rect.rect = CGRectMake(startLine.bounds.origin.x, offsetStart, MAX(startLine.width, endLine.width), offsetEnd - offsetStart);
        } else {
            rect.rect = CGRectMake(offsetStart, startLine.bounds.origin.y, offsetEnd - offsetStart, MAX(startLine.height, endLine.height));
        }
        rect.isVertical = isVertical;
        [rects addObject:rect];
        
    } else { // more than one row
        
        // start line select rect
        TextSelectionRect *topRect = [TextSelectionRect new];
        topRect.isVertical = isVertical;
        CGFloat topOffset = [self offsetForTextPosition:range.start.offset lineIndex:startLineIndex];
        CTRunRef topRun = [self _runForLine:startLine position:range.start];
        if (topRun && (CTRunGetStatus(topRun) & kCTRunStatusRightToLeft)) {
            if (isVertical) {
                topRect.rect = CGRectMake(startLine.left, _container.path ? startLine.top : _container.insets.top, startLine.width, topOffset - startLine.top);
            } else {
                topRect.rect = CGRectMake(_container.path ? startLine.left : _container.insets.left, startLine.top, topOffset - startLine.left, startLine.height);
            }
            topRect.writingDirection = UITextWritingDirectionRightToLeft;
        } else {
            if (isVertical) {
                topRect.rect = CGRectMake(startLine.left, topOffset, startLine.width, (_container.path ? startLine.bottom : _container.size.height - _container.insets.bottom) - topOffset);
            } else {
                topRect.rect = CGRectMake(topOffset, startLine.top, (_container.path ? startLine.right : _container.size.width - _container.insets.right) - topOffset, startLine.height);
            }
        }
        [rects addObject:topRect];
        
        // end line select rect
        TextSelectionRect *bottomRect = [TextSelectionRect new];
        bottomRect.isVertical = isVertical;
        CGFloat bottomOffset = [self offsetForTextPosition:range.end.offset lineIndex:endLineIndex];
        CTRunRef bottomRun = [self _runForLine:endLine position:range.end];
        if (bottomRun && (CTRunGetStatus(bottomRun) & kCTRunStatusRightToLeft)) {
            if (isVertical) {
                bottomRect.rect = CGRectMake(endLine.left, bottomOffset, endLine.width, (_container.path ? endLine.bottom : _container.size.height - _container.insets.bottom) - bottomOffset);
            } else {
                bottomRect.rect = CGRectMake(bottomOffset, endLine.top, (_container.path ? endLine.right : _container.size.width - _container.insets.right) - bottomOffset, endLine.height);
            }
            bottomRect.writingDirection = UITextWritingDirectionRightToLeft;
        } else {
            if (isVertical) {
                CGFloat top = _container.path ? endLine.top : _container.insets.top;
                bottomRect.rect = CGRectMake(endLine.left, top, endLine.width, bottomOffset - top);
            } else {
                CGFloat left = _container.path ? endLine.left : _container.insets.left;
                bottomRect.rect = CGRectMake(left, endLine.top, bottomOffset - left, endLine.height);
            }
        }
        [rects addObject:bottomRect];
        
        if (endLineIndex - startLineIndex >= 2) {
            CGRect r = CGRectZero;
            BOOL startLineDetected = NO;
            for (NSUInteger l = startLineIndex + 1; l < endLineIndex; l++) {
                TextLine *line = _lines[l];
                if (line.row == startLine.row || line.row == endLine.row) continue;
                if (!startLineDetected) {
                    r = line.bounds;
                    startLineDetected = YES;
                } else {
                    r = CGRectUnion(r, line.bounds);
                }
            }
            if (startLineDetected) {
                if (isVertical) {
                    if (!_container.path) {
                        r.origin.y = _container.insets.top;
                        r.size.height = _container.size.height - _container.insets.bottom - _container.insets.top;
                    }
                    r.size.width =  CGRectGetMinX(topRect.rect) - CGRectGetMaxX(bottomRect.rect);
                    r.origin.x = CGRectGetMaxX(bottomRect.rect);
                } else {
                    if (!_container.path) {
                        r.origin.x = _container.insets.left;
                        r.size.width = _container.size.width - _container.insets.right - _container.insets.left;
                    }
                    r.origin.y = CGRectGetMaxY(topRect.rect);
                    r.size.height = bottomRect.rect.origin.y - r.origin.y;
                }
                
                TextSelectionRect *rect = [TextSelectionRect new];
                rect.rect = r;
                rect.isVertical = isVertical;
                [rects addObject:rect];
            }
        } else {
            if (isVertical) {
                CGRect r0 = bottomRect.rect;
                CGRect r1 = topRect.rect;
                CGFloat mid = (CGRectGetMaxX(r0) + CGRectGetMinX(r1)) * 0.5;
                r0.size.width = mid - r0.origin.x;
                CGFloat r1ofs = r1.origin.x - mid;
                r1.origin.x -= r1ofs;
                r1.size.width += r1ofs;
                topRect.rect = r1;
                bottomRect.rect = r0;
            } else {
                CGRect r0 = topRect.rect;
                CGRect r1 = bottomRect.rect;
                CGFloat mid = (CGRectGetMaxY(r0) + CGRectGetMinY(r1)) * 0.5;
                r0.size.height = mid - r0.origin.y;
                CGFloat r1ofs = r1.origin.y - mid;
                r1.origin.y -= r1ofs;
                r1.size.height += r1ofs;
                topRect.rect = r0;
                bottomRect.rect = r1;
            }
        }
    }
    return rects;
}
////textRange  对应的rect 不包含 开始和结束
- (NSArray <TextSelectionRect *> *)selectionRectsWithoutStartAndEndForRange:(TextRange *)range {
    NSMutableArray *rects = [self selectionRectsForRange:range].mutableCopy;
    for (NSInteger i = 0, max = rects.count; i < max; i++) {
        TextSelectionRect *rect = rects[i];
        if (rect.containsStart || rect.containsEnd) {
            [rects removeObjectAtIndex:i];
            i--;
            max--;
        }
    }
    return rects;
}
////textRange  仅仅包含 开始和结束
- (NSArray<TextSelectionRect *> *)selectionRectsWithOnlyStartAndEndForRange:(TextRange *)range {
    NSMutableArray *rects = [self selectionRectsForRange:range].mutableCopy;
    for (NSInteger i = 0, max = rects.count; i < max; i++) {
        TextSelectionRect *rect = rects[i];
        if (!rect.containsStart && !rect.containsEnd) {
            [rects removeObjectAtIndex:i];
            i--;
            max--;
        }
    }
    return rects;
}

///下划线 中划线
typedef NS_OPTIONS(NSUInteger, TextDecorationType) {
    TextDecorationTypeUnderline     = 1 << 0,
    TextDecorationTypeStrikethrough = 1 << 1,
};

/// 一般的边框  背景边框
typedef NS_OPTIONS(NSUInteger, TextBorderType) {
    TextBorderTypeBackgound = 1 << 0,
    TextBorderTypeNormal    = 1 << 1,
};

///合并同一行的两个rect
static CGRect YYTextMergeRectInSameLine(CGRect rect1, CGRect rect2, BOOL isVertical) {
    if (isVertical) {
        CGFloat top = MIN(rect1.origin.y, rect2.origin.y);
        CGFloat bottom = MAX(rect1.origin.y + rect1.size.height, rect2.origin.y + rect2.size.height);
        CGFloat width = MAX(rect1.size.width, rect2.size.width);
        return CGRectMake(rect1.origin.x, top, width, bottom - top);
    } else {
        CGFloat left = MIN(rect1.origin.x, rect2.origin.x);
        CGFloat right = MAX(rect1.origin.x + rect1.size.width, rect2.origin.x + rect2.size.width);
        CGFloat height = MAX(rect1.size.height, rect2.size.height);
        return CGRectMake(left, rect1.origin.y, right - left, height);
    }
}

////获取多个 CTRun 的 最大的 高度  Thickness(下划线粗细)  下划线的位置
static void YYTextGetRunsMaxMetric(CFArrayRef runs, CGFloat *xHeight, CGFloat *underlinePosition, CGFloat *lineThickness) {
    CGFloat maxXHeight = 0;
    CGFloat maxUnderlinePos = 0;
    CGFloat maxLineThickness = 0;
    for (NSUInteger i = 0, max = CFArrayGetCount(runs); i < max; i++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, i);
        CFDictionaryRef attrs = CTRunGetAttributes(run);
        if (attrs) {
            CTFontRef font = CFDictionaryGetValue(attrs, kCTFontAttributeName);
            if (font) {
                CGFloat xHeight = CTFontGetXHeight(font);
                if (xHeight > maxXHeight) maxXHeight = xHeight;
                CGFloat underlinePos = CTFontGetUnderlinePosition(font);
                if (underlinePos < maxUnderlinePos) maxUnderlinePos = underlinePos;
                CGFloat lineThickness = CTFontGetUnderlineThickness(font);
                if (lineThickness > maxLineThickness) maxLineThickness = lineThickness;
            }
        }
    }
    if (xHeight) *xHeight = maxXHeight;
    if (underlinePosition) *underlinePosition = maxUnderlinePos;
    if (lineThickness) *lineThickness = maxLineThickness;
}

////绘制CTRun
static void TextDrawRun(TextLine *line,CTRunRef run, CGContextRef context, CGSize size, BOOL isVertical, NSArray *runRanges, CGFloat verticalOffset){
    ///run 的 矩阵
    CGAffineTransform runTextMatrix = CTRunGetTextMatrix(run);
    ///是否矩阵变换
    BOOL runTextMatrixIsID = CGAffineTransformIsIdentity(runTextMatrix);
    /// 获取属性
    CFDictionaryRef runAttrs = CTRunGetAttributes(run);
    ///字形变换
    NSValue *glyphTransformValue = CFDictionaryGetValue(runAttrs, (__bridge void *)TextGlyphTransformAttributeName);
    ////没有字形变换
    if (!isVertical && !glyphTransformValue) {
        if (!runTextMatrixIsID) {
            //// 保存之前的context 状态 并开始新的context 状态
            CGContextSaveGState(context);
            CGAffineTransform textaTrans = CGContextGetTextMatrix(context);
            ////两个已经存在的放射矩阵生成一个新的矩阵
            CGContextSetTextMatrix(context, CGAffineTransformConcat(textaTrans, runTextMatrix));
        }
        CTRunDraw(run, context, CFRangeMake(0, 0));
        if (!runTextMatrixIsID) {
            ////重新回到保存之前的状态
            CGContextRestoreGState(context);
        }
    }else{
        CTFontRef runFont = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
        if (!runFont) return;
        NSUInteger glyphCount = CTRunGetGlyphCount(run);
        if (glyphCount <= 0 ) return;
        ///字形
        CGGlyph glyphs[glyphCount];
        ///位置
        CGPoint glyphPositions[glyphCount];
        CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);
        CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);
        
        ///字体颜色
        CGColorRef fillColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTForegroundColorAttributeName);
        fillColor = TextGetCGColor(fillColor);
        ///线宽
        NSNumber *strokeWidth = CFDictionaryGetValue(runAttrs, kCTStrokeWidthAttributeName);
        CGContextSaveGState(context);
        {
            CGContextSetFillColorWithColor(context, fillColor);
            if (strokeWidth == nil || strokeWidth.floatValue == 0) {
                CGContextSetTextDrawingMode(context,kCGTextFill);
            }else{
                ///线的颜色
                CGColorRef strokeColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTStrokeColorAttributeName);
                if (!strokeColor) strokeColor = fillColor;
                CGContextSetStrokeColorWithColor(context, strokeColor);
                CGContextSetLineWidth(context, CTFontGetSize(runFont) * fabs(strokeWidth.floatValue * 0.01));
                if (strokeWidth.floatValue > 0) {
                    ///线的填充模式
                    CGContextSetTextDrawingMode(context, kCGTextStroke);
                }else{
                    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
                }
                
            }
            if (isVertical) {
                CFIndex runStrIdx[glyphCount + 1];
                CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
                CFRange runStrRange = CTRunGetStringRange(run);
                runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
                CGSize glyphAdvances[glyphCount];
                CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
                CGFloat ascent = CTFontGetAscent(runFont);
                CGFloat descent = CTFontGetDescent(runFont);
                CGAffineTransform glyphTransform = glyphTransformValue.CGAffineTransformValue;
                CGPoint zeroPoint = CGPointZero;
                
                for (TextRunGlyphRange *oneRange in runRanges) {
                    NSRange range = oneRange.glyphRangeInRun;
                    NSUInteger rangeMax = range.location + range.length;
                    TextRunGlyphDrawMode mode = oneRange.drawMode;
                    
                    for (NSUInteger g = range.location; g < rangeMax; g++) {
                        CGContextSaveGState(context); {
                            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                            if (glyphTransformValue) {
                                CGContextSetTextMatrix(context, glyphTransform);
                            }
                            if (mode) { // CJK glyph, need rotated
                                CGFloat ofs = (ascent - descent) * 0.5;
                                CGFloat w = glyphAdvances[g].width * 0.5;
                                CGFloat x = x = line.position.x + verticalOffset + glyphPositions[g].y + (ofs - w);
                                CGFloat y = -line.position.y + size.height - glyphPositions[g].x - (ofs + w);
                                if (mode == TextRunGlyphDrawModeVerticalRotateMove) {
                                    x += w;
                                    y += w;
                                }
                                CGContextSetTextPosition(context, x, y);
                            } else {
                                CGContextRotateCTM(context, TextDegreesToRadians(-90));
                                CGContextSetTextPosition(context,
                                                         line.position.y - size.height + glyphPositions[g].x,
                                                         line.position.x + verticalOffset + glyphPositions[g].y);
                            }
                            
                            if (TextCTFontContainsColorBitmapGlyphs(runFont)) {
                                CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
                            } else {
                                CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
                                CGContextSetFont(context, cgFont);
                                CGContextSetFontSize(context, CTFontGetSize(runFont));
                                CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
                                CGFontRelease(cgFont);
                            }
                        } CGContextRestoreGState(context);
                    }
                }
            }else{
                if (glyphTransformValue) {
                    CFIndex runStrIdx[glyphCount + 1];
                    CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
                    CFRange runStrRange = CTRunGetStringRange(run);
                    runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
                    CGSize glyphAdvances[glyphCount];
                    CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
                    CGAffineTransform glyphTransform = glyphTransformValue.CGAffineTransformValue;
                    CGPoint zeroPoint = CGPointZero;
                    
                    for (NSUInteger g = 0; g < glyphCount; g++) {
                        CGContextSaveGState(context); {
                            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                            CGContextSetTextMatrix(context, glyphTransform);
                            CGContextSetTextPosition(context,
                                                     line.position.x + glyphPositions[g].x,
                                                     size.height - (line.position.y + glyphPositions[g].y));
                            
                            if (TextCTFontContainsColorBitmapGlyphs(runFont)) {
                                CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
                            } else {
                                CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
                                CGContextSetFont(context, cgFont);
                                CGContextSetFontSize(context, CTFontGetSize(runFont));
                                CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
                                CGFontRelease(cgFont);
                            }
                        } CGContextRestoreGState(context);
                    }
                }else{
                    if (TextCTFontContainsColorBitmapGlyphs(runFont)) {
                        CTFontDrawGlyphs(runFont, glyphs, glyphPositions, glyphCount, context);
                    } else {
                        CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
                        CGContextSetFont(context, cgFont);
                        CGContextSetFontSize(context, CTFontGetSize(runFont));
                        CGContextShowGlyphsAtPositions(context, glyphs, glyphPositions, glyphCount);
                        CGFontRelease(cgFont);
                    }
                }
            }
        }
        CGContextRestoreGState(context);
    }
}

///设置线的样式
static void TextSetLinePatternInContext(TextLineStyle style, CGFloat width, CGFloat phase, CGContextRef context){
    CGContextSetLineWidth(context, width);
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    
    CGFloat dash = 12, dot = 5, space = 3;
    NSUInteger pattern = style & 0xF00;
    if (pattern == TextLineStylePatternSolid) {
        CGContextSetLineDash(context, phase, NULL, 0);
    } else if (pattern == TextLineStylePatternDot) {
        CGFloat lengths[2] = {width * dot, width * space};
        CGContextSetLineDash(context, phase, lengths, 2);
    } else if (pattern == TextLineStylePatternDash) {
        CGFloat lengths[2] = {width * dash, width * space};
        CGContextSetLineDash(context, phase, lengths, 2);
    } else if (pattern == TextLineStylePatternDashDot) {
        CGFloat lengths[4] = {width * dash, width * space, width * dot, width * space};
        CGContextSetLineDash(context, phase, lengths, 4);
    } else if (pattern == TextLineStylePatternDashDotDot) {
        CGFloat lengths[6] = {width * dash, width * space,width * dot, width * space, width * dot, width * space};
        CGContextSetLineDash(context, phase, lengths, 6);
    } else if (pattern == TextLineStylePatternCircleDot) {
        CGFloat lengths[2] = {width * 0, width * 3};
        CGContextSetLineDash(context, phase, lengths, 2);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
    }
}
//// 绘制多个块边框
static void TextDrawBorderRects(CGContextRef context, CGSize size, TextBorder *border, NSArray *rects, BOOL isVertical) {
    if (rects.count == 0) return;
    
    TextShadow *shadow = border.shadow;
    if (shadow.color) {
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow.offset, shadow.radius, shadow.color.CGColor);
        CGContextBeginTransparencyLayer(context, NULL);
    }
    
    NSMutableArray *paths = [NSMutableArray new];
    for (NSValue *value in rects) {
        CGRect rect = value.CGRectValue;
        if (isVertical) {
            rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetRotateVertical(border.insets));
        } else {
            rect = UIEdgeInsetsInsetRect(rect, border.insets);
        }
        rect = TextCGRectPixelRound(rect);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:border.cornerRadius];
        [path closePath];
        [paths addObject:path];
    }
    
    if (border.fillColor) {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, border.fillColor.CGColor);
        for (UIBezierPath *path in paths) {
            CGContextAddPath(context, path.CGPath);
        }
        CGContextFillPath(context);
        CGContextRestoreGState(context);
    }
    
    if (border.strokeColor && border.lineStyle > 0 && border.strokeWidth > 0) {
        
        //-------------------------- single line ------------------------------//
        CGContextSaveGState(context);
        for (UIBezierPath *path in paths) {
            CGRect bounds = CGRectUnion(path.bounds, (CGRect){CGPointZero, size});
            bounds = CGRectInset(bounds, -2 * border.strokeWidth, -2 * border.strokeWidth);
            CGContextAddRect(context, bounds);
            CGContextAddPath(context, path.CGPath);
            CGContextEOClip(context);
        }
        [border.strokeColor setStroke];
        TextSetLinePatternInContext(border.lineStyle, border.strokeWidth, 0, context);
        CGFloat inset = -border.strokeWidth * 0.5;
        if ((border.lineStyle & 0xFF) == TextLineStyleThick) {
            inset *= 2;
            CGContextSetLineWidth(context, border.strokeWidth * 2);
        }
        CGFloat radiusDelta = -inset;
        if (border.cornerRadius <= 0) {
            radiusDelta = 0;
        }
        CGContextSetLineJoin(context, border.lineJoin);
        for (NSValue *value in rects) {
            CGRect rect = value.CGRectValue;
            if (isVertical) {
                rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetRotateVertical(border.insets));
            } else {
                rect = UIEdgeInsetsInsetRect(rect, border.insets);
            }
            rect = CGRectInset(rect, inset, inset);
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:border.cornerRadius + radiusDelta];
            [path closePath];
            CGContextAddPath(context, path.CGPath);
        }
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
        
        //------------------------- second line ------------------------------//
        if ((border.lineStyle & 0xFF) == TextLineStyleDouble) {
            CGContextSaveGState(context);
            CGFloat inset = -border.strokeWidth * 2;
            for (NSValue *value in rects) {
                CGRect rect = value.CGRectValue;
                rect = UIEdgeInsetsInsetRect(rect, border.insets);
                rect = CGRectInset(rect, inset, inset);
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:border.cornerRadius + 2 * border.strokeWidth];
                [path closePath];
                
                CGRect bounds = CGRectUnion(path.bounds, (CGRect){CGPointZero, size});
                bounds = CGRectInset(bounds, -2 * border.strokeWidth, -2 * border.strokeWidth);
                CGContextAddRect(context, bounds);
                CGContextAddPath(context, path.CGPath);
                CGContextEOClip(context);
            }
            CGContextSetStrokeColorWithColor(context, border.strokeColor.CGColor);
            TextSetLinePatternInContext(border.lineStyle, border.strokeWidth, 0, context);
            CGContextSetLineJoin(context, border.lineJoin);
            inset = -border.strokeWidth * 2.5;
            radiusDelta = border.strokeWidth * 2;
            if (border.cornerRadius <= 0) {
                radiusDelta = 0;
            }
            for (NSValue *value in rects) {
                CGRect rect = value.CGRectValue;
                rect = UIEdgeInsetsInsetRect(rect, border.insets);
                rect = CGRectInset(rect, inset, inset);
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:border.cornerRadius + radiusDelta];
                [path closePath];
                CGContextAddPath(context, path.CGPath);
            }
            CGContextStrokePath(context);
            CGContextRestoreGState(context);
        }
    }
    
    if (shadow.color) {
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
}
////绘制线的样式
static void TextDrawLineStyle(CGContextRef context, CGFloat length, CGFloat lineWidth, TextLineStyle style, CGPoint position, CGColorRef color, BOOL isVertical){
    ///基线的位置
    NSUInteger styleBase = style & 0xFF;
    if (styleBase == 0) return;
    CGContextSaveGState(context);
    {
        if (isVertical) {
            CGFloat x, y1, y2, w;
            y1 = TextCGFloatPixelRound(position.y);
            y2 = TextCGFloatPixelRound(position.y + length);
            w = (styleBase == TextLineStyleThick ? lineWidth * 2 : lineWidth);
            
            CGFloat linePixel = TextCGFloatToPixel(w);
            if (fabs(linePixel - floor(linePixel)) < 0.1) {
                int iPixel = linePixel;
                if (iPixel == 0 || (iPixel % 2)) { // odd line pixel
                    x = TextCGFloatPixelHalf(position.x);
                } else {
                    x = TextCGFloatPixelFloor(position.x);
                }
            } else {
                x = position.x;
            }
            
            CGContextSetStrokeColorWithColor(context, color);
            TextSetLinePatternInContext(style, lineWidth, position.y, context);
            CGContextSetLineWidth(context, w);
            if (styleBase == TextLineStyleSingle) {
                CGContextMoveToPoint(context, x, y1);
                CGContextAddLineToPoint(context, x, y2);
                CGContextStrokePath(context);
            } else if (styleBase == TextLineStyleThick) {
                CGContextMoveToPoint(context, x, y1);
                CGContextAddLineToPoint(context, x, y2);
                CGContextStrokePath(context);
            } else if (styleBase == TextLineStyleDouble) {
                CGContextMoveToPoint(context, x - w, y1);
                CGContextAddLineToPoint(context, x - w, y2);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, x + w, y1);
                CGContextAddLineToPoint(context, x + w, y2);
                CGContextStrokePath(context);
            }
        }else{
            CGFloat x1, x2, y, w;
            x1 = TextCGFloatPixelRound(position.x);
            x2 = TextCGFloatPixelRound(position.x + length);
            w = (styleBase == TextLineStyleThick ? lineWidth * 2 : lineWidth);
            
            CGFloat linePixel = TextCGFloatToPixel(w);
            if (fabs(linePixel - floor(linePixel)) < 0.1) {
                int iPixel = linePixel;
                if (iPixel == 0 || (iPixel % 2)) { // odd line pixel
                    y = TextCGFloatPixelHalf(position.y);
                } else {
                    y = TextCGFloatPixelFloor(position.y);
                }
            } else {
                y = position.y;
            }
            
            CGContextSetStrokeColorWithColor(context, color);
            TextSetLinePatternInContext(style, lineWidth, position.x, context);
            CGContextSetLineWidth(context, w);
            if (styleBase == TextLineStyleSingle) {
                CGContextMoveToPoint(context, x1, y);
                CGContextAddLineToPoint(context, x2, y);
                CGContextStrokePath(context);
            } else if (styleBase == TextLineStyleThick) {
                CGContextMoveToPoint(context, x1, y);
                CGContextAddLineToPoint(context, x2, y);
                CGContextStrokePath(context);
            } else if (styleBase == TextLineStyleDouble) {
                CGContextMoveToPoint(context, x1, y - w);
                CGContextAddLineToPoint(context, x2, y - w);
                CGContextStrokePath(context);
                CGContextMoveToPoint(context, x1, y + w);
                CGContextAddLineToPoint(context, x2, y + w);
                CGContextStrokePath(context);
            }
        }
    }
    CGContextRestoreGState(context);
}
///绘制文本
static void TextDrawText(TextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void)) {
    CGContextSaveGState(context); {
        
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        
        BOOL isVertical = layout.container.verticalForm;
        CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
        
        NSArray *lines = layout.lines;
        for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
            TextLine *line = lines[l];
            if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
            NSArray *lineRunRanges = line.verticalRotateRange;
            CGFloat posX = line.position.x + verticalOffset;
            CGFloat posY = size.height - line.position.y;
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
                CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                CGContextSetTextPosition(context, posX, posY);
                TextDrawRun(line, run, context, size, isVertical, lineRunRanges[r], verticalOffset);
            }
            if (cancel && cancel()) break;
        }
        
        // Use this to draw frame for test/debug.
        // CGContextTranslateCTM(context, verticalOffset, size.height);
        // CTFrameDraw(layout.frame, context);
        
    } CGContextRestoreGState(context);
}

///绘制块边框
static void TextDrawBlockBorder(TextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void)) {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    
    NSArray *lines = layout.lines;
    for (NSInteger l = 0, lMax = lines.count; l < lMax; l++) {
        if (cancel && cancel()) break;
        
        TextLine *line = lines[l];
        if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
        CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
        for (NSInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, r);
            CFIndex glyphCount = CTRunGetGlyphCount(run);
            if (glyphCount == 0) continue;
            NSDictionary *attrs = (id)CTRunGetAttributes(run);
            TextBorder *border = attrs[TextBlockBorderAttributeName];
            if (!border) continue;
            
            NSUInteger lineStartIndex = line.index;
            while (lineStartIndex > 0) {
                if (((TextLine *)lines[lineStartIndex - 1]).row == line.row) lineStartIndex--;
                else break;
            }
            
            CGRect unionRect = CGRectZero;
            NSUInteger lineStartRow = ((TextLine *)lines[lineStartIndex]).row;
            NSUInteger lineContinueIndex = lineStartIndex;
            NSUInteger lineContinueRow = lineStartRow;
            do {
                TextLine *one = lines[lineContinueIndex];
                if (lineContinueIndex == lineStartIndex) {
                    unionRect = one.bounds;
                } else {
                    unionRect = CGRectUnion(unionRect, one.bounds);
                }
                if (lineContinueIndex + 1 == lMax) break;
                TextLine *next = lines[lineContinueIndex + 1];
                if (next.row != lineContinueRow) {
                    TextBorder *nextBorder = [layout.text attribut:TextBlockBorderAttributeName atIndex:next.range.location];
                    if ([nextBorder isEqual:border]) {
                        lineContinueRow++;
                    } else {
                        break;
                    }
                }
                lineContinueIndex++;
            } while (true);
            
            if (isVertical) {
                UIEdgeInsets insets = layout.container.insets;
                unionRect.origin.y = insets.top;
                unionRect.size.height = layout.container.size.height -insets.top - insets.bottom;
            } else {
                UIEdgeInsets insets = layout.container.insets;
                unionRect.origin.x = insets.left;
                unionRect.size.width = layout.container.size.width -insets.left - insets.right;
            }
            unionRect.origin.x += verticalOffset;
            TextDrawBorderRects(context, size, border, @[[NSValue valueWithCGRect:unionRect]], isVertical);
            
            l = lineContinueIndex;
            break;
        }
    }
    CGContextRestoreGState(context);
}
static void TextDrawBorder(TextLayout *layout, CGContextRef context, CGSize size, CGPoint point, TextBorderType type, BOOL (^cancel)(void)) {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    
    NSArray *lines = layout.lines;
    NSString *borderKey = (type == TextBorderTypeNormal ? TextBorderAttributeName : TextBackgroundBorderAttributeName);
    
    BOOL needJumpRun = NO;
    NSUInteger jumpRunIndex = 0;
    
    for (NSInteger l = 0, lMax = lines.count; l < lMax; l++) {
        if (cancel && cancel()) break;
        
        TextLine *line = lines[l];
        if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
        CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
        for (NSInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
            if (needJumpRun) {
                needJumpRun = NO;
                r = jumpRunIndex + 1;
                if (r >= rMax) break;
            }
            
            CTRunRef run = CFArrayGetValueAtIndex(runs, r);
            CFIndex glyphCount = CTRunGetGlyphCount(run);
            if (glyphCount == 0) continue;
            
            NSDictionary *attrs = (id)CTRunGetAttributes(run);
            TextBorder *border = attrs[borderKey];
            if (!border) continue;
            
            CFRange runRange = CTRunGetStringRange(run);
            if (runRange.location == kCFNotFound || runRange.length == 0) continue;
            if (runRange.location + runRange.length > layout.text.length) continue;
            
            NSMutableArray *runRects = [NSMutableArray new];
            NSInteger endLineIndex = l;
            NSInteger endRunIndex = r;
            BOOL endFound = NO;
            for (NSInteger ll = l; ll < lMax; ll++) {
                if (endFound) break;
                TextLine *iLine = lines[ll];
                CFArrayRef iRuns = CTLineGetGlyphRuns(iLine.CTLine);
                
                CGRect extLineRect = CGRectNull;
                for (NSInteger rr = (ll == l) ? r : 0, rrMax = CFArrayGetCount(iRuns); rr < rrMax; rr++) {
                    CTRunRef iRun = CFArrayGetValueAtIndex(iRuns, rr);
                    NSDictionary *iAttrs = (id)CTRunGetAttributes(iRun);
                    TextBorder *iBorder = iAttrs[borderKey];
                    if (![border isEqual:iBorder]) {
                        endFound = YES;
                        break;
                    }
                    endLineIndex = ll;
                    endRunIndex = rr;
                    
                    CGPoint iRunPosition = CGPointZero;
                    CTRunGetPositions(iRun, CFRangeMake(0, 1), &iRunPosition);
                    CGFloat ascent, descent;
                    CGFloat iRunWidth = CTRunGetTypographicBounds(iRun, CFRangeMake(0, 0), &ascent, &descent, NULL);
                    
                    if (isVertical) {
                        YYTEXT_SWAP(iRunPosition.x, iRunPosition.y);
                        iRunPosition.y += iLine.position.y;
                        CGRect iRect = CGRectMake(verticalOffset + line.position.x - descent, iRunPosition.y, ascent + descent, iRunWidth);
                        if (CGRectIsNull(extLineRect)) {
                            extLineRect = iRect;
                        } else {
                            extLineRect = CGRectUnion(extLineRect, iRect);
                        }
                    } else {
                        iRunPosition.x += iLine.position.x;
                        CGRect iRect = CGRectMake(iRunPosition.x, iLine.position.y - ascent, iRunWidth, ascent + descent);
                        if (CGRectIsNull(extLineRect)) {
                            extLineRect = iRect;
                        } else {
                            extLineRect = CGRectUnion(extLineRect, iRect);
                        }
                    }
                }
                
                if (!CGRectIsNull(extLineRect)) {
                    [runRects addObject:[NSValue valueWithCGRect:extLineRect]];
                }
            }
            
            NSMutableArray *drawRects = [NSMutableArray new];
            CGRect curRect= ((NSValue *)[runRects firstObject]).CGRectValue;
            for (NSInteger re = 0, reMax = runRects.count; re < reMax; re++) {
                CGRect rect = ((NSValue *)runRects[re]).CGRectValue;
                if (isVertical) {
                    if (fabs(rect.origin.x - curRect.origin.x) < 1) {
                        curRect = YYTextMergeRectInSameLine(rect, curRect, isVertical);
                    } else {
                        [drawRects addObject:[NSValue valueWithCGRect:curRect]];
                        curRect = rect;
                    }
                } else {
                    if (fabs(rect.origin.y - curRect.origin.y) < 1) {
                        curRect = YYTextMergeRectInSameLine(rect, curRect, isVertical);
                    } else {
                        [drawRects addObject:[NSValue valueWithCGRect:curRect]];
                        curRect = rect;
                    }
                }
            }
            if (!CGRectEqualToRect(curRect, CGRectZero)) {
                [drawRects addObject:[NSValue valueWithCGRect:curRect]];
            }
            
            TextDrawBorderRects(context, size, border, drawRects, isVertical);
            
            if (l == endLineIndex) {
                r = endRunIndex;
            } else {
                l = endLineIndex - 1;
                needJumpRun = YES;
                jumpRunIndex = endRunIndex;
                break;
            }
            
        }
    }
    
    CGContextRestoreGState(context);
}
////绘制线
static void TextDrawDecoration(TextLayout *layout, CGContextRef context, CGSize size, CGPoint point, TextDecorationType type, BOOL (^cancel)(void)) {
    NSArray *lines = layout.lines;
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    CGContextTranslateCTM(context, verticalOffset, 0);
    
    for (NSUInteger l = 0, lMax = layout.lines.count; l < lMax; l++) {
        if (cancel && cancel()) break;
        
        TextLine *line = lines[l];
        if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
        CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
        for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, r);
            CFIndex glyphCount = CTRunGetGlyphCount(run);
            if (glyphCount == 0) continue;
            
            NSDictionary *attrs = (id)CTRunGetAttributes(run);
            TextDecoration *underline = attrs[TextUnderlineAttributeName];
            TextDecoration *strikethrough = attrs[TextStrikethroughAttributeName];
            
            BOOL needDrawUnderline = NO, needDrawStrikethrough = NO;
            if ((type & TextDecorationTypeUnderline) && underline.style > 0) {
                needDrawUnderline = YES;
            }
            if ((type & TextDecorationTypeStrikethrough) && strikethrough.style > 0) {
                needDrawStrikethrough = YES;
            }
            if (!needDrawUnderline && !needDrawStrikethrough) continue;
            
            CFRange runRange = CTRunGetStringRange(run);
            if (runRange.location == kCFNotFound || runRange.length == 0) continue;
            if (runRange.location + runRange.length > layout.text.length) continue;
            NSString *runStr = [layout.text attributedSubstringFromRange:NSMakeRange(runRange.location, runRange.length)].string;
            if (TextIsLinebreakString(runStr)) continue; // may need more checks...
            
            CGFloat xHeight, underlinePosition, lineThickness;
            YYTextGetRunsMaxMetric(runs, &xHeight, &underlinePosition, &lineThickness);
            
            CGPoint underlineStart, strikethroughStart;
            CGFloat length;
            
            if (isVertical) {
                underlineStart.x = line.position.x + underlinePosition;
                strikethroughStart.x = line.position.x + xHeight / 2;
                
                CGPoint runPosition = CGPointZero;
                CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
                underlineStart.y = strikethroughStart.y = runPosition.x + line.position.y;
                length = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), NULL, NULL, NULL);
                
            } else {
                underlineStart.y = line.position.y - underlinePosition;
                strikethroughStart.y = line.position.y - xHeight / 2;
                
                CGPoint runPosition = CGPointZero;
                CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
                underlineStart.x = strikethroughStart.x = runPosition.x + line.position.x;
                length = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), NULL, NULL, NULL);
            }
            
            if (needDrawUnderline) {
                CGColorRef color = underline.color.CGColor;
                if (!color) {
                    color = (__bridge CGColorRef)(attrs[(id)kCTForegroundColorAttributeName]);
                    color = TextGetCGColor(color);
                }
                CGFloat thickness = (underline.width != nil) ? underline.width.floatValue : lineThickness;
                TextShadow *shadow = underline.shadow;
                while (shadow) {
                    if (!shadow.color) {
                        shadow = shadow.subShadow;
                        continue;
                    }
                    CGFloat offsetAlterX = size.width + 0xFFFF;
                    CGContextSaveGState(context); {
                        CGSize offset = shadow.offset;
                        offset.width -= offsetAlterX;
                        CGContextSaveGState(context); {
                            CGContextSetShadowWithColor(context, offset, shadow.radius, shadow.color.CGColor);
                            CGContextSetBlendMode(context, shadow.blendMode);
                            CGContextTranslateCTM(context, offsetAlterX, 0);
                            TextDrawLineStyle(context, length, thickness, underline.style, underlineStart, color, isVertical);
                        } CGContextRestoreGState(context);
                    } CGContextRestoreGState(context);
                    shadow = shadow.subShadow;
                }
                TextDrawLineStyle(context, length, thickness, underline.style, underlineStart, color, isVertical);
            }
            
            if (needDrawStrikethrough) {
                CGColorRef color = strikethrough.color.CGColor;
                if (!color) {
                    color = (__bridge CGColorRef)(attrs[(id)kCTForegroundColorAttributeName]);
                    color = TextGetCGColor(color);
                }
                CGFloat thickness = (strikethrough.width != nil) ? strikethrough.width.floatValue : lineThickness;
                TextShadow *shadow = underline.shadow;
                while (shadow) {
                    if (!shadow.color) {
                        shadow = shadow.subShadow;
                        continue;
                    }
                    CGFloat offsetAlterX = size.width + 0xFFFF;
                    CGContextSaveGState(context); {
                        CGSize offset = shadow.offset;
                        offset.width -= offsetAlterX;
                        CGContextSaveGState(context); {
                            CGContextSetShadowWithColor(context, offset, shadow.radius, shadow.color.CGColor);
                            CGContextSetBlendMode(context, shadow.blendMode);
                            CGContextTranslateCTM(context, offsetAlterX, 0);
                            TextDrawLineStyle(context, length, thickness, underline.style, underlineStart, color, isVertical);
                        } CGContextRestoreGState(context);
                    } CGContextRestoreGState(context);
                    shadow = shadow.subShadow;
                }
                TextDrawLineStyle(context, length, thickness, strikethrough.style, strikethroughStart, color, isVertical);
            }
        }
    }
    CGContextRestoreGState(context);
}
///绘制图片
static void TextDrawAttachment(TextLayout *layout, CGContextRef context, CGSize size, CGPoint point, UIView *targetView, CALayer *targetLayer, BOOL (^cancel)(void)) {
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    
    for (NSUInteger i = 0, max = layout.attachments.count; i < max; i++) {
        TextAttachment *a = layout.attachments[i];
        if (!a.content) continue;
        
        UIImage *image = nil;
        UIView *view = nil;
        CALayer *layer = nil;
        if ([a.content isKindOfClass:[UIImage class]]) {
            image = a.content;
        } else if ([a.content isKindOfClass:[UIView class]]) {
            view = a.content;
        } else if ([a.content isKindOfClass:[CALayer class]]) {
            layer = a.content;
        }
        if (!image && !view && !layer) continue;
        if (image && !context) continue;
        if (view && !targetView) continue;
        if (layer && !targetLayer) continue;
        if (cancel && cancel()) break;
        
        CGSize asize = image ? image.size : view ? view.frame.size : layer.frame.size;
        CGRect rect = ((NSValue *)layout.attachmentRects[i]).CGRectValue;
        if (isVertical) {
            rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetRotateVertical(a.contentInsets));
        } else {
            rect = UIEdgeInsetsInsetRect(rect, a.contentInsets);
        }
        rect = TextCGRectFitWithContentMode(rect, asize, a.contentMode);
        rect = TextCGRectPixelRound(rect);
        rect = CGRectStandardize(rect);
        rect.origin.x += point.x + verticalOffset;
        rect.origin.y += point.y;
        if (image) {
            CGImageRef ref = image.CGImage;
            if (ref) {
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, 0, CGRectGetMaxY(rect) + CGRectGetMinY(rect));
                CGContextScaleCTM(context, 1, -1);
                CGContextDrawImage(context, rect, ref);
                CGContextRestoreGState(context);
            }
        } else if (view) {
            view.frame = rect;
            [targetView addSubview:view];
        } else if (layer) {
            layer.frame = rect;
            [targetLayer addSublayer:layer];
        }
    }
}
///绘制阴影
static void TextDrawShadow(TextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void)) {
    //move out of context. (0xFFFF is just a random large number)
    CGFloat offsetAlterX = size.width + 0xFFFF;
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    
    CGContextSaveGState(context); {
        CGContextTranslateCTM(context, point.x, point.y);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        NSArray *lines = layout.lines;
        for (NSUInteger l = 0, lMax = layout.lines.count; l < lMax; l++) {
            if (cancel && cancel()) break;
            TextLine *line = lines[l];
            if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
            NSArray *lineRunRanges = line.verticalRotateRange;
            CGFloat linePosX = line.position.x;
            CGFloat linePosY = size.height - line.position.y;
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
                CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                CGContextSetTextPosition(context, linePosX, linePosY);
                NSDictionary *attrs = (id)CTRunGetAttributes(run);
                TextShadow *shadow = attrs[TextShadowAttributeName];
                TextShadow *nsShadow = [TextShadow shadowWithNSShadow:attrs[NSShadowAttributeName]]; // NSShadow compatible
                if (nsShadow) {
                    nsShadow.subShadow = shadow;
                    shadow = nsShadow;
                }
                while (shadow) {
                    if (!shadow.color) {
                        shadow = shadow.subShadow;
                        continue;
                    }
                    CGSize offset = shadow.offset;
                    offset.width -= offsetAlterX;
                    CGContextSaveGState(context); {
                        CGContextSetShadowWithColor(context, offset, shadow.radius, shadow.color.CGColor);
                        CGContextSetBlendMode(context, shadow.blendMode);
                        CGContextTranslateCTM(context, offsetAlterX, 0);
                        TextDrawRun(line, run, context, size, isVertical, lineRunRanges[r], verticalOffset);
                    } CGContextRestoreGState(context);
                    shadow = shadow.subShadow;
                }
            }
        }
    } CGContextRestoreGState(context);
}

///内部的shadown
static void TextDrawInnerShadow(TextLayout *layout, CGContextRef context, CGSize size, CGPoint point, BOOL (^cancel)(void)) {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    
    NSArray *lines = layout.lines;
    for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
        if (cancel && cancel()) break;
        
        TextLine *line = lines[l];
        if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
        NSArray *lineRunRanges = line.verticalRotateRange;
        CGFloat linePosX = line.position.x;
        CGFloat linePosY = size.height - line.position.y;
        CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
        for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, r);
            if (CTRunGetGlyphCount(run) == 0) continue;
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextSetTextPosition(context, linePosX, linePosY);
            NSDictionary *attrs = (id)CTRunGetAttributes(run);
            TextShadow *shadow = attrs[TextInnerShadowAttributeName];
            while (shadow) {
                if (!shadow.color) {
                    shadow = shadow.subShadow;
                    continue;
                }
                CGPoint runPosition = CGPointZero;
                CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
                CGRect runImageBounds = CTRunGetImageBounds(run, context, CFRangeMake(0, 0));
                runImageBounds.origin.x += runPosition.x;
                if (runImageBounds.size.width < 0.1 || runImageBounds.size.height < 0.1) continue;
                
                CFDictionaryRef runAttrs = CTRunGetAttributes(run);
                NSValue *glyphTransformValue = CFDictionaryGetValue(runAttrs, (__bridge const void *)(TextGlyphTransformAttributeName));
                if (glyphTransformValue) {
                    runImageBounds = CGRectMake(0, 0, size.width, size.height);
                }
                
                // text inner shadow
                CGContextSaveGState(context); {
                    CGContextSetBlendMode(context, shadow.blendMode);
                    CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
                    CGContextSetAlpha(context, CGColorGetAlpha(shadow.color.CGColor));
                    CGContextClipToRect(context, runImageBounds);
                    CGContextBeginTransparencyLayer(context, NULL); {
                        UIColor *opaqueShadowColor = [shadow.color colorWithAlphaComponent:1];
                        CGContextSetShadowWithColor(context, shadow.offset, shadow.radius, opaqueShadowColor.CGColor);
                        CGContextSetFillColorWithColor(context, opaqueShadowColor.CGColor);
                        CGContextSetBlendMode(context, kCGBlendModeSourceOut);
                        CGContextBeginTransparencyLayer(context, NULL); {
                            CGContextFillRect(context, runImageBounds);
                            CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
                            CGContextBeginTransparencyLayer(context, NULL); {
                                TextDrawRun(line, run, context, size, isVertical, lineRunRanges[r], verticalOffset);
                            } CGContextEndTransparencyLayer(context);
                        } CGContextEndTransparencyLayer(context);
                    } CGContextEndTransparencyLayer(context);
                } CGContextRestoreGState(context);
                shadow = shadow.subShadow;
            }
        }
    }
    
    CGContextRestoreGState(context);
}

static void TextDrawDebug(TextLayout *layout, CGContextRef context, CGSize size, CGPoint point, TextDebugOption *op) {
    UIGraphicsPushContext(context);
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);
    CGContextSetLineWidth(context, 1.0 / TextScreenScale());
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextSetLineCap(context, kCGLineCapButt);
    
    BOOL isVertical = layout.container.verticalForm;
    CGFloat verticalOffset = isVertical ? (size.width - layout.container.size.width) : 0;
    CGContextTranslateCTM(context, verticalOffset, 0);
    
    if (op.CTFrameBorderColor || op.CTFrameFillColor) {
        UIBezierPath *path = layout.container.path;
        if (!path) {
            CGRect rect = (CGRect){CGPointZero, layout.container.size};
            rect = UIEdgeInsetsInsetRect(rect, layout.container.insets);
            if (op.CTFrameBorderColor) rect = TextCGRectPixelHalf(rect);
            else rect = TextCGRectPixelRound(rect);
            path = [UIBezierPath bezierPathWithRect:rect];
        }
        [path closePath];
        
        for (UIBezierPath *ex in layout.container.exclusionPaths) {
            [path appendPath:ex];
        }
        if (op.CTFrameFillColor) {
            [op.CTFrameFillColor setFill];
            if (layout.container.pathLineWidth > 0) {
                CGContextSaveGState(context); {
                    CGContextBeginTransparencyLayer(context, NULL); {
                        CGContextAddPath(context, path.CGPath);
                        if (layout.container.pathFillEvenOdd) {
                            CGContextEOFillPath(context);
                        } else {
                            CGContextFillPath(context);
                        }
                        CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
                        [[UIColor blackColor] setFill];
                        CGPathRef cgPath = CGPathCreateCopyByStrokingPath(path.CGPath, NULL, layout.container.pathLineWidth, kCGLineCapButt, kCGLineJoinMiter, 0);
                        if (cgPath) {
                            CGContextAddPath(context, cgPath);
                            CGContextFillPath(context);
                        }
                        CGPathRelease(cgPath);
                    } CGContextEndTransparencyLayer(context);
                } CGContextRestoreGState(context);
            } else {
                CGContextAddPath(context, path.CGPath);
                if (layout.container.pathFillEvenOdd) {
                    CGContextEOFillPath(context);
                } else {
                    CGContextFillPath(context);
                }
            }
        }
        if (op.CTFrameBorderColor) {
            CGContextSaveGState(context); {
                if (layout.container.pathLineWidth > 0) {
                    CGContextSetLineWidth(context, layout.container.pathLineWidth);
                }
                [op.CTFrameBorderColor setStroke];
                CGContextAddPath(context, path.CGPath);
                CGContextStrokePath(context);
            } CGContextRestoreGState(context);
        }
    }
    
    NSArray *lines = layout.lines;
    for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
        TextLine *line = lines[l];
        if (layout.truncatedLine && layout.truncatedLine.index == line.index) line = layout.truncatedLine;
        CGRect lineBounds = line.bounds;
        if (op.CTLineFillColor) {
            [op.CTLineFillColor setFill];
            CGContextAddRect(context, TextCGRectPixelRound(lineBounds));
            CGContextFillPath(context);
        }
        if (op.CTLineBorderColor) {
            [op.CTLineBorderColor setStroke];
            CGContextAddRect(context, TextCGRectPixelHalf(lineBounds));
            CGContextStrokePath(context);
        }
        if (op.baselineColor) {
            [op.baselineColor setStroke];
            if (isVertical) {
                CGFloat x = TextCGFloatPixelHalf(line.position.x);
                CGFloat y1 = TextCGFloatPixelHalf(line.top);
                CGFloat y2 = TextCGFloatPixelHalf(line.bottom);
                CGContextMoveToPoint(context, x, y1);
                CGContextAddLineToPoint(context, x, y2);
                CGContextStrokePath(context);
            } else {
                CGFloat x1 = TextCGFloatPixelHalf(lineBounds.origin.x);
                CGFloat x2 = TextCGFloatPixelHalf(lineBounds.origin.x + lineBounds.size.width);
                CGFloat y = TextCGFloatPixelHalf(line.position.y);
                CGContextMoveToPoint(context, x1, y);
                CGContextAddLineToPoint(context, x2, y);
                CGContextStrokePath(context);
            }
        }
        if (op.CTLineNumberColor) {
            [op.CTLineNumberColor set];
            NSMutableAttributedString *num = [[NSMutableAttributedString alloc] initWithString:@(l).description];
            num.foreColor = op.CTLineNumberColor;
            num.font = [UIFont systemFontOfSize:6];
            [num drawAtPoint:CGPointMake(line.position.x, line.position.y - (isVertical ? 1 : 6))];
        }
        if (op.CTRunFillColor || op.CTRunBorderColor || op.CTRunNumberColor || op.CGGlyphFillColor || op.CGGlyphBorderColor) {
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
                CFIndex glyphCount = CTRunGetGlyphCount(run);
                if (glyphCount == 0) continue;
                
                CGPoint glyphPositions[glyphCount];
                CTRunGetPositions(run, CFRangeMake(0, glyphCount), glyphPositions);
                
                CGSize glyphAdvances[glyphCount];
                CTRunGetAdvances(run, CFRangeMake(0, glyphCount), glyphAdvances);
                
                CGPoint runPosition = glyphPositions[0];
                if (isVertical) {
                    YYTEXT_SWAP(runPosition.x, runPosition.y);
                    runPosition.x = line.position.x;
                    runPosition.y += line.position.y;
                } else {
                    runPosition.x += line.position.x;
                    runPosition.y = line.position.y - runPosition.y;
                }
                
                CGFloat ascent, descent, leading;
                CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
                CGRect runTypoBounds;
                if (isVertical) {
                    runTypoBounds = CGRectMake(runPosition.x - descent, runPosition.y, ascent + descent, width);
                } else {
                    runTypoBounds = CGRectMake(runPosition.x, line.position.y - ascent, width, ascent + descent);
                }
                
                if (op.CTRunFillColor) {
                    [op.CTRunFillColor setFill];
                    CGContextAddRect(context, TextCGRectPixelRound(runTypoBounds));
                    CGContextFillPath(context);
                }
                if (op.CTRunBorderColor) {
                    [op.CTRunBorderColor setStroke];
                    CGContextAddRect(context, TextCGRectPixelHalf(runTypoBounds));
                    CGContextStrokePath(context);
                }
                if (op.CTRunNumberColor) {
                    [op.CTRunNumberColor set];
                    NSMutableAttributedString *num = [[NSMutableAttributedString alloc] initWithString:@(r).description];
                    num.foreColor = op.CTRunNumberColor;
                    num.font = [UIFont systemFontOfSize:6];
                    [num drawAtPoint:CGPointMake(runTypoBounds.origin.x, runTypoBounds.origin.y - 1)];
                }
                if (op.CGGlyphBorderColor || op.CGGlyphFillColor) {
                    for (NSUInteger g = 0; g < glyphCount; g++) {
                        CGPoint pos = glyphPositions[g];
                        CGSize adv = glyphAdvances[g];
                        CGRect rect;
                        if (isVertical) {
                            YYTEXT_SWAP(pos.x, pos.y);
                            pos.x = runPosition.x;
                            pos.y += line.position.y;
                            rect = CGRectMake(pos.x - descent, pos.y, runTypoBounds.size.width, adv.width);
                        } else {
                            pos.x += line.position.x;
                            pos.y = runPosition.y;
                            rect = CGRectMake(pos.x, pos.y - ascent, adv.width, runTypoBounds.size.height);
                        }
                        if (op.CGGlyphFillColor) {
                            [op.CGGlyphFillColor setFill];
                            CGContextAddRect(context, TextCGRectPixelRound(rect));
                            CGContextFillPath(context);
                        }
                        if (op.CGGlyphBorderColor) {
                            [op.CGGlyphBorderColor setStroke];
                            CGContextAddRect(context, TextCGRectPixelHalf(rect));
                            CGContextStrokePath(context);
                        }
                    }
                }
            }
        }
    }
    CGContextRestoreGState(context);
    UIGraphicsPopContext();
}


- (void)drawInContext:(nullable CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
                 view:(nullable UIView *)view
                layer:(nullable CALayer *)layer
                debug:(nullable TextDebugOption *)debug
               cancel:(nullable BOOL (^)(void))cancel{
    @autoreleasepool{
        if (self.needDrawBlockBorder && context) {
            if (cancel && cancel()) return;
            TextDrawBlockBorder(self, context, size, point, cancel);
        }
        if (self.needDrawBackgroundBorder && context) {
            if (cancel && cancel()) return;
            TextDrawBorder(self, context, size, point, TextBorderTypeBackgound, cancel);
        }
        if (self.needDrawShadow && context) {
            if (cancel && cancel()) return;
            TextDrawShadow(self, context, size, point, cancel);
        }
        if (self.needDrawUnderline && context) {
            if (cancel && cancel()) return;
            TextDrawDecoration(self, context, size, point, TextDecorationTypeUnderline, cancel);
        }
        if (self.needDrawText && context) {
            if (cancel && cancel()) return;
            TextDrawText(self, context, size, point, cancel);
        }
        if (self.needDrawAttachment && (context || view || layer)) {
            if (cancel && cancel()) return;
            TextDrawAttachment(self, context, size, point, view, layer, cancel);
        }
        if (self.needDrawInnerShadow && context) {
            if (cancel && cancel()) return;
            TextDrawInnerShadow(self, context, size, point, cancel);
        }
        if (self.needDrawStrikethrough && context) {
            if (cancel && cancel()) return;
            TextDrawDecoration(self, context, size, point, TextDecorationTypeStrikethrough, cancel);
        }
        if (self.needDrawBorder && context) {
            if (cancel && cancel()) return;
            TextDrawBorder(self, context, size, point, TextBorderTypeNormal, cancel);
        }
        if (debug.needDrawDebug && context) {
            if (cancel && cancel()) return;
            TextDrawDebug(self, context, size, point, debug);
        }
    }
}
- (void)drawInContext:(CGContextRef)context
                 size:(CGSize)size
                debug:(TextDebugOption *)debug {
    [self drawInContext:context size:size point:CGPointZero view:nil layer:nil debug:debug cancel:nil];
}


- (void)addAttachmentToView:(UIView *)view layer:(CALayer *)layer {
    NSAssert([NSThread isMainThread], @"This method must be called on the main thread");
    [self drawInContext:NULL size:CGSizeZero point:CGPointZero view:view layer:layer debug:nil cancel:nil];
}

- (void)removeAttachmentFromViewAndLayer {
    NSAssert([NSThread isMainThread], @"This method must be called on the main thread");
    for (TextAttachment *a in self.attachments) {
        if ([a.content isKindOfClass:[UIView class]]) {
            UIView *v = a.content;
            [v removeFromSuperview];
        } else if ([a.content isKindOfClass:[CALayer class]]) {
            CALayer *l = a.content;
            [l removeFromSuperlayer];
        }
    }
}





@end