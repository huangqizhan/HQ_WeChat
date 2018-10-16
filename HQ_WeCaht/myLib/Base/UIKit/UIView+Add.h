//
//  UIView+Add.h
//  YYKitStudy
//
//  Created by GoodSrc on 2017/12/14.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Add)

///屏幕快照
- (UIImage *)snapshotImage;
- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

///PDF data
- (NSData *)snapshotPDF;

///设置阴影
- (void)setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;

///移除所有子视图
- (void)removeAllSubviews;

///获取当前控制器
- (UIViewController *)viewController;

///当前可见的透明度
- (CGFloat)visibleAlpha;

////convert
- (CGPoint)convertPoint:(CGPoint)point toViewOrWindow:(UIView *)view;
- (CGPoint)convertPoint:(CGPoint)point fromViewOrWindow:(UIView *)view;
- (CGRect)convertRect:(CGRect)rect toViewOrWindow:(UIView *)view ;
- (CGRect)convertRect:(CGRect)rect fromViewOrWindow:(UIView *)view ;




@property (nonatomic) CGFloat left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  size;        ///< Shortcut for frame.size.

@end


NS_ASSUME_NONNULL_END
