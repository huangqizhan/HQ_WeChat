//
//  ClassInfo.m
//  YYStudy
//
//  Created by hqz on 2018/4/17.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import "ClassInfo.h"

YYEncodingType YYEncodingGetType(const char *typeEncoding){
    char *type = (char *)typeEncoding;
    if (!type) return YYEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return YYEncodingTypeUnknown;
    YYEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= YYEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= YYEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= YYEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= YYEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= YYEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= YYEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= YYEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }
    
    len = strlen(type);
    if (len == 0) return YYEncodingTypeUnknown | qualifier;
    
    switch (*type) {
        case 'v': return YYEncodingTypeVoid | qualifier;
        case 'B': return YYEncodingTypeBool | qualifier;
        case 'c': return YYEncodingTypeInt8 | qualifier;
        case 'C': return YYEncodingTypeUInt8 | qualifier;
        case 's': return YYEncodingTypeInt16 | qualifier;
        case 'S': return YYEncodingTypeUInt16 | qualifier;
        case 'i': return YYEncodingTypeInt32 | qualifier;
        case 'I': return YYEncodingTypeUInt32 | qualifier;
        case 'l': return YYEncodingTypeInt32 | qualifier;
        case 'L': return YYEncodingTypeUInt32 | qualifier;
        case 'q': return YYEncodingTypeInt64 | qualifier;
        case 'Q': return YYEncodingTypeUInt64 | qualifier;
        case 'f': return YYEncodingTypeFloat | qualifier;
        case 'd': return YYEncodingTypeDouble | qualifier;
        case 'D': return YYEncodingTypeLongDouble | qualifier;
        case '#': return YYEncodingTypeClass | qualifier;
        case ':': return YYEncodingTypeSEL | qualifier;
        case '*': return YYEncodingTypeCString | qualifier;
        case '^': return YYEncodingTypePointer | qualifier;
        case '[': return YYEncodingTypeCArray | qualifier;
        case '(': return YYEncodingTypeUnion | qualifier;
        case '{': return YYEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return YYEncodingTypeBlock | qualifier;
            else
                return YYEncodingTypeObject | qualifier;
        }
        default: return YYEncodingTypeUnknown | qualifier;
    }
    return qualifier;
}


@implementation  ClassInvarInfo

- (instancetype)initWithIvar:(Ivar)ivar{
    if (!ivar) return nil;
    self = [super init];
    _ivar = ivar;
    const char *name = ivar_getName(_ivar);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    _offset = ivar_getOffset(ivar);
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        _type = YYEncodingGetType(typeEncoding);
    }
    return self;
}
@end

@implementation  ClassMethodInfo

- (instancetype)initWithMethed:(Method )metned{
    if (!metned) {
        return nil;
    }
    self = [super init];
    _method = metned;
    _sel = method_getName(_method);
    _imp = method_getImplementation(_method);
    const char *name = sel_getName(_sel);
    if (name){
        _name = [NSString stringWithUTF8String:name];
    }
    const char *typeEncoding = method_getTypeEncoding(_method);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    }
    char *returnType = method_copyReturnType(_method);
    if (returnType) {
        _returnTypeEcoding = [NSString stringWithUTF8String:returnType];
        free(returnType);
    }
    unsigned int argmentCount = method_getNumberOfArguments(_method);
    if (argmentCount > 0) {
        NSMutableArray *arr = [NSMutableArray new];
        for (unsigned int i = 0 ; i < argmentCount; i++) {
            char *argType = method_copyArgumentType(_method, i);
            NSString *argTyprStr = [NSString stringWithUTF8String:argType ? : nil];
            [arr addObject:argTyprStr ?:@""];
            if (argType) free(argType);
        }
        _argumentTypeEncoding = arr;
    }
    return self;
}

@end


