//
//  HQPopoverView.m
//  HQ_WeChat
//
//  Created by 黄麒展 on 2017/8/27.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQPopoverView.h"

/// 边距
static float const PopoverViewMargin = 8.f;
///cell指定高度
static float const PopoverViewCellHeight = 40.f;
///箭头高度
static float const PopoverViewArrowHeight = 13.f;


float DegreesToRadians(float angle) {
    return angle*M_PI/180;
}

@interface HQPopoverView ()<UITableViewDelegate,UITableViewDataSource>

#pragma mark - UI
///当前窗口
@property (nonatomic, weak) UIWindow *keyWindow;
@property (nonatomic, strong) UITableView *tableView;
/// 遮罩层
@property (nonatomic, strong) UIView *shadeView;
/// 边框Layer
@property (nonatomic, weak) CAShapeLayer *borderLayer;
/// 点击背景阴影的手势
@property (nonatomic, weak) UITapGestureRecognizer *tapGesture;

#pragma mark ----- DATA
@property (nonatomic, copy) NSArray<HQPopoverAction *> *actions;
///窗口宽度
@property (nonatomic, assign) CGFloat windowWidth;
/// 窗口高度
@property (nonatomic, assign) CGFloat windowHeight;
/// 箭头指向, YES为向上, 反之为向下, 默认为YES.
@property (nonatomic, assign) BOOL isUpward;
@end

@implementation HQPopoverView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
}
@end





