//
//  TextRubyAnnotation.h
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/7/19.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
/*
 该类为亚洲文字添加注释（拼音）   属性  主要封装 coreText-> CTRubyAnnotationRef
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface TextRubyAnnotation : NSObject<NSCopying,NSCoding>

///annotation 注释的对齐方式
@property (nonatomic) CTRubyAlignment alignment;
///I do not know
@property (nonatomic) CTRubyOverhang overhang;
///注释占原来文本的比例
@property (nonatomic) CGFloat sizeFactor;
///元文本上面的注释
@property (nullable, nonatomic,copy) NSString *textBefore;
///元文本下面的注释
@property (nullable, nonatomic,copy) NSString *textAfter;
/// I do not know 可能是台湾的用法
@property (nullable, nonatomic,copy) NSString *textInterCharacter;
///跟原来文本的排列方式相反  原来是横行排列  此注释就会竖向排列
@property (nullable, nonatomic , copy) NSString *textInline;

////根据CTRubyAnnotationRef 创建实例 NS_AVAILABLE_IOS
+ (instancetype)rubyWithCTRubyRef:(CTRubyAnnotationRef )ref NS_AVAILABLE_IOS(8_0);

- (nullable CTRubyAnnotationRef)CTRubyAnnotation CF_RETURNS_RETAINED NS_AVAILABLE_IOS(8_0);
@end


NS_ASSUME_NONNULL_END
