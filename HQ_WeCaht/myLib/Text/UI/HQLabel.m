//
//  HQLabel.m
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/4.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "HQLabel.h"
#import "TextUtilites.h"
#import "TextAsyncLayer.h"
#import "TextWeakProxy.h"
#import "NSAttributedString+Add.h"
#import "TextDebugOption.h"
#import "TextAttribute.h"
#import <libkern/OSAtomic.h>
#import "TextSelecttionView.h"
#import "TextEffectWindow.h"


NSString * const HQLabelDidShowSelectionViewNotification = @"HQLabelDidShowSelectionViewNotification";
NSString * const HQLabelDidHiddenSelectionViewNotification = @"HQLabelDidHiddenSelectionViewNotification";

static dispatch_queue_t HQLabelReleaseQueue(){
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    return queue;
}
///长按自身最小时间
#define kLongPressLabelMinmumDuration 0.5
///长按高亮时间最小值
#define kLongPressMinimumDuration 0.5
///touch move 最小的移动量
#define kLongPressAllowableMovement 9.0
///高亮的动画时间
#define kHighlightFadeDuration 0.15
///异步的动画时间
#define kAsyncFadeDuration 0.08
// Magnifier ranged offset fix.
#define kLabelMagnifierRangedTrackFix -6.0
typedef NS_ENUM (NSUInteger, HQLabelGrabberDirection) {
    kNone  = 0,
    kStart = 1,
    kEnd   = 2,
};


@interface HQLabel()<TextDebugTarget,TextAsyncLayerDelegate>{
    NSMutableAttributedString *_innerText;
    ////布局
    TextLayout *_innerLayout;
    TextContainer *_innerContainer;
    
    ////
    NSMutableArray *_attachmentViews;
    NSMutableArray *_attachmentLayers;
    
    NSRange _highLightRange;
    TextHeightLight *_highLight;
    ///< when _state.showingHighlight=YES, this layout should be displayed
    TextLayout *_highLightLayout;
    
    TextLayout *_shrinkInnerLayout;
    TextLayout *_shrinkHighLightLayout;
    
    NSTimer *_longPressTimer;
    CGPoint _touchBeginPoint;
    ///选中w内容的视图
    TextSelecttionView *_selectionView;
    ///选中范围
    TextRange *_selectedTextRange;
    ///追踪选中区域
    TextRange *_trackingRange;
    CGPoint _trackingPoint;
    struct {
        unsigned int trackingGrabber : 2;
        ///是否更新layout
        unsigned int layoutNeedUpdate : 1;
        ///是否显示高亮
        unsigned int showingHighlight : 1;
        
        ///有点击事件追踪touch
        unsigned int trackingTouch : 1;
        ///touch 已经被吸收 持续响应
        unsigned int swallowTouch : 1;
        unsigned int touchMoved : 1;
        
        ///是否有tap响应事件
        unsigned int hasTapAction : 1;
        ///是否有长按事件
        unsigned int hasLongPressAction : 1;
        
        ///是否包含fade 动画
        unsigned int contentsNeedFade : 1;
        ///是否已经touchend
        unsigned int isToutchEnd : 1;
        ///是否touchcancel
        unsigned int isToucheCancel : 1;
        ///是否正在显示选中视图
        unsigned int isHiddenSelectedView : 1;
    } _state;
    
}


@end

@implementation HQLabel

#pragma mark private

- (void)_updateIfneeded{
    if (_state.layoutNeedUpdate) {
        _state.layoutNeedUpdate = NO;
        [self _updateLayout];
        [self _setLayoutNeedRedraw];
    }
}
///更新layout
- (void)_updateLayout{
    _innerLayout = [TextLayout layoutWithContainer:_innerContainer text:_innerText];
    _shrinkInnerLayout = [self.class _shrinkLayoutWithLayout:_innerLayout];
}
- (void)_setLayoutNeedUpdata{
    _state.layoutNeedUpdate = YES;
    [self _hiddenSelectionView];
    [self _clearInnerLayout];
    [self _setLayoutNeedRedraw];
}
///重绘
- (void)_setLayoutNeedRedraw{
    [self _hiddenSelectionView];
    [self.layer setNeedsDisplay];
}
- (void)_clearInnerLayout{
    if (!_innerLayout) return;
    TextLayout *layout = _innerLayout;
    _innerLayout = nil;
    _shrinkInnerLayout = nil;
    dispatch_async(HQLabelReleaseQueue(), ^{
        ///释放layout 保留属性字符串
        NSAttributedString *att = [layout text];
        dispatch_async(dispatch_get_main_queue(), ^{
            ///属性字符串可能有view 必须在主线程中释放
            [att length];
        });
    });
}
- (TextLayout *)_innerLayout {
    return _shrinkInnerLayout ? _shrinkInnerLayout : _innerLayout;
}

- (TextLayout *)_highlightLayout {
    return _shrinkHighLightLayout ? _shrinkHighLightLayout : _highLightLayout;
}

+ (TextLayout *)_shrinkLayoutWithLayout:(TextLayout *)layout {
    if (layout.text.length && layout.lines.count == 0) {
        TextContainer *container = layout.container.copy;
        container.maximumNumberOfRows = 1;
        CGSize containerSize = container.size;
        if (!container.verticalForm) {
            containerSize.height = textContainerMaxSize.height;
        } else {
            containerSize.width = textContainerMaxSize.width;
        }
        container.size = containerSize;
        return [TextLayout layoutWithContainer:container text:layout.text];
    } else {
        return nil;
    }
}

