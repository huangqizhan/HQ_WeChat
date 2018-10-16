//
//  TextAttribute.m
//  YYStudyDemo
//
//  Created by hqz on 2018/7/20.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "TextAttribute.h"
#import <CoreText/CoreText.h>
#import "TextArchive.h"

static double _DeviceSystemVersion() {
    static double version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion.doubleValue;
    });
    return version;
}

NSString *const TextBackedStringAttributeName = @"TextBackedString";
NSString *const TextBindingAttributeName = @"TextBinding";
NSString *const TextShadowAttributeName = @"TextShadow";
NSString *const TextInnerShadowAttributeName = @"TextInnerShadow";
NSString *const TextUnderlineAttributeName = @"TextUnderline";
NSString *const TextStrikethroughAttributeName = @"TextStrikethrough";
NSString *const TextBorderAttributeName = @"TextBorder";
NSString *const TextBackgroundBorderAttributeName = @"TextBackgroundBorder";
NSString *const TextBlockBorderAttributeName = @"TextBlockBorder";
NSString *const TextAttachmentAttributeName = @"TextAttachment";
NSString *const TextHighlightAttributeName = @"TextHighlight";
NSString *const TextGlyphTransformAttributeName = @"TextGlyphTransform";
///空格编码
NSString *const TextAttachmentToken = @"\uFFFC";
///... 编码 
NSString *const TextTruncationToken = @"\u2026";


static TextAttributeType textAttributGetType(NSString *name){
    if (name.length == 0) return TextAttributeTypeNone;
    NSMutableDictionary *dic = [NSMutableDictionary new];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSNumber *uikit = @(TextAttributeTypeUIKit);
        NSNumber *coreText = @(TextAttributeTypeCoreText);
        NSNumber *cusText = @(TextAttributeTypeText);
        NSNumber *uikit_core = @(TextAttributeTypeUIKit|TextAttributeTypeCoreText);
        NSNumber *text_core = @(TextAttributeTypeText|TextAttributeTypeCoreText);
        NSNumber *text_uikit = @(TextAttributeTypeText|TextAttributeTypeUIKit);
        NSNumber *all = @(TextAttributeTypeUIKit|TextAttributeTypeCoreText|TextAttributeTypeText);
        ///字体
        dic[NSFontAttributeName] = all;
        ///字符间距
        dic[NSKernAttributeName] = all;
        ///字体颜色
        dic[NSForegroundColorAttributeName] = uikit;
        ///字体颜色
        dic[(id) kCTForegroundColorAttributeName] = coreText;
        ///设置字体颜色为前影色
        dic[(id) kCTForegroundColorFromContextAttributeName]  = coreText;
        ///字体背景色
        dic[NSBackgroundColorAttributeName] = uikit;
        ///画笔宽度
        dic[NSStrokeWidthAttributeName] = all;
        ///填充部分颜色，不是字体颜色
        dic[NSStrokeColorAttributeName] = uikit;
        dic[(id) kCTStrokeColorAttributeName] = text_core;
        dic[(id) kCTStrokeWidthAttributeName] = all;
        ///阴影
        dic[NSShadowAttributeName] = text_uikit;
        ///删除线
        dic[NSStrikethroughStyleAttributeName] = uikit;
        ///下划线
        dic[NSUnderlineStyleAttributeName] = uikit_core;
        ///下划线颜色
        dic[(id) kCTUnderlineColorAttributeName] = coreText;
        ///  设置连体属性，取值为NSNumber 对象(整数)，0 表示没有连体字符，1 表示使用默认的连体字符
        dic[NSLigatureAttributeName] = all;
        ////设置字体的上下标属性 必须是CFNumberRef对象 默认为0,可为-1为下标,1为上标，需要字体支持才行。如排列组合的样式Cn1
        //it's a CoreText attrubite, but only supported by UIKit...
        dic[(id) kCTSuperscriptAttributeName] = uikit;
        ////设置文字排版方向，取值为 NSNumber 对象(整数)，0 表示横排文本，1 表示竖排文本
        dic[NSVerticalGlyphFormAttributeName] = all;
        //字体信息属性 必须是CTGlyphInfo对象
        dic[(id)kCTGlyphInfoAttributeName] = text_core;
        //字体形状属性  必须是CFNumberRef对象默认为0，非0则对应相应的字符形状定义，如1表示传统字符形状
        dic[(id)kCTCharacterShapeAttributeName] = text_core;
        //CTRun 委托属性 必须是CTRunDelegate对象
        dic[(id) kCTRunDelegateAttributeName] = text_core;
        ///基线
        dic[(id) kCTBaselineClassAttributeName] = text_core;
        dic[(id) kCTBaselineInfoAttributeName] = text_core;
        dic[(id) kCTBaselineReferenceInfoAttributeName] = text_core;
        ///书写方向
        dic[(id) kCTWritingDirectionAttributeName] = text_core;
        ///段落
        dic[(id) NSParagraphStyleAttributeName] = all;
        
        if (_DeviceSystemVersion() >= 7.0) {
            ////设置删除线颜色，取值为 UIColor 对象，默认值为黑色
            dic[NSStrikethroughColorAttributeName] = uikit;
            ///下划线颜色
            dic[NSUnderlineColorAttributeName] = uikit;
            ////设置文本特殊效果，取值为 NSString 对象，目前只有图版印刷效果可用
            dic[NSTextEffectAttributeName] = uikit;
            ///设置字形倾斜度，取值为 NSNumber （float）,正值右倾，负值左倾
            dic[NSObliquenessAttributeName] = uikit;
            ////设置文本横向拉伸属性，取值为 NSNumber （float）,正值横向拉伸文本，负值横向压缩文本
            dic[NSExpansionAttributeName] = uikit;
            dic[(id) kCTLanguageAttributeName] = text_core;
            ///基线 移动
            dic[NSBaselineOffsetAttributeName] = uikit;
            ///书写方向
            dic[NSWritingDirectionAttributeName] = uikit;
            ////图片
            dic[NSAttachmentAttributeName] = uikit;
            ///超链接
            dic[NSLinkAttributeName] = uikit;
        }
        if (_DeviceSystemVersion() > 8.0) {
            ////拼音
            dic[(id) kCTRubyAnnotationAttributeName] = coreText;
        }
        ////自定义
        dic[TextBackedStringAttributeName] = cusText;
        dic[TextBindingAttributeName] = cusText;
        dic[TextShadowAttributeName] = cusText;
        dic[TextInnerShadowAttributeName] = cusText;
        dic[TextUnderlineAttributeName] = cusText;
        dic[TextStrikethroughAttributeName] = cusText;
        dic[TextBorderAttributeName] = cusText;
        dic[TextBackgroundBorderAttributeName] = cusText;
        dic[TextBlockBorderAttributeName] = cusText;
        dic[TextAttachmentAttributeName] = cusText;
        dic[TextHighlightAttributeName] = cusText;
        dic[TextGlyphTransformAttributeName] = cusText;
    });
    NSNumber *num = dic[name];
    if(num != nil ) return num.unsignedIntegerValue;
    return TextAttributeTypeNone;
}

