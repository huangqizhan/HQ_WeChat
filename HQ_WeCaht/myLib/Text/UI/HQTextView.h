//
//  HQTextView.h
//  YYStudyDemo
//
//  Created by hqz on 2018/9/8.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextParser.h"
#import "TextLayout.h"
#import "TextAttribute.h"

NS_ASSUME_NONNULL_BEGIN

/*
 */

///HQTextView NotificationName

UIKIT_EXTERN NSString *const HQTextViewTextDidBeginEditingNotification;
UIKIT_EXTERN NSString *const HQTextViewTextDidChangeNotification;
UIKIT_EXTERN NSString *const HQTextViewTextDidEndEditingNotification;

@class HQTextView;

@protocol HQTextViewDelegate <NSObject, UIScrollViewDelegate>
@optional
- (BOOL)textViewShouldBeginEditing:(HQTextView *)textView;
- (BOOL)textViewShouldEndEditing:(HQTextView *)textView;
- (void)textViewDidBeginEditing:(HQTextView *)textView;
- (void)textViewDidEndEditing:(HQTextView *)textView;
- (BOOL)textView:(HQTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(HQTextView *)textView;
- (void)textViewDidChangeSelection:(HQTextView *)textView;

- (BOOL)textView:(HQTextView *)textView shouldTapHighlight:(TextHeightLight *)highlight inRange:(NSRange)characterRange;
- (void)textView:(HQTextView *)textView didTapHighlight:(TextHeightLight *)highlight inRange:(NSRange)characterRange rect:(CGRect)rect;
- (BOOL)textView:(HQTextView *)textView shouldLongPressHighlight:(TextHeightLight *)highlight inRange:(NSRange)characterRange;
- (void)textView:(HQTextView *)textView didLongPressHighlight:(TextHeightLight *)highlight inRange:(NSRange)characterRange rect:(CGRect)rect;
@end

@interface HQTextView : UIScrollView<UITextInput>


@property (nullable, nonatomic, weak) id<HQTextViewDelegate> delegate;
@property (null_resettable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, strong) UIFont *font;
@property (nullable, nonatomic, strong) UIColor *textColor;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) TextVerticalAlignment textVerticalAlignment;
///输入类型检测
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;
///链接 属性  (非编辑状态)
@property (nullable, nonatomic, copy) NSDictionary<NSString *, id> *linkTextAttributes;
///高亮属性 (非编辑状态)
@property (nullable, nonatomic, copy) NSDictionary<NSString *, id> *highlightTextAttributes;

@property (nullable, nonatomic, copy) NSDictionary<NSString *, id> *typingAttributes;

@property (nullable, nonatomic, copy) NSAttributedString *attributedText;

@property (nullable, nonatomic, strong) id<TextParser> textParser;

@property (nullable, nonatomic, strong, readonly) TextLayout *textLayout;

#pragma mark ---- placeHolder -------
@property (nullable, nonatomic, copy) NSString *placeholderText;
@property (nullable, nonatomic, strong) UIFont *placeholderFont;
@property (nullable, nonatomic, strong) UIColor *placeholderTextColor;
@property (nullable, nonatomic, copy) NSAttributedString *placeholderAttributedText;

#pragma mark ------ 容器  container  -----
@property (nonatomic) UIEdgeInsets textContainerInset;
@property (nullable, nonatomic, copy) NSArray<UIBezierPath *> *exclusionPaths;
@property (nonatomic, getter=isVerticalForm) BOOL verticalForm;
////自定义修改
@property (nullable, nonatomic, copy) id<TextLinePositionModifier> linePositionModifier;
///测试
@property (nullable, nonatomic, copy) TextDebugOption *debugOption;


- (void)scrollRangeToVisible:(NSRange)range;
@property (nonatomic) NSRange selectedRange;
/**
 A Boolean value indicating whether inserting text replaces the previous contents.
 The default value is NO.
 */
@property (nonatomic) BOOL clearsOnInsertion;
///是否可选择
@property (nonatomic, getter=isSelectable) BOOL selectable;

@property (nonatomic, getter=isHighlightable) BOOL highlightable;

@property (nonatomic, getter=isEditable) BOOL editable;
////是否可以粘贴图片
@property (nonatomic) BOOL allowsPasteImage;
///是否粘贴属性字符串
@property (nonatomic) BOOL allowsPasteAttributedString;
///是否复制属性字符串
@property (nonatomic) BOOL allowsCopyAttributedString;
///undo  redo
@property (nonatomic) BOOL allowsUndoAndRedo;
///undo  redo   max num
@property (nonatomic) NSUInteger maximumUndoLevel;

///自定义的键盘
@property (nullable, nonatomic, readwrite, strong) __kindof UIView *inputView;
///键盘顶部的视图
@property (nullable, nonatomic, readwrite, strong) __kindof UIView *inputAccessoryView;
///键盘顶部的视图高度
@property (nonatomic) CGFloat extraAccessoryViewHeight;



@end

NS_ASSUME_NONNULL_END