- (void)_startLongPressTimer {
    [_longPressTimer invalidate];
    _longPressTimer = [NSTimer timerWithTimeInterval:kLongPressLabelMinmumDuration target:[TextWeakProxy proxyWithTarget:self] selector:@selector(_trackDidLongPress) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_longPressTimer forMode:NSRunLoopCommonModes];
}
- (void)_endLongPressTimer{
    [_longPressTimer timeInterval];
    _longPressTimer = nil;
}
- (void)_trackDidLongPress{
    [self _endLongPressTimer];
    if (_state.isToutchEnd ||_state.touchMoved || !self.isLongPressShowSelectionView) {
        return;
    }
    if (_state.hasLongPressAction && self.textLongPressAction) {
        ///用layout 计算text 位置
        NSRange range = NSMakeRange(NSNotFound, 0);
        CGRect rect = CGRectNull;
        CGPoint point = [self _convertPointToLayout:_touchBeginPoint];
        TextRange *textRange = [_innerLayout textRangeAtPoint:point];
        CGRect textRect = [_innerLayout rectForRange:textRange];
        textRect = [self _convertRectFromLayout:textRect];
        if (textRange) {
            range = textRange.asRange;
            rect = textRect;
        }
        if (_textLongPressAction) _textLongPressAction(self,_innerText,range,rect);
    }
    ///高亮
    if (_highLight) {
        TextAction longPressAction = _highLight.longPressAction ? _highLight.longPressAction : _highlightLongPressAction;
        if (longPressAction) {
            TextPosition *start = [TextPosition positionWith:_highLightRange.location];
            TextPosition *end = [TextPosition positionWith:_highLightRange.location + _highLightRange.length];
            TextRange *textRange = [TextRange rangeWithStart:start end:end];
            CGRect textrect = [_innerLayout rectForRange:textRange];
            textrect = [self _convertRectFromLayout:textrect];
            longPressAction(self,_innerText,_highLightRange,textrect);
            [self _removeHighlightAnimated:YES];
            _state.trackingTouch = NO;
        }
    }else{
        ///选中视图
        if (!_state.touchMoved) {
            [self _showSelectionView];
        }
    }
}
- (TextHeightLight *)_getHighlightAtPoint:(CGPoint)point range:(NSRangePointer)range{
    if (!_innerLayout.containsHighlight) return nil;
    point = [self _convertPointToLayout:point];
    TextRange *textRange = [_innerLayout textRangeAtPoint:point];
    if (!textRange) return nil;
    NSUInteger startIndex = textRange.start.offset;
    if (startIndex == _innerText.length) {
        if (startIndex > 0) {
            startIndex --;
        }
    }
    NSRange highlightRange = {0};
    TextHeightLight *highlight = [_innerText attribute:TextHighlightAttributeName atIndex:startIndex longestEffectiveRange:&highlightRange inRange:NSMakeRange(0, _innerText.length)];
    if (!highlight) return nil;
    if (range) *range = highlightRange;
    return highlight;
}
- (void)_showHighlightAnimated:(BOOL)animated{
    if (!_highLight) return;
    if (!_highLightLayout) {
        NSMutableAttributedString *hitText = _innerText.mutableCopy;
        NSDictionary *newAtts = _highLight.attributes;
        [newAtts enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
            [hitText h_setAttribute:key value:value range:self->_highLightRange];
        }];
        _highLightLayout = [TextLayout layoutWithContainer:_innerContainer text:hitText];
        _shrinkHighLightLayout = [self.class _shrinkLayoutWithLayout:_highLightLayout];
        if(!_highLightLayout) _highLight = nil;
    }
    if (_highLightLayout && !_state.showingHighlight) {
        _state.showingHighlight = YES;
        _state.contentsNeedFade = animated;
        [self _setLayoutNeedRedraw];
    }
}
///隐藏高亮
- (void)_hiddenHighlightAnimated:(BOOL)animated{
    if (_state.showingHighlight) {
        _state.showingHighlight = NO;
        _state.contentsNeedFade = animated;
        [self _setLayoutNeedRedraw];
    }
}

