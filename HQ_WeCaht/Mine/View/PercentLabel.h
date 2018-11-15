//
//  PercentLabel.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/10.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <Foundation/Foundation.h>



@class PercentLayer;
@protocol PercentDelegate;

@interface PercentLabel : NSObject

@property (strong, nonatomic) CAMediaTimingFunction *timingFunction;


- (instancetype)initWithObject:(UIView *)object key:(NSString *)key from:(CGFloat)fromValue to:(CGFloat)toValue duration:(NSTimeInterval)duration;

- (void)start;


@end


@interface PercentLayer : CALayer

@property (weak, nonatomic) id<PercentDelegate> tweenDelegate;
@property (nonatomic) CGFloat fromValue;
@property (nonatomic) CGFloat toValue;
@property (nonatomic) NSTimeInterval tweenDuration;

- (instancetype)initWithFromValue:(CGFloat)fromValue toValue:(CGFloat)toValue duration:(CGFloat)duration;
- (void)startAnimation;
@end

@protocol PercentDelegate <NSObject>

- (void)layer:(PercentLayer *)layer didSetAnimationPropertyTo:(CGFloat)toValue;
- (void)layerDidStopAnimation;

@end
