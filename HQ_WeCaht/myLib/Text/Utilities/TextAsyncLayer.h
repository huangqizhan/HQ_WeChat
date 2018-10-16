//
//  TextAsyncLayer.h
//  YYStudyDemo
//
//  Created by hqz on 2018/9/3.
//  Copyright © 2018年 hqz. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TextAsyncLayerDisplayTask;

@interface TextAsyncLayer : CALayer

///是否是异步绘图
@property BOOL displaysAsynchronously;

@end


@protocol TextAsyncLayerDelegate <NSObject>

- (TextAsyncLayerDisplayTask *)newTextAsyncLayerDisplayTask;

@end




@interface TextAsyncLayerDisplayTask : NSObject

////callback
@property (nonatomic,nullable,copy) void (^willDisplay)(CALayer *layer);
@property (nonatomic,nullable,copy) void (^display)(CGContextRef context , CGSize size, BOOL(^isCancel)(void));

@property (nonatomic,nullable,copy) void (^didDisplay)(CALayer *layer,BOOL isFinish);

@end

NS_ASSUME_NONNULL_END
