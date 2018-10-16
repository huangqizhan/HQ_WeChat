//
//  UIFont+Add.m
//  YYKitStudy
//
//  Created by GoodSrc on 2017/12/14.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import "UIFont+Add.h"
#import "Global.h"

YYSSSYNTH_DUMMY_CLASS(UIFont_Add)

///表示去掉没有实现协议的警告       。。。。。。。
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"


@implementation UIFont (Add)


- (BOOL)isBold {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold) > 0;
}

- (BOOL)isItalic {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitItalic) > 0;
}

- (BOOL)isMonoSpace {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitMonoSpace) > 0;
}

- (BOOL)isColorGlyphs {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
    return (CTFontGetSymbolicTraits((__bridge CTFontRef)self) & kCTFontTraitColorGlyphs) != 0;
}
- (CGFloat)fontWeight {
    NSDictionary *traits = [self.fontDescriptor objectForKey:UIFontDescriptorTraitsAttribute];
    return [traits[UIFontWeightTrait] floatValue];
}

- (UIFont *)fontWithBold {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:self.pointSize];
}

- (UIFont *)fontWithItalic {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:self.pointSize];
}

- (UIFont *)fontWithBoldItalic {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic] size:self.pointSize];
}

- (UIFont *)fontWithNormal {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:0] size:self.pointSize];
}
+ (UIFont *)fontWithCTFont:(CTFontRef)CTFont {
    if (!CTFont) return nil;
    CFStringRef name = CTFontCopyPostScriptName(CTFont);
    if (!name) return nil;
    CGFloat size = CTFontGetSize(CTFont);
    UIFont *font = [self fontWithName:(__bridge NSString *)(name) size:size];
    CFRelease(name);
    return font;
}

+ (UIFont *)fontWithCGFont:(CGFontRef)CGFont size:(CGFloat)size {
    if (!CGFont) return nil;
    CFStringRef name = CGFontCopyPostScriptName(CGFont);
    if (!name) return nil;
    UIFont *font = [self fontWithName:(__bridge NSString *)(name) size:size];
    CFRelease(name);
    return font;
}

- (CTFontRef)CTFontRef CF_RETURNS_RETAINED {
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.fontName, self.pointSize, NULL);
    return font;
}

- (CGFontRef)CGFontRef CF_RETURNS_RETAINED {
    CGFontRef font = CGFontCreateWithFontName((__bridge CFStringRef)self.fontName);
    return font;
}




/*
  类的动态配置 和 消息传递
  替换类原来的方法
 + (void)load {
 // 获取替换后的类方法
 Method newMethod = class_getClassMethod([self class], @selector(adjustFont:));
 // 获取替换前的类方法
 Method method = class_getClassMethod([self class], @selector(systemFontOfSize:));
 // 然后交换类方法，交换两个方法的IMP指针，(IMP代表了方法的具体的实现）
 method_exchangeImplementations(newMethod, method);
 }
 
 + (UIFont *)adjustFont:(CGFloat)fontSize {
 UIFont *newFont = nil;
 newFont = [UIFont adjustFont:fontSize * [UIScreen mainScreen].bounds.size.width/MyUIScreen];
 return newFont;
 }
 */


@end

#pragma clang diagnostic pop
