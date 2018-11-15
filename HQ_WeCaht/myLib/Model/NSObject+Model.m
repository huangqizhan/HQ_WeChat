//
//  NSObject+Model.m
//  YYStudy
//
//  Created by hqz  QQ 757618403 on 2018/5/2.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "NSObject+Model.h"
#import "ClassInfo.h"
#import <objc/runtime.h>
#import <objc/message.h>


/// Foundation Class Type
typedef NS_ENUM (NSUInteger, YYEncodingNSType) {
    YYEncodingTypeNSUnknown = 0,
    YYEncodingTypeNSString,
    YYEncodingTypeNSMutableString,
    YYEncodingTypeNSValue,
    YYEncodingTypeNSNumber,
    YYEncodingTypeNSDecimalNumber,
    YYEncodingTypeNSData,
    YYEncodingTypeNSMutableData,
    YYEncodingTypeNSDate,
    YYEncodingTypeNSURL,
    YYEncodingTypeNSArray,
    YYEncodingTypeNSMutableArray,
    YYEncodingTypeNSDictionary,
    YYEncodingTypeNSMutableDictionary,
    YYEncodingTypeNSSet,
    YYEncodingTypeNSMutableSet,
};

static force_inline YYEncodingNSType ClassGetNsType(Class cls){
    if (!cls) return YYEncodingTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return YYEncodingTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]]) return YYEncodingTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return YYEncodingTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return YYEncodingTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return YYEncodingTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return YYEncodingTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return YYEncodingTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return YYEncodingTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return YYEncodingTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return YYEncodingTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return YYEncodingTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return YYEncodingTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return YYEncodingTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return YYEncodingTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]]) return YYEncodingTypeNSSet;
    return YYEncodingTypeNSUnknown;
}
/// Whether the type is c number.
static force_inline BOOL YYEncodingTypeIsCNumber(YYEncodingType type) {
    switch (type & YYEncodingTypeMask) {
        case YYEncodingTypeBool:
        case YYEncodingTypeInt8:
        case YYEncodingTypeUInt8:
        case YYEncodingTypeInt16:
        case YYEncodingTypeUInt16:
        case YYEncodingTypeInt32:
        case YYEncodingTypeUInt32:
        case YYEncodingTypeInt64:
        case YYEncodingTypeUInt64:
        case YYEncodingTypeFloat:
        case YYEncodingTypeDouble:
        case YYEncodingTypeLongDouble: return YES;
        default: return NO;
    }
}

/// Parse a number value from 'id'.