@implementation  ClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property{
    if (!property) {
        return nil;
    }
    self = [super init];
    _property = property;
    const char *name = property_getName(_property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    YYEncodingType type = 0;
    unsigned int propertyCount = 0;
    objc_property_attribute_t *atts = property_copyAttributeList(_property, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++) {
//        NSString *n = [NSString stringWithUTF8String:atts[i].name];
//        NSString *va = [NSString stringWithUTF8String:atts[i].value];
        switch (atts[i].name[0]) {
            case 'T':{
                if (atts[i].value) {
                    _typeEncoding = [NSString stringWithUTF8String:atts[i].value];
                    type = YYEncodingGetType(atts[i].value);
                    if ((type & YYEncodingTypeMask) == YYEncodingTypeObject  && _typeEncoding.length) {
                        NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                        if (![scanner scanString:@"@\"" intoString:NULL]) {
                            continue;
                        }
                        NSString *className = nil;
                        if ([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&className]) {
                            if (className) {
                                _cls =  objc_getClass(className.UTF8String);
                            }
                        }
                        NSMutableArray *protocols = nil;
                        while ([scanner scanString:@"<" intoString:NULL]) {
                            NSString *protocol = nil;
                            if ([scanner scanString:@">" intoString:&protocol]) {
                                if (protocol.length) {
                                    if (protocols == nil) {
                                        protocols = [NSMutableArray new];
                                    }
                                    [protocols addObject:protocol];
                                }
                            }
                            [scanner scanString:@">" intoString:NULL];
                        }
                        _protocols = protocols;
                    }
                }
            } break;
            case 'V':{
                if (atts[i].value) {
                    _ivarName = [NSString stringWithUTF8String:atts[i].value];
                }
            }break;
            case 'R':{
                type |= YYEncodingTypePropertyReadonly;
            }break;
            case 'C':{
                type |= YYEncodingTypePropertyCopy;
            }break;
            case '&':{
                type |= YYEncodingTypePropertyRetain;
            }break;
            case 'N':{
                type |= YYEncodingTypePropertyNonatomic;
            }break;
            case 'D':{
                type |= YYEncodingTypePropertyDynamic;
            }break;
            case 'W':{
                type |= YYEncodingTypePropertyWeak;
            }break;
            case 'G':{
                type |= YYEncodingTypePropertyCustomGetter;
                if (atts[i].value) {
                    _getter = NSSelectorFromString([NSString stringWithUTF8String:atts[i].value]);
                }
            }break;
            case 'S':{
                type |= YYEncodingTypePropertyCustomSetter;
                if (atts[i].value) {
                    _setter = NSSelectorFromString([NSString stringWithUTF8String:atts[i].value]);
                }
            }break;
            default:
                break;
        }
    }
    if (atts) {
        free(atts);
        atts = NULL;
    }
    _type = type;
    
    if (_name.length) {
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[_name substringToIndex:1].uppercaseString,[_name substringFromIndex:1]]);
        }
    }
    return self;
}
@end



@implementation ClassInfo{
    BOOL _needUpdate;
}
- (instancetype)initWithClass:(Class)cls{
    if (!cls) {
        return nil;
    }
    self = [super init];
    _cls = cls;
    _superCls = class_getSuperclass(_cls);
    _isMeta = class_isMetaClass(_cls);
    if (!_isMeta) {
        _metaCls = objc_getMetaClass(class_getName(_cls));
    }
    _name = NSStringFromClass(_cls);
    [self _update];
    ///此处递归查找 父类及父类的父类
    _supertClassInfo = [self.class classInfoWithClass:_superCls];
    return self;
}

- (void)_update{
    _ivarInfos = nil;
    _methoInfos = nil;
    _propertyInfos = nil;
    Class cls = self.cls;
    unsigned int methodCount = 0;
    Method *method = class_copyMethodList(cls, &methodCount);
    if (method) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary new];
        _methoInfos = methodInfos;
        for (unsigned int i = 0; i<methodCount; i++) {
            ClassMethodInfo *info = [[ClassMethodInfo alloc] initWithMethed:method[i]];
            if (info.name) {
                methodInfos[info.name] = info;
            }
        }
        free(method);
    }
    unsigned int propertyCount = 0;
    objc_property_t *propertys = class_copyPropertyList(cls, &propertyCount);
    if (propertys) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        for (unsigned int i = 0; i < propertyCount; i++) {
            ClassPropertyInfo *info = [[ClassPropertyInfo alloc] initWithProperty:propertys[i]];
            if (info.name) {
                propertyInfos[info.name] = info;
            }
        }
        free(propertys);
    }
    
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(_cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        for (unsigned int i = 0; i<ivarCount; i++) {
            ClassInvarInfo *info = [[ClassInvarInfo alloc] initWithIvar:ivars[i]];
            if (info.name) ivarInfos[info.name] = info;
        }
        _ivarInfos = ivarInfos;
        free(ivars);
    }
    if (!_ivarInfos) _ivarInfos = @{};
    if (!_propertyInfos) _propertyInfos = @{};
    if (!_methoInfos) _methoInfos = @{};
    _needUpdate = NO;
}

- (void)setNeedUpDate{
    _needUpdate = YES;
}
- (BOOL)needUpdate{
    return _needUpdate;
}

+ (instancetype)classInfoWithClass:(Class)cls{
    if (!cls) {
        return nil;
    }
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    ///信号量 每次执行只能有一个信号量执行
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
        
    });
    //下面一组信号量 相当于一个线程锁 (给字典取值和赋值可能在不同的线程中 所以需要加上线程锁之类的机制)
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    ClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls)? metaCache : classCache, (__bridge const void *)(cls));
    if (info && info->_needUpdate) {
        [info _update];
    }
    dispatch_semaphore_signal(lock);
    
    if (!info) {
        info = [[ClassInfo alloc] initWithClass:cls];
        if (info) {
            //下面一组信号量 相当于一个线程锁 (给字典取值和赋值可能在不同的线程中 所以需要加上线程锁之类的机制)
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls),(__bridge const void *)(info));
            dispatch_semaphore_signal(lock);
        }
    }
    return info;
}
+ (instancetype)classInfoWithClassName:(NSString *)className{
    if (!className) {
        return nil;
    }
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}
@end
