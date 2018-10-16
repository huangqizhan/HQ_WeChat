//
//  NSAttributedString+Add.m
//  YYStudyDemo
//
//  Created by hqz on 2018/8/7.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "NSAttributedString+Add.h"
#import "TextArchive.h"
#import "NSParagraphStyle+Add.h"
#import "TextUtilites.h"


@interface NSAttributedString_Add : NSObject @end
@implementation NSAttributedString_Add  @end

static double DeviceSystemVersion() {
    static double version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion.doubleValue;
    });
    return version;
}

#ifndef kSystemVersion
#define kSystemVersion DeviceSystemVersion()
#endif

#ifndef kiOS6Later
#define kiOS6Later (kSystemVersion >= 6)
#endif

#ifndef kiOS7Later
#define kiOS7Later (kSystemVersion >= 7)
#endif

#ifndef kiOS8Later
#define kiOS8Later (kSystemVersion >= 8)
#endif

#ifndef kiOS9Later
#define kiOS9Later (kSystemVersion >= 9)
#endif

@implementation NSAttributedString (Add)

- (NSData *)archiveToData{
    NSData *data = nil;
    @try{
        data = [TextArchive archivedDataWithRootObject:self];
    }
    @catch(NSException *ex){
        NSLog(@"ex = %@",ex);
    }
    return data;
}

+ (instancetype)unarchiveFromData:(NSData *)data{
    NSAttributedString *att = nil;
    @try{
        att = [TextUnarchiver unarchiveObjectWithData:data];
    }
    @catch(NSException *ex){
        NSLog(@"ex = %@",ex);
    }
    return att;
}
- (NSDictionary *)attributesAtIndex:(NSUInteger)index{
    if (index > self.length || self.length == 0) {
        return nil;
    }
    if (self.length > 0 && self.length == index) {
        index --;
    }
    return [self attributesAtIndex:index effectiveRange:NULL];
}

- (id)attribut:(NSString *)attributeName atIndex:(NSUInteger)index{
    if (attributeName.length == 0) return nil;
    if (index > self.length || self.length == 0) return nil;
    if (self.length > 0 && self.length == index)
        index --;
    return [self attribute:attributeName atIndex:index effectiveRange:NULL];
}
- (NSDictionary <NSString * , id>*)attributes{
   return [self attributesAtIndex:0];
}
- (UIFont *)font{
    return [self fontAtIndex:0];
}
- (UIFont *)fontAtIndex:(NSUInteger)index{
    UIFont *font = [self attribut:NSFontAttributeName atIndex:0];
    if (kSystemVersion <= 6) {
        if (font) {
            if (CFGetTypeID((__bridge CFTypeRef)font) == CTFontGetTypeID()) {
                CTFontRef ctf = (__bridge CTFontRef)font;
                CFStringRef fname = CTFontCopyPostScriptName(ctf);
                CGFloat fsize = CTFontGetSize(ctf);
                if (fname == nil) {
                    font = nil;
                }else{
                    font = [UIFont fontWithName:(__bridge NSString *)fname size:fsize];
                }
            }
        }
    }
    return font;
}
- (NSNumber *)kern{
   return [self kernAtIndex:0];
}
- (NSNumber *)kernAtIndex:(NSUInteger)index{
    return [self attribut:NSKernAttributeName atIndex:index];
}

- (UIColor *)foreColor{
    return [self foreColorAtIndex:0];
}
- (UIColor *)foreColorAtIndex:(NSUInteger)index{
    UIColor *color = [self attribut:NSForegroundColorAttributeName atIndex:index];
    if (!color) {
        CGColorRef col = (__bridge CGColorRef)[self attribut:(NSString *)kCTForegroundColorAttributeName atIndex:index];
        color = [UIColor colorWithCGColor:col];
    }
    if (color && ![color isKindOfClass:[UIColor class]]) {
        if (CFGetTypeID((__bridge CGColorRef)color) == CGColorGetTypeID()) {
            color = [UIColor colorWithCGColor:(__bridge CGColorRef)color];
        }else{
            color = nil;
        }
    }
    return color;
}
- (UIColor *)backGroundColor{
    return [self backGroundColorAtIndex:0];
}
- (UIColor *)backGroundColorAtIndex:(NSUInteger)index{
    return [self attribut:NSBackgroundColorAttributeName atIndex:index];
}

- (NSNumber *)strokeWidth{
    return [self strokeWidthAtIndex:0];
}
- (NSNumber *)strokeWidthAtIndex:(NSUInteger)index{
    return [self attribut:NSStrokeWidthAttributeName atIndex:index];
}

- (UIColor *)strokeColor{
    return [self strokeColorAtIndex:0];
}
- (UIColor *)strokeColorAtIndex:(NSUInteger)index{
    UIColor *color = [self attribut:NSStrokeColorAttributeName atIndex:index];
    if (!color) {
        CGColorRef cgcol = (__bridge CGColorRef) [self attribut:(NSString *)kCTStrokeColorAttributeName atIndex:index];
        color = [UIColor colorWithCGColor:cgcol];
    }
    return color;
}

- (NSShadow *)shadow{
    return [self shadowAtIndex:0];
}
- (NSShadow *)shadowAtIndex:(NSUInteger)index{
    NSShadow *shadow = [self attribut:NSShadowAttributeName atIndex:index];
    return shadow;
}
- (NSUnderlineStyle)strikethroughStyle{
    return [self strikethroughStyleAtIndex:0];
}
- (NSUnderlineStyle)strikethroughStyleAtIndex:(NSUInteger)index{
    NSNumber *strike = [self attribut:NSStrikethroughColorAttributeName atIndex:index];
    return strike.integerValue;
}
- (UIColor *)strikethroughColor{
    return [self strikethroughColorAtIndex:0];
}
- (UIColor *)strikethroughColorAtIndex:(NSUInteger)index{
    if (kSystemVersion >= 7) {
        return [self attribut:NSStrikethroughColorAttributeName atIndex:index];
    }
    return nil;
}

