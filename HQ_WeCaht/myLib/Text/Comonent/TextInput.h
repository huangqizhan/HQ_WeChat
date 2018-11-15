//
//  TextInput.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/8/13.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*
 - (NSUInteger)hash返回一个整数,这个数代表的就是当前对象的哈希值
 有一个很重要的规范 : 如果两个对象相等,他们的hash值必须相等, 如果某个类自定义了isEqual方法,并且这个类的实例有可能会被加入到集合中,一点要确保hash方法被重新定义
 */


///精确度
typedef NS_ENUM(NSUInteger , TextAffinity) {
    TextAffinityForward = 0,   ///字符前
    TextAffinityBackward = 1   ///字符后
};
#pragma mark  --- 文本位置 ----
@interface TextPosition : UITextPosition <NSCopying>
///偏移量
@property (nonatomic,readonly) CGFloat offset;
///精确度
@property (nonatomic,readonly) TextAffinity affinity;

+ (instancetype)positionWith:(CGFloat)offset ;
+ (instancetype)positionWith:(CGFloat)offset affinity:(TextAffinity)affinity;
- (NSComparisonResult)compare:(TextPosition *)otherPosition;

@end

#pragma mark ------- 文本区域 --------
@interface TextRange : UITextRange <NSCopying>

@property (nonatomic,readonly) TextPosition *start;
@property (nonatomic,readonly) TextPosition *end;
@property (nonatomic,readonly,getter=isEmpty) BOOL empty;
+ (instancetype)rangeWithRange:(NSRange)range;
+ (instancetype)rangeWithRange:(NSRange)range affinity:(TextAffinity) affinity;
+ (instancetype)rangeWithStart:(TextPosition *)start end:(TextPosition *)end;
+ (instancetype)defaultRange;

- (NSRange)asRange;


@end


@interface TextSelectionRect : UITextSelectionRect<NSCopying>


@property (nonatomic, readwrite) CGRect rect;
@property (nonatomic, readwrite) UITextWritingDirection writingDirection;
@property (nonatomic, readwrite) BOOL containsStart;
@property (nonatomic, readwrite) BOOL containsEnd;
@property (nonatomic, readwrite) BOOL isVertical;


@end



NS_ASSUME_NONNULL_END
