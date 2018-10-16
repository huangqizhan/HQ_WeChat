//
//  TextRunDelegate.h
//  YYStudyDemo
//
//  Created by hqz on 2018/7/19.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

/*
 UIFont :
 
 ascender 基准线以上的高度
 descender 基准线以下的高度
 
 
 其中CTFramesetter是由CFAttributedString(NSAttributedString)初始化而来，可以认为它是CTFrame的一个Factory，通过传入CGPath生成相应的CTFrame并使用它进行渲染：直接以CTFrame为参数使用CTFrameDraw绘制或者从CTFrame中获取CTLine进行微调后使用CTLineDraw进行绘制。
 
 一个CTFrame是由一行一行的CLine组成，每个CTLine又会包含若干个CTRun(既字形绘制的最小单元)，通过相应的方法可以获取到不同位置的CTRun和CTLine，以实现对不同位置touch事件的响应。

 glyph = ctrun + (font color ...) 
 
 
 AttributedString某个段设置kCTRunDelegateAttributeName属性之后，CoreText使用它生成CTRun是通过当前Delegate的回调来获取自己的ascent，descent和width，而不是根据字体信息
 */

NS_ASSUME_NONNULL_BEGIN

/////
@interface TextRunDelegate : NSObject<NSCopying,NSCoding>

////绘制每一个CTRun 都会有一个delegate 回调  来获取相应的数据 width ascent  decent
- (nullable CTRunDelegateRef)CTRunDelegate CF_RETURNS_RETAINED;

////自定义的信息
@property (nullable, nonatomic, strong) NSDictionary *userInfo;

////一个CFRun  对应的距最上边的距离
@property (nonatomic) CGFloat ascent;

////一个CFRun  对应的距最下边的距离
@property (nonatomic) CGFloat descent;

////一个CFRun  对应的宽度
@property (nonatomic) CGFloat width;


@end

NS_ASSUME_NONNULL_END
