

//
//  TextRunDelegate.m
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/7/19.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "TextRunDelegate.h"

static void DeallocCallBacks(void *ref){
    TextRunDelegate *self = (__bridge_transfer TextRunDelegate *)ref;
    self = nil;
}
static CGFloat GetAsentCallBacks(void *ref){
    TextRunDelegate *self = (__bridge TextRunDelegate *)ref;
    return self.ascent;
}
static CGFloat GetDecentCallBacks(void *ref){
    TextRunDelegate *self = (__bridge TextRunDelegate *)ref;
    return self.descent;
}
static CGFloat GetWidthCallBacks(void *ref){
    TextRunDelegate *self = (__bridge TextRunDelegate *)ref;
    return self.width;
}
@implementation TextRunDelegate

- (CTRunDelegateRef)CTRunDelegate{
    CTRunDelegateCallbacks callBacks;
    callBacks.version = kCTRunDelegateCurrentVersion;
    callBacks.dealloc = DeallocCallBacks;
    callBacks.getAscent = GetAsentCallBacks;
    callBacks.getDescent = GetDecentCallBacks;
    callBacks.getWidth = GetWidthCallBacks;
    return CTRunDelegateCreate(&callBacks, (__bridge_retained void *)self.copy);
}

#pragma mark  ------- NSCoding ----------
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_userInfo forKey:@"userInfo"];
    [aCoder encodeObject:@(_ascent) forKey:@"ascent"];
    [aCoder encodeObject:@(_descent) forKey:@"descent"];
    [aCoder encodeObject:@(_width) forKey:@"width"];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    _userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    _ascent = ((NSNumber *)[aDecoder decodeObjectForKey:@"ascent"]).floatValue;
    _descent = ((NSNumber *) [aDecoder decodeObjectForKey:@"descent"]).floatValue;
    _width = ((NSNumber *)[aDecoder decodeObjectForKey:@"width"]).floatValue;
    return self;
    
}

#pragma mark -------- NSCopying -------

- (instancetype)copyWithZone:(NSZone *)zone{
    typeof(self) one = [self.class new];
    one.userInfo = self.userInfo;
    one.ascent = self.ascent;
    one.descent = self.descent;
    one.width = self.width;
    return one;
}
@end
