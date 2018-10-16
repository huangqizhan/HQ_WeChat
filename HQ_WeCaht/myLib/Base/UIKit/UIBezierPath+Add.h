//
//  UIBezierPath+Add.h
//  YYKitStudy
//
//  Created by GoodSrc on 2018/1/4.
//  Copyright © 2018年 GoodSrc. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (Add)

/**
 Creates and returns a new UIBezierPath object initialized with the text glyphs
 generated from the specified font.
 
 @discussion It doesnot support apple emoji. If you want get emoji image, try
 [UIImage imageWithEmoji:size:] in `UIImage(YYAdd)`.
 
 @param text The text to generate glyph path.
 @param font The font to generate glyph path.
 
 @return A new path object with the text and font, or nil if an error occurs.
 */
+ (nullable UIBezierPath *)bezierPathWithText:(NSString *)text font:(UIFont *)font;


@end


NS_ASSUME_NONNULL_END
