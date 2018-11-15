//
//  TextInput.m
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/8/13.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "TextInput.h"
#import "TextUtilites.h"


@implementation TextPosition

+ (instancetype)positionWith:(CGFloat)offset{
    return [self positionWith:offset affinity:TextAffinityForward];
}
+ (instancetype)positionWith:(CGFloat)offset affinity:(TextAffinity)affinity{
    TextPosition *position = [self new];
    position->_offset = offset;
    position->_affinity = affinity;
    return position;
}
- (instancetype)copyWithZone:(NSZone *)zone{
    return [self.class positionWith:_offset affinity:_affinity];
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> (%@%@)", self.class, self, @(_offset), _affinity == TextAffinityForward ? @"F":@"B"];
}
- (NSUInteger)hash {
    return _offset * 2 + (_affinity == TextAffinityForward ? 1 : 0);
}
- (BOOL)isEqual:(TextPosition *)object{
    if (object == nil) return NO;
    return self.offset == object.offset && self.affinity == object.offset;
}
- (NSComparisonResult)compare:(TextPosition *)otherPosition{
    if (!otherPosition) return NSOrderedAscending;
    if (_offset < otherPosition.offset) return NSOrderedAscending;
    if (_offset > otherPosition.offset) return NSOrderedDescending;
    if (_affinity == TextAffinityBackward && otherPosition.affinity == TextAffinityForward) return NSOrderedAscending;
    if (_affinity == TextAffinityForward && otherPosition.affinity == TextAffinityBackward) return NSOrderedDescending;
    return NSOrderedSame;

}

@end 


@implementation  TextRange{
    TextPosition *_start;
    TextPosition *_end;
}
- (instancetype)init{
    self = [super init];
    if(!self) return nil;
    _start = [TextPosition  positionWith:0];
    _end = [TextPosition positionWith:0];
    return self;
}

- (TextPosition *)start {
    return _start;
}
- (TextPosition *)end {
    return _end;
}
- (BOOL)isEmpty{
    return _start.offset == _end.offset;
}
- (NSRange)asRange{
    return NSMakeRange(_start.offset, _end.offset - _start.offset);
}

+ (instancetype)rangeWithRange:(NSRange)range{
    return [self rangeWithRange:range affinity:TextAffinityForward];
}
+ (instancetype)rangeWithRange:(NSRange)range affinity:(TextAffinity)affinity{
    TextPosition *start = [TextPosition positionWith:range.location affinity:affinity];
    TextPosition *end = [TextPosition positionWith:range.location + range.length affinity:affinity];
    return [self rangeWithStart:start end:end];
}

+ (instancetype)rangeWithStart:(TextPosition *)start end:(TextPosition *)end{
    if (!start || !end) return nil;
    if ([start compare:end] == NSOrderedDescending) {
        YYTEXT_SWAP(start, end);
    }
    TextRange *range = [TextRange new];
    range->_start = start;
    range->_end = end;
    return range;
}
+ (instancetype)defaultRange{
    return [self new];
}
- (instancetype)copyWithZone:(NSZone *)zone{
    return [self.class rangeWithStart:_start end:_end];
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> (%@, %@)%@", self.class, self, @(_start.offset), @(_end.offset - _start.offset), _end.affinity == TextAffinityForward ? @"F":@"B"];
}
- (NSUInteger)hash{
    return (sizeof(NSUInteger) == 8) ? OSSwapInt64(_start.hash) : OSSwapInt32(_start.hash) + _end.hash;
}
- (BOOL)isEqual:(TextRange *)object{
    return [_start isEqual:object.start] && [_end isEqual:object.end];
}

@end


@implementation TextSelectionRect

@synthesize rect = _rect;
@synthesize writingDirection = _writingDirection;
@synthesize containsStart = _containsStart;
@synthesize containsEnd = _containsEnd;
@synthesize isVertical = _isVertical;

- (instancetype)copyWithZone:(NSZone *)zone{
    TextSelectionRect *rect = [TextSelectionRect new];
    rect.rect = _rect;
    rect.writingDirection = _writingDirection;
    rect.containsStart = _writingDirection;
    rect.containsEnd = _containsEnd;
    rect.isVertical = _isVertical;
    return rect;
}

@end 
