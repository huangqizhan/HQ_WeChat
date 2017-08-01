//
//  HQEdiateBottomView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/31.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEdiateBottomView.h"
#import "HQEdiateToolInfo.h"
#import "HQEdiateImageBaseTools.h"




@implementation HQEdiateBottomView

- (instancetype)initWithFrame:(CGRect)frame andClickButtonIndex:(void(^)(HQEdiateToolInfo *toolInfo))callClickButtonIndex{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _bottomEdiateViewClick = callClickButtonIndex;
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews{
    CGFloat width  = (App_Frame_Width - 30)/5.0;
    NSArray *classes = [HQEdiateToolInfo toolsWithToolClass:[HQEdiateImageBaseTools class]];
    for (int i = 0; i< classes.count; i++) {
        HQEdiateItem *item = [[HQEdiateItem alloc] initWithFram:CGRectMake(15 + i*width, 10, width, 60)  andToolInfo:classes[i] andClickCallBackAction:^(HQEdiateToolInfo *info) {
            if (_bottomEdiateViewClick) {
                _bottomEdiateViewClick(info);
            }
        }];
        [self addSubview:item];
    }
    
}




@end



@interface HQEdiateItem ()

@property (nonatomic,strong) UIImageView *contentImageView;

@property (nonatomic,strong) HQEdiateToolInfo *info;

@end

@implementation HQEdiateItem

- (instancetype)initWithFram:(CGRect)frame andToolInfo:(HQEdiateToolInfo *)toolInfo   andClickCallBackAction:(void (^)(HQEdiateToolInfo *info))clickCallBackAction{
    self = [super initWithFrame:frame];
    if (self) {
        _clickBackAction = clickCallBackAction;
        self.info = toolInfo;
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - 30)/2.0, (self.height - 30)/2.0, 30, 30)];
        _contentImageView.image = toolInfo.iconImage;
        _contentImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_contentImageView];
        
        [self addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)buttonClickAction:(UIControl *)sender{
    if (_clickBackAction) _clickBackAction(self.info);
}



@end








