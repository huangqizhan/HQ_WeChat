//
//  HQEdiateBottomView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/31.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEdiateBottomView.h"

@implementation HQEdiateBottomView

- (instancetype)initWithFrame:(CGRect)frame andClickButtonIndex:(void(^)(NSInteger index))callClickButtonIndex{
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
    NSArray *imageArray = @[@"ToolDraw",@"ToolMasaic",@"ToolViewEmotion",@"ToolClipping",@"ToolText"];
    for (int i = 0; i< 5; i++) {
        HQEdiateItem *item = [[HQEdiateItem alloc] initWithFram:CGRectMake(15 + i*width, 10, width, 60) ImageName:imageArray[i]   andIndex:i+1 andClickCallBackAction:^(NSInteger index) {
            if (_bottomEdiateViewClick)  _bottomEdiateViewClick(index);
        }];
        [self addSubview:item];
    }
    
}


@end



@interface HQEdiateItem ()

@property (nonatomic,strong) UIImageView *contentImageView;

@property (nonatomic,assign) NSInteger index;

@end

@implementation HQEdiateItem

- (instancetype)initWithFram:(CGRect)frame ImageName:(NSString *)imageName  andIndex:(NSInteger )index  andClickCallBackAction:(void (^)(NSInteger index))clickCallBackAction{
    self = [super initWithFrame:frame];
    if (self) {
        _clickBackAction = clickCallBackAction;
        self.index = index;
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - 30)/2.0, (self.height - 30)/2.0, 30, 30)];
        _contentImageView.image = [UIImage imageNamed:imageName];
        _contentImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_contentImageView];
        
        [self addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)buttonClickAction:(UIControl *)sender{
    if (_clickBackAction) _clickBackAction(self.index);
}
@end
