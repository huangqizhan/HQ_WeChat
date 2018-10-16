//
//  TextRubyAnnotation.m
//  YYStudyDemo
//
//  Created by hqz on 2018/7/19.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "TextRubyAnnotation.h"

@implementation TextRubyAnnotation

+ (instancetype)rubyWithCTRubyRef:(CTRubyAnnotationRef )ref{
    if (!ref)return nil;
    TextRubyAnnotation *annotation = [self new];
    annotation.alignment = CTRubyAnnotationGetAlignment(ref);
    annotation.overhang = CTRubyAnnotationGetOverhang(ref);
    annotation.sizeFactor = CTRubyAnnotationGetSizeFactor(ref);
    annotation.textBefore = (__bridge NSString *) CTRubyAnnotationGetTextForPosition(ref, kCTRubyPositionBefore);
    annotation.textInline = (__bridge NSString *) CTRubyAnnotationGetTextForPosition(ref, kCTRubyPositionInline);
    annotation.textAfter = (__bridge NSString *) CTRubyAnnotationGetTextForPosition(ref, kCTRubyPositionAfter);
    annotation.textInterCharacter = (__bridge NSString *) CTRubyAnnotationGetTextForPosition(ref,kCTRubyPositionInterCharacter);
    return annotation;
}
- (CTRubyAnnotationRef)CTRubyAnnotation CF_RETURNS_RETAINED{
    if ((long)(CTRubyAnnotationCreate + 1) == 1) {
        return NULL;
    }
    CFStringRef text[kCTRubyPositionCount];
    text[kCTRubyPositionBefore] = (__bridge CFStringRef) _textBefore;
    text[kCTRubyPositionAfter] = (__bridge CFStringRef) _textAfter;
    text[kCTRubyPositionInterCharacter] = (__bridge CFStringRef) _textInterCharacter;
    text[kCTRubyPositionInline] = (__bridge CFStringRef) _textInline;
    return CTRubyAnnotationCreate(_alignment, _overhang, _sizeFactor, text);
}

#pragma mark ------ NSCoding -------
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    self.textBefore = [aDecoder decodeObjectForKey:@"textBefore"];
    self.textAfter = [aDecoder decodeObjectForKey:@"textAfter"];
    self.textInterCharacter = [aDecoder decodeObjectForKey:@"textInterCharacter"];
    self.textInline = [aDecoder decodeObjectForKey:@""];
    self.alignment = ((NSNumber *)[aDecoder decodeObjectForKey:@"textInline"]).intValue;
    self.sizeFactor = ((NSNumber *)[aDecoder decodeObjectForKey:@"sizeFactor"]).floatValue;
    self.overhang = ((NSNumber *)[aDecoder decodeObjectForKey:@"overhang"]).intValue;
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_textBefore forKey:@"textBefore"];
    [aCoder encodeObject:_textAfter forKey:@"textAfter"];
    [aCoder encodeObject:_textInterCharacter forKey:@"textInterCharacter"];
    [aCoder encodeObject:_textInline forKey:@"textInline"];
    [aCoder encodeObject:@(_overhang) forKey:@"overhang"];
    [aCoder encodeObject:@(_alignment) forKey:@"alignment"];
    [aCoder encodeObject:@(_sizeFactor) forKey:@"sizeFactor"];
}

#pragma mark ------ NSCopying -------

- (instancetype)copyWithZone:(NSZone *)zone{
    typeof(self) one = [self.class new];
    one.textBefore = self.textBefore;
    one.textAfter = self.textAfter;
    one.textInline = self.textInline;
    one.textInterCharacter = self.textInterCharacter;
    one.alignment = self.alignment;
    one.overhang = self.overhang;
    one.sizeFactor = self.sizeFactor;
    return one;
}

@end
