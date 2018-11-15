//
//  TextUtilites.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/8/6.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <CoreFoundation/CoreFoundation.h>


#ifndef YYTEXT_SWAP // 交换两个值 
#define YYTEXT_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif

#ifndef YYTEXT_CLAMP // 返回中间值
#define YYTEXT_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif

//// 判断一个字符 是否是换行
static inline BOOL TextIsLinebreakChar(unichar c) {
    switch (c) {
        case 0x000D:
        case 0x2028:
        case 0x000A:
        case 0x2029:
            return YES;
        default:
            return NO;
    }
}
//// 判断字符串是否是 换行符
static inline BOOL TextIsLinebreakString(NSString * _Nullable str) {
    if (str.length > 2 || str.length == 0) return NO;
    if (str.length == 1) {
        unichar c = [str characterAtIndex:0];
        return TextIsLinebreakChar(c);
    } else {
        return ([str characterAtIndex:0] == '\r') && ([str characterAtIndex:1] == '\n');
    }
}
///末尾是不是有换行符
static inline NSUInteger TextLinebreakTailLength(NSString * _Nullable str) {
    if (str.length >= 2) {
        unichar c2 = [str characterAtIndex:str.length - 1];
        if (TextIsLinebreakChar(c2)) {
            unichar c1 = [str characterAtIndex:str.length - 2];
            if (c1 == '\r' && c2 == '\n') return 2;
            else return 1;
        } else {
            return 0;
        }
    } else if (str.length == 1) {
        return TextIsLinebreakChar([str characterAtIndex:0]) ? 1 : 0;
    } else {
        return 0;
    }
}
/// 字符串检测类型 转换
static inline NSTextCheckingType TextNSTextCheckingTypeFromUIDataDetectorType(UIDataDetectorTypes types) {
    
    NSTextCheckingType t = 0;
    if (types & UIDataDetectorTypePhoneNumber) t |= NSTextCheckingTypePhoneNumber;
    if (types & UIDataDetectorTypeLink) t |= NSTextCheckingTypeLink;
    if (types & UIDataDetectorTypeAddress) t |= NSTextCheckingTypeAddress;
    if (types & UIDataDetectorTypeCalendarEvent) t |= NSTextCheckingTypeDate;
    return t;
}
///字体是否是 AppleColorEmoji
static inline BOOL TextUIFontIsEmoji(UIFont *font) {
    return [font.fontName isEqualToString:@"AppleColorEmoji"];
}
///coreText
static inline BOOL TextCTFontIsEmoji(CTFontRef font) {
    BOOL isEmoji = NO;
    CFStringRef name = CTFontCopyPostScriptName(font);
    if (name && CFEqual(CFSTR("AppleColorEmoji"), name)) isEmoji = YES;
    if (name) CFRelease(name);
    return isEmoji;
}
////coreGraphics
static inline BOOL TextCGFontIsEmoji(CGFontRef font) {
    BOOL isEmoji = NO;
    CFStringRef name = CGFontCopyPostScriptName(font);
    if (name && CFEqual(CFSTR("AppleColorEmoji"), name)) isEmoji = YES;
    if (name) CFRelease(name);
    return isEmoji;
}

////CTFont 是否包含 颜色位图的字形
static inline BOOL TextCTFontContainsColorBitmapGlyphs(CTFontRef font) {
    return  (CTFontGetSymbolicTraits(font) & kCTFontTraitColorGlyphs) != 0;
}

////带有字形的字体是否是位图
static inline BOOL YYTextCGGlyphIsBitmap(CTFontRef font, CGGlyph glyph) {
    if (!font && !glyph) return NO;
    if (!TextCTFontContainsColorBitmapGlyphs(font)) return NO;
    CGPathRef path = CTFontCreatePathForGlyph(font, glyph, NULL);
    if (path) {
        CFRelease(path);
        return NO;
    }
    return YES;
}