///删除高亮
- (void)_removeHighlightAnimated:(BOOL)animated{
    [self _hiddenHighlightAnimated:animated];
    _highLight = nil;
    _highLightLayout = nil;
    _shrinkHighLightLayout = nil;
}
- (void)_endTouch{
    [self _endLongPressTimer];
    [self _removeHighlightAnimated:YES];
    _state.isToutchEnd = YES;
    _state.trackingTouch = NO;
}
///把layout 上的point 转到label 上
- (CGPoint)_convertPointFromLayout:(CGPoint)point{
    CGSize boundingSize = self->_innerLayout.textBoundingSize;
    if (self->_innerLayout.container.isVerticalForm) {
        CGFloat w = self->_innerLayout.textBoundingSize.width;
        if (w < self.bounds.size.width) w = self.bounds.size.width;
        point.x -= self->_innerLayout.container.size.width - w;
        if (boundingSize.width < self.bounds.size.width) {
            if (_textVerticalAlignment == TextVerticalAlignmentCenter) {
                point.x -= (self.bounds.size.width - boundingSize.width) * 0.5;
            } else if (_textVerticalAlignment == TextVerticalAlignmentBottom) {
                point.x -= (self.bounds.size.width - boundingSize.width);
            }
        }
        return point;
    } else {
        if (boundingSize.height < self.bounds.size.height) {
            if (_textVerticalAlignment == TextVerticalAlignmentCenter) {
                point.y += (self.bounds.size.height - boundingSize.height) * 0.5;
            } else if (_textVerticalAlignment == TextVerticalAlignmentBottom) {
                point.y += (self.bounds.size.height - boundingSize.height);
            }
        }
        return point;
    }
}
///把label上的 point 转到 layout 上
- (CGPoint)_convertPointToLayout:(CGPoint)point{
    CGSize boundingSize = self->_innerLayout.textBoundingSize;
    if (self->_innerLayout.container.isVerticalForm) {
        CGFloat w = self->_innerLayout.textBoundingSize.width;
        if (w < self.bounds.size.width) w = self.bounds.size.width;
        point.x += self->_innerLayout.container.size.width - w;
        if (_textVerticalAlignment == TextVerticalAlignmentCenter) {
            point.x += (self.bounds.size.width - boundingSize.width) * 0.5;
        } else if (_textVerticalAlignment == TextVerticalAlignmentBottom) {
            point.x += (self.bounds.size.width - boundingSize.width);
        }
        return point;
    } else {
        if (_textVerticalAlignment == TextVerticalAlignmentCenter) {
            point.y -= (self.bounds.size.height - boundingSize.height) * 0.5;
        } else if (_textVerticalAlignment == TextVerticalAlignmentBottom) {
            point.y -= (self.bounds.size.height - boundingSize.height);
        }
        return point;
    }
}
- (CGRect)_convertRectToLayout:(CGRect)rect{
    rect.origin = [self _convertPointToLayout:rect.origin];
    return rect;
}
- (CGRect)_convertRectFromLayout:(CGRect)rect{
    rect.origin = [self _convertPointFromLayout:rect.origin];
    return rect;
}
- (CGRect)_convertSelectionViewRectFromLayout:(CGRect)rect{
    CGPoint point = rect.origin;
    point = [self convertPoint:point toView:_selectionView];
    rect.origin = point;
    return rect;
}
///分词器(tokenizer)通过 词粒度（granularity） 获取焦点最近的词的范围
- (TextRange *)_getClosestTokenRangeAtPoint:(CGPoint)point {
    point = [self _convertPointToLayout:point];
    TextRange *touchRange = [_innerLayout closestTextRangeAtPoint:point];
    touchRange = [self _correctedTextRange:touchRange];
    
    //    if (_tokenizer && touchRange) {
    //        TextRange *encEnd = (id)[_tokenizer rangeEnclosingPosition:touchRange.end withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionBackward];
    //        TextRange *encStart = (id)[_tokenizer rangeEnclosingPosition:touchRange.start withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionForward];
    //        if (encEnd && encStart) {
    //            NSArray *arr = [@[encEnd.start, encEnd.end, encStart.start, encStart.end] sortedArrayUsingSelector:@selector(compare:)];
    //            touchRange = [TextRange rangeWithStart:arr.firstObject end:arr.lastObject];
    //        }
    //    }
    
    if (touchRange) {
        TextRange *extStart = [_innerLayout textRangeByExtendingPosition:touchRange.start];
        TextRange *extEnd = [_innerLayout textRangeByExtendingPosition:touchRange.end];
        if (extStart && extEnd) {
            NSArray *arr = [@[extStart.start, extStart.end, extEnd.start, extEnd.end] sortedArrayUsingSelector:@selector(compare:)];
            touchRange = [TextRange rangeWithStart:arr.firstObject end:arr.lastObject];
        }
    }
    
    if (!touchRange) touchRange = [TextRange defaultRange];
    
    if (_innerText.length && touchRange.asRange.length == 0) {
        touchRange = [TextRange rangeWithRange:NSMakeRange(0, _innerText.length)];
    }
    
    return touchRange;
}
///校正TextRange  如果超出了边界.
- (TextRange *)_correctedTextRange:(TextRange *)range {
    if (!range) return nil;
    if ([self _isTextRangeValid:range]) return range;
    TextPosition *start = [self _correctedTextPosition:range.start];
    TextPosition *end = [self _correctedTextPosition:range.end];
    return [TextRange rangeWithStart:start end:end];
}
///是否TextRange 有效
- (BOOL)_isTextRangeValid:(TextRange *)range {
    if (![self _isTextPositionValid:range.start]) return NO;
    if (![self _isTextPositionValid:range.end]) return NO;
    return YES;
}
///校正textPosition  如果超出了边界
- (TextPosition *)_correctedTextPosition:(TextPosition *)position {
    if (!position) return nil;
    if ([self _isTextPositionValid:position]) return position;
    if (position.offset < 0) {
        return [TextPosition positionWith:0];
    }
    if (position.offset > _innerText.length) {
        return [TextPosition positionWith:_innerText.length];
    }
    if (position.offset == 0 && position.affinity == TextAffinityBackward) {
        return [TextPosition positionWith:position.offset];
    }
    if (position.offset == _innerText.length && position.affinity == TextAffinityBackward) {
        return [TextPosition positionWith:position.offset];
    }
    return position;
}
///是否textPosition 有效
- (BOOL)_isTextPositionValid:(TextPosition *)position {
    if (!position) return NO;
    if (position.offset < 0) return NO;
    if (position.offset > _innerText.length) return NO;
    if (position.offset == 0 && position.affinity == TextAffinityBackward) return NO;
    if (position.offset == _innerText.length && position.affinity == TextAffinityBackward) return NO;
    return YES;
}
- (UIFont *)_defaultFont{
    return [UIFont systemFontOfSize:17];
}
- (NSShadow *)_shadowFromProperties{
    if (!_shadowColor || _shadowBlurRadius < 0) {
        return nil;
    }
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = _shadowColor;
    shadow.shadowBlurRadius = _shadowBlurRadius;
    shadow.shadowOffset = _shadowOffset;
    return shadow;
}
///更新lineBreakModel
- (void)_updateOuterLineBreakModel{
    if (_innerContainer.truncationType) {
        switch (_innerContainer.truncationType) {
            case TextTruncationTypeStart:
                _lineBreakModel = NSLineBreakByTruncatingHead;
                break;
            case TextTruncationTypeMiddle:
                _lineBreakModel = NSLineBreakByTruncatingMiddle;
                break;
            case TextTruncationTypeEnd:
                _lineBreakModel = NSLineBreakByTruncatingTail;
                break;
            default:
                break;
        }
    }else{
        _lineBreakModel = _innerText.lineBreakMode;
    }
}
- (void)_updateOuterProperties{
    _text = [_innerText plainTextForRange:NSMakeRange(0, _innerText.length)];
    _font = _innerText.font;
    if (!_font) _font = [self _defaultFont];
    _textColor = _innerText.foreColor;
    if(!_textColor) _textColor = [UIColor blackColor];
    _textAlignment = _innerText.aligenment;
    _lineBreakModel = _innerText.lineBreakMode;
    NSShadow *shadow = _innerText.shadow;
    _shadowColor = shadow.shadowColor;
    _shadowOffset = shadow.shadowOffset;
    _shadowBlurRadius = shadow.shadowBlurRadius;
    _attributedText = _innerText;
    [self _updateOuterLineBreakModel];
}
- (void)_updateOuterContainerProperties{
    _truncationToken = _innerContainer.truncationToken;
    _numberOfLines = _innerContainer.maximumNumberOfRows;
    _textContainerPath = _innerContainer.path;
    _exclusionPaths = _innerContainer.exclusionPaths;
    _textContainerInset = _innerContainer.insets;
    _verticalForm = _innerContainer.isVerticalForm;
    _linePositionModifier = _innerContainer.linePositionModifier;
    [self _updateOuterLineBreakModel];
}
///选中区域随着触摸点移动
- (void)_updateTextRangeByTrackingGrabber{
    if (!_state.trackingTouch ) return;
    if (_state.trackingGrabber == kNone) {
        return;
    }
    BOOL isStart = _state.trackingGrabber == kStart;
    CGPoint magPoint = _trackingPoint;
    if (magPoint.y <= kLongPressAllowableMovement) {
        magPoint.y = kLongPressAllowableMovement;
    }
    if (magPoint.y >= self.height) {
        magPoint.y = self.height - kLongPressAllowableMovement;
    }
    NSLog(@"msgPoint = %@",NSStringFromCGPoint(magPoint));
    magPoint.y += kLabelMagnifierRangedTrackFix;
    magPoint = [self _convertPointToLayout:magPoint];
    TextPosition *position = [_innerLayout closestPositionToPoint:magPoint];
    if (position) {
        position = [self _correctedTextPosition:position];
        if ((NSUInteger)position.offset > _innerText.length) {
            position = [TextPosition positionWith:_innerText.length];
        }
        ///original
        TextRange *newRange;
        TextPosition *s , *e;
        if (isStart) {
            if (position.offset <= _selectedTextRange.end.offset) {
                s = position;
                e = _selectedTextRange.end;
            }else{
                s = _selectedTextRange.end;
                e = position;
            }
        }else{
            if (position.offset >= _selectedTextRange.start.offset) {
                s = _selectedTextRange.start;
                e = position;
            }else{
                s = position;
                e = _selectedTextRange.start;
            }
        }
        newRange = [TextRange rangeWithStart:s                    end:e];
        _trackingRange = newRange;
    }
}
///显示选中视图
- (void)_showSelectionView{
    [self _addSelectionView];
    _selectionView.frame = _innerLayout.textBoundingRect;
    _selectionView.hidden = NO;
    _selectionView.selectionRects = nil;
    if (!_innerLayout) return;
    [[TextEffectWindow sharedWindow] showSelectionDot:_selectionView];
    NSMutableArray *allRects = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] postNotificationName:HQLabelDidShowSelectionViewNotification object:self];
    TextRange *range = [TextRange rangeWithStart:[TextPosition positionWith:0] end:[TextPosition positionWith:_innerText.length]];
    _selectedTextRange = _trackingRange = range;
    NSArray *rects = [_innerLayout selectionRectsForRange:range];
    if (rects) [allRects addObjectsFromArray:rects];
    [allRects enumerateObjectsUsingBlock:^(TextSelectionRect *rect, NSUInteger idx, BOOL *stop) {
        CGRect re = [self _convertSelectionViewRectFromLayout:rect.rect];
        rect.rect = re;
    }];
    _state.isHiddenSelectedView = NO;
    _selectionView.selectionRects = allRects;
}
- (void)_addSelectionView{
    _selectionView = [TextSelecttionView shareSelectionView];
    _selectionView.userInteractionEnabled = NO;
    _selectionView.hidden = YES;
    _selectionView.hostView = self;
    _selectionView.color = [self _defaultTintColor];
    [self addSubview:_selectionView];
}
///隐藏选中视图
- (void)_hiddenSelectionView{
    if (_state.isHiddenSelectedView) return;
    _state.isHiddenSelectedView = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:HQLabelDidHiddenSelectionViewNotification object:self];
    [UIView animateWithDuration:0.12 animations:^{
        self->_selectionView.hidden = YES;
    } completion:^(BOOL finished) {
        [self->_selectionView removeFromSuperview];
        self->_selectionView = nil;
    }];
}
///更新选中视图
- (void)_updateSelectionView{
    _selectionView.frame = _innerLayout.textBoundingRect;
    _selectionView.selectionRects = nil;
    _selectionView.caretBlinks = NO;
    _selectionView.caretVisible = NO;
    [[TextEffectWindow sharedWindow] hideSelectionDot:_selectionView];
    if (!_innerLayout) return;
    NSMutableArray *allRects = [NSMutableArray new];
    TextRange *selectedRange = _trackingRange;
    NSArray *rects = [_innerLayout selectionRectsForRange:selectedRange];;
    if (rects) [allRects addObjectsFromArray:rects];
    [allRects enumerateObjectsUsingBlock:^(TextSelectionRect *selectionRect, NSUInteger idx, BOOL * _Nonnull stop) {
        selectionRect.rect = [self _convertSelectionViewRectFromLayout:selectionRect.rect];
    }];
    _selectionView.selectionRects = allRects;
}
///更新提前选中的区域
- (void)_updateTextRangeByTrackingPreSelect {
    if (!_state.trackingTouch) return;
    TextRange *newRange = [self _getClosestTokenRangeAtPoint:_trackingPoint];
    _trackingRange = newRange;
}
- (void)_clearContens{
    CGImageRef cgimage = (__bridge_retained CGImageRef)self.constraints;
    self.layer.contents = nil;
    if (cgimage) {
        dispatch_async(HQLabelReleaseQueue(), ^{
            CGImageRelease(cgimage);
        });
    }
}
- (void)_initLabel{
    ((TextAsyncLayer *)self.layer).displaysAsynchronously = NO;
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.contentMode = UIViewContentModeRedraw;
    _attachmentViews = [NSMutableArray new];
    _attachmentLayers = [NSMutableArray new];
    
    _font = [self _defaultFont];
    _debugOption = [TextDebugOption sharedDebugOption];
    [TextDebugOption addDebugTarget:self];
    
    _textColor = [UIColor blackColor];
    _textVerticalAlignment = TextVerticalAlignmentCenter;
    _numberOfLines = 1;
    _textAlignment = NSTextAlignmentNatural;
    _lineBreakModel = NSLineBreakByTruncatingTail;
    _innerText = [NSMutableAttributedString new];
    _innerContainer = [TextContainer new];
    _innerContainer.truncationType = TextTruncationTypeEnd;
    _innerContainer.maximumNumberOfRows = _numberOfLines;
    _clearContentsBeforeAsynchronouslyDisplay = YES;
    _fadeOnAsynchronouslyDisplay = YES;
    _fadeOnHighlight = YES;
    ///voice over
    self.isAccessibilityElement = YES;
    
//    _selectionView = [TextSelecttionView shareSelectionView];
//    _selectionView.userInteractionEnabled = NO;
//    _selectionView.hidden = YES;
//    _selectionView.hostView = self;
//    _selectionView.color = [self _defaultTintColor];
//    [self addSubview:_selectionView];
    _state.isHiddenSelectedView = YES;
}
#pragma mark ------ public  method
- (void)removeSelectionView{
    [self _hiddenSelectionView];
}
#pragma mark ------ override
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    if (!self) return nil;
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    [self _initLabel];
    self.frame = frame;
    return self;
}
- (void)dealloc{
    [TextDebugOption removeDebugTarget:self];
    [self _endLongPressTimer];
}
///重写label 的 layer
+ (Class)layerClass{
    return [TextAsyncLayer class];
}
- (void)setFrame:(CGRect)frame{
    CGSize oldSize = self.frame.size;
    [super setFrame:frame];
    CGSize newSize = self.frame.size;
    if (!CGSizeEqualToSize(newSize, oldSize)) {
        _innerContainer.size = self.frame.size;
        if (!_ignoreCommonProperties) {
            _state.layoutNeedUpdate = YES;
        }
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedRedraw];
    }
}
- (void)setBounds:(CGRect)bounds{
    CGSize oldSize = self.frame.size;
    [super setBounds:bounds];
    CGSize newSize = self.frame.size;
    if (!CGSizeEqualToSize(newSize, oldSize)) {
        _innerContainer.size = self.frame.size;
        if (!_ignoreCommonProperties) {
            _state.layoutNeedUpdate = YES;
        }
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedRedraw];
    }
}
- (CGSize)sizeThatFits:(CGSize)size{
    if (_ignoreCommonProperties) {
        return _innerLayout.textBoundingSize;
    }
    if (!_verticalForm && size.width <= 0) {
        size.width = textContainerMaxSize.width;
    }
    if (_verticalForm && size.height <= 0) {
        size.height = textContainerMaxSize.height;
    }
    if ((!_verticalForm && size.width == self.frame.size.width) || (_verticalForm && size.height == self.frame.size.height)) {
        [self _updateIfneeded];
        TextLayout *layout = _innerLayout;
        BOOL contains = NO;
        if (layout.container.maximumNumberOfRows == 0) {
            if (layout.truncatedLine == nil) {
                contains = YES;
            }
        }else{
            if (layout.rowCount <= layout.container.maximumNumberOfRows) {
                contains = YES;
            }
        }
    }
    if (!_verticalForm) {
        size.height = textContainerMaxSize.height;
    }else{
        size.width = textContainerMaxSize.width;
    }
    TextContainer *container = [_innerContainer copy];
    container.size = size;
    
    TextLayout *onelayout = [TextLayout layoutWithContainer:container text:_innerText];
    return onelayout.textBoundingSize;
}
///voice over
- (NSString *)accessibilityLabel{
    return [_innerLayout.text plainTextForRange:_innerLayout.text.rangeOfAll];
}