- (NSUnderlineStyle)underlineStyle{
    return [self underlineStyleAtIndex:0];
}
- (NSUnderlineStyle)underlineStyleAtIndex:(NSUInteger)index{
    NSNumber *strike = [self attribut:NSUnderlineStyleAttributeName atIndex:index];
    return strike.integerValue;
}
- (UIColor *)underLineColor{
    return [self underLineColorAtIndex:0];
}
- (UIColor *)underLineColorAtIndex:(NSUInteger)index{
    UIColor *color = [self attribut:NSUnderlineStyleAttributeName atIndex:index];
    if (!color) {
        CGColorRef cgcol = (__bridge CGColorRef)[self attribut:(NSString *)kCTUnderlineColorAttributeName atIndex:index];
        color = [UIColor colorWithCGColor:cgcol];
    }
    return color;
}
- (NSNumber *)ligature{
    return [self ligatureAtIndex:0];
}
- (NSNumber *)ligatureAtIndex:(NSUInteger)index{
    return [self attribut:NSLigatureAttributeName atIndex:index];
}

- (NSString *)textEffectName{
    return [self textEffectNameAtIndex:0];
}
- (NSString *)textEffectNameAtIndex:(NSUInteger)index{
    return [self attribut:NSTextEffectAttributeName atIndex:index];
}
- (NSNumber *)obliqueness{
    return [self obliquenessAtIndex:0];
}
- (NSNumber *)obliquenessAtIndex:(NSUInteger)index{
    return [self attribut:NSObliquenessAttributeName atIndex:index];
}
- (NSNumber *)expansion{
    return [self expansionAtIndex:0];
}
- (NSNumber *)expansionAtIndex:(NSUInteger)index{
    return [self attribut:NSExpansionAttributeName atIndex:index];
}
- (NSNumber *)baseLineOffset{
    return [self baseLineOffsetAtIndex:0];
}
- (NSNumber *)baseLineOffsetAtIndex:(NSUInteger)index{
    return [self attribut:NSBaselineOffsetAttributeName atIndex:index];
}
- (BOOL)verticalGlyphForm{
    return [self verticalGlyphFormAtIndex:0];
}
- (BOOL)verticalGlyphFormAtIndex:(NSUInteger)index{
    NSNumber *num = [self attribut:NSVerticalGlyphFormAttributeName atIndex:index];
    return num.boolValue;
}

- (NSString *)languageName{
    return [self languageNameAtIndex:0];
}
- (NSString *)languageNameAtIndex:(NSUInteger)index{
    return (NSString *)[self attribut:(NSString *)kCTLanguageAttributeName atIndex:index];
}

- (NSArray <NSNumber *> *)writingDirection{
    return [self writingDirectionAtIndex:0];
}
- (NSArray <NSNumber *>*)writingDirectionAtIndex:(NSUInteger)index{
    return [self attribut:(NSString *)kCTWritingDirectionAttributeName atIndex:index];
}

- (NSParagraphStyle *)paragraphStyle{
    return [self paragraphStyleAtIndex:0];
}
- (NSParagraphStyle *)paragraphStyleAtIndex:(NSUInteger)index{
    NSParagraphStyle *style = [self attribut:NSParagraphStyleAttributeName atIndex:index];
    if (style) {
        if (CFGetTypeID((__bridge CTParagraphStyleRef)style) == CTParagraphStyleGetTypeID()) {
             style = [NSParagraphStyle paragraphStyleWithCTStyle:(__bridge CTParagraphStyleRef) style];
        }
    }
    return style;
}

#define ParagraphAttribute(_attr_) \
NSParagraphStyle *style = self.paragraphStyle; \
if (!style) style = [NSParagraphStyle defaultParagraphStyle]; \
return style. _attr_;

#define ParagraphAttributeAtIndex(_attr_) \
NSParagraphStyle *style = [self paragraphStyleAtIndex:index]; \
if (!style) style = [NSParagraphStyle defaultParagraphStyle]; \
return style. _attr_;

- (NSTextAlignment)aligenment{
    ParagraphAttribute(alignment);
}
- (NSTextAlignment)aligenmentAtIndex:(NSUInteger)index{
    ParagraphAttributeAtIndex(alignment);
}

- (NSLineBreakMode)lineBreakMode{
    ParagraphAttribute(lineBreakMode);
}
- (NSLineBreakMode)lineBreakModelAtIndex:(NSUInteger)index{
    ParagraphAttributeAtIndex(lineBreakMode);
}
- (CGFloat)linespace{
    ParagraphAttribute(lineSpacing);
}
- (CGFloat)linespaceAtIndex:(NSUInteger)index{
    ParagraphAttributeAtIndex(lineSpacing);
}
- (CGFloat)paraGraphSpace{
    ParagraphAttribute(paragraphSpacing);
}
- (CGFloat)paraGraphSpaceAtIndex:(NSUInteger)index{
    ParagraphAttributeAtIndex(paragraphSpacing);
}
- (CGFloat)paraGraphHead{
    ParagraphAttribute(paragraphSpacingBefore);
}
- (CGFloat)paraGraphHeadAtIndex:(CGFloat)index{
    ParagraphAttributeAtIndex(paragraphSpacingBefore);
}

- (CGFloat)firstLineHeadIndentAtIndex:(NSUInteger)index{
    ParagraphAttributeAtIndex(firstLineHeadIndent);
}

