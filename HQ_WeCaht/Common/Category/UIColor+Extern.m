//
//  UIColor+Extern.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "UIColor+Extern.h"

@implementation UIColor (Extern)


+ (UIColor *)randomColor {
    CGFloat red = arc4random_uniform(256) / 255.0;
    CGFloat green = arc4random_uniform(256) / 255.0;
    CGFloat blue = arc4random_uniform(256) / 255.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIColor *)randomColorWithAlpha:(CGFloat)alpha {
    CGFloat red = arc4random_uniform(256) / 255.0;
    CGFloat green = arc4random_uniform(256) / 255.0;
    CGFloat blue = arc4random_uniform(256) / 255.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
+ (instancetype)colorWithHexRGBA:(NSString *)rgba {
    NSAssert([rgba hasPrefix:@"#"], @"颜色字符串要以#开头");
    
    NSString *hexString = [rgba substringFromIndex:1];
    unsigned int hexInt;
    BOOL result = [[NSScanner scannerWithString:hexString] scanHexInt:&hexInt];
    if (!result)
        return nil;
    
    CGFloat divisor = 255.0;
    CGFloat red = ((hexInt & 0xFF000000) >> 24) / divisor;
    CGFloat green   = ((hexInt & 0x00FF0000) >> 16) / divisor;
    CGFloat blue    = ((hexInt & 0x0000FF00) >>  8) / divisor;
    CGFloat alpha   = ( hexInt & 0x000000FF       ) / divisor;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
}

+ (instancetype)colorWithHexARGB:(NSString *)argb {
    NSAssert([argb hasPrefix:@"#"], @"颜色字符串要以#开头");
    
    NSString *hexString = [argb substringFromIndex:1];
    unsigned int hexInt;
    BOOL result = [[NSScanner scannerWithString:hexString] scanHexInt:&hexInt];
    if (!result) {
        return nil;
    }
    
    CGFloat divisor = 255.0;
    CGFloat alpha = ((hexInt & 0xFF000000) >> 24) / divisor;
    CGFloat red   = ((hexInt & 0x00FF0000) >> 16) / divisor;
    CGFloat green    = ((hexInt & 0x0000FF00) >>  8) / divisor;
    CGFloat blue   = ( hexInt & 0x000000FF       ) / divisor;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
}

+ (instancetype)colorWithHexRGB:(NSString *)rgb {
    NSAssert([rgb hasPrefix:@"#"], @"颜色字符串要以#开头");
    
    NSString *hexString = [rgb substringFromIndex:1];
    unsigned int hexInt;
    BOOL result = [[NSScanner scannerWithString:hexString] scanHexInt:&hexInt];
    if (!result) {
        return nil;
    }
    
    CGFloat divisor = 255.0;
    CGFloat red   = ((hexInt & 0x00FF0000) >> 16) / divisor;
    CGFloat green    = ((hexInt & 0x0000FF00) >>  8) / divisor;
    CGFloat blue   = ( hexInt & 0x000000FF       ) / divisor;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
}

//
//+ (BOOL)color:(UIColor *)color1 isEqualToColor:(UIColor *)color2 withTolerance:(CGFloat)tolerance {
//    
//    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
//    [color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
//    [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
//    return
//    fabs(r1 - r2) <= tolerance &&
//    fabs(g1 - g2) <= tolerance &&
//    fabs(b1 - b2) <= tolerance &&
//    fabs(a1 - a2) <= tolerance;
//}
//static BOOL hexStrToRGBA(NSString *str,
//                         CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
//    str = [[str stringByTrim] uppercaseString];
//    if ([str hasPrefix:@"#"]) {
//        str = [str substringFromIndex:1];
//    } else if ([str hasPrefix:@"0X"]) {
//        str = [str substringFromIndex:2];
//    }
//    
//    NSUInteger length = [str length];
//    //         RGB            RGBA          RRGGBB        RRGGBBAA
//    if (length != 3 && length != 4 && length != 6 && length != 8) {
//        return NO;
//    }
//    
//    //RGB,RGBA,RRGGBB,RRGGBBAA
//    if (length < 5) {
//        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0f;
//        *g = hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0f;
//        *b = hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0f;
//        if (length == 4)  *a = hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0f;
//        else *a = 1;
//    } else {
//        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0f;
//        *g = hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0f;
//        *b = hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0f;
//        if (length == 8) *a = hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0f;
//        else *a = 1;
//    }
//    return YES;
//}
//
//+ (UIColor *)colorWithHexString:(NSString *)hexStr {
//    CGFloat r, g, b, a;
//    if (hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
//        return [UIColor colorWithRed:r green:g blue:b alpha:a];
//    }
//    return nil;
//}

@end
