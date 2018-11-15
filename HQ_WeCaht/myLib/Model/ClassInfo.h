//
//  ClassInfo.h
//  YYStudy
//
//  Created by hqz  QQ 757618403 on 2018/4/17.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_OPTIONS(NSUInteger, YYEncodingType) {
    YYEncodingTypeMask       = 0xFF, ///< mask of type value
    YYEncodingTypeUnknown    = 0, ///< unknown
    YYEncodingTypeVoid       = 1, ///< void
    YYEncodingTypeBool       = 2, ///< bool
    YYEncodingTypeInt8       = 3, ///< char / BOOL
    YYEncodingTypeUInt8      = 4, ///< unsigned char
    YYEncodingTypeInt16      = 5, ///< short
    YYEncodingTypeUInt16     = 6, ///< unsigned short
    YYEncodingTypeInt32      = 7, ///< int
    YYEncodingTypeUInt32     = 8, ///< unsigned int
    YYEncodingTypeInt64      = 9, ///< long long
    YYEncodingTypeUInt64     = 10, ///< unsigned long long
    YYEncodingTypeFloat      = 11, ///< float
    YYEncodingTypeDouble     = 12, ///< double
    YYEncodingTypeLongDouble = 13, ///< long double
    YYEncodingTypeObject     = 14, ///< id
    YYEncodingTypeClass      = 15, ///< Class
    YYEncodingTypeSEL        = 16, ///< SEL
    YYEncodingTypeBlock      = 17, ///< block
    YYEncodingTypePointer    = 18, ///< void*
    YYEncodingTypeStruct     = 19, ///< struct
    YYEncodingTypeUnion      = 20, ///< union
    YYEncodingTypeCString    = 21, ///< char*
    YYEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    YYEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    YYEncodingTypeQualifierConst  = 1 << 8,  ///< const
    YYEncodingTypeQualifierIn     = 1 << 9,  ///< in
    YYEncodingTypeQualifierInout  = 1 << 10, ///< inout
    YYEncodingTypeQualifierOut    = 1 << 11, ///< out
    YYEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    YYEncodingTypeQualifierByref  = 1 << 13, ///< byref
    YYEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    YYEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    YYEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    YYEncodingTypePropertyCopy         = 1 << 17, ///< copy
    YYEncodingTypePropertyRetain       = 1 << 18, ///< retain
    YYEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    YYEncodingTypePropertyWeak         = 1 << 20, ///< weak
    YYEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    YYEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    YYEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};


YYEncodingType YYEncodingGetType(const char *typeEncoding);



@interface ClassInvarInfo : NSObject

/// 属性变量结构体
@property (nonatomic, assign,readonly)Ivar ivar;
///变量名
@property (nonatomic, strong,readonly)NSString *name;
///变量的 offset
@property (nonatomic,assign,readonly) ptrdiff_t offset;
///变量的编码类型
@property (nonatomic,strong,readonly) NSString *typeEncoding;
///类型
@property (nonatomic,assign,readonly) YYEncodingType type;

- (instancetype)initWithIvar:(Ivar)ivar;

@end


@interface ClassMethodInfo :NSObject
///方法信息
@property (nonatomic, assign ,readonly) Method method;
///方法名称
@property (nonatomic, strong , readonly) NSString *name;
///方法 selector
@property (nonatomic, assign,readonly) SEL sel;
///方法的实现
@property (nonatomic,assign,readonly) IMP imp;
///方法类型
@property (nonatomic,strong,readonly) NSString *typeEncoding;
///方法的返回值类型
@property (nonatomic, strong,readonly) NSString *returnTypeEcoding;
///方法参数类型
@property (nullable , nonatomic,strong,readonly) NSArray<NSString *>*argumentTypeEncoding;

- (instancetype)initWithMethed:(Method )metned;

@end



@interface ClassPropertyInfo :NSObject
////属性信息
@property (nonatomic,assign,readonly) objc_property_t property;
///属性名称
@property (nonatomic,strong,readonly) NSString *name;
/// type
@property (nonatomic,assign,readonly) YYEncodingType type;
////encoding type
@property (nonatomic,strong,readonly) NSString *typeEncoding;
///变量名称
@property (nonatomic,strong,readonly) NSString *ivarName;
@property (nonatomic,assign,readonly) Class cls;
@property (nonatomic,strong,readonly) NSArray<NSString *> *protocols;
@property (nonatomic,assign,readonly) SEL getter;
@property (nonatomic,assign,readonly) SEL setter;

- (instancetype)initWithProperty:(objc_property_t)property;

@end



@interface ClassInfo : NSObject

@property (nonatomic,assign,readonly) Class cls;
@property (nullable,nonatomic,assign,readonly) Class superCls;
@property (nullable,nonatomic,assign,readonly) Class metaCls;
@property (nonatomic,assign,readonly)BOOL isMeta;
@property (nonatomic,strong,readonly)NSString *name;
@property (nullable,nonatomic,strong,readonly) ClassInfo *supertClassInfo;
@property (nullable,nonatomic,strong,readonly) NSDictionary <NSString *,ClassInvarInfo *> *ivarInfos;
@property (nullable,nonatomic,strong,readonly) NSDictionary <NSString *,ClassMethodInfo *> *methoInfos;
@property (nullable,nonatomic,strong,readonly) NSDictionary <NSString *,ClassPropertyInfo*> *propertyInfos;


- (BOOL)needUpdate;

- (instancetype)initWithClass:(Class)cls;

+ (instancetype)classInfoWithClass:(Class)cls;

+ (instancetype)classInfoWithClassName:(NSString *)className;


@end

