//
//  HQCutEdiateImageTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQCutEdiateImageTools.h"
#import "HQEdiateImageController.h"
#import "HQEdiateImageCutView.h"
#import "HQCutImageController.h"




@interface HQCutEdiateImageTools ()

@property (nonatomic) UIView *bottomMenuView;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIButton *rotateButton;
@property (nonatomic) UIButton *reBackButton;
@property (nonatomic) UIButton *confirmButton;
@property (nonatomic) HQEdiateImageCutView *gridView;


@end

@implementation HQCutEdiateImageTools


- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateToolInfo:(HQEdiateToolInfo *)toolInfo{
    return [super initWithEdiateController:ediateController andEdiateToolInfo:toolInfo];
}

- (void)setUpCurrentEdiateStatus{
//    [super setUpCurrentEdiateStatus];
    
    HQCutImageController *cutVc  = [[HQCutImageController alloc] init];
    cutVc.originalImage = self.imageEdiateController.originalImage;
    cutVc.transitioningDelegate = self.imageEdiateController;
    WEAKSELF;
    [cutVc setEndEdiateImageCallBack:^{
        [weakSelf clearDrawViewButtonAction:nil];
    }];
    [cutVc setEdiateCompliteCallBack:^(UIImage *image){
        [weakSelf clearDrawViewButtonAction:nil];
        [weakSelf.imageEdiateController refershUIWhenediateCompliteWithNewImage:image];
    }];
    [self.imageEdiateController presentViewController:cutVc animated:YES completion:nil];
}
- (void)clearCurrentEdiateStatus{
    [super clearCurrentEdiateStatus];
    [self.imageEdiateController resetZoomScaleWithAnimated:YES];
    [_gridView removeFromSuperview];
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _bottomMenuView.top = APP_Frame_Height;
    } completion:^(BOOL finished){
        [_bottomMenuView removeFromSuperview];
    }];
}
- (void)clearDrawViewButtonAction:(UIButton *)sender{
    [self.imageEdiateController resetZoomScaleWithAnimated:YES];
    [_gridView removeFromSuperview];
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _bottomMenuView.top = APP_Frame_Height;
    } completion:^(BOOL finished){
        [_bottomMenuView removeFromSuperview];
        [self.imageEdiateController resetBottomViewEdiateStatus];
    }];
}
- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock{
    completionBlock(self.imageEdiateController.ediateImageView.image,nil,nil);
}

- (void)confirmButtonAction:(UIButton *)sender{
    
}
- (void)rebackButtonAction:(UIButton *)sender{
    
}
- (void)roateButtonAction:(UIButton *)sender{
    
}
//图片
+ (UIImage*)defaultIconImage{
    return [UIImage imageNamed:@"ToolClipping"];
}

//工具名称
+ (NSString*)defaultTitle{
    return nil;
    
}

//显示顺序
+ (NSUInteger)orderNum{
    return 4;
}

@end