- (CGFloat)firstLineHeadIndent{
    ParagraphAttribute(firstLineHeadIndent);
}
- (CGFloat)headIndentAtIndex:(NSUInteger)index{
    ParagraphAttributeAtIndex(headIndent);
}
- (CGFloat)headIndent{
    ParagraphAttribute(headIndent);
}
- (CGFloat)tailIndent{
    ParagraphAttribute(tailIndent);
}
- (CGFloat)tailIndentAtIndex:(NSUInteger)index{
    ParagraphAttributeAtIndex(tailIndent);
}
- (CGFloat)minLineHeight{
    ParagraphAttribute(minimumLineHeight);
}
- (CGFloat)minLineHeightAtIndex:(NSUInteger)index{
    ParagraphAttributeAtIndex(minimumLineHeight);
}
- (CGFloat)maxLineHeight{
    ParagraphAttribute(maximumLineHeight);
}
- (CGFloat)maxLineHeightAtIndex:(NSUInteger)index{
    ParagraphAttributeAtIndex(maximumLineHeight);
}
- (CGFloat)lineHeightMultiple{
    ParagraphAttribute(lineHeightMultiple);
}
- (CGFloat)lineHeightMultipleAtIndex:(NSUInteger)index{
    ParagraphAttributeAtIndex(lineHeightMultiple);
}
- (NSWritingDirection)baseWritingDirection{
    ParagraphAttribute(baseWritingDirection);
}
- (NSWritingDirection)baseWritingDirectionAtIndex:(NSUInteger)index{
    ParagraphAttributeAtIndex(baseWritingDirection);
}
- (float)hyphenationFactor{
    ParagraphAttribute(hyphenationFactor);
}
- (float)hyphenationFactorAtIndex:(NSUInteger)index{
    ParagraphAttributeAtIndex(hyphenationFactor);
}
- (CGFloat)defaultTabInterval{
    ParagraphAttribute(defaultTabInterval);
}
- (CGFloat)defaultTabIntervalAtIndex:(NSUInteger)index{
    ParagraphAttributeAtIndex(defaultTabInterval);
}
- (NSArray <NSTextTab *> *)textStops{
    ParagraphAttribute(tabStops);
}
- (NSArray <NSTextTab *> *)textStopsAtIndex:(NSUInteger)index{
    ParagraphAttributeAtIndex(tabStops);
}

- (TextShadow *)textShadow{
    return [self textShadowAtIndex:0];
}
- (TextShadow *)textShadowAtIndex:(NSUInteger)index{
    return [self attribut:TextShadowAttributeName atIndex:index];
}

- (TextShadow *)textInnerShadow{
    return [self textShadowAtIndex:0];
}
- (TextShadow *)textInnerShadowAtIndex:(NSUInteger)index{
   return [self attribut:TextInnerShadowAttributeName atIndex:index];
}

- (TextDecoration *)textUnderLine{
    return [self textUnderLineAtIndex:0];
}
- (TextDecoration *)textUnderLineAtIndex:(NSUInteger)index{
    return [self attribut:TextUnderlineAttributeName atIndex:index];
}

- (TextDecoration *)strikeThrough{
    return [self strikeThroughAtIndex:0];
}
- (TextDecoration *)strikeThroughAtIndex:(NSUInteger)index{
    return [self attribut:TextStrikethroughAttributeName atIndex:index];
}

- (TextBorder *)textBorder{
    return [self textBorderAtIndex:0];
}
- (TextBorder *)textBorderAtIndex:(NSUInteger)index{
    return [self attribut:TextBorderAttributeName atIndex:index];
}

- (TextBorder *)textBackgroundBorder{
    return [self textBackgroundBorderAtIndex:0];
}
- (TextBorder *)textBackgroundBorderAtIndex:(NSUInteger)index{
    return [self attribut:TextBackgroundBorderAttributeName atIndex:index];
}

- (CGAffineTransform)textGlyphTransform{
    return [self textGlyphTransformAtIndex:0];
}
- (CGAffineTransform)textGlyphTransformAtIndex:(NSUInteger)index{
    NSValue *value = [self attribut:TextGlyphTransformAttributeName atIndex:index];
    if(value == nil) return CGAffineTransformIdentity;
    return [value CGAffineTransformValue];
}

- (NSString *)plainTextForRange:(NSRange)range{
    if (range.location == NSNotFound || range.length == NSNotFound) {
        return nil;
    }
    NSMutableString *result = [[NSMutableString alloc] init];
    if (range.length == 0) {
        return result;
    }
    NSString *string = self.string;
    [self enumerateAttribute:TextBackedStringAttributeName inRange:range options:kNilOptions usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        TextBackedString *backed = value;
        if (backed && backed.string) {
            [result appendString:backed.string];
        }else{
            [result appendString:[string substringWithRange:range]];
        }
    }];
    return result;
}
+ (NSMutableAttributedString *)h_attachmentStringWithContent:(id)content
                                                 contentMode:(UIViewContentMode)contentMode
                                                        width:(CGFloat)width
                                                       ascent:(CGFloat)ascent
                                                      descent:(CGFloat)descent {
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:TextAttachmentToken];
    TextAttachment *attachement = [TextAttachment new];
    attachement.content = content;
    attachement.contentMode = contentMode;
    [atr h_setTextAttachment:attachement range:NSMakeRange(0, atr.length)];
    TextRunDelegate *runDelegate = [TextRunDelegate new];
    runDelegate.width = width;
    runDelegate.ascent = ascent;
    runDelegate.descent = descent;
    CTRunDelegateRef ctrunDelegate = [runDelegate CTRunDelegate];
    [atr h_setRunDelegate:ctrunDelegate range:NSMakeRange(0, atr.length)];
    if(ctrunDelegate) CFRelease(ctrunDelegate);
    return atr;
}
+ (NSMutableAttributedString *)h_attachmentStringWithContent:(id)content
                                                  contentMode:(UIViewContentMode)contentMode
                                               attachmentSize:(CGSize)attachmentSize alignToFont:(UIFont *)font alignment:(TextVerticalAlignment)alignment{
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:TextAttachmentToken];
    TextAttachment *attachment = [TextAttachment new];
    attachment.content = content;
    attachment.contentMode = contentMode;
    [atr h_setTextAttachment:attachment range:NSMakeRange(0, atr.length)];
    TextRunDelegate *runDele = [TextRunDelegate new];
    runDele.width = attachmentSize.width;
    switch (alignment) {
        case TextVerticalAlignmentTop:{
            runDele.ascent = font.ascender;
            runDele.descent = attachmentSize.height - font.ascender;
            if (runDele.descent < 0) {
                runDele.descent = 0;
                runDele.ascent = attachmentSize.height;
            }
        }
            break;
        case TextVerticalAlignmentCenter:{
            CGFloat fontHeight = font.ascender - font.descender;
            CGFloat yOffset = font.ascender - fontHeight * 0.5;
            runDele.ascent = attachmentSize.height * 0.5 + yOffset;
            runDele.descent = attachmentSize.height - runDele.ascent;
            if (runDele.descent < 0) {
                runDele.descent = 0;
                runDele.ascent = attachmentSize.height;
            }
        }
            break;
        case TextVerticalAlignmentBottom:{
            runDele.ascent = attachmentSize.height + font.descender;
            runDele.descent = -font.descender;
            if (runDele.ascent < 0) {
                runDele.ascent = 0;
                runDele.descent = attachmentSize.height;
            }
        }
            break;
        default:
            runDele.ascent = attachmentSize.height;
            runDele.descent = 0;
            break;
    }
    CTRunDelegateRef delegateRef = runDele.CTRunDelegate;
    [atr h_setRunDelegate:delegateRef range:NSMakeRange(0, atr.length)];
    if (runDele) CFRelease(delegateRef);
    return atr;
}
+ (NSMutableAttributedString *)h_attachmentStringWithEmojiImage:(UIImage *)image
                                                        fontSize:(CGFloat)fontSize {
    if (!image || fontSize <= 0) {
        return nil;
    }
    BOOL hasAnimation = NO;
    if (image.images.count > 1) {
        hasAnimation = YES;
    }else if (NSProtocolFromString(@"YYAnimatedImage") && [image conformsToProtocol:NSProtocolFromString(@"YYAnimatedImage")]){
        NSNumber *count = [image valueForKey:@"animatedImageFrameCount"];
        if (count.integerValue > 1) {
            hasAnimation = YES;
        }
    }
    CGFloat ascent = TextEmojiGetAscentWithFontSize(fontSize);
    CGFloat dscent = TextEmojiGetDescentWithFontSize(fontSize);
    CGRect bounding = YYTextEmojiGetGlyphBoundingRectWithFontSize(fontSize);
    TextRunDelegate *runDele = [TextRunDelegate new];
    runDele.ascent = ascent;
    runDele.descent = dscent;
    runDele.width = bounding.size.width + 2 * bounding.origin.x;
    TextAttachment *attachment = [TextAttachment new];
    attachment.contentMode = UIViewContentModeScaleAspectFit;
    attachment.contentInsets = UIEdgeInsetsMake(ascent - (bounding.size.height + bounding.origin.y), bounding.origin.x, dscent + bounding.origin.y, bounding.origin.x);
    if (hasAnimation) {
        Class imageViewClass = NSClassFromString(@"AnimatedImageView");
        UIImageView *view = [imageViewClass new];
        view.frame = bounding;
        view.image = image;
        view.contentMode = UIViewContentModeScaleAspectFit;
        attachment.content = view;
    }else{
        attachment.content = image;
    }
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:TextAttachmentToken];
    [atr h_setTextAttachment:attachment range:NSMakeRange(0, atr.length)];
    CTRunDelegateRef runDelegateRef = runDele.CTRunDelegate;
    [atr h_setRunDelegate:runDelegateRef range:NSMakeRange(0, atr.length)];
    if (runDelegateRef) CFRelease(runDelegateRef);
    return atr;
}
- (NSRange)rangeOfAll {
    return NSMakeRange(0, self.length);
}

