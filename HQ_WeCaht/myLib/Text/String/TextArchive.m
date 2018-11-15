//
//  TextArchive.m
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/7/19.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "TextArchive.h"
#import "TextRunDelegate.h"
#import <CoreText/CoreText.h>
#import "TextRubyAnnotation.h"

///CoreFundation  的每一种数据类型都会有一个Id 来标识

/// 获取CTRubyDelegateRef 的Id
static CFTypeID CTRunDelegateTypeId(){
    static CFTypeID typeId ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TextRunDelegate *delegate = [TextRunDelegate new];
        CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
        typeId = CFGetTypeID(delegateRef);
    });
    return typeId;
}
///文本注释typeId
static CFTypeID CTRubyAnnotationTypeId(){
    static CFTypeID typeId ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((long)CTRubyAnnotationGetTypeID + 1 > 1) {
            typeId = CTRubyAnnotationGetTypeID();
        }else{
            typeId = kCFNotFound;
        }
    });
    return typeId;
}
////封装一个CGColorRef  来archive  unarchive
@interface ArCGColor : NSObject<NSCopying,NSCoding>
@property (nonatomic,assign) CGColorRef cgColor;
+ (instancetype)colorWithCGColor:(CGColorRef )coloeRef;
@end

@implementation ArCGColor
+ (instancetype)colorWithCGColor:(CGColorRef)coloeRef{
    ArCGColor *arColor = [self new];
    arColor.cgColor = coloeRef;
    return arColor;
}
- (void)setCgColor:(CGColorRef)cgColor{
    if (_cgColor != cgColor) {
        ///引用新的值
        if(cgColor) cgColor = (CGColorRef) CFRetain(cgColor);
        ///释放旧的值
        if (_cgColor) CFRelease(_cgColor);
        _cgColor = cgColor;
    }
}
- (void)dealloc{
    if (_cgColor) CFRelease(_cgColor);
    _cgColor = NULL;
}
#pragma mark ------ NSCoding  -------
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    ArCGColor *color = [super init];
    color.cgColor = (__bridge CGColorRef)[aDecoder decodeObjectForKey:@"color"];
    return color;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    UIColor *col = [UIColor colorWithCGColor:_cgColor];
    [aCoder encodeObject:col forKey:@"color"];
}
#pragma mark ------ NSCopying  --------
- (instancetype)copyWithZone:(NSZone *)zone{
    typeof(self) one = [self.class new];
    one.cgColor = self.cgColor;
    return one;
}
@end

////封装CGImage  for archive / unarchive
@interface ArCGImage : NSObject <NSCopying,NSCoding>
@property (nonatomic,assign) CGImageRef cgImage;
+ (instancetype)imageWithCGImage:(CGImageRef )cgImage;
@end

@implementation ArCGImage
+ (instancetype)imageWithCGImage:(CGImageRef )cgImage{
    ArCGImage *arimage = [ArCGImage new];
    arimage.cgImage = cgImage;
    return arimage;
}
- (void)dealloc{
    if (_cgImage) CFRelease(_cgImage);
    _cgImage = NULL;
}
- (void)setCgImage:(CGImageRef)cgImage{
    if (_cgImage != cgImage) {
        if (cgImage) cgImage = (CGImageRef )CFRetain(cgImage);
        if (_cgImage) CFRelease(_cgImage);
        _cgImage = cgImage;
    }
}
#pragma mark -------- NSCoding ------
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    ArCGImage *one = [super init];
    one.cgImage = (__bridge CGImageRef)[aDecoder decodeObjectForKey:@"image"];
    return one;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    UIImage *image = [UIImage imageWithCGImage:_cgImage];
    [aCoder encodeObject:image forKey:@"image"];
}
#pragma mark ---- NSCopying -------
- (instancetype)copyWithZone:(NSZone *)zone{
    typeof(self) one = [self.class new];
    one.cgImage = self.cgImage;
    return one;
}
@end

@implementation TextArchive

#pragma mark -------- override super method --------
- (instancetype)init{
    self = [super init];
    self.delegate = self;
    return self;
}
- (instancetype)initForWritingWithMutableData:(NSMutableData *)data{
    self = [super initForWritingWithMutableData:data];
    self.delegate = self;
    return self;
}
+ (NSData *)archivedDataWithRootObject:(id)rootObject {
    if (!rootObject) return nil;
    NSMutableData *data = [NSMutableData data];
    TextArchive *archiver = [[[self class] alloc] initForWritingWithMutableData:data];
    [archiver encodeRootObject:rootObject];
    [archiver finishEncoding];
    return data;
}
+ (BOOL)archiveRootObject:(id)rootObject toFile:(NSString *)path {
    NSData *data = [self archivedDataWithRootObject:rootObject];
    if (!data) return NO;
    return [data writeToFile:path atomically:YES];
}

#pragma mark -------- NSKedArchiveDelegate  -----
- (id)archiver:(NSKeyedArchiver *)archiver willEncodeObject:(id)object{
    CFTypeID typeID = CFGetTypeID((CFTypeRef)object);
    if (typeID == CTRunDelegateTypeId()) {
        CTRunDelegateRef runDelegate = (__bridge CFTypeRef)(object);
        id ref = CTRunDelegateGetRefCon(runDelegate);
        if (ref) return ref;
    } else if (typeID == CTRubyAnnotationTypeId()) {
        CTRubyAnnotationRef ctRuby = (__bridge CFTypeRef)(object);
        TextRubyAnnotation *ruby = [TextRubyAnnotation rubyWithCTRubyRef:ctRuby];
        if (ruby) return ruby;
    } else if (typeID == CGColorGetTypeID()) {
        return [ArCGColor colorWithCGColor:(CGColorRef)object];
    } else if (typeID == CGImageGetTypeID()) {
        return [ArCGImage imageWithCGImage:(CGImageRef)object];
    }
    return object;
}

@end


@implementation TextUnarchiver

+ (id)unarchiveObjectWithData:(NSData *)data {
    if (data.length == 0) return nil;
    TextUnarchiver *unarchiver = [[self alloc] initForReadingWithData:data];
    return [unarchiver decodeObject];
}

+ (id)unarchiveObjectWithFile:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [self unarchiveObjectWithData:data];
}

- (instancetype)init {
    self = [super init];
    self.delegate = self;
    return self;
}

- (instancetype)initForReadingWithData:(NSData *)data {
    self = [super initForReadingWithData:data];
    self.delegate = self;
    return self;
}
////解归档时把 TextRubyAnnotation 转成 CTRuby
- (id)unarchiver:(NSKeyedUnarchiver *)unarchiver didDecodeObject:(id) NS_RELEASES_ARGUMENT object NS_RETURNS_RETAINED {
    if ([object class] == [TextRunDelegate class]) {
        TextRunDelegate *runDelegate = object;
        CTRunDelegateRef ct = runDelegate.CTRunDelegate;
        id ctObj = (__bridge id)ct;
        if (ct) CFRelease(ct);
        return ctObj;
    } else if ([object class] == [TextRubyAnnotation class]) {
        TextRubyAnnotation *ruby = object;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8) {
            CTRubyAnnotationRef ct = ruby.CTRubyAnnotation;
            id ctObj = (__bridge id)(ct);
            if (ct) CFRelease(ct);
            return ctObj;
        } else {
            return object;
        }
    } else if ([object class] == [ArCGColor class]) {
        ArCGColor *color = object;
        return (id)color.cgColor;
    } else if ([object class] == [ArCGImage class]) {
        ArCGImage *image = object;
        return (id)image.cgImage;
    }
    return object;
}
@end