@implementation  TextBackedString

+ (instancetype)stringWithString:(NSString *)string {
    TextBackedString *one = [self new];
    one.string = string;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.string forKey:@"string"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _string = [aDecoder decodeObjectForKey:@"string"];
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.string = self.string;
    return one;
}
@end

@implementation  TextBingString

+ (instancetype)bindingWithDeleteConfirm:(BOOL)deleteConfirm {
    TextBingString *one = [self new];
    one.deleteConfirm = deleteConfirm;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.deleteConfirm) forKey:@"deleteConfirm"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _deleteConfirm = ((NSNumber *)[aDecoder decodeObjectForKey:@"deleteConfirm"]).boolValue;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.deleteConfirm = self.deleteConfirm;
    return one;
}

@end

@implementation  TextShadow

+ (instancetype)shadowWithNSShadow:(NSShadow *)nsShadow {
    if (!nsShadow) return nil;
    TextShadow *shadow = [self new];
    shadow.offset = nsShadow.shadowOffset;
    shadow.radius = nsShadow.shadowBlurRadius;
    id color = nsShadow.shadowColor;
    if (color) {
        if (CGColorGetTypeID() == CFGetTypeID((__bridge CFTypeRef)(color))) {
            color = [UIColor colorWithCGColor:(__bridge CGColorRef)(color)];
        }
        if ([color isKindOfClass:[UIColor class]]) {
            shadow.color = color;
        }
    }
    return shadow;
}