- (BOOL)isSharedAttributesInAllRange {
    __block BOOL shared = YES;
    __block NSDictionary *firstAttrs = nil;
    [self enumerateAttributesInRange:self.rangeOfAll options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (range.location == 0) {
            firstAttrs = attrs;
        } else {
            if (firstAttrs.count != attrs.count) {
                shared = NO;
                *stop = YES;
            } else if (firstAttrs) {
                if (![firstAttrs isEqualToDictionary:attrs]) {
                    shared = NO;
                    *stop = YES;
                }
            }
        }
    }];
    return shared;
}
- (BOOL)canDrawWithUIKit {
    static NSMutableSet *failSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        failSet = [NSMutableSet new];
        [failSet addObject:(id)kCTGlyphInfoAttributeName];
        [failSet addObject:(id)kCTCharacterShapeAttributeName];
        if (kiOS7Later) {
            [failSet addObject:(id)kCTLanguageAttributeName];
        }
        [failSet addObject:(id)kCTRunDelegateAttributeName];
        [failSet addObject:(id)kCTBaselineClassAttributeName];
        [failSet addObject:(id)kCTBaselineInfoAttributeName];
        [failSet addObject:(id)kCTBaselineReferenceInfoAttributeName];
        if (kiOS8Later) {
            [failSet addObject:(id)kCTRubyAnnotationAttributeName];
        }
        [failSet addObject:TextShadowAttributeName];
        [failSet addObject:TextInnerShadowAttributeName];
        [failSet addObject:TextUnderlineAttributeName];
        [failSet addObject:TextStrikethroughAttributeName];
        [failSet addObject:TextBorderAttributeName];
        [failSet addObject:TextBackgroundBorderAttributeName];
        [failSet addObject:TextBlockBorderAttributeName];
        [failSet addObject:TextAttachmentAttributeName];
        [failSet addObject:TextHighlightAttributeName];
        [failSet addObject:TextGlyphTransformAttributeName];
    });
    
#define Fail { result = NO; *stop = YES; return; }
    __block BOOL result = YES;
    [self enumerateAttributesInRange:self.rangeOfAll options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (attrs.count == 0) return;
        for (NSString *str in attrs.allKeys) {
            if ([failSet containsObject:str]) Fail;
        }
        if (!kiOS7Later) {
            UIFont *font = attrs[NSFontAttributeName];
            if (CFGetTypeID((__bridge CFTypeRef)(font)) == CTFontGetTypeID()) Fail;
        }
        if (attrs[(id)kCTForegroundColorAttributeName] && !attrs[NSForegroundColorAttributeName]) Fail;
        if (attrs[(id)kCTStrokeColorAttributeName] && !attrs[NSStrokeColorAttributeName]) Fail;
        if (attrs[(id)kCTUnderlineColorAttributeName]) {
            if (!kiOS7Later) Fail;
            if (!attrs[NSUnderlineColorAttributeName]) Fail;
        }
        NSParagraphStyle *style = attrs[NSParagraphStyleAttributeName];
        if (style && CFGetTypeID((__bridge CFTypeRef)(style)) == CTParagraphStyleGetTypeID()) Fail;
    }];
    return result;
#undef Fail
}
@end



@implementation  NSMutableAttributedString (Add)