#pragma mark  coding
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_attributedText forKey:@"attributedText"];
    [aCoder encodeObject:_innerContainer forKey:@"innerContainer"];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self _initLabel];
    TextContainer *innerContainer = [aDecoder decodeObjectForKey:@"innerContainer"];
    if (innerContainer) {
        _innerContainer = innerContainer;
    } else {
        _innerContainer.size = self.bounds.size;
    }
    [self _updateOuterContainerProperties];
    self.attributedText = [aDecoder decodeObjectForKey:@"attributedText"];
    [self _setLayoutNeedUpdata];
    return self;
}
#pragma mark ---- touches ------
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self _updateIfneeded];
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    _highLight = [self _getHighlightAtPoint:point range:&_highLightRange];
    _highLightLayout = nil;
    _shrinkInnerLayout = nil;
    _touchBeginPoint = point;
    _state.hasTapAction = _textTapAction != nil;
    _state.hasLongPressAction = _textLongPressAction != nil;
    _state.isToutchEnd = NO;
    if (_highLight || _textLongPressAction || _textTapAction) {
        _state.trackingTouch = YES;
        _state.swallowTouch = YES;
        _state.touchMoved = NO;
        ///longTapAction
        [self _startLongPressTimer];
        if (_highLight) [self _showHighlightAnimated:YES];
    }else{
        if (!_state.isHiddenSelectedView){
            _state.trackingTouch = YES;
            _state.swallowTouch = YES;
            point = [self convertPoint:point toView:_selectionView];
            if ([_selectionView isStartGrabberContainsPoint:point]) {
                _state.trackingGrabber = kStart;
            }else if ([_selectionView isEndGrabberContainsPoint:point]){
                _state.trackingGrabber = kEnd;
            }else{
                _state.trackingGrabber = kNone;
            }
        }else{
            ///选中视图
            _state.trackingTouch = YES;
            if (self.isLongPressShowSelectionView) {
                [self _startLongPressTimer];
            }
        }
        _state.touchMoved = NO;
    }
    if (!_state.swallowTouch) {
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self _updateIfneeded];
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    _state.isToutchEnd = NO;
    _trackingPoint = point;
    if (_state.trackingTouch) {
        if (!_state.touchMoved) {
            CGFloat moveH = point.x - _touchBeginPoint.x;
            CGFloat moveV = point.y - _touchBeginPoint.y;
            if (fabs(moveH) > fabs(moveV)) {
                if(fabs(moveH) > kLongPressAllowableMovement)
                    _state.touchMoved = YES;
            }else{
                if(fabs(moveV) > kLongPressAllowableMovement)
                    _state.touchMoved = YES;
            }
        }
        if (_state.touchMoved) {
            [self _endLongPressTimer];
        }
        if (_state.touchMoved && _highLight) {
            TextHeightLight *highLight = [self _getHighlightAtPoint:point range:NULL];
            if (highLight == _highLight) {
                [self _showHighlightAnimated:YES];
            }else{
                [self _hiddenHighlightAnimated:YES];
            }
        }else if (!_state.isHiddenSelectedView){
            [self _updateTextRangeByTrackingGrabber];
            [self _updateSelectionView];
        }
    }
    if (!_state.swallowTouch) {
        [super touchesMoved:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    _state.isToutchEnd = YES;
    if (_state.trackingTouch) {
        [self _endLongPressTimer];
        if (!_state.touchMoved && _textTapAction) {
            NSRange range = NSMakeRange(NSNotFound, 0);
            CGRect rect = CGRectNull;
            CGPoint point = [self _convertPointToLayout:_touchBeginPoint];
            TextRange *textRange = [_innerLayout textRangeAtPoint:point];
            CGRect textRect = [_innerLayout rectForRange:textRange];
            textRect = [self _convertRectFromLayout:textRect];
            if (textRange) {
                range = textRange.asRange;
                rect = textRect;
            } _textTapAction(self,_innerText,range,rect);
        }
        if (_highLight) {
            if (!_state.touchMoved || ([self _getHighlightAtPoint:point range:NULL] == _highLight)) {
                TextAction textAction = _highLight.tapAction ? _highLight.tapAction : _highlightTapAction;
                if (textAction) {
                    TextPosition *start = [TextPosition positionWith:_highLightRange.location];
                    TextPosition *end = [TextPosition positionWith:_highLightRange.location + _highLightRange.length];
                    TextRange *textRange = [TextRange rangeWithStart:start end:end];
                    CGRect textRect = [_innerLayout rectForRange:textRange];
                    textRect = [self _convertRectFromLayout:textRect];
                    textAction(self,_innerText,_highLightRange,textRect);
                }
            }
            [self _removeHighlightAnimated:YES];
        }else{
            if (!_state.isHiddenSelectedView) {
                _selectedTextRange = _trackingRange;
            }
        }
    }
    if (!_state.swallowTouch) {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self _endTouch];
    if (!_state.swallowTouch) {
        [super touchesEnded:touches withEvent:event];
    } }
- (BOOL)canBecomeFirstResponder{
    return YES;
}
- (BOOL)becomeFirstResponder{
    return YES;
}
- (BOOL)canResignFirstResponder{
    return YES;
}
- (BOOL)resignFirstResponder{
    return YES;
}
#pragma mark ------ properties ----
- (void)setText:(NSString *)text{
    if ([_text isEqualToString:text] || _text == text) return;
    _text = text.copy;
    BOOL needAddAttribute = _innerText.length == 0 && _text.length > 0;
    [_innerText replaceCharactersInRange:NSMakeRange(0, _innerText.length) withString:_text?:@""];
    [_innerText h_removeDiscontinuousAttributesInRange:NSMakeRange(0, _innerText.length)];
    if (needAddAttribute) {
        _innerText.font = _font;
        _innerText.foreColor = _textColor;
        _innerText.shadow = [self _shadowFromProperties];
        _innerText.aligenment = _textAlignment;
        switch (_lineBreakModel) {
            case NSLineBreakByWordWrapping:
            case NSLineBreakByCharWrapping:
            case NSLineBreakByClipping: {
                _innerText.lineBreakMode = _lineBreakModel;
            } break;
            case NSLineBreakByTruncatingHead:
            case NSLineBreakByTruncatingTail:
            case NSLineBreakByTruncatingMiddle: {
                _innerText.lineBreakMode = NSLineBreakByWordWrapping;
            } break;
            default: break;
        }
    }
    if ([_textParser parseText:_innerText selectedRange:NULL]) {
        [self _updateOuterProperties];
    }
    if (!_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
        [self _endTouch];
        ///UIKit 内容改变
        [self invalidateIntrinsicContentSize];
    }
}
- (void)setFont:(UIFont *)font {
    if (!font) {
        font = [self _defaultFont];
    }
    if (_font == font || [_font isEqual:font]) return;
    _font = font;
    _innerText.font = _font;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (!textColor) {
        textColor = [UIColor blackColor];
    }
    if (_textColor == textColor || [_textColor isEqual:textColor]) return;
    _textColor = textColor;
    _innerText.foreColor = textColor;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
    }
}

