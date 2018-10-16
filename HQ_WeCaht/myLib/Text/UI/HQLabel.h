//
//  HQLabel.h
//  YYStudyDemo
//
//  Created by hqz on 2018/9/4.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextParser.h"
#import "TextLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface HQLabel : UIView<NSCoding>

///text
@property (nullable,nonatomic,copy) NSString *text;
///font
@property (null_resettable,nonatomic,strong) UIFont *font;
///textColor
@property (null_resettable,nonatomic,strong) UIColor *textColor;
///shadownColor
@property (nullable,nonatomic,strong) UIColor *shadowColor;
///shadowOffet
@property (nonatomic) CGSize shadowOffset;
///shadowRedioud
@property (nonatomic) CGFloat shadowBlurRadius;
///水平方式对齐方式
@property (nonatomic) NSTextAlignment textAlignment;
///垂直方式的对齐方式
@property (nonatomic) TextVerticalAlignment textVerticalAlignment;
///属性字符串
@property (nullable,nonatomic,copy) NSAttributedString *attributedText;
///截断类型
@property (nonatomic) NSLineBreakMode lineBreakModel;
///截断值
@property (nullable, nonatomic, copy) NSAttributedString *truncationToken;
///行数
@property (nonatomic) NSUInteger numberOfLines;
///解析器
@property (nullable,nonatomic,strong) id <TextParser>textParser;
///布局
@property (nullable,nonatomic,strong) TextLayout *textLayout;

#pragma mark text Container
///contatiner path
@property (nullable,nonatomic,copy) UIBezierPath *textContainerPath;
/// an array of  container path
@property (nullable, nonatomic, copy) NSArray<UIBezierPath *> *exclusionPaths;
///container UIEdgeset
@property (nonatomic) UIEdgeInsets textContainerInset;
///CJK(中韩日) 排版
@property (nonatomic ,getter=isVerticalForm) BOOL verticalForm;
///修改行的位置的实例
@property (nullable,nonatomic,copy) id<TextLinePositionModifier>linePositionModifier;
///测试
@property (nonatomic,nullable,copy) TextDebugOption *debugOption;

#pragma mark --- Constraints

@property (nonatomic) CGFloat preferredMaxLayoutWidth;

#pragma mark ----- Action ----

///tap
@property (nullable, nonatomic,copy) TextAction textTapAction;

///longpress
@property (nullable, nonatomic,copy) TextAction textLongPressAction;

///hightlight tap
@property (nullable , nonatomic ,copy) TextAction highlightTapAction;
///hightlight longpress aciton
@property (nullable , nonatomic, copy) TextAction highlightLongPressAction;
///double tap aciton
@property (nullable, nonatomic, copy) TextAction doubleTapAction;


#pragma mark   diaplay
///异步绘制 default no
@property (nonatomic) BOOL displaysAsynchronously;
///在异步绘制之前 清空layer 的 contents   default yes
@property (nonatomic) BOOL clearContentsBeforeAsynchronouslyDisplay;
///fade 动画显示
@property (nonatomic) BOOL fadeOnAsynchronouslyDisplay;
///高亮的时候是否 fade 动画显示
@property (nonatomic) BOOL fadeOnHighlight;
///是否忽略一般的属性
@property (nonatomic) BOOL ignoreCommonProperties;


@end

NS_ASSUME_NONNULL_END