- (void)h_setAttribute:(NSString *)key value:(id)value range:(NSRange)range{
    if (!key || [NSNull isEqual:key]) return;
    if (value && ![NSNull isEqual:value]) [self addAttribute:key value:value range:range];
    else [self removeAttribute:key range:range];
}
- (void)h_setAttribute:(NSString *)key value:(id)value{
    [self h_setAttribute:key value:value range:NSMakeRange(0, self.length)];
}
- (void)h_setAttributes:(NSDictionary<NSString *,id> *)attributes{
    if(attributes.count == 0){
        return ;
    }
    [attributes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self h_setAttribute:key value:obj range:NSMakeRange(0, self.length)];
    }];
}
- (void)h_removeAttributesInRange:(NSRange)range{
    [self setAttributes:nil range:range];
}

- (void)setFont:(UIFont *)font{
    [self h_setFont:font range:NSMakeRange(0, self.length)];
}
- (void)h_setFont:(UIFont *)font range:(NSRange)range{
    [self h_setAttribute:NSFontAttributeName value: font range:range];
}

- (void)setKern:(NSNumber *)kern{
    [self h_setKern:kern range:NSMakeRange(0, self.length)];
}
- (void)h_setKern:(NSNumber *)kern range:(NSRange)range{
    [self h_setAttribute:NSKernAttributeName value:kern range:range];
}
- (void)setForeColor:(UIColor *)foreColor{
    [self h_setForeColor:foreColor range:NSMakeRange(0, self.length)];
}
- (void)h_setForeColor:(UIColor *)color range:(NSRange)range{
    [self h_setAttribute:(id)kCTForegroundColorAttributeName value:(id)color.CGColor range:range];
    [self h_setAttribute:NSForegroundColorAttributeName value:color range:range];
}

- (void)setBackGroundColor:(UIColor *)backGroundColor{
    [self h_setBackGroungColor:backGroundColor range:NSMakeRange(0, self.length)];
}
- (void)h_setBackGroungColor:(UIColor *)color range:(NSRange)range{
    [self h_setAttribute:NSBackgroundColorAttributeName value:color range:range];
    if (@available(iOS 10.0, *)) {
        [self h_setAttribute:(id)kCTBackgroundColorAttributeName value:(id)color.CGColor range:range];
    } else {
        // Fallback on earlier versions
    }
}
- (void)setStrokeWidth:(NSNumber * _Nullable)strokeWidth{
    [self h_setStrokeWidth:strokeWidth range:NSMakeRange(0, self.length)];
}
- (void)h_setStrokeWidth:(NSNumber *)width range:(NSRange)range{
    [self h_setAttribute:NSStrokeWidthAttributeName value:width range:range];
}
- (void)setStrokeColor:(UIColor * _Nullable)strokeColor{
    [self h_setStrokeColor:strokeColor range:NSMakeRange(0, self.length)];
}
- (void)h_setStrokeColor:(UIColor *)color range:(NSRange)range{
    [self h_setAttribute:(id)kCTStrokeColorAttributeName value:(id)color.CGColor range:range];
    [self h_setAttribute:NSStrokeColorAttributeName value:color range:range];
}

- (void)setShadow:(NSShadow * _Nonnull)shadow{
    [self h_setShadow:shadow range:NSMakeRange(0, self.length)];
}
- (void)h_setShadow:(NSShadow *)shadow range:(NSRange)range{
    [self h_setAttribute:NSShadowAttributeName value:shadow range:range];
    
}
- (void)setStrikethroughStyle:(NSUnderlineStyle)strikethroughStyle{
    [self h_setStrikethroughStyle:strikethroughStyle range:NSMakeRange(0, self.length)];
}
- (void)h_setStrikethroughStyle:(NSUnderlineStyle)strikethroughStyle range:(NSRange)range{
    NSNumber *style = strikethroughStyle == 0 ? nil : @(strikethroughStyle);
    [self h_setAttribute:NSStrikethroughStyleAttributeName value:style range:range];
}
- (void)setStrikethroughColor:(UIColor * _Nullable)strikethroughColor{
    [self h_setStrikethroughColor:strikethroughColor range:NSMakeRange(0, self.length)];
}
- (void)h_setStrikethroughColor:(UIColor *)color range:(NSRange)range{
    [self h_setAttribute:NSStrikethroughColorAttributeName value:color range:range];
}

- (void)setUnderlineStyle:(NSUnderlineStyle)underlineStyle{
    [self h_setUnderlineStyle:underlineStyle range:NSMakeRange(0, self.length)];
}
- (void)h_setUnderlineStyle:(NSUnderlineStyle)underline range:(NSRange)range{
    NSNumber *style = underline == 0 ? nil : @(underline);
    [self h_setAttribute:NSUnderlineStyleAttributeName value:style range:range];
}

- (void)setUnderLineColor:(UIColor * _Nullable)underLineColor{
    [self h_setUnderLineColor:underLineColor range:NSMakeRange(0, self.length)];
}
- (void)h_setUnderLineColor:(UIColor *)color range:(NSRange)range{
    [self h_setAttribute:(id)kCTUnderlineColorAttributeName value:(id)color.CGColor range:range];
    [self h_setAttribute:NSUnderlineColorAttributeName value:color range:range];
}

- (void)setLigature:(NSNumber * _Nullable)ligature{
    [self h_setLigature:ligature range:NSMakeRange(0, self.length)];
}
- (void)h_setLigature:(NSNumber *)ligature range:(NSRange)range{
    [self h_setAttribute:NSLigatureAttributeName value:ligature range:range];
}

- (void)setTextEffectName:(NSString * _Nullable)textEffectName{
    [self h_setTextEffectName:textEffectName range:NSMakeRange(0, self.length)];
}
- (void)h_setTextEffectName:(NSString *)name range:(NSRange)range{
    [self h_setAttribute:NSTextEffectAttributeName value:name range:range];
}

- (void)setObliqueness:(NSNumber * _Nullable)obliqueness{
    [self h_setObliqueness:obliqueness range:NSMakeRange(0, self.length)];
}
- (void)h_setObliqueness:(NSNumber *)obliquness range:(NSRange)range{
    [self h_setAttribute:NSObliquenessAttributeName value:obliquness range:range];
}