static force_inline NSNumber * NumberCreateFromID(__unsafe_unretained id value){
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ///用ascall 码 创建字符集
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE" :   @(YES),
                @"True" :   @(YES),
                @"true" :   @(YES),
                @"FALSE" :  @(NO),
                @"False" :  @(NO),
                @"false" :  @(NO),
                @"YES" :    @(YES),
                @"Yes" :    @(YES),
                @"yes" :    @(YES),
                @"NO" :     @(NO),
                @"No" :     @(NO),
                @"no" :     @(NO),
                @"NIL" :    (id)kCFNull,
                @"Nil" :    (id)kCFNull,
                @"nil" :    (id)kCFNull,
                @"NULL" :   (id)kCFNull,
                @"Null" :   (id)kCFNull,
                @"null" :   (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull};
    });
    if (!value || value == (id) kCFNull) {
        return nil;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *num = [dic objectForKey:value];
        if (num != nil){
            if (num == (id) kCFNull) {
                return nil;
            }
            return num;
        }
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *cStr = ((NSString *)value).UTF8String;
            if (!cStr) return nil;
            double num = atof(cStr);
            if (isnan(num) || isinf(num)) {
                return nil;
            }
            return @(num);
        }else{
            const char *cStr = ((NSString *)value).UTF8String;
            if (!cStr) return nil;
            return @(atoll(cStr));
        }
    }
    return nil;
}
static force_inline NSDate *NSDateFromString(NSString *string){
    
    typedef NSDate * (^NSDataPaserBlock)(NSString *string);
    #define kParseBlocks 34
    static NSDataPaserBlock parseBlocls[kParseBlocks + 1] = {};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            ///2014-01-20
            NSDateFormatter *formater = [[NSDateFormatter alloc] init];
            formater.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formater.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formater.dateFormat = @"yyyy-MM-dd";
            parseBlocls[10] = ^(NSString *string){
                return [formater dateFromString:string];
            };
            
        }
        
        {
            /*
             2014-01-20 12:24:48
             2014-01-20T12:24:48   // Google
             2014-01-20 12:24:48.000
             2014-01-20T12:24:48.000
             */
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
            formatter3.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter3.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter3.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
            
            NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
            formatter4.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter4.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter4.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            
            parseBlocls[19] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter1 dateFromString:string];
                } else {
                    return [formatter2 dateFromString:string];
                }
            };
            
            parseBlocls[23] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter3 dateFromString:string];
                } else {
                    return [formatter4 dateFromString:string];
                }
            };
        }
        
        {
            /*
             2014-01-20T12:24:48Z        // Github, Apple
             2014-01-20T12:24:48+0800    // Facebook
             2014-01-20T12:24:48+12:00   // Google
             2014-01-20T12:24:48.000Z
             2014-01-20T12:24:48.000+0800
             2014-01-20T12:24:48.000+12:00
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
            
            parseBlocls[20] = ^(NSString *string) { return [formatter dateFromString:string]; };
            parseBlocls[24] = ^(NSString *string) { return [formatter dateFromString:string]?: [formatter2 dateFromString:string]; };
            parseBlocls[25] = ^(NSString *string) { return [formatter dateFromString:string]; };
            parseBlocls[28] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
            parseBlocls[29] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
        
        {
            /*
             Fri Sep 04 00:12:21 +0800 2015 // Weibo, Twitter
             Fri Sep 04 00:12:21.000 +0800 2015
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"EEE MMM dd HH:mm:ss.SSS Z yyyy";
            
            parseBlocls[30] = ^(NSString *string) { return [formatter dateFromString:string]; };
            parseBlocls[34] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
    });
    if (!string) return nil;
    if (string.length > kParseBlocks) return nil;
    NSDataPaserBlock parser = parseBlocls[string.length];
    if (!parser) return nil;
    return parser(string);
    #undef kParseBlocks
}
///block Class
static force_inline Class GetBlockClass(){
    static Class cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^blcok)(void) = ^{};
        cls = ((NSObject *)blcok).class;
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
    });
    return cls;
}
///世界标准 IOS 时间格式
static force_inline NSDateFormatter *ISODateFormeters(){
    static NSDateFormatter *formater;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formater = [[NSDateFormatter alloc] init];
        formater.locale = [[NSLocale  alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formater.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return formater;
}
//// __unsafe_unretained 修饰的参数是不会被方法引用的
static force_inline id ValueForKeyPaths(__unsafe_unretained NSDictionary *dic,__unsafe_unretained NSArray *keypaths){
    id value = nil;
    for (NSUInteger i = 0 , max = keypaths.count ; i < max; i++) {
        value = dic[keypaths[i]];
        if (i + 1 < max) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                dic = value;
            }else{
                return nil;
            }
        }
    }
    return value;
}
static force_inline id ValueForMultiKeys(__unsafe_unretained NSDictionary *dic, __unsafe_unretained NSArray *multiKeys) {
    id value = nil;
    for (NSString *key in multiKeys) {
        if ([key isKindOfClass:[NSString class]]) {
            value = dic[key];
            if (value) break;
        } else {
            value = ValueForKeyPaths(dic, (NSArray *)key);
            if (value) break;
        }
    }
    return value;
}

////记录属性的元类
@interface  ModelPropertyMeta :NSObject{
    @package
    NSString *_name;            ///属性名称
    YYEncodingType _type;       ///属性类型
    YYEncodingNSType _nsType;   ///OC的类型
    BOOL _isCNumber;            ///是否是c 语言的数据类型
    Class _cls;                 /// 属性所属的类型
    Class _genericCls;          ///当前属性自定义的类
    SEL _setter;                ///属性的set方法
    SEL _getter;                ///属性的getter 方法
    BOOL _isKvcCompatible;      ///是否兼容KVC
    BOOL _isStructAvaliableKeyedArchiver; ///属性是否是结构体
    BOOL _hasCustomerClassFromDictionary; ///解析的时候碰到字典 是否生成自定义的类
    ClassPropertyInfo *_info;             ///属性的详细信息
    NSString *_mapedToKey;                ///自己定义的模型字段
    NSArray *_mappedToKeyPath;            ///模型字段对应的字段的路径
    NSArray *_mappedToKeyArray;           ///提个属性字段可以多个json的字段
#warning  _next 删了 看是不是有影响  估计没有用 ------
    ModelPropertyMeta *_next;
}


@end

@implementation ModelPropertyMeta

+ (instancetype)metaWithClassInfo:(ClassInfo *)classInfo propertyInfo:(ClassPropertyInfo *)propertyInfo generic:(Class)generic{
    if (!generic && propertyInfo.protocols) {
        for (NSString *protocol in propertyInfo.protocols) {
            Class cls = objc_getClass(protocol.UTF8String);
            if (cls) {
                generic = cls;
                break;
            }
        }
    }
    ModelPropertyMeta *meta = [ModelPropertyMeta new];
    meta->_info = propertyInfo;
    meta->_name = propertyInfo.name;
    meta->_type = propertyInfo.type;
    meta->_genericCls = generic;
    
    if ((meta->_type & YYEncodingTypeMask) == YYEncodingTypeObject) {
        meta->_nsType = ClassGetNsType(propertyInfo.cls);
    }else{
        meta->_isCNumber = YYEncodingTypeIsCNumber(meta->_type);
    }
    if ((meta->_type & YYEncodingTypeStruct) == YYEncodingTypeStruct) {
        static NSSet *structSet = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableSet *set = [NSMutableSet new];
            // 32 bit
            [set addObject:@"{CGSize=ff}"];
            [set addObject:@"{CGPoint=ff}"];
            [set addObject:@"{CGRect={CGPoint=ff}{CGSize=ff}}"];
            [set addObject:@"{CGAffineTransform=ffffff}"];
            [set addObject:@"{UIEdgeInsets=ffff}"];
            [set addObject:@"{UIOffset=ff}"];
            // 64 bit
            [set addObject:@"{CGSize=dd}"];
            [set addObject:@"{CGPoint=dd}"];
            [set addObject:@"{CGRect={CGPoint=dd}{CGSize=dd}}"];
            [set addObject:@"{CGAffineTransform=dddddd}"];
            [set addObject:@"{UIEdgeInsets=dddd}"];
            [set addObject:@"{UIOffset=dd}"];
            structSet = set;
        });
        if ([structSet containsObject:propertyInfo.typeEncoding]) {
            meta->_isStructAvaliableKeyedArchiver = YES;
        }

    }
    meta->_cls = propertyInfo.cls;
    if (generic) {
        meta->_hasCustomerClassFromDictionary = [generic respondsToSelector:@selector(modelCustomClassForDictionary:)];
    }else if (meta->_cls && meta->_type == YYEncodingTypeNSUnknown){
        meta->_hasCustomerClassFromDictionary = [meta->_cls respondsToSelector:@selector(modelCustomClassForDictionary:)];
    }
    if (propertyInfo.getter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.getter]) {
            meta->_getter = propertyInfo.getter;
        }
    }
    if (propertyInfo.setter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.setter]) {
            meta->_setter = propertyInfo.setter;
        }
    }
    if (meta->_setter && meta->_getter) {
        switch (meta->_type & YYEncodingTypeMask) {
            case YYEncodingTypeBool:
            case YYEncodingTypeInt8:
            case YYEncodingTypeUInt8:
            case YYEncodingTypeInt16:
            case YYEncodingTypeUInt16:
            case YYEncodingTypeInt32:
            case YYEncodingTypeUInt32:
            case YYEncodingTypeInt64:
            case YYEncodingTypeUInt64:
            case YYEncodingTypeFloat:
                
            case YYEncodingTypeDouble:
            case YYEncodingTypeObject:
            case YYEncodingTypeClass:
            case YYEncodingTypeBlock:
            case YYEncodingTypeStruct:
            case YYEncodingTypeUnion: {
                meta->_isKvcCompatible = YES;
            } break;
            default: break;
        }
    }
    return meta;
}
@end

///记录类的元类
@interface ModelMeta :NSObject{
    @package
    ///类的信息
    ClassInfo *_classInfo;
    ///key 属性名  value propertyMeta
    NSDictionary *_maper;
    ////所有的propertyMeta
    NSArray *_allPropertyMetas;
    ///
    NSArray *_keyPathPropertyMetas;
    NSArray *_mutiKeyPropertyMetas;
    NSUInteger _keyMappedCount;
    YYEncodingNSType _nsType;
    
    BOOL _hasCustomWillTransformFromDictionary;
    BOOL _hasCustomTransformFromDictionary;
    BOOL _hasCustomTransformToDictionary;
    BOOL _hasCustomClassFromDictionary;
}

@end


@implementation  ModelMeta

- (instancetype)initWithClass:(Class )cls{
    ClassInfo *classInfo = [[ClassInfo alloc] initWithClass:cls];
    if (!classInfo) {
        return nil;
    }
    self = [super init];
    ///不用转化的property
    NSSet *blackList = nil;
    if ([cls respondsToSelector:@selector(modelPropertyBlacklist)]) {
        NSArray *list = [(id<Model>)cls modelPropertyBlacklist];
        if (list) {
            blackList = [NSSet setWithArray:list];
        }
    }
    ///需要转化的property
    NSSet *whiteList = nil;
    if ([cls respondsToSelector:@selector(modelPropertyWhitelist)]) {
        NSArray *list = [(id<Model>)cls modelPropertyWhitelist];
        if (list) {
            whiteList = [NSSet setWithArray:list];
        }
    }
    ///字段对用的是 自定义的class
    NSDictionary *genericMapper = nil;
    if ([cls respondsToSelector:@selector(modelContainerPropertyGenericClass)]) {
        genericMapper = [(id<Model>)cls modelContainerPropertyGenericClass];
        if (genericMapper) {
            NSMutableDictionary *temp = [NSMutableDictionary new];
            [genericMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (![key isKindOfClass:[NSString class]]) return ;
                Class cls = object_getClass(obj);
                if (!cls) return;
                if (class_isMetaClass(cls)) {
                    temp[key] = obj;
                }else if ([obj isKindOfClass:[NSString class]]){
                    Class cls = NSClassFromString(obj);
                    if (cls) {
                        temp[key] = cls;
                    }
                }
            }];
            genericMapper = temp;
        }
    }
   // 所有属性的meta   递归查找所有的property 包括 父类及父类的父类
    NSMutableDictionary *allPropertysMeats = [NSMutableDictionary new];
    ClassInfo *curClassInfo = classInfo;
    while (curClassInfo && curClassInfo.superCls != nil) {
        for (ClassPropertyInfo *propertyInfo in curClassInfo.propertyInfos.allValues) {
            if (!propertyInfo.name)  continue ;
            ///不包含黑名单里面的
            if (blackList && [blackList containsObject:propertyInfo.name]) continue;
            ///白名单里面的
            if (whiteList && ![whiteList containsObject:propertyInfo.name]) continue;
            ///一个属性绑定一个 ModelPropertyMeta
            ModelPropertyMeta *propertyMeta = [ModelPropertyMeta metaWithClassInfo:curClassInfo propertyInfo:propertyInfo generic:genericMapper[propertyInfo.name]];
            if (!propertyMeta && !propertyMeta->_name) continue;
            if (!propertyMeta->_setter && !propertyMeta->_getter) continue;
            if (allPropertysMeats[propertyMeta->_name]) continue;
            allPropertysMeats[propertyMeta->_name] = propertyMeta;
        }
        curClassInfo = curClassInfo.supertClassInfo;
    }
    if (allPropertysMeats.count) _allPropertyMetas = allPropertysMeats.allValues.copy;
    
    NSMutableDictionary *mapper = [NSMutableDictionary new];
    NSMutableArray *keyPathPropertyMetas = [NSMutableArray new];
    NSMutableArray *multiKeyPropertyMetas = [NSMutableArray new];
    
    ///模型的字段跟json的字段不一样时 实现 modelCustomPropertyMapper
    if ([cls respondsToSelector:@selector(modelCustomPropertyMapper)]) {
        NSDictionary *customMapper = [(id<Model>)cls modelCustomPropertyMapper];
        [customMapper enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSString *mappedToKey, BOOL * _Nonnull stop) {
            ModelPropertyMeta *propertyMeta = allPropertysMeats[propertyName];
            if (!propertyMeta)  return ;
#warning -------   _next
            [allPropertysMeats removeObjectForKey:propertyName];
            if ([mappedToKey isKindOfClass:[NSString class]]) {
                if(mappedToKey.length == 0) return;
                propertyMeta->_mapedToKey = mappedToKey;
                NSArray *keyToPath = [mappedToKey componentsSeparatedByString:@"."];
                for (NSString *onePath in keyToPath) {
                    if (onePath.length == 0) {
                        NSMutableArray *temp = keyToPath.mutableCopy;
                        [temp removeObject:@""];
                        keyToPath = temp;
                    }
                }
                if (keyToPath.count > 1) {
                    propertyMeta->_mappedToKeyPath = keyToPath;
                    [keyPathPropertyMetas addObject:propertyMeta];
                }
                propertyMeta->_next = mapper[mappedToKey] ?: nil;
                mapper[mappedToKey] = propertyMeta;
               
            }else if ([mappedToKey isKindOfClass:[NSArray class]]){
                NSMutableArray *mappedToKeyArray = [NSMutableArray new];
                for (NSString *oneKey in (NSArray *)mappedToKey) {
                    if (![oneKey isKindOfClass:[NSString class]]) continue;
                    if (oneKey.length == 0 ) continue;
                    NSArray *keyPath = [oneKey componentsSeparatedByString:@"."];
                    if (keyPath.count > 1) {
                        [mappedToKeyArray addObject:keyPath];
                    }else{
                        [mappedToKeyArray addObject:oneKey];
                    }
                    if (!propertyMeta->_mapedToKey) {
                        propertyMeta->_mapedToKey = oneKey;
                        propertyMeta->_mappedToKeyPath = keyPath.count > 1 ? keyPath : nil;
                    }
                }
                if (!propertyMeta->_mapedToKey) return;
                propertyMeta->_mappedToKeyArray = mappedToKeyArray;
                [multiKeyPropertyMetas addObject:propertyMeta];
                propertyMeta->_next = mapper[mappedToKey] ?: nil;
                mapper[mappedToKey] = propertyMeta;
                
            }
        }];
    }
    [allPropertysMeats enumerateKeysAndObjectsUsingBlock:^(NSString *name, ModelPropertyMeta *meta , BOOL * _Nonnull stop) {
        meta->_mapedToKey = name;
        meta->_next = mapper[name] ?: nil;
        mapper[name] = meta;
    }];
    if (mapper) _maper = mapper;
    if (keyPathPropertyMetas) _keyPathPropertyMetas = keyPathPropertyMetas;
    if (multiKeyPropertyMetas) _mutiKeyPropertyMetas = multiKeyPropertyMetas;
//    [_maper enumerateKeysAndObjectsUsingBlock:^(NSString *name, ModelPropertyMeta *meta , BOOL * _Nonnull stop) {
//        if (meta->_next) {
//            ModelPropertyMeta *next = meta->_next;
//            NSLog(@"next = %@",next);
//        }
//    }];
    _classInfo = classInfo;
    _keyMappedCount = _allPropertyMetas.count;
    _nsType = ClassGetNsType(cls);
    
    _hasCustomWillTransformFromDictionary = [cls instancesRespondToSelector:@selector(modelCustomWillTransformFromDictionary:)];
    _hasCustomTransformFromDictionary = [cls instancesRespondToSelector:@selector(modelCustomTransformFromDictionary:)];
    _hasCustomTransformToDictionary = [cls instancesRespondToSelector:@selector(modelCustomTransformToDictionary:)];
    _hasCustomClassFromDictionary = [cls instancesRespondToSelector:@selector(modelCustomClassForDictionary:)];
    return self;
}

+ (instancetype)metaWithClass:(Class)cls{
    if(!cls) return nil;
    static CFMutableDictionaryRef cache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        cache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    ModelMeta *meta = CFDictionaryGetValue(cache, (__bridge const void *)(cls));
    dispatch_semaphore_signal(lock);
    if (!meta || meta->_classInfo.needUpdate) {
        meta = [[ModelMeta alloc] initWithClass:cls];
        if (meta) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(cache, (__bridge const void *)(cls),(__bridge const void *) meta);
            dispatch_semaphore_signal(lock);
        }
    }
    return meta;
}
@end

///
static force_inline NSNumber *ModelCreateNumberFromProperty(__unsafe_unretained id model, __unsafe_unretained ModelPropertyMeta *meta){
    switch (meta->_type & YYEncodingTypeMask) {
            ///用objc_msgSend 调用 get方法
        case YYEncodingTypeBool:{
            return @(((BOOL(*) (id,SEL))(void *)objc_msgSend)((id)model , meta->_getter));
            break;
        }
        case YYEncodingTypeInt8:{
            return @(((int8_t (*)(id , SEL))(void *)objc_msgSend)((id)model,meta->_getter));
            break;
        }
        case YYEncodingTypeUInt8:{
            return @(((uint8_t (*)(id,SEL ))(void *)objc_msgSend)((id)model,meta->_getter));
            break;
        }
        case YYEncodingTypeInt16: {
            return @(((int16_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case YYEncodingTypeUInt16: {
            return @(((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case YYEncodingTypeInt32: {
            return @(((int32_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case YYEncodingTypeUInt32: {
            return @(((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case YYEncodingTypeInt64: {
            return @(((int64_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case YYEncodingTypeUInt64: {
            return @(((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case YYEncodingTypeFloat: {
            float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case YYEncodingTypeDouble: {
            double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case YYEncodingTypeLongDouble: {
            double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        default:
            break;
    }
    return nil;
}

static force_inline void ModelSetNumberToProperty(__unsafe_unretained id model,
                                                  __unsafe_unretained NSNumber *num,
                                                  __unsafe_unretained ModelPropertyMeta *meta
                                                ){
    switch (meta->_type & YYEncodingTypeMask) {
        case YYEncodingTypeBool:{
            ((void(*)(id,SEL,BOOL))(void *)objc_msgSend)((id)model ,meta->_setter,num.boolValue);
        }
            break;
        case YYEncodingTypeInt8:{
            ((void(*)(id,SEL,int8_t))(void *)objc_msgSend)((id)model,meta->_setter,num.intValue);
        }
            break;
        case YYEncodingTypeUInt8:{
            ((void(*) (id,SEL,int8_t))(void *)objc_msgSend)((id)model,meta->_setter,num.intValue);
        }
            break;
        case YYEncodingTypeInt16:{
            ((void(*)(id,SEL,int16_t))(void *)objc_msgSend)((id)model,meta->_setter,num.intValue);
        }
            break;
        case YYEncodingTypeUInt16:{
            ((void (*)(id,SEL,int16_t))(void *)objc_msgSend)((id)model,meta->_setter,num.integerValue);
        }
            break;
        case YYEncodingTypeInt32:{
            ((void(*)(id,SEL,int32_t))(void *)objc_msgSend)((id)model,meta->_setter,(int32_t)num.unsignedIntegerValue);
        }
            break;
        case YYEncodingTypeUInt32:{
            ((void (*)(id,SEL,uint32_t))(void *)objc_msgSend)((id)model,meta->_setter,(uint32_t)num.unsignedIntegerValue);
        }
            break;
        case YYEncodingTypeInt64:{
            ((void(*)(id,SEL,int64_t))(void *)objc_msgSend)((id)model,meta->_setter,(int64_t)num.stringValue.longLongValue);
        }
            break;
        case YYEncodingTypeUInt64:{
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                 ((void (*)(id,SEL,int64_t))(void *)objc_msgSend)((id)model,meta->_setter,(int64_t)num.stringValue.propertyListFromStringsFileFormat);
            }else{
              ((void (*)(id,SEL,uint64_t))(void *)objc_msgSend)((id)model,meta->_setter,(uint64_t)num.stringValue.propertyListFromStringsFileFormat);
            }
        }
            break;
        case YYEncodingTypeFloat:{
            float n = num.floatValue;
            if (isnan(n) || isinf(n)) n = 0;
            ((void (*)(id ,SEL,float))(void *)objc_msgSend)((id)model,meta->_setter,n);
        }
            break;
        case YYEncodingTypeDouble:{
            double n = num.doubleValue;
            if (isnan(n) || isinf(n)) n = 0;
            ((void (*)(id ,SEL,float))(void *)objc_msgSend)((id)model,meta->_setter,n);
        }
            break;
        case YYEncodingTypeLongDouble:{
             long double n = num.doubleValue;
            if (isnan(n) || isinf(n)) n = 0;
            ((void (*)(id ,SEL,float))(void *)objc_msgSend)((id)model,meta->_setter,n);
        }
            break;
        default:
            break;
    }
}

static void ModelSetValueForProperty(__unsafe_unretained id model ,
                                     __unsafe_unretained id value,  __unsafe_unretained ModelPropertyMeta *meta){
    if (meta->_isCNumber) {
        NSNumber *num = NumberCreateFromID(value);
        ModelSetNumberToProperty(model, num, meta);
        if (num != nil) [num class];  ///先不让num 销毁
    }else if(meta->_nsType) {
        if (value == (id) kCFNull) {
            ((void (*)(id ,SEL,id))(void *)objc_msgSend)((id)model , meta->_setter , nil);
        }else{
            switch (meta->_nsType) {
                case YYEncodingTypeNSString:
                case YYEncodingTypeNSMutableString:{
                    if ([value isKindOfClass:[NSString class]]) {
                        if (meta->_nsType == YYEncodingTypeNSString) {
                            ((void (*)(id,SEL,NSString *))(void *)objc_msgSend)((id)model , meta->_setter , (NSString *)value);
                        }else{
                            ((void (*)(id,SEL,NSString *))(void *)objc_msgSend)((id)model , meta->_setter , ((NSString *)value).mutableCopy);
                        }
                    }else if ([value isKindOfClass:[NSNumber class]]){
                        ((void (*) (id ,SEL,id))(void *)objc_msgSend)((id)model , meta->_setter,(meta->_nsType == YYEncodingTypeNSString) ? (NSString *)value :((NSString *)value).mutableCopy);
                    }else if ([value isKindOfClass:[NSDate class]]){
                        NSMutableString *string = [[NSMutableString alloc] initWithData:(NSData *)value encoding:NSUTF8StringEncoding];
                        ((void (*)(id,SEL,id))(void *)objc_msgSend)((id)model,meta->_setter,string);
                    }else if ([value isKindOfClass:[NSURL class]]){
                          ((void (*) (id ,SEL,id))(void *)objc_msgSend)((id)model , meta->_setter,(meta->_nsType == YYEncodingTypeNSString) ? ((NSURL *)value).absoluteString :((NSURL *)value).absoluteString.mutableCopy);
                    }else if ([value isKindOfClass:[NSAttributedString class]]){
                          ((void (*) (id ,SEL,id))(void *)objc_msgSend)((id)model , meta->_setter,(meta->_nsType == YYEncodingTypeNSString) ? ((NSAttributedString *)value).string :((NSAttributedString *)value).string.mutableCopy);
                    }
                }
                    break;
                case YYEncodingTypeNSNumber:
                case YYEncodingTypeNSDecimalNumber:
                case YYEncodingTypeNSValue:{
                    if (meta->_nsType == YYEncodingTypeNSNumber) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, NumberCreateFromID(value));
                    } else if (meta->_nsType == YYEncodingTypeNSDecimalNumber) {
                        if ([value isKindOfClass:[NSDecimalNumber class]]) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        } else if ([value isKindOfClass:[NSNumber class]]) {
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[((NSNumber *)value) decimalValue]];
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, decNum);
                        } else if ([value isKindOfClass:[NSString class]]) {
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithString:value];
                            NSDecimal dec = decNum.decimalValue;
                            if (dec._length == 0 && dec._isNegative) {
                                decNum = nil; // NaN
                            }
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, decNum);
                        }
                    } else { // YYEncodingTypeNSValue
                        if ([value isKindOfClass:[NSValue class]]) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        }
                    }
                }
                    break;
                case YYEncodingTypeNSData:
                case YYEncodingTypeNSMutableData:{
                    if ([value isKindOfClass:[NSData class]]) {
                        if (meta->_nsType == YYEncodingTypeNSData) {
                             ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                        }else{
                            NSMutableData *data = ((NSData *)value).mutableCopy;
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, data);
                        }
                    }else if ([value isKindOfClass:[NSString class]]){
                        NSData *data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                        if (meta->_nsType == YYEncodingTypeNSMutableString) {
                            data = data.mutableCopy;
                        }
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, data);
                    }
                }
                    break;
                case YYEncodingTypeNSDate:{
                    if ([value isKindOfClass:[NSDate class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                    }else if ([value isKindOfClass:[NSString class]]){
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, NSDateFromString((NSString *)value));
                    }
                }
                    break;
                case YYEncodingTypeNSURL:{
                    if ([value isKindOfClass:[NSURL class]]) {
                          ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                    }else if ([value isKindOfClass:[NSString class]]){
                        ///去掉空格和换行
                        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                        NSString *str = [(NSString *)value stringByTrimmingCharactersInSet:set];
                        if (str.length == 0) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, nil);
                        }else{
                           ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, [[NSURL alloc] initWithString:str]);
                        }
                    }
                }
                    break;
                case YYEncodingTypeNSArray:
                case YYEncodingTypeNSMutableArray:{
                    ///数组元素是子自定义的
                    if (meta->_genericCls) {
                        NSArray *valueArray = nil;
                        if ([value isKindOfClass:[NSArray class]]) valueArray = (NSArray *)value;
                        else if ([value isKindOfClass:[NSSet class]])
                            valueArray = ((NSSet *)value).allObjects;
                        if (valueArray) {
                            NSMutableArray *objcArr = [NSMutableArray new];
                            for (id one in valueArray) {
                                if ([one isKindOfClass:meta->_genericCls]) {
                                    [objcArr addObject:one];
                                }else if ([one isKindOfClass:[NSDictionary class]]){
                                    Class cls = meta->_genericCls;
                                    if (meta->_hasCustomerClassFromDictionary) {
                                       cls = [(id<Model>)cls modelCustomClassForDictionary:one];
                                        if (!cls) cls = meta->_genericCls;
                                    }
                                    NSObject *obj = [cls new];
                                    [obj modelSetWithDictionary:(NSDictionary *)one];
                                    if (obj) {
                                        [objcArr addObject:obj];
                                    }
                                }
                            }
                            ((void(*)(id,SEL,id))(void *)objc_msgSend)((id)model,meta->_setter,objcArr);
                        }
                    }else{
                        if ([value isKindOfClass:[NSArray class]]) {
                            if (meta->_nsType == YYEncodingTypeNSArray) {
                                 ((void(*)(id,SEL,NSArray *))(void *)objc_msgSend)((id)model,meta->_setter,(NSArray *)value);
                            }else{
                                 ((void(*)(id,SEL,id))(void *)objc_msgSend)((id)model,meta->_setter,((NSArray *)value).mutableCopy);
                            }
                        }else if ([value isKindOfClass:[NSSet class]]){
                            if (meta->_nsType == YYEncodingTypeNSArray) {
                                  ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, ((NSSet *)value).allObjects);
                            }else{
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,                              meta->_setter,((NSSet *)value).allObjects.mutableCopy);
                            }
                        }
                    }
                }
                    break;
                case YYEncodingTypeNSDictionary:
                case YYEncodingTypeNSMutableDictionary:{
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        if (meta->_genericCls) {
                            NSMutableDictionary *dic = [NSMutableDictionary new];
                            [((NSDictionary *)value) enumerateKeysAndObjectsUsingBlock:^(NSString *oneKey, id oneValue, BOOL *stop) {
                                if ([oneValue isKindOfClass:[NSDictionary class]]) {
                                    Class cls = meta->_genericCls;
                                    if (meta->_hasCustomerClassFromDictionary) {
                                        cls = [cls modelCustomClassForDictionary:oneValue];
                                        if (!cls) cls = meta->_genericCls; // for xcode code coverage
                                    }
                                    NSObject *newOne = [cls new];
                                    [newOne modelSetWithDictionary:(id)oneValue];
                                    if (newOne) dic[oneKey] = newOne;
                                }
                            }];
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, dic);
                        }else{
                            if (meta->_nsType == YYEncodingTypeNSDictionary) {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, value);
                            } else {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,
                                                                               meta->_setter,
                                                                               ((NSDictionary *)value).mutableCopy);
                            }
                        }
                    }
                }
                    break;
                case YYEncodingTypeNSSet:
                case YYEncodingTypeNSMutableSet:{
                    NSSet *valueSet = nil;
                    if ([value isKindOfClass:[NSArray class]]) valueSet = [NSMutableSet setWithArray:value];
                    else if ([value isKindOfClass:[NSSet class]]) valueSet = ((NSSet *)value);
                    if (meta->_genericCls) {
                            NSMutableSet *set = [NSMutableSet new];
                            for (id one in valueSet) {
                                if ([one isKindOfClass:meta->_genericCls]) {
                                    [set addObject:one];
                                } else if ([one isKindOfClass:[NSDictionary class]]) {
                                    Class cls = meta->_genericCls;
                                    if (meta->_hasCustomerClassFromDictionary) {
                                        cls = [cls modelCustomClassForDictionary:one];
                                        if (!cls) cls = meta->_genericCls; // for xcode code coverage
                                    }
                                    NSObject *newOne = [cls new];
                                    [newOne modelSetWithDictionary:one];
                                    if (newOne) [set addObject:newOne];
                                }
                            }
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, set);
                        
                    }else{
                        if (meta->_nsType == YYEncodingTypeNSSet) {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, valueSet);
                        } else {
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,                    meta->_setter,((NSSet *)valueSet).mutableCopy);
                        }
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }else{
        BOOL isNull  = (value == (id)kCFNull);
        switch (meta->_type & YYEncodingTypeMask) {
            case YYEncodingTypeObject:{
                Class cls = meta->_genericCls ?: meta->_cls;
                if (isNull) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)nil);
                }else if ([value isKindOfClass:cls] || !cls){
                     ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)value);
                }else if ([value isKindOfClass:[NSDictionary class]]){
                    NSObject *obj = [cls new];
                    if (meta->_getter) {
                        obj = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
                    }
                    if (obj) {
                        [obj modelSetWithDictionary:(NSDictionary *)value];
                    }else{
                        if (meta->_hasCustomerClassFromDictionary) {
                            cls = [cls modelCustomClassForDictionary:value] ?:cls;
                        }
                        obj = [cls new];
                        [obj modelSetWithDictionary:value];
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)obj);
                    }
                }
            }
                break;
            case YYEncodingTypeClass:{
                if (isNull) {
                    ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter, (Class)NULL);
                } else {
                    Class cls = nil;
                    if ([value isKindOfClass:[NSString class]]) {
                        cls = NSClassFromString(value);
                        if (cls) {
                            ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter, (Class)cls);
                        }
                    } else {
                        cls = object_getClass(value);
                        if (cls) {
                            if (class_isMetaClass(cls)) {
                                ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model, meta->_setter, (Class)value);
                            }
                        }
                    }
                }
            }
                break;
            case YYEncodingTypeSEL:{
                if (isNull) {
                    ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, meta->_setter, (SEL)NULL);
                } else if ([value isKindOfClass:[NSString class]]) {
                    SEL sel = NSSelectorFromString(value);
                    if (sel) ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model, meta->_setter, (SEL)sel);
                }
            }
                break;
            case YYEncodingTypeBlock:{
                if (isNull) {
                    ((void (*)(id, SEL, void (^)(void)))(void *) objc_msgSend)((id)model, meta->_setter, (void (^)(void))NULL);
                } else if ([value isKindOfClass:GetBlockClass()]) {
                    ((void (*)(id, SEL, void (^)(void)))(void *) objc_msgSend)((id)model, meta->_setter, (void (^)(void))value);
                }
            }
                break;
                
            case YYEncodingTypeStruct:
            case YYEncodingTypeUnion:
            case YYEncodingTypeCArray:{
                if ([value isKindOfClass:[NSValue class]]) {
                    const char *valueType = ((NSValue *)value).objCType;
                    const char *metaType = meta->_info.typeEncoding.UTF8String;
                    if (valueType && metaType && strcmp(valueType, metaType) == 0) {
                        [model setValue:value forKey:meta->_name];
                    }
                }
            }
                break;
            case YYEncodingTypePointer:
            case YYEncodingTypeCString: {
                if (isNull) {
                    ((void (*)(id, SEL, void *))(void *) objc_msgSend)((id)model, meta->_setter, (void *)NULL);
                } else if ([value isKindOfClass:[NSValue class]]) {
                    NSValue *nsValue = value;
                    if (nsValue.objCType && strcmp(nsValue.objCType, "^v") == 0) {
                        ((void (*)(id, SEL, void *))(void *) objc_msgSend)((id)model, meta->_setter, nsValue.pointerValue);
                    }
                }
            }
            default:
                break;
        }
    }
}

typedef struct {
    void *modelMeta;  ///< _YYModelMeta
    void *model;      ///< id (self)
    void *dictionary; ///< NSDictionary (json)
} ModelSetContext;

////coreFoundation 中 注册遍历字典的方法
static void modelSetWithDictionaryFunction(const void *key , const void *value, void *ctx){
    ModelSetContext *context = ctx;
    __unsafe_unretained ModelMeta *meta = (__bridge ModelMeta *)context->modelMeta;
    __unsafe_unretained ModelPropertyMeta *propertyMeta = [meta->_maper objectForKey:(__bridge id)key];
    __unsafe_unretained id model = (__bridge id)context->model;
    while (propertyMeta) {
        if (propertyMeta->_setter) {
            ModelSetValueForProperty(model, (__bridge __unsafe_unretained id)(value), propertyMeta);
        }
        propertyMeta = propertyMeta->_next;
    };
}
////coreFoundation 中 注册遍历数组的方法
static void modelSetWithPropertyMetaArrayFunction(const void *_propertyMeta,void *_ctx){
    ModelSetContext *context = _ctx;
    __unsafe_unretained NSDictionary *dic = (__bridge NSDictionary *)(context->dictionary);
    __unsafe_unretained ModelPropertyMeta *propertyMeta = (__bridge ModelPropertyMeta *)_propertyMeta;
    if(!propertyMeta->_setter) return;
    id value = nil;
    if (propertyMeta->_mappedToKeyArray) {
        /////没有明白
    }else if (propertyMeta->_mappedToKeyPath){
        value = ValueForKeyPaths(dic, propertyMeta->_mappedToKeyPath);
    }else{
        value = [dic objectForKey:propertyMeta->_mapedToKey];
    }
    if (propertyMeta->_setter) {
        __unsafe_unretained id model = (__bridge id)context->model;
        ModelSetValueForProperty(model, value, propertyMeta);
    }
    
}

static id ModelToJsonObjectRecursive(NSObject *model){
    if ([model isKindOfClass:[NSString class]]) return model;
    if ([model isKindOfClass:[NSNumber class]]) return model;
    if ([model isKindOfClass:[NSDictionary class]]) {
        if ([NSJSONSerialization isValidJSONObject:model]) return model;
        NSMutableDictionary *resultDic = [NSMutableDictionary new];
        [(NSDictionary *)model enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *keyStr = [key isKindOfClass:[NSString class]] ? key : key.description;
            if (!keyStr) return ;
            id value = ModelToJsonObjectRecursive(obj);
            if (!value) value = (id)kCFNull;
            resultDic[keyStr] = value;
        }];
        return resultDic;
    }
    if ([model isKindOfClass:[NSSet class]]) {
        NSArray *array = ((NSSet *)model).allObjects;
        if ([NSJSONSerialization isValidJSONObject:array]) return array;
        NSMutableArray *resultArray = [NSMutableArray new];
        for (id obj in array) {
            if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                [resultArray addObject:obj];
            }else{
                id jsonObj = ModelToJsonObjectRecursive(model);
                if (jsonObj || jsonObj != (id)kCFNull) {
                    [resultArray addObject:obj];
                }
            }
        }
        return resultArray;
    }
    if ([model isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)model;
        if ([NSJSONSerialization isValidJSONObject:array]) return array;
        NSMutableArray *resulrArr = [NSMutableArray new];
        for (id value in array) {
            if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                [resulrArr addObject:value];
            }else{
                id jsonObj = ModelToJsonObjectRecursive(model);
                if (jsonObj || jsonObj != (id)kCFNull)
                    [resulrArr addObject:jsonObj];
            }
        }
        return resulrArr;
    }
    if ([model isKindOfClass:[NSURL class]]) return ((NSURL *)model).absoluteString;
    if ([model isKindOfClass:[NSAttributedString class]]) return ((NSAttributedString *)model).string;
    if ([model isKindOfClass:[NSDate class]])
        return [ISODateFormeters() stringFromDate:(NSDate *)model];
    if ([model isKindOfClass:[NSData class]])
        return [[NSMutableString alloc] initWithData:(NSData *)model encoding:NSUTF8StringEncoding];
    
    ModelMeta *meta = [[ModelMeta alloc] initWithClass:[model class]];
    if (!meta || meta->_keyMappedCount == 0) return nil;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:64];
    ///避免 在block 中 retain 或 relese
    __unsafe_unretained NSMutableDictionary *dic = result;
    [meta->_maper enumerateKeysAndObjectsUsingBlock:^(NSString  *_Nonnull key, ModelPropertyMeta * _Nonnull propertyMeta, BOOL * _Nonnull stop) {
        if(!propertyMeta->_getter) return ;
        id value = nil;
        if (propertyMeta->_isCNumber) {
            value = ModelCreateNumberFromProperty(model, propertyMeta);
        }else if (propertyMeta->_nsType){
            id v = ((id (*)(id,SEL))(void *)objc_msgSend)((id)model,propertyMeta->_getter);
            value = ModelToJsonObjectRecursive(v);
        }else{
            switch (propertyMeta->_type & YYEncodingTypeMask) {
                case YYEncodingTypeObject:{
                    id v = ((id (*)(id,SEL))(void *)objc_msgSend)((id)model,propertyMeta->_getter);
                    value = ModelToJsonObjectRecursive(v);
                    if (value == (id)kCFNull) value = nil;
                }
                    break;
                case YYEncodingTypeClass:{
                    Class cls = ((Class (*)(id,SEL))(void *)objc_msgSend)((id)model,propertyMeta->_getter);
                    value = cls ? NSStringFromClass(cls) : nil;
                }
                    break;
                case YYEncodingTypeSEL:{
                    SEL sel = ((SEL (*)(id,SEL))(void *)objc_msgSend)((id)model,propertyMeta->_getter);
                    value = sel ? NSStringFromSelector(sel) : nil;
                }
                    break;
                default:
                    break;
            }
        }
        if (!value) return;
        if (propertyMeta->_mappedToKeyPath) {
            ////主要是指针的引用  testAction   superDic 在连续的两次循环之间起桥梁作用  中间链接的字典  
            NSMutableDictionary *superDic = dic;
            NSMutableDictionary *subDic = nil;
            for (NSUInteger i = 0, max = propertyMeta->_mappedToKeyPath.count; i < max; i++) {
                NSString *key = propertyMeta->_mappedToKeyPath[i];
                if (i + 1 == max) { // end
                    if (!superDic[key]) superDic[key] = value;
                    break;
                }
                
                subDic = superDic[key];
                if (subDic) {
                    if ([subDic isKindOfClass:[NSDictionary class]]) {
                        subDic = subDic.mutableCopy;
                        superDic[key] = subDic;
                    } else {
                        break;
                    }
                } else {
                    subDic = [NSMutableDictionary new];
                    superDic[key] = subDic;
                }
                /// i == 0  此时 superDic 指向 (NSDictionary *)(dic[key])
                superDic = subDic;
                subDic = nil;
            }
        }else{
            if (!dic[propertyMeta->_mapedToKey]) {
                dic[propertyMeta->_mapedToKey] = value;
            }
        }
    }];
    if (meta->_hasCustomTransformToDictionary) {
        BOOL suc = [(id<Model>)model modelCustomTransformToDictionary:dic];
        if (!suc) return nil;
    }
    return result;
}
/// Add indent to string (exclude first line)
static NSMutableString *ModelDescriptionAddIndent(NSMutableString *desc, NSUInteger indent) {
    for (NSUInteger i = 0, max = desc.length; i < max; i++) {
        unichar c = [desc characterAtIndex:i];
        if (c == '\n') {
            for (NSUInteger j = 0; j < indent; j++) {
                [desc insertString:@"    " atIndex:i + 1];
            }
            i += indent * 4;
            max += indent * 4;
        }
    }
    return desc;
}

/// Generate a description string
static NSString *ModelDescription(NSObject *model) {
    static const int kDescMaxLength = 100;
    if (!model) return @"<nil>";
    if (model == (id)kCFNull) return @"<null>";
    if (![model isKindOfClass:[NSObject class]]) return [NSString stringWithFormat:@"%@",model];
    
    
    ModelMeta *modelMeta = [ModelMeta metaWithClass:model.class];
    switch (modelMeta->_nsType) {
        case YYEncodingTypeNSString: case YYEncodingTypeNSMutableString: {
            return [NSString stringWithFormat:@"\"%@\"",model];
        }
            
        case YYEncodingTypeNSValue:
        case YYEncodingTypeNSData: case YYEncodingTypeNSMutableData: {
            NSString *tmp = model.description;
            if (tmp.length > kDescMaxLength) {
                tmp = [tmp substringToIndex:kDescMaxLength];
                tmp = [tmp stringByAppendingString:@"..."];
            }
            return tmp;
        }
            
        case YYEncodingTypeNSNumber:
        case YYEncodingTypeNSDecimalNumber:
        case YYEncodingTypeNSDate:
        case YYEncodingTypeNSURL: {
            return [NSString stringWithFormat:@"%@",model];
        }
            
        case YYEncodingTypeNSSet: case YYEncodingTypeNSMutableSet: {
            model = ((NSSet *)model).allObjects;
        } // no break
            
        case YYEncodingTypeNSArray: case YYEncodingTypeNSMutableArray: {
            NSArray *array = (id)model;
            NSMutableString *desc = [NSMutableString new];
            if (array.count == 0) {
                return [desc stringByAppendingString:@"[]"];
            } else {
                [desc appendFormat:@"[\n"];
                for (NSUInteger i = 0, max = array.count; i < max; i++) {
                    NSObject *obj = array[i];
                    [desc appendString:@"    "];
                    [desc appendString:ModelDescriptionAddIndent(ModelDescription(obj).mutableCopy, 1)];
                    [desc appendString:(i + 1 == max) ? @"\n" : @";\n"];
                }
                [desc appendString:@"]"];
                return desc;
            }
        }
        case YYEncodingTypeNSDictionary: case YYEncodingTypeNSMutableDictionary: {
            NSDictionary *dic = (id)model;
            NSMutableString *desc = [NSMutableString new];
            if (dic.count == 0) {
                return [desc stringByAppendingString:@"{}"];
            } else {
                NSArray *keys = dic.allKeys;
                
                [desc appendFormat:@"{\n"];
                for (NSUInteger i = 0, max = keys.count; i < max; i++) {
                    NSString *key = keys[i];
                    NSObject *value = dic[key];
                    [desc appendString:@"    "];
                    [desc appendFormat:@"%@ = %@",key, ModelDescriptionAddIndent(ModelDescription(value).mutableCopy, 1)];
                    [desc appendString:(i + 1 == max) ? @"\n" : @";\n"];
                }
                [desc appendString:@"}"];
            }
            return desc;
        }
            
        default: {
            NSMutableString *desc = [NSMutableString new];
            [desc appendFormat:@"<%@: %p>", model.class, model];
            if (modelMeta->_allPropertyMetas.count == 0) return desc;
            
            // sort property names
            NSArray *properties = [modelMeta->_allPropertyMetas
                                   sortedArrayUsingComparator:^NSComparisonResult(ModelPropertyMeta *p1, ModelPropertyMeta *p2) {
                                       return [p1->_name compare:p2->_name];
                                   }];
            
            [desc appendFormat:@" {\n"];
            for (NSUInteger i = 0, max = properties.count; i < max; i++) {
                ModelPropertyMeta *property = properties[i];
                NSString *propertyDesc;
                if (property->_isCNumber) {
                    NSNumber *num = ModelCreateNumberFromProperty(model, property);
                    propertyDesc = num.stringValue;
                } else {
                    switch (property->_type & YYEncodingTypeMask) {
                        case YYEncodingTypeObject: {
                            id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = ModelDescription(v);
                            if (!propertyDesc) propertyDesc = @"<nil>";
                        } break;
                        case YYEncodingTypeClass: {
                            id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = ((NSObject *)v).description;
                            if (!propertyDesc) propertyDesc = @"<nil>";
                        } break;
                        case YYEncodingTypeSEL: {
                            SEL sel = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            if (sel) propertyDesc = NSStringFromSelector(sel);
                            else propertyDesc = @"<NULL>";
                        } break;
                        case YYEncodingTypeBlock: {
                            id block = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = block ? ((NSObject *)block).description : @"<nil>";
                        } break;
                        case YYEncodingTypeCArray: case YYEncodingTypeCString: case YYEncodingTypePointer: {
                            void *pointer = ((void* (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = [NSString stringWithFormat:@"%p",pointer];
                        } break;
                        case YYEncodingTypeStruct: case YYEncodingTypeUnion: {
                            NSValue *value = [model valueForKey:property->_name];
                            propertyDesc = value ? value.description : @"{unknown}";
                        } break;
                        default: propertyDesc = @"<unknown>";
                    }
                }
                
                propertyDesc = ModelDescriptionAddIndent(propertyDesc.mutableCopy, 1);
                [desc appendFormat:@"    %@ = %@",property->_name, propertyDesc];
                [desc appendString:(i + 1 == max) ? @"\n" : @";\n"];
            }
            [desc appendFormat:@"}"];
            return desc;
        }
    }
}

@implementation NSObject (Model)

+ (NSDictionary *)_yy_dictionaryWithJSON:(id)json {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}
+ (instancetype)modelWithJSON:(id)json {
    NSDictionary *dic = [self _yy_dictionaryWithJSON:json];
    return [self modelWithDictionary:dic];
}
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    
    Class cls = [self class];
    ModelMeta *modelMeta = [ModelMeta metaWithClass:cls];
    if (modelMeta->_hasCustomClassFromDictionary) {
        cls = [cls modelCustomClassForDictionary:dictionary] ?: cls;
    }
    
    NSObject *one = [cls new];
    if ([one modelSetWithDictionary:dictionary]) return one;
    return nil;
}
- (BOOL)modelSetWithDictionary:(NSDictionary *)dic{
    if (!dic || dic == (id)kCFNull) return  NO;
    ModelMeta *modelMeta = [[ModelMeta alloc] initWithClass:object_getClass(self)];
    if (modelMeta->_keyMappedCount == 0) return NO;
    if (modelMeta->_hasCustomWillTransformFromDictionary) {
        dic = [(id<Model>)self modelCustomWillTransformFromDictionary:dic];
        if (![dic isKindOfClass:[NSDictionary class]]) return NO;
    }
    
    ModelSetContext context = {0};
    context.modelMeta = (__bridge void *)(modelMeta);
    context.model = (__bridge void *)(self);
    context.dictionary =  (__bridge void *)(dic);
    
    if (modelMeta->_keyMappedCount > CFDictionaryGetCount((CFDictionaryRef) dic)) {
        CFDictionaryApplyFunction((CFDictionaryRef) dic, modelSetWithDictionaryFunction, &context);
        if (modelMeta->_keyPathPropertyMetas) {
            CFArrayApplyFunction((CFArrayRef)modelMeta->_keyPathPropertyMetas, CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_keyPathPropertyMetas)), modelSetWithPropertyMetaArrayFunction, &context);
        }else if (modelMeta->_mutiKeyPropertyMetas){
            ///等待
        }
    }else{
        CFArrayApplyFunction((CFArrayRef)modelMeta->_allPropertyMetas, CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_allPropertyMetas)), modelSetWithPropertyMetaArrayFunction, &context);
    }
    if (modelMeta->_hasCustomTransformFromDictionary) {
        return [ (id<Model>)self modelCustomTransformFromDictionary:dic];
    }
    return YES;
}

- (id)modelToJSONObject {
    /*
     Apple said:
     The top level object is an NSArray or NSDictionary.
     All objects are instances of NSString, NSNumber, NSArray, NSDictionary, or NSNull.
     All dictionary keys are instances of NSString.
     Numbers are not NaN or infinity.
     */
    id jsonObject = ModelToJsonObjectRecursive(self);
    if ([jsonObject isKindOfClass:[NSArray class]]) return jsonObject;
    if ([jsonObject isKindOfClass:[NSDictionary class]]) return jsonObject;
    return nil;
}
- (NSData *)modelToJSONData {
    id jsonObject = [self modelToJSONObject];
    if (!jsonObject) return nil;
    return [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:NULL];
}

