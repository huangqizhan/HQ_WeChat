//
//  UIFont+Add.h
//  YYKitStudy
//
//  Created by GoodSrc on 2017/12/14.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (Add)<NSCoding>

///粗体
@property (nonatomic,readonly) BOOL isBold NS_AVAILABLE_IOS(7_0);
//斜体
@property (nonatomic,readonly) BOOL isItalic NS_AVAILABLE_IOS(7_0);
///等款字体
@property (nonatomic,readonly) BOOL isMonoSpace NS_AVAILABLE_IOS(7_0);
///颜色符号
@property (nonatomic,readonly) BOOL isColorGlyphs NS_AVAILABLE_IOS(7_0);
///字体粗细 -1.0 -------- 1.0
@property (nonatomic,readonly) CGFloat fontWeight NS_AVAILABLE_IOS(7_0);


/**
 Create a bold font from receiver.
 @return A bold font, or nil if failed.
 */
- (nullable UIFont *)fontWithBold NS_AVAILABLE_IOS(7_0);

/**
 Create a italic font from receiver.
 @return A italic font, or nil if failed.
 */
- (nullable UIFont *)fontWithItalic NS_AVAILABLE_IOS(7_0);

/**
 Create a bold and italic font from receiver.
 @return A bold and italic font, or nil if failed.
 */
- (nullable UIFont *)fontWithBoldItalic NS_AVAILABLE_IOS(7_0);

/**
 Create a normal (no bold/italic/...) font from receiver.
 @return A normal font, or nil if failed.
 */
- (nullable UIFont *)fontWithNormal NS_AVAILABLE_IOS(7_0);



#pragma mark - Create font
///=============================================================================
/// @name Create font
///=============================================================================

/**
 Creates and returns a font object for the specified CTFontRef.
 
 @param CTFont  CoreText font.
 */
+ (nullable UIFont *)fontWithCTFont:(CTFontRef)CTFont;

/**
 Creates and returns a font object for the specified CGFontRef and size.
 
 @param CGFont  CoreGraphic font.
 @param size    Font size.
 */
+ (nullable UIFont *)fontWithCGFont:(CGFontRef)CGFont size:(CGFloat)size;

/**
 Creates and returns the CTFontRef object. (need call CFRelease() after used)
 */
- (nullable CTFontRef)CTFontRef CF_RETURNS_RETAINED;

/**
 Creates and returns the CGFontRef object. (need call CFRelease() after used)
 */
- (nullable CGFontRef)CGFontRef CF_RETURNS_RETAINED;


@end


NS_ASSUME_NONNULL_END