- (void)setExpansion:(NSNumber * _Nullable)expansion{
    [self h_setExpansion:expansion range:NSMakeRange(0, self.length)];
}
- (void)h_setExpansion:(NSNumber *)expansion range:(NSRange)range{
    [self h_setAttribute:NSExpansionAttributeName value:expansion range:range];
}

- (void)setBaseLineOffset:(NSNumber * _Nullable)baseLineOffset{
    [self h_setBaseLineOffset:baseLineOffset range:NSMakeRange(0, self.length)];
}
- (void)h_setBaseLineOffset:(NSNumber *)baseLineOffset range:(NSRange)range{
    [self h_setAttribute:NSBaselineOffsetAttributeName value:baseLineOffset range:range];
}
- (void)setVerticalGlyphForm:(BOOL)verticalGlyphForm{
    [self h_setVerticalGlyphForm:verticalGlyphForm];
}
- (void)h_setVerticalGlyphForm:(BOOL)verticalGlyphForm{
    [self h_setAttribute:NSVerticalGlyphFormAttributeName value:@(verticalGlyphForm) range:NSMakeRange(0, self.length)];
}

- (void)setLanguageName:(NSString * _Nullable)languageName{
    [self h_setLanguageName:languageName range:NSMakeRange(0, self.length)];
}
- (void)h_setLanguageName:(NSString *)name range:(NSRange)range{
    [self h_setLanguageName:(id)kCTLanguageAttributeName range:range];
}

