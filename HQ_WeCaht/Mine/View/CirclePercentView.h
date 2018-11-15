//
//  CirclePercentView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/10.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CirclePercentTypeLine = 0,
    CirclePercentTypePie
} CirclePercentType;


@interface CirclePercentView : UIView


@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;
@property (nonatomic, strong) UILabel *percentLabel;



/*
 * Auto calculated radius base on View's frame
 *
 * @param percent percent of circle to display
 * @param lineWidth witdth of circle
 * @param clockwise determine clockwise
 * @param fillColor color inside cricle
 * @param strokeColor color of circle line
 * @param animatedColors colors array to animated. if this param is nil, Stroke color will be used to draw circle
 */

- (void)drawCircleWithPercent:(CGFloat)percent
                     duration:(CGFloat)duration
                    lineWidth:(CGFloat)lineWidth
                    clockwise:(BOOL)clockwise
                      lineCap:(NSString *)lineCap
                    fillColor:(UIColor *)fillColor
                  strokeColor:(UIColor *)strokeColor
               animatedColors:(NSArray *)colors;

- (void)drawPieChartWithPercent:(CGFloat)percent
                       duration:(CGFloat)duration
                      clockwise:(BOOL)clockwise
                      fillColor:(UIColor *)fillColor
                    strokeColor:(UIColor *)strokeColor
                 animatedColors:(NSArray *)colors;

/*
 * Start draw animation
 */
- (void)startAnimation;



@end