- (NSShadow *)nsShadow {
    NSShadow *shadow = [NSShadow new];
    shadow.shadowOffset = self.offset;
    shadow.shadowBlurRadius = self.radius;
    shadow.shadowColor = self.color;
    return shadow;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.color forKey:@"color"];
    [aCoder encodeObject:@(self.radius) forKey:@"radius"];
    [aCoder encodeObject:[NSValue valueWithCGSize:self.offset] forKey:@"offset"];
    [aCoder encodeObject:self.subShadow forKey:@"subShadow"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _color = [aDecoder decodeObjectForKey:@"color"];
    _radius = ((NSNumber *)[aDecoder decodeObjectForKey:@"radius"]).floatValue;
    _offset = ((NSValue *)[aDecoder decodeObjectForKey:@"offset"]).CGSizeValue;
    _subShadow = [aDecoder decodeObjectForKey:@"subShadow"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.color = self.color;
    one.radius = self.radius;
    one.offset = self.offset;
    one.subShadow = self.subShadow.copy;
    return one;
}

@end

@implementation  TextDecoration

- (instancetype)init {
    self = [super init];
    _style = TextLineStyleSingle;
    return self;
}

+ (instancetype)decorationWithStyle:(TextLineStyle)style {
    TextDecoration *one = [self new];
    one.style = style;
    return one;
}
+ (instancetype)decorationWithStyle:(TextLineStyle)style width:(NSNumber *)width color:(UIColor *)color {
    TextDecoration *one = [self new];
    one.style = style;
    one.width = width;
    one.color = color;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.style) forKey:@"style"];
    [aCoder encodeObject:self.width forKey:@"width"];
    [aCoder encodeObject:self.color forKey:@"color"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.style = ((NSNumber *)[aDecoder decodeObjectForKey:@"style"]).unsignedIntegerValue;
    self.width = [aDecoder decodeObjectForKey:@"width"];
    self.color = [aDecoder decodeObjectForKey:@"color"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.style = self.style;
    one.width = self.width;
    one.color = self.color;
    return one;
}

@end

@implementation  TextBorder

+ (instancetype)borderWithLineStyle:(TextLineStyle)lineStyle lineWidth:(CGFloat)width strokeColor:(UIColor *)color {
    TextBorder *one = [self new];
    one.lineStyle = lineStyle;
    one.strokeWidth = width;
    one.strokeColor = color;
    return one;
}

+ (instancetype)borderWithFillColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius {
    TextBorder *one = [self new];
    one.fillColor = color;
    one.cornerRadius = cornerRadius;
    one.insets = UIEdgeInsetsMake(-2, 0, 0, -2);
    return one;
}

- (instancetype)init {
    self = [super init];
    self.lineStyle = TextLineStyleSingle;
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.lineStyle) forKey:@"lineStyle"];
    [aCoder encodeObject:@(self.strokeWidth) forKey:@"strokeWidth"];
    [aCoder encodeObject:self.strokeColor forKey:@"strokeColor"];
    [aCoder encodeObject:@(self.lineJoin) forKey:@"lineJoin"];
    [aCoder encodeObject:[NSValue valueWithUIEdgeInsets:self.insets] forKey:@"insets"];
    [aCoder encodeObject:@(self.cornerRadius) forKey:@"cornerRadius"];
    [aCoder encodeObject:self.shadow forKey:@"shadow"];
    [aCoder encodeObject:self.fillColor forKey:@"fillColor"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _lineStyle = ((NSNumber *)[aDecoder decodeObjectForKey:@"lineStyle"]).unsignedIntegerValue;
    _strokeWidth = ((NSNumber *)[aDecoder decodeObjectForKey:@"strokeWidth"]).doubleValue;
    _strokeColor = [aDecoder decodeObjectForKey:@"strokeColor"];
    _lineJoin = (CGLineJoin)((NSNumber *)[aDecoder decodeObjectForKey:@"join"]).unsignedIntegerValue;
    _insets = ((NSValue *)[aDecoder decodeObjectForKey:@"insets"]).UIEdgeInsetsValue;
    _cornerRadius = ((NSNumber *)[aDecoder decodeObjectForKey:@"cornerRadius"]).doubleValue;
    _shadow = [aDecoder decodeObjectForKey:@"shadow"];
    _fillColor = [aDecoder decodeObjectForKey:@"fillColor"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.lineStyle = self.lineStyle;
    one.strokeWidth = self.strokeWidth;
    one.strokeColor = self.strokeColor;
    one.lineJoin = self.lineJoin;
    one.insets = self.insets;
    one.cornerRadius = self.cornerRadius;
    one.shadow = self.shadow.copy;
    one.fillColor = self.fillColor;
    return one;
}

@end


@implementation  TextAttachment


+ (instancetype)attachmentWithContent:(id)content {
    TextAttachment *one = [self new];
    one.content = content;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:[NSValue valueWithUIEdgeInsets:self.contentInsets] forKey:@"contentInsets"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _content = [aDecoder decodeObjectForKey:@"content"];
    _contentInsets = ((NSValue *)[aDecoder decodeObjectForKey:@"contentInsets"]).UIEdgeInsetsValue;
    _userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    if ([self.content respondsToSelector:@selector(copy)]) {
        one.content = [self.content copy];
    } else {
        one.content = self.content;
    }
    one.contentInsets = self.contentInsets;
    one.userInfo = self.userInfo.copy;
    return one;
}


@end


@implementation  TextHeightLight

+ (instancetype)highlightWithAttributes:(NSDictionary<NSString *,id> *)attributes{
    TextHeightLight *one = [self new];
    one.attributes = attributes;
    return one;
}
+ (instancetype)highlightWithBackgroundColor:(UIColor *)color{
    TextBorder *highlighborder = [TextBorder new];
    highlighborder.insets = UIEdgeInsetsMake(-2, -1, -2, -1);
    highlighborder.cornerRadius = 3;
    highlighborder.fillColor = color;
    TextHeightLight *one = [self new];
    [one setBackgroundBorder:highlighborder];
    return one;
}
- (void)setAttributes:(NSDictionary<NSString *,id> *)attributes{
    _attributes = attributes.mutableCopy;
}
#pragma mark ---- NSCoding ------
- (void)encodeWithCoder:(NSCoder *)aCoder{
    NSData *data;
    @try {
        data = [TextArchive archivedDataWithRootObject:_attributes];
    } @catch (NSException *exception) {
        NSLog(@"excetion = %@",exception);
    }
    [aCoder encodeObject:data forKey:@"attributes"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    NSData *date = [aDecoder decodeObjectForKey:@"attributes"];
    @try {
        _attributes = [TextUnarchiver unarchiveObjectWithData:date];
    } @catch (NSException *exception) {
        NSLog(@"excetion = %@",exception);
    }
    return self;
}
- (instancetype)copyWithZone:(NSZone *)zone{
    typeof(self) one = [self.class new];
    one.attributes = self.attributes.mutableCopy;
    return one;
}

- (void)_makeMutableAttributes{
    if (!_attributes) {
        _attributes = [NSMutableDictionary new];
    }else if (![_attributes isKindOfClass:[NSMutableDictionary class]]){
        _attributes = _attributes.mutableCopy;
    }
}

- (void)setFont:(UIFont *)font{
    [self _makeMutableAttributes];
    if (font == (id)[NSNull null] || font == nil) {
        ((NSMutableDictionary *)_attributes)[(id) kCTFontAttributeName] = [NSNull null];
    }else{
        CTFontRef cfont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
        if (cfont) {
            ((NSMutableDictionary *)_attributes)[(id) kCTFontAttributeName] = (__bridge id)cfont;
            CFRelease(cfont);
        }
    }
}
- (void)setColor:(UIColor *)color{
    [self _makeMutableAttributes];
    if (color == (id)[NSNull null] || color == nil) {
        ((NSMutableDictionary *)_attributes)[(id) kCTForegroundColorAttributeName] = [NSNull null];
        ((NSMutableDictionary *)_attributes)[NSForegroundColorAttributeName] = [NSNull null];
    }else{
        ((NSMutableDictionary *)_attributes)[(id) kCTForegroundColorAttributeName] = (__bridge id)color.CGColor;
        ((NSMutableDictionary *)_attributes)[NSForegroundColorAttributeName] = color;
    }
}
- (void)setStrokeColor:(UIColor *)color{
    [self _makeMutableAttributes];
    if (color == (id)[NSNull null] || color == nil) {
        ((NSMutableDictionary *)_attributes)[(id) kCTStrokeColorAttributeName] = [NSNull null];
        ((NSMutableDictionary *)_attributes)[(id) NSStrokeColorAttributeName] = [NSNull null];
    }else{
        ((NSMutableDictionary *)_attributes)[(id) kCTStrokeColorAttributeName] = (__bridge id)color.CGColor;
        ((NSMutableDictionary *)_attributes)[NSStrokeColorAttributeName] = color;

    }
}
- (void)setStrokeWidth:(NSNumber *)width {
    [self _makeMutableAttributes];
    if (width == (id)[NSNull null] || width == nil) {
        ((NSMutableDictionary *)_attributes)[(id)kCTStrokeWidthAttributeName] = [NSNull null];
    } else {
        ((NSMutableDictionary *)_attributes)[(id)kCTStrokeWidthAttributeName] = width;
    }
}
- (void)setTextAttribute:(NSString *)attName value:(id)value{
    [self _makeMutableAttributes];
    if (value == nil) value = [NSNull null];
    ((NSMutableDictionary *)_attributes)[attName] = value;
}
- (void)setShadow:(TextShadow *)shadow{
    [self setTextAttribute:TextShadowAttributeName value:shadow];
}
- (void)setInnerShadow:(TextShadow *)shadow{
    [self setTextAttribute:TextInnerShadowAttributeName value:shadow];
}
- (void)setUnderline:(TextDecoration *)underline{
    [self setTextAttribute:TextUnderlineAttributeName value:underline];
}
- (void)setStrikethrough:(TextDecoration *)strikethrough{
    [self setTextAttribute:TextStrikethroughAttributeName value:strikethrough];
}
- (void)setBackgroundBorder:(TextBorder *)border{
    [self setTextAttribute:TextBackgroundBorderAttributeName value:border];
}
- (void)setBorder:(TextBorder *)border{
    [self setTextAttribute:TextBorderAttributeName value:border];
}
- (void)setAttachment:(TextAttachment *)attachment{
    [self setTextAttribute:TextAttachmentAttributeName value:attachment];
}

@end