- (void)setWritingDirection:(NSArray<NSNumber *> * _Nullable)writingDirection{
    [self h_setWritingDirection:writingDirection range:NSMakeRange(0, self.length)];
}
- (void)h_setWritingDirection:(NSArray *)writingDirection range:(NSRange)range{
    [self h_setAttribute:(id)kCTWritingDirectionAttributeName value:writingDirection range:range];
}
- (void)setParagraphStyle:(NSParagraphStyle * _Nullable)paragraphStyle{
    [self h_setParagraphStyle:paragraphStyle range:NSMakeRange(0,self.length)];
}
- (void)h_setParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range{
    [self h_setAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}
#define ParagraphStyleSet(_attr_) \
  [self enumerateAttribute:NSParagraphStyleAttributeName inRange:range options:kNilOptions usingBlock:^(NSParagraphStyle *value, NSRange subRange, BOOL * _Nonnull stop) {\
    NSMutableParagraphStyle *style = nil;\
    if (value) {\
        if (CFGetTypeID((__bridge CFTypeRef)value) == CTParagraphStyleGetTypeID()) {\
            value = [NSParagraphStyle paragraphStyleWithCTStyle:(__bridge CTParagraphStyleRef)value];\
        }\
        if (value. _attr_ == _attr_) return; \
        if ([value isKindOfClass:[NSMutableParagraphStyle class]]) { \
            style = (id)value; \
        } else { \
            style = value.mutableCopy; \
        } \
    }else {\
       if ([NSParagraphStyle defaultParagraphStyle]. _attr_ == _attr_) return; \
       style = [NSParagraphStyle defaultParagraphStyle].mutableCopy; \
      }\
     style. _attr_ = _attr_; \
     [self h_setParagraphStyle:style range:subRange]; \
  }];

- (void)setAligenment:(NSTextAlignment)alignment{
    [self h_setAligement:alignment range:NSMakeRange(0, self.length)];
}
- (void)h_setAligement:(NSTextAlignment)alignment range:(NSRange)range{
    ParagraphStyleSet(alignment);
}
- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode{
    [self h_setLineBreakMode:lineBreakMode range:NSMakeRange(0, self.length)];
}
- (void)h_setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range{
    ParagraphStyleSet(lineBreakMode);
}
- (void)setLinespace:(CGFloat)linespace{
    [self h_setLinespace:linespace range:NSMakeRange(0, self.length)];
}
- (void)h_setLinespace:(CGFloat)lineSpacing range:(NSRange)range{
    ParagraphStyleSet(lineSpacing)
}
- (void)setParaGraphSpace:(CGFloat)paraGraphSpace{
    [self h_setParagraphSpacing:paraGraphSpace range:NSMakeRange(0, self.length)];
}
- (void)h_setParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range{
    ParagraphStyleSet(paragraphSpacing);
}
- (void)setParaGraphHead:(CGFloat)paraGraphHead{
    [self h_setParaGraphHead:paraGraphHead range:NSMakeRange(0, self.length)];
}
- (void)h_setParaGraphHead:(CGFloat)paragraphSpacingBefore range:(NSRange)range{
    ParagraphStyleSet(paragraphSpacingBefore);
}
- (void)setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent{
    [self h_setFirstLineHeadIndent:firstLineHeadIndent range:NSMakeRange(0, self.length)];
}
- (void)h_setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range{
    ParagraphStyleSet(firstLineHeadIndent);
}
- (void)setHeadIndent:(CGFloat)headIndent{
    [self h_setHeadIndent:headIndent range:NSMakeRange(0, self.length)];
}
- (void)h_setHeadIndent:(CGFloat)headIndent range:(NSRange)range{
    ParagraphStyleSet(headIndent);
}
- (void)setTailIndent:(CGFloat)tailIndent{
    [self h_setTailIndent:tailIndent range:NSMakeRange(0, self.length)];
}
- (void)h_setTailIndent:(CGFloat)tailIndent range:(NSRange)range{
    ParagraphStyleSet(tailIndent);
}
- (void)setMinLineHeight:(CGFloat)minLineHeight{
    [self h_setMinimumLineHeight:minLineHeight range:NSMakeRange(0, self.length)];
}
- (void)h_setMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range{
    ParagraphStyleSet(minimumLineHeight);
}
- (void)setMaxLineHeight:(CGFloat)maxLineHeight{
    [self h_setMaximumLineHeight:maxLineHeight range:NSMakeRange(0, self.length)];
}
- (void)h_setMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range{
    ParagraphStyleSet(maximumLineHeight);
}

- (void)setLineHeightMultiple:(CGFloat)lineHeightMultiple{
    [self h_setLineHeightMultiple:lineHeightMultiple range:NSMakeRange(0, self.length)];
}
- (void)h_setLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range{
    ParagraphStyleSet(lineHeightMultiple);
}
- (void)setBaseWritingDirection:(NSWritingDirection)baseWritingDirection{
    [self h_setBaseWritingDirection:baseWritingDirection range:NSMakeRange(0, self.length)];
}
- (void)h_setBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range{
    ParagraphStyleSet(baseWritingDirection);
}
- (void)setHyphenationFactor:(float)hyphenationFactor{
    [self h_setHyphenationFactor:hyphenationFactor range:NSMakeRange(0, self.length)];
}
- (void)h_setHyphenationFactor:(float)hyphenationFactor range:(NSRange)range{
    ParagraphStyleSet(hyphenationFactor);
}
- (void)setDefaultTabInterval:(CGFloat)defaultTabInterval{
    [self h_setDefaultTabInterval:defaultTabInterval range:NSMakeRange(0, self.length)];
}
- (void)h_setDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range{
    ParagraphStyleSet(defaultTabInterval);
}

- (void)setTextStops:(NSArray<NSTextTab *> * _Nullable)textStops{
    [self h_setTabStops:textStops range:NSMakeRange(0, self.length)];
}
- (void)h_setTabStops:(nullable NSArray<NSTextTab *> *)tabStops range:(NSRange)range{
    ParagraphStyleSet(tabStops);
}

#undef ParagraphStyleSet

- (void)setTextShadow:(TextShadow * _Nullable)textShadow{
    [self h_setTextShadow:textShadow range:NSMakeRange(0, self.length)];
}
- (void)h_setTextShadow:(TextShadow *)shadow range:(NSRange)range{
    [self h_setAttribute:TextShadowAttributeName value:shadow range:range];
}
- (void)setTextInnerShadow:(TextShadow * _Nullable)textInnerShadow{
    [self h_setTextInnerShadow:textInnerShadow range:NSMakeRange(0, self.length)];
}
- (void)h_setTextInnerShadow:(TextShadow *)innerShadow range:(NSRange)range{
    [self h_setAttribute:TextInnerShadowAttributeName value:innerShadow range:range];
}

- (void)setTextUnderLine:(TextDecoration * _Nullable)textUnderLine{
    [self h_setTextUnderLine:textUnderLine range:NSMakeRange(0, self.length)];
}
- (void)h_setTextUnderLine:(TextDecoration *)textUnderLine range:(NSRange)range{
    [self h_setAttribute:TextUnderlineAttributeName value:textUnderLine range:range];
}
- (void)setStrikeThrough:(TextDecoration * _Nullable)strikeThrough{
    [self h_setStrikeThrough:strikeThrough range:NSMakeRange(0, self.length)];
}
- (void)h_setStrikeThrough:(TextDecoration *)strikeThrough range:(NSRange)range{
    [self h_setAttribute:TextStrikethroughAttributeName value:strikeThrough range:range];
}
- (void)setTextBorder:(TextBorder *)textBorder{
    [self h_setTextBorder:textBorder range:NSMakeRange(0, self.length)];
}
- (void)h_setTextBorder:(TextBorder *)border range:(NSRange)range{
    [self h_setAttribute:TextBorderAttributeName value:border range:range];
}
- (void)setTextBackgroundBorder:(TextBorder * _Nullable)textBackgroundBorder{
    [self h_setTextBackgroundBorder:textBackgroundBorder range:NSMakeRange(0, self.length)];
}
- (void)h_setTextBackgroundBorder:(TextBorder *)border range:(NSRange)range{
    [self h_setAttribute:TextBackgroundBorderAttributeName value:border range:range];
}

- (void)setTextGlyphTransform:(CGAffineTransform)textGlyphTransform{
    [self h_setTextGlyphTransform:textGlyphTransform range:NSMakeRange(0, self.length)];
}
- (void)h_setTextGlyphTransform:(CGAffineTransform)tramsform range:(NSRange)range{
    NSValue *value = CGAffineTransformIsIdentity(tramsform) ? nil : [NSValue valueWithCGAffineTransform:tramsform];
    [self h_setAttribute:TextGlyphTransformAttributeName value:value range:range];
}


- (void)h_setSuperscript:(nullable NSNumber *)superscript range:(NSRange)range{
    if ([superscript isEqualToNumber:@(0)]) {
        superscript = nil;
    }
    [self h_setAttribute:(id)kCTSuperscriptAttributeName value:superscript range:range];
}
- (void)h_setGlyphInfo:(nullable CTGlyphInfoRef)glyphInfo range:(NSRange)range{
    [self h_setAttribute:(id)kCTGlyphInfoAttributeName value:(__bridge id)glyphInfo range:range];
}
- (void)h_setCharacterShape:(nullable NSNumber *)characterShape range:(NSRange)range{
    [self h_setCharacterShape:(id)kCTCharacterShapeAttributeName range:range];
}
- (void)h_setRunDelegate:(nullable CTRunDelegateRef)runDelegate range:(NSRange)range{
    [self h_setAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:range];
}
- (void)h_setBaselineClass:(nullable CFStringRef)baselineClass range:(NSRange)range{
    [self h_setAttribute:(id)kCTBaselineInfoAttributeName value:(__bridge id)baselineClass range:range];
}
- (void)h_setBaselineInfo:(nullable CFDictionaryRef)baselineInfo range:(NSRange)range{
    [self h_setAttribute:(id)kCTBaselineInfoAttributeName value:(__bridge id)baselineInfo range:range];
}
- (void)h_setBaselineReferenceInfo:(nullable CFDictionaryRef)referenceInfo range:(NSRange)range{
    [self h_setAttribute:(id)kCTBaselineReferenceInfoAttributeName value:(__bridge id)referenceInfo range:range];
}
- (void)h_setRubyAnnotation:(nullable CTRubyAnnotationRef)ruby range:(NSRange)range{
    if (kSystemVersion >= 8) {
        [self h_setAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)ruby range:range];
    }
}
- (void)h_setAttachment:(nullable NSTextAttachment *)attachment range:(NSRange)range{
    if (kSystemVersion > 7) {
        [self h_setAttribute:NSAttachmentAttributeName value:attachment range:range];
    }
}
- (void)h_setLink:(nullable id)link range:(NSRange)range {
    if (kSystemVersion > 7) {
        [self h_setAttribute:NSLinkAttributeName value:link range:range];
    }
}
- (void)h_setTextBackedString:(nullable TextBackedString *)textBackedString range:(NSRange)range{
    [self h_setAttribute:TextBackedStringAttributeName value:textBackedString range:range];
}
- (void)h_setTextBinding:(nullable TextBingString *)textBinding range:(NSRange)range{
    [self h_setAttribute:TextBindingAttributeName value:textBinding range:range];
}
- (void)h_setTextAttachment:(nullable TextAttachment *)textAttachment range:(NSRange)range{
    [self h_setAttribute:TextAttachmentAttributeName value:textAttachment range:range];
}
- (void)h_setTextHighlight:(nullable TextHeightLight *)textHighlight range:(NSRange)range{
    [self h_setAttribute:TextHighlightAttributeName value:textHighlight range:range];
}
- (void)h_setTextBlockBorder:(nullable TextBorder *)textBlockBorder range:(NSRange)range{
    [self h_setAttribute:TextBorderAttributeName value:textBlockBorder range:range];
}
- (void)h_setTextRubyAnnotation:(nullable TextRubyAnnotation *)ruby range:(NSRange)range{
    if (kSystemVersion >= 8.0) {
        CTRubyAnnotationRef ctruby = [ruby CTRubyAnnotation];
        [self h_setRubyAnnotation:ctruby range:range];
        if (ctruby) CFRelease(ctruby);
    }
}
- (void)h_setTextHighlightRange:(NSRange)range
                          color:(nullable UIColor *)color
                backgroundColor:(nullable UIColor *)backgroundColor
                       userInfo:(nullable NSDictionary *)userInfo
                      tapAction:(nullable TextAction)tapAction
                longPressAction:(nullable TextAction)longPressAction{
    TextHeightLight *heightLight = [TextHeightLight  highlightWithBackgroundColor:backgroundColor];
    heightLight.userInfo = userInfo;
    heightLight.tapAction = tapAction;
    heightLight.longPressAction = longPressAction;
    if (color) {
        [self h_setForeColor:color range:range];
    }
    [self h_setTextHighlight:heightLight range:range];
}

