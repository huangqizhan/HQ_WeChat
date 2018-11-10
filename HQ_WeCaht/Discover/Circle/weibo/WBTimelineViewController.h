//
//  WBTimelineViewController.h
//  YYStudyDemo
//
//  Created by hqz on 2018/9/28.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 列表性能优化点:
 1: 布局     提前计算好每个控件的布局  只创建一次 之后存入缓存
 
 2: 绘制文本  自定义文本控件 采用coretext绘制 （可异步绘制）效率远高于UILabel
 
 3: 绘制图片  自定义图片展示控件  采用UIView的Layer.contents = image ;    从网络获取到图片之后 先解码 然后用 CGContextBitMap 绘制成位图 再缓存到内存中
 
 */
@interface WBTimelineViewController : UIViewController

@end

NS_ASSUME_NONNULL_END




@interface MyTableView : UITableView


@end