////字体大小  升序调整
static inline CGFloat TextEmojiGetAscentWithFontSize(CGFloat fontSize) {
    if (fontSize < 16) {
        return 1.25 * fontSize;
    } else if (16 <= fontSize && fontSize <= 24) {
        return 0.5 * fontSize + 12;
    } else {
        return fontSize;
    }
}
////字体大小  降序调整
static inline CGFloat TextEmojiGetDescentWithFontSize(CGFloat fontSize) {
    if (fontSize < 16) {
        return 0.390625 * fontSize;
    } else if (16 <= fontSize && fontSize <= 24) {
        return 0.15625 * fontSize + 3.75;
    } else {
        return 0.3125 * fontSize;
    }
    return 0;
}
/////根据字体大小 获取字体rect
static inline CGRect YYTextEmojiGetGlyphBoundingRectWithFontSize(CGFloat fontSize) {
    CGRect rect;
    rect.origin.x = 0.75;
    rect.size.width = rect.size.height = TextEmojiGetAscentWithFontSize(fontSize);
    if (fontSize < 16) {
        rect.origin.y = -0.2525 * fontSize;
    } else if (16 <= fontSize && fontSize <= 24) {
        rect.origin.y = 0.1225 * fontSize -6;
    } else {
        rect.origin.y = -0.1275 * fontSize;
    }
    return rect;
}


////垂直格式的字符集
extern NSCharacterSet *TextVerticalFormRotateCharacterSet(void);

extern NSCharacterSet *TextVerticalFormRotateAndMoveCharacterSet(void);



/// Convert degrees to radians.
static inline CGFloat TextDegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

/// Convert radians to degrees.
static inline CGFloat TextRadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
}

/*
 CGAffineTransform  是一个三位矩阵的参数结构     包含 平移   放缩  旋转
 
 当前视图的锚点（x,y）  乘以一个三维矩阵 得到一个新的坐标   三维矩阵的每一个项代表不同的作用  需要用数学公式推导
 
 当需平移视图时  ：
 当前坐标 (x,y,0)  乘以  三位矩阵 {}
  保证   x1 = x + tx;  y1 = y + ty;
 只需要 tx，ty  此时其他值都0
 */
#pragma mark -----  CGAffineTransform  相关的值
//// 根据起始值计算当前的旋转角度 （弧度）
static inline CGFloat TextCGAffineTransformGetRotation(CGAffineTransform transform) {
    return atan2(transform.b, transform.a);
}
//// 根据起始值计算当前 scale.x
static inline CGFloat TextCGAffineTransformGetScaleX(CGAffineTransform transform) {
    return  sqrt(transform.a * transform.a + transform.c * transform.c);
}
//// 根据起始值计算当前 scale.y
static inline CGFloat TextCGAffineTransformGetScaleY(CGAffineTransform transform) {
    return sqrt(transform.b * transform.b + transform.d * transform.d);
}
//// 根据起始值计算当前  translate.x
static inline CGFloat YYTextCGAffineTransformGetTranslateX(CGAffineTransform transform) {
    return transform.tx;
}
//// 根据起始值计算当前 translate.y
static inline CGFloat YYTextCGAffineTransformGetTranslateY(CGAffineTransform transform) {
    return transform.ty;
}

//// 同一个CGAffineTransform  做完变换之后的状态和变换之前的状态 对应的3对CGPoint  就可以计算出原始的CGAffineTransform

CGAffineTransform TextCGAffineTransformGetFromPoints(CGPoint before[3], CGPoint after[3]);


////  view1 到view2的 CGAffineTransform

CGAffineTransform TextCGAffineTransformGetFromViews(UIView *from, UIView *to);

////创建一个倾斜度
static inline CGAffineTransform TextCGAffineTransformMakeSkew(CGFloat x, CGFloat y){
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform.c = -x;
    transform.b = y;
    return transform;
}
//方向的 UIEdgeInsets
static inline UIEdgeInsets TextUIEdgeInsetsInvert(UIEdgeInsets insets) {
    return UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right);
}




///重力感应
UIViewContentMode TextCAGravityToUIViewContentMode(NSString *gravity);

NSString *TextUIViewContentModeToCAGravity(UIViewContentMode contentMode);

/// Returns a rectangle to fit the `rect` with specified content mode.
CGRect TextCGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode);
////rect 的中心点
static inline CGPoint TextCGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}
///rect 面积
static inline CGFloat TextCGRectGetArea(CGRect rect) {
    if (CGRectIsNull(rect)) return 0;
    rect = CGRectStandardize(rect);
    return rect.size.width * rect.size.height;
}