- (void)h_setTextHighlightRange:(NSRange)range
                           color:(UIColor *)color
                 backgroundColor:(UIColor *)backgroundColor
                       tapAction:(TextAction)tapAction {
    [self h_setTextHighlightRange:range
                            color:color
                  backgroundColor:backgroundColor
                         userInfo:nil
                        tapAction:tapAction
                  longPressAction:nil];
}
- (void)h_setTextHighlightRange:(NSRange)range
                           color:(UIColor *)color
                 backgroundColor:(UIColor *)backgroundColor
                       userInfo:(NSDictionary *)userInfo {
    [self h_setTextHighlightRange:range
                            color:color
                  backgroundColor:backgroundColor
                         userInfo:userInfo
                        tapAction:nil
                  longPressAction:nil];
}

- (void)h_insertString:(NSString *)string atIndex:(NSUInteger)location{
    [self replaceCharactersInRange:NSMakeRange(location, 0) withString:string];
    [self h_removeDiscontinuousAttributesInRange:NSMakeRange(location, string.length)];
}
- (void)h_appendString:(NSString *)string {
    NSUInteger length = self.length;
    [self replaceCharactersInRange:NSMakeRange(length, 0) withString:string];
    [self h_removeDiscontinuousAttributesInRange:NSMakeRange(length, string.length)];
}
- (void)h_setClearColorToJoinedEmoji{
    NSString *str = self.string;
    if (str.length < 8) return;
    // Most string do not contains the joined-emoji, test the joiner first.
    BOOL containsJoiner = NO;
    {
        CFStringRef cfStr = (__bridge CFStringRef)str;
        BOOL needFree = NO;
        UniChar *chars = NULL;
        chars = (void *)CFStringGetCharactersPtr(cfStr);
        if (!chars) {
            chars = malloc(str.length * sizeof(UniChar));
            if (chars) {
                needFree = YES;
                CFStringGetCharacters(cfStr, CFRangeMake(0, str.length), chars);
            }
        }
        if (!chars) { // fail to get unichar..
            containsJoiner = YES;
        } else {
            for (int i = 0, max = (int)str.length; i < max; i++) {
                if (chars[i] == 0x200D) { // 'ZERO WIDTH JOINER' (U+200D)
                    containsJoiner = YES;
                    break;
                }
            }
            if (needFree) free(chars);
        }
    }
    if (!containsJoiner) return;
    
    // NSRegularExpression is designed to be immutable and thread safe.
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"((👨‍👩‍👧‍👦|👨‍👩‍👦‍👦|👨‍👩‍👧‍👧|👩‍👩‍👧‍👦|👩‍👩‍👦‍👦|👩‍👩‍👧‍👧|👨‍👨‍👧‍👦|👨‍👨‍👦‍👦|👨‍👨‍👧‍👧)+|(👨‍👩‍👧|👩‍👩‍👦|👩‍👩‍👧|👨‍👨‍👦|👨‍👨‍👧))" options:kNilOptions error:nil];
    });
    
    UIColor *clear = [UIColor clearColor];
    [regex enumerateMatchesInString:str options:kNilOptions range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self h_setForeColor:clear range:result.range];
    }];
}
- (void)h_removeDiscontinuousAttributesInRange:(NSRange)range {
    NSArray *keys = [NSMutableAttributedString h_allDiscontinuousAttributeKeys];
    for (NSString *key in keys) {
        [self removeAttribute:key range:range];
    }
}
+ (NSArray *)h_allDiscontinuousAttributeKeys {
    static NSMutableArray *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @[(id)kCTSuperscriptAttributeName,
                 (id)kCTRunDelegateAttributeName,
                 TextBackedStringAttributeName,
                 TextBindingAttributeName,
                 TextAttachmentAttributeName].mutableCopy;
        if (kiOS8Later) {
            [keys addObject:(id)kCTRubyAnnotationAttributeName];
        }
        if (kiOS7Later) {
            [keys addObject:NSAttachmentAttributeName];
        }
    });
    return keys;
}
@end
