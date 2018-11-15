//
//  TextDebugOption.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/3.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TextDebugOption;

////调试观察的回调
@protocol TextDebugTarget <NSObject>

- (void)setDebugOption:(TextDebugOption *)option;

@end



@interface TextDebugOption : NSObject <NSCopying>

@property (nullable, nonatomic, strong) UIColor *baselineColor;      ///< baseline color
@property (nullable, nonatomic, strong) UIColor *CTFrameBorderColor; ///< CTFrame path border color
@property (nullable, nonatomic, strong) UIColor *CTFrameFillColor;   ///< CTFrame path fill color
@property (nullable, nonatomic, strong) UIColor *CTLineBorderColor;  ///< CTLine bounds border color
@property (nullable, nonatomic, strong) UIColor *CTLineFillColor;    ///< CTLine bounds fill color
@property (nullable, nonatomic, strong) UIColor *CTLineNumberColor;  ///< CTLine line number color
@property (nullable, nonatomic, strong) UIColor *CTRunBorderColor;   ///< CTRun bounds border color
@property (nullable, nonatomic, strong) UIColor *CTRunFillColor;     ///< CTRun bounds fill color
@property (nullable, nonatomic, strong) UIColor *CTRunNumberColor;   ///< CTRun number color
@property (nullable, nonatomic, strong) UIColor *CGGlyphBorderColor; ///< CGGlyph bounds border color
@property (nullable, nonatomic, strong) UIColor *CGGlyphFillColor;   ///< CGGlyph bounds fill color

- (BOOL)needDrawDebug; ///< `YES`: at least one debug color is visible. `NO`: all debug color is invisible/nil.
- (void)clear; ///< Set all debug color to nil.

///设置调试条件
+ (void)setSharedDebugOption:(nullable TextDebugOption *)option;
///添加观察者
+ (void)addDebugTarget:(id<TextDebugTarget>)target;
///移除观察者
+ (void)removeDebugTarget:(id<TextDebugTarget>)target;
///
+ (nullable TextDebugOption *)sharedDebugOption;


@end


NS_ASSUME_NONNULL_END