/// 两点距离
static inline CGFloat TextCGPointGetDistanceToPoint(CGPoint p1, CGPoint p2) {
    return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}
///点到矩形的最短距离
static inline CGFloat TextCGPointGetDistanceToRect(CGPoint p, CGRect r) {
    r = CGRectStandardize(r);
    if (CGRectContainsPoint(r, p)) return 0;
    CGFloat distV, distH;
    if (CGRectGetMinY(r) <= p.y && p.y <= CGRectGetMaxY(r)) {
        distV = 0;
    } else {
        distV = p.y < CGRectGetMinY(r) ? CGRectGetMinY(r) - p.y : p.y - CGRectGetMaxY(r);
    }
    if (CGRectGetMinX(r) <= p.x && p.x <= CGRectGetMaxX(r)) {
        distH = 0;
    } else {
        distH = p.x < CGRectGetMinX(r) ? CGRectGetMinX(r) - p.x : p.x - CGRectGetMaxX(r);
    }
    return MAX(distV, distH);
}
CGFloat TextScreenScale(void) ;
CGSize TextScreenSize(void);

///点转成像素
static inline CGFloat TextCGFloatToPixel(CGFloat value) {
    return value * TextScreenScale();
}
/// 像素转成点
static inline CGFloat TextCGFloatFromPixel(CGFloat value) {
    return value / TextScreenScale();
}

///像素向下取值
static inline CGFloat TextCGFloatPixelFloor(CGFloat value) {
    CGFloat scale = TextScreenScale();
    return floor(value * scale) / scale;
}
/// 像素向上取值
static inline CGFloat TextCGFloatPixelCeil(CGFloat value) {
    CGFloat scale = TextScreenScale();
    return ceil(value * scale) / scale;
}
/// 像素 四舍五入
static inline CGFloat TextCGFloatPixelRound(CGFloat value) {
    CGFloat scale = TextScreenScale();
    return round(value * scale) / scale;
}

/// 像素向上取值
static inline CGFloat TextCGFloatPixelHalf(CGFloat value) {
    CGFloat scale = TextScreenScale();
    return (floor(value * scale) + 0.5) / scale;
}


/// 点转像素 向下取整
static inline CGPoint TextCGPointPixelFloor(CGPoint point) {
    CGFloat scale = TextScreenScale();
    return CGPointMake(floor(point.x * scale) / scale,
                       floor(point.y * scale) / scale);
}

/// 点转像素 四舍五入
static inline CGPoint TextCGPointPixelRound(CGPoint point) {
    CGFloat scale = TextScreenScale();
    return CGPointMake(round(point.x * scale) / scale,
                       round(point.y * scale) / scale);
}

/// 点转像素 向上取整
static inline CGPoint TextCGPointPixelCeil(CGPoint point) {
    CGFloat scale = TextScreenScale();
    return CGPointMake(ceil(point.x * scale) / scale,
                       ceil(point.y * scale) / scale);
}


/// 点转像素  取大值
static inline CGPoint TextCGPointPixelHalf(CGPoint point) {
    CGFloat scale = TextScreenScale();
    return CGPointMake((floor(point.x * scale) + 0.5) / scale,
                       (floor(point.y * scale) + 0.5) / scale);
}

/// size 向下取整
static inline CGSize TextCGSizePixelFloor(CGSize size) {
    CGFloat scale = TextScreenScale();
    return CGSizeMake(floor(size.width * scale) / scale,
                      floor(size.height * scale) / scale);
}

/// size 四舍五入
static inline CGSize TextCGSizePixelRound(CGSize size) {
    CGFloat scale = TextScreenScale();
    return CGSizeMake(round(size.width * scale) / scale,
                      round(size.height * scale) / scale);
}

/// size  ceil
static inline CGSize TextCGSizePixelCeil(CGSize size) {
    CGFloat scale = TextScreenScale();
    return CGSizeMake(ceil(size.width * scale) / scale,
                      ceil(size.height * scale) / scale);
}