- (void)setShadowColor:(UIColor *)shadowColor {
    if (_shadowColor == shadowColor || [_shadowColor isEqual:shadowColor]) return;
    _shadowColor = shadowColor;
    _innerText.shadow = [self _shadowFromProperties];
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
    }
}
- (void)setShadowOffset:(CGSize)shadowOffset {
    if (CGSizeEqualToSize(_shadowOffset, shadowOffset)) return;
    _shadowOffset = shadowOffset;
    _innerText.shadow = [self _shadowFromProperties];
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
    }
}
- (void)setShadowBlurRadius:(CGFloat)shadowBlurRadius {
    if (_shadowBlurRadius == shadowBlurRadius) return;
    _shadowBlurRadius = shadowBlurRadius;
    _innerText.shadow = [self _shadowFromProperties];
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
    }
}
- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (_textAlignment == textAlignment) return;
    _textAlignment = textAlignment;
    _innerText.aligenment = textAlignment;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (_lineBreakModel == lineBreakMode) return;
    _lineBreakModel = lineBreakMode;
    _innerText.lineBreakMode = lineBreakMode;
    // allow multi-line break
    switch (lineBreakMode) {
        case NSLineBreakByWordWrapping:
        case NSLineBreakByCharWrapping:
        case NSLineBreakByClipping: {
            _innerContainer.truncationType = TextTruncationTypeNone;
            _innerText.lineBreakMode = lineBreakMode;
        } break;
        case NSLineBreakByTruncatingHead:{
            _innerContainer.truncationType = TextTruncationTypeStart;
            _innerText.lineBreakMode = NSLineBreakByWordWrapping;
        } break;
        case NSLineBreakByTruncatingTail:{
            _innerContainer.truncationType = TextTruncationTypeEnd;
            _innerText.lineBreakMode = NSLineBreakByWordWrapping;
        } break;
        case NSLineBreakByTruncatingMiddle: {
            _innerContainer.truncationType = TextTruncationTypeMiddle;
            _innerText.lineBreakMode = NSLineBreakByWordWrapping;
        } break;
        default: break;
    }
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTextVerticalAlignment:(TextVerticalAlignment)textVerticalAlignment {
    if (_textVerticalAlignment == textVerticalAlignment) return;
    _textVerticalAlignment = textVerticalAlignment;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTruncationToken:(NSAttributedString *)truncationToken {
    if (_truncationToken == truncationToken || [_truncationToken isEqual:truncationToken]) return;
    _truncationToken = truncationToken.copy;
    _innerContainer.truncationToken = truncationToken;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    if (_numberOfLines == numberOfLines) return;
    _numberOfLines = numberOfLines;
    _innerContainer.maximumNumberOfRows = numberOfLines;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (attributedText.length > 0) {
        _innerText = attributedText.mutableCopy;
        switch (_lineBreakModel) {
            case NSLineBreakByWordWrapping:
            case NSLineBreakByCharWrapping:
            case NSLineBreakByClipping: {
                _innerText.lineBreakMode = _lineBreakModel;
            } break;
            case NSLineBreakByTruncatingHead:
            case NSLineBreakByTruncatingTail:
            case NSLineBreakByTruncatingMiddle: {
                _innerText.lineBreakMode = NSLineBreakByWordWrapping;
            } break;
            default: break;
        }
    } else {
        _innerText = [NSMutableAttributedString new];
    }
    [_textParser parseText:_innerText selectedRange:NULL];
    if (!_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _updateOuterProperties];
        [self _setLayoutNeedUpdata];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}
- (void)setTextContainerPath:(UIBezierPath *)textContainerPath {
    if (_textContainerPath == textContainerPath || [_textContainerPath isEqual:textContainerPath]) return;
    _textContainerPath = textContainerPath.copy;
    _innerContainer.path = textContainerPath;
    if (!_textContainerPath) {
        _innerContainer.size = self.bounds.size;
        _innerContainer.insets = _textContainerInset;
    }
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setExclusionPaths:(NSArray *)exclusionPaths {
    if (_exclusionPaths == exclusionPaths || [_exclusionPaths isEqual:exclusionPaths]) return;
    _exclusionPaths = exclusionPaths.copy;
    _innerContainer.exclusionPaths = exclusionPaths;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    if (UIEdgeInsetsEqualToEdgeInsets(_textContainerInset, textContainerInset)) return;
    _textContainerInset = textContainerInset;
    _innerContainer.insets = textContainerInset;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setVerticalForm:(BOOL)verticalForm {
    if (_verticalForm == verticalForm) return;
    _verticalForm = verticalForm;
    _innerContainer.verticalForm = verticalForm;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setLinePositionModifier:(id<TextLinePositionModifier>)linePositionModifier {
    if (_linePositionModifier == linePositionModifier) return;
    _linePositionModifier = linePositionModifier;
    _innerContainer.linePositionModifier = linePositionModifier;
    if (_innerText.length && !_ignoreCommonProperties) {
        if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
            [self _clearContens];
        }
        [self _setLayoutNeedUpdata];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTextParser:(id<TextParser>)textParser {
    if (_textParser == textParser || [_textParser isEqual:textParser]) return;
    _textParser = textParser;
    if ([_textParser parseText:_innerText selectedRange:NULL]) {
        [self _updateOuterProperties];
        if (!_ignoreCommonProperties) {
            if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
                [self _clearContens];
            }
            [self _setLayoutNeedUpdata];
            [self _endTouch];
            [self invalidateIntrinsicContentSize];
        }
    }
}
- (void)setTextLayout:(TextLayout *)textLayout {
    _innerLayout = textLayout;
    _shrinkInnerLayout = nil;
    
    if (_ignoreCommonProperties) {
        _innerText = (NSMutableAttributedString *)textLayout.text;
        _innerContainer = textLayout.container.copy;
    } else {
        _innerText = textLayout.text.mutableCopy;
        if (!_innerText) {
            _innerText = [NSMutableAttributedString new];
        }
        [self _updateOuterProperties];
        
        _innerContainer = textLayout.container.copy;
        if (!_innerContainer) {
            _innerContainer = [TextContainer new];
            _innerContainer.size = self.bounds.size;
            _innerContainer.insets = self.textContainerInset;
        }
        [self _updateOuterContainerProperties];
    }
    
    if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
        [self _clearContens];
    }
    _state.layoutNeedUpdate = NO;
    [self _setLayoutNeedRedraw];
    [self _endTouch];
    [self invalidateIntrinsicContentSize];
}

- (TextLayout *)textLayout {
    [self _updateIfneeded];
    return _innerLayout;
}

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously {
    _displaysAsynchronously = displaysAsynchronously;
    ((TextAsyncLayer *)self.layer).displaysAsynchronously = displaysAsynchronously;
}
- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    if (_preferredMaxLayoutWidth == preferredMaxLayoutWidth) return;
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    [self invalidateIntrinsicContentSize];
}
#pragma mark -----over ride autolayout
- (CGSize)intrinsicContentSize {
    if (_preferredMaxLayoutWidth == 0) {
        TextContainer *container = [_innerContainer copy];
        container.size = textContainerMaxSize;
        
        TextLayout *layout = [TextLayout layoutWithContainer:container text:_innerText];
        return layout.textBoundingSize;
    }
    
    CGSize containerSize = _innerContainer.size;
    if (!_verticalForm) {
        containerSize.height = textContainerMaxSize.height;
        containerSize.width = _preferredMaxLayoutWidth;
        if (containerSize.width == 0) containerSize.width = self.bounds.size.width;
    } else {
        containerSize.width = textContainerMaxSize.width;
        containerSize.height = _preferredMaxLayoutWidth;
        if (containerSize.height == 0) containerSize.height = self.bounds.size.height;
    }
    
    TextContainer *container = [_innerContainer copy];
    container.size = containerSize;
    
    TextLayout *layout = [TextLayout layoutWithContainer:container text:_innerText];
    return layout.textBoundingSize;
}

#pragma mark ------- TextDebugOption  ----
- (void)setDebugOption:(TextDebugOption *)debugOption {
    BOOL needDraw = _debugOption.needDrawDebug;
    _debugOption = debugOption.copy;
    if (_debugOption.needDrawDebug != needDraw) {
        [self _setLayoutNeedRedraw];
    }
}
#pragma mark ------- TextAsyncLayerDelegate
- (nonnull TextAsyncLayerDisplayTask *)newTextAsyncLayerDisplayTask {
    BOOL contentNeedFade  = _state.contentsNeedFade;
    NSAttributedString *text = _innerText;
    TextContainer *container = _innerContainer;
    TextVerticalAlignment verticalAlignment = _textVerticalAlignment;
    TextDebugOption *debugOption = _debugOption;
    
    NSMutableArray *attachLayers = _attachmentLayers;
    NSMutableArray *attachViews = _attachmentViews;
    BOOL layoutNeedUpdate = _state.layoutNeedUpdate;
    BOOL fadeForAsync = _displaysAsynchronously && _fadeOnAsynchronouslyDisplay;
    __block TextLayout *textLayout = (_state.showingHighlight && _highLightLayout) ? _highLightLayout : _innerLayout;
    __block TextLayout *shrinkLayout = nil;
    __block BOOL layoutUpdated = NO;
    if (layoutUpdated) {
        text = text.copy;
        container = container.copy;
    }
    TextAsyncLayerDisplayTask *task = [TextAsyncLayerDisplayTask new];
    task.willDisplay = ^(CALayer * _Nonnull layer) {
        [layer removeAnimationForKey:@"contents"];
        for (UIView *view in attachViews) {
            if (layoutNeedUpdate || ![textLayout.attachmentContentsSet containsObject:view]) {
                if (view.superview == self ) {
                    [view removeFromSuperview];
                }
            }
        }
        
        for (CALayer *layer in attachLayers) {
            if (layoutNeedUpdate || ![textLayout.attachmentContentsSet containsObject:layer]) {
                if (layer.superlayer == self.layer) {
                    [layer removeFromSuperlayer];
                }
            }
        }
        [attachViews removeAllObjects];
        [attachLayers removeAllObjects];
    };
    task.display = ^(CGContextRef  _Nonnull context, CGSize size, BOOL (^ _Nonnull isCancel)(void)) {
        if (isCancel()) return ;
        if (text.length == 0) return;
        TextLayout *drawLayout = textLayout;
        if (layoutNeedUpdate) {
            textLayout = [TextLayout layoutWithContainer:container text:text];
            shrinkLayout = [self.class _shrinkLayoutWithLayout:textLayout];
            if (isCancel()) return;
            layoutUpdated = YES;
            drawLayout = shrinkLayout ? shrinkLayout : textLayout;
        }
        CGSize boundingSize = drawLayout.textBoundingSize;
        CGPoint point = CGPointZero;
        if (verticalAlignment == TextVerticalAlignmentCenter) {
            if (drawLayout.container.isVerticalForm) {
                point.x = -(size.width - boundingSize.width) * 0.5;
            } else {
                point.y = (size.height - boundingSize.height) * 0.5;
            }
        } else if (verticalAlignment == TextVerticalAlignmentBottom) {
            if (drawLayout.container.isVerticalForm) {
                point.x = -(size.width - boundingSize.width);
            } else {
                point.y = (size.height - boundingSize.height);
            }
        }
        point = TextCGPointPixelRound(point);
        [drawLayout drawInContext:context size:size point:point view:nil layer:nil debug:debugOption cancel:isCancel];
    };
    task.didDisplay = ^(CALayer * _Nonnull layer, BOOL isFinish) {
        TextLayout *drawLayout = textLayout;
        if (layoutUpdated && shrinkLayout) {
            drawLayout = shrinkLayout;
        }
        if (!isFinish) {
            for (TextAttachment *a in drawLayout.attachments) {
                if ([a.content isKindOfClass:[UIView class]]) {
                    if (((UIView *)a.content).superview == layer.delegate) {
                        [((UIView *)a.content) removeFromSuperview];
                    }
                } else if ([a.content isKindOfClass:[CALayer class]]) {
                    if (((CALayer *)a.content).superlayer == layer) {
                        [((CALayer *)a.content) removeFromSuperlayer];
                    }
                }
            }
            return ;
        }
        [layer removeAnimationForKey:@"contents"];
        __strong HQLabel *view = (HQLabel *) layer.delegate;
        if (view->_state.layoutNeedUpdate && layoutUpdated) {
            view->_innerLayout = textLayout;
            view->_shrinkInnerLayout = shrinkLayout;
            view->_state.layoutNeedUpdate = NO;
        }
        CGSize size = layer.bounds.size;
        CGSize boundingSize = drawLayout.textBoundingSize;
        CGPoint point = CGPointZero;
        if (verticalAlignment == TextVerticalAlignmentCenter) {
            if (drawLayout.container.isVerticalForm) {
                point.x = -(size.width - boundingSize.width) * 0.5;
            } else {
                point.y = (size.height - boundingSize.height) * 0.5;
            }
        } else if (verticalAlignment == TextVerticalAlignmentBottom) {
            if (drawLayout.container.isVerticalForm) {
                point.x = -(size.width - boundingSize.width);
            } else {
                point.y = (size.height - boundingSize.height);
            }
        }
        point = TextCGPointPixelRound(point);
        [drawLayout drawInContext:nil size:size point:point view:view layer:layer debug:nil cancel:NULL];
        for (TextAttachment *a in drawLayout.attachments) {
            if ([a.content isKindOfClass:[UIView class]]) [attachViews addObject:a.content];
            else if ([a.content isKindOfClass:[CALayer class]]) [attachLayers addObject:a.content];
        }
        if (contentNeedFade) {
            CATransition *transition = [CATransition animation];
            transition.duration = kHighlightFadeDuration;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            transition.type = kCATransitionFade;
            [layer addAnimation:transition forKey:@"contents"];
        } else if (fadeForAsync) {
            CATransition *transition = [CATransition animation];
            transition.duration = kAsyncFadeDuration;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            transition.type = kCATransitionFade;
            [layer addAnimation:transition forKey:@"contents"];
        }
    };
    return task;
}

- (UIColor *)_defaultTintColor {
    return [UIColor redColor];
}

@end