- (NSString *)modelToJSONString {
    NSData *jsonData = [self modelToJSONData];
    if (jsonData.length == 0) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
- (NSString *)modelDescription {
    return ModelDescription(self);
}
- (id)modelCopy{
    if (self == (id)kCFNull) return self;
    ModelMeta *modelMeta = [ModelMeta metaWithClass:self.class];
    if (modelMeta->_nsType) return [self copy];
    
    NSObject *one = [self.class new];
    for (ModelPropertyMeta *propertyMeta in modelMeta->_allPropertyMetas) {
        if (!propertyMeta->_getter || !propertyMeta->_setter) continue;
        
        if (propertyMeta->_isCNumber) {
            switch (propertyMeta->_type & YYEncodingTypeMask) {
                case YYEncodingTypeBool: {
                    bool num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case YYEncodingTypeInt8:
                case YYEncodingTypeUInt8: {
                    uint8_t num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case YYEncodingTypeInt16:
                case YYEncodingTypeUInt16: {
                    uint16_t num = ((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case YYEncodingTypeInt32:
                case YYEncodingTypeUInt32: {
                    uint32_t num = ((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case YYEncodingTypeInt64:
                case YYEncodingTypeUInt64: {
                    uint64_t num = ((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case YYEncodingTypeFloat: {
                    float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case YYEncodingTypeDouble: {
                    double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } break;
                case YYEncodingTypeLongDouble: {
                    long double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)one, propertyMeta->_setter, num);
                } // break; commented for code coverage in next line
                default: break;
            }
        } else {
            switch (propertyMeta->_type & YYEncodingTypeMask) {
                case YYEncodingTypeObject:
                case YYEncodingTypeClass:
                case YYEncodingTypeBlock: {
                    id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)one, propertyMeta->_setter, value);
                } break;
                case YYEncodingTypeSEL:
                case YYEncodingTypePointer:
                case YYEncodingTypeCString: {
                    size_t value = ((size_t (*)(id, SEL))(void *) objc_msgSend)((id)self, propertyMeta->_getter);
                    ((void (*)(id, SEL, size_t))(void *) objc_msgSend)((id)one, propertyMeta->_setter, value);
                } break;
                case YYEncodingTypeStruct:
                case YYEncodingTypeUnion: {
                    @try {
                        NSValue *value = [self valueForKey:NSStringFromSelector(propertyMeta->_getter)];
                        if (value) {
                            [one setValue:value forKey:propertyMeta->_name];
                        }
                    } @catch (NSException *exception) {}
                } // break; commented for code coverage in next line
                default: break;
            }
        }
    }
    return one;
}

- (void)testAction{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:64];
    NSString *str = @"1.2.3.4.5.6.7";
    NSArray *sepArray = [str componentsSeparatedByString:@"."];
    ////superDic 在连续的两次循环之间起桥梁作用  中间链接的字典
    __unsafe_unretained NSMutableDictionary *superDic = dic;
    NSMutableDictionary *subDic;
    for (NSInteger i = 0, max = sepArray.count;i < max ; i++ ) {
        NSString *key = sepArray[i];
        if ((i + 1 ) == max) {
            superDic[key] = @"1234567";
            break;
        }
        subDic = [NSMutableDictionary new];
        superDic[key] = subDic;
        superDic = subDic;
    }
    
    NSLog(@"dic = %@",dic);
}
@end




@implementation  NSArray (Model)
+ (NSArray *)modelArrayWithClass:(Class)cls json:(id)json {
    if (!json) return nil;
    NSArray *arr = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSArray class]]) {
        arr = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        arr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![arr isKindOfClass:[NSArray class]]) arr = nil;
    }
    return [self modelArrayWithClass:cls array:arr];
}


+ (NSArray *)modelArrayWithClass:(Class)cls array:(NSArray *)arr {
    if (!cls || !arr) return nil;
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *dic in arr) {
        if (![dic isKindOfClass:[NSDictionary class]]) continue;
        NSObject *obj = [cls modelWithDictionary:dic];
        if (obj) [result addObject:obj];
    }
    return result;
}

@end


@implementation   NSDictionary (Model)

+ (NSDictionary *)modelDictionaryWithClass:(Class)cls json:(id)json {
    if (!json) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return [self modelDictionaryWithClass:cls dictionary:dic];
}

+ (NSDictionary *)modelDictionaryWithClass:(Class)cls dictionary:(NSDictionary *)dic {
    if (!cls || !dic) return nil;
    NSMutableDictionary *result = [NSMutableDictionary new];
    for (NSString *key in dic.allKeys) {
        if (![key isKindOfClass:[NSString class]]) continue;
        NSObject *obj = [cls modelWithDictionary:dic[key]];
        if (obj) result[key] = obj;
    }
    return result;
}

@end 