///size  取大值
static inline CGSize TextCGSizePixelHalf(CGSize size) {
    CGFloat scale = TextScreenScale();
    return CGSizeMake((floor(size.width * scale) + 0.5) / scale,
                      (floor(size.height * scale) + 0.5) / scale);
}


/// rect 向下取整
static inline CGRect TextCGRectPixelFloor(CGRect rect) {
    CGPoint origin = TextCGPointPixelCeil(rect.origin);
    CGPoint corner = TextCGPointPixelFloor(CGPointMake(rect.origin.x + rect.size.width,
                                                         rect.origin.y + rect.size.height));
    CGRect ret = CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
    if (ret.size.width < 0) ret.size.width = 0;
    if (ret.size.height < 0) ret.size.height = 0;
    return ret;
}

/// rect 四舍五入
static inline CGRect TextCGRectPixelRound(CGRect rect) {
    CGPoint origin = TextCGPointPixelRound(rect.origin);
    CGPoint corner = TextCGPointPixelRound(CGPointMake(rect.origin.x + rect.size.width,
                                                         rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// rect 向上取整
static inline CGRect TextCGRectPixelCeil(CGRect rect) {
    CGPoint origin = TextCGPointPixelFloor(rect.origin);
    CGPoint corner = TextCGPointPixelCeil(CGPointMake(rect.origin.x + rect.size.width,
                                                        rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// rect  四舍五入
static inline CGRect TextCGRectPixelHalf(CGRect rect) {
    CGPoint origin = TextCGPointPixelHalf(rect.origin);
    CGPoint corner = TextCGPointPixelHalf(CGPointMake(rect.origin.x + rect.size.width,
                                                        rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}
//// UIEdgeInsets 向下取整
static inline UIEdgeInsets TextUIEdgeInsetPixelFloor(UIEdgeInsets insets) {
    insets.top = TextCGFloatPixelFloor(insets.top);
    insets.left = TextCGFloatPixelFloor(insets.left);
    insets.bottom = TextCGFloatPixelFloor(insets.bottom);
    insets.right = TextCGFloatPixelFloor(insets.right);
    return insets;
}

/// UIEdgeInsets 向上取整
static inline UIEdgeInsets TextUIEdgeInsetPixelCeil(UIEdgeInsets insets) {
    insets.top = TextCGFloatPixelCeil(insets.top);
    insets.left = TextCGFloatPixelCeil(insets.left);
    insets.bottom = TextCGFloatPixelCeil(insets.bottom);
    insets.right = TextCGFloatPixelCeil(insets.right);
    return insets;
}
static inline UIFont * _Nullable TextFontWithBold(UIFont *font) {
    if (![font respondsToSelector:@selector(fontDescriptor)]) return font;
    return [UIFont fontWithDescriptor:[font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:font.pointSize];
}
static inline UIFont * _Nullable TextFontWithItalic(UIFont *font) {
    if (![font respondsToSelector:@selector(fontDescriptor)]) return font;
    return [UIFont fontWithDescriptor:[font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize];
}
static inline UIFont * _Nullable TextFontWithBoldItalic(UIFont *font) {
    if (![font respondsToSelector:@selector(fontDescriptor)]) return font;
    return [UIFont fontWithDescriptor:[font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic] size:font.pointSize];
}

/**
   CFRange ->  NSRange
 */
static inline NSRange TextNSRangeFromCFRange(CFRange range) {
    return NSMakeRange(range.location, range.length);
}

/**
 NSRange -> CFRange
 */
static inline CFRange TextCFRangeFromNSRange(NSRange range) {
    return CFRangeMake(range.location, range.length);
}

/// app  扩展
BOOL TextIsAppExtension(void);

UIApplication *TextSharedApplication(void);


// main screen's scale
#ifndef kScreenScale
#define kScreenScale YYScreenScale()
#endif

// main screen's size (portrait)
#ifndef kScreenSize
#define kScreenSize YYScreenSize()
#endif

// main screen's width (portrait)
#ifndef kScreenWidth
#define kScreenWidth YYScreenSize().width
#endif

// main screen's height (portrait)
#ifndef kScreenHeight
#define kScreenHeight YYScreenSize().height
#endif
