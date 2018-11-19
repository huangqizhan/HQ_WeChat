//
//  TextSelecttionView.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/8/14.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextAttribute.h"
#import "TextInput.h"


NS_ASSUME_NONNULL_BEGIN


@interface TextSelecttionGrabberDot : UIView
///镜子
@property (nonatomic, strong) UIView *mirror;
@end






@interface TextSelectionGrabber : UIView

@property (nonatomic, readonly) TextSelecttionGrabberDot *dot; ///< the dot view
@property (nonatomic) TextDirection dotDirection;         ///< don't support composite direction
@property (nullable, nonatomic, strong) UIColor *color;     ///< tint color, default is nil
@end


@interface TextSelecttionView : UIView

+ (instancetype)shareSelectionView;

@property (nullable, nonatomic, weak) UIView *hostView; ///< the holder view
@property (nullable, nonatomic, strong) UIColor *color; ///< the tint color
///插入点是否活跃
@property (nonatomic, getter = isCaretBlinks) BOOL caretBlinks;
///插入点是否可见
@property (nonatomic, getter = isCaretVisible) BOOL caretVisible;
@property (nonatomic, getter = isVerticalForm) BOOL verticalForm;

@property (nonatomic) CGRect caretRect; ///< caret rect (width==0 or height==0)
@property (nullable, nonatomic, copy) NSArray<TextSelectionRect *> *selectionRects; ///< default is nil

@property (nonatomic, readonly) UIView *caretView;
@property (nonatomic, readonly) TextSelectionGrabber *startGrabber;
@property (nonatomic, readonly) TextSelectionGrabber *endGrabber;

///显示menuController 的rect
@property (nonatomic,assign) CGRect menuRect;

- (BOOL)isGrabberContainsPoint:(CGPoint)point;
- (BOOL)isStartGrabberContainsPoint:(CGPoint)point;
- (BOOL)isEndGrabberContainsPoint:(CGPoint)point;
- (BOOL)isCaretContainsPoint:(CGPoint)point;
- (BOOL)isSelectionRectsContainsPoint:(CGPoint)point;

@end


NS_ASSUME_NONNULL_END
