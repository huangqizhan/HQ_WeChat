//
//  HQCutEdiateImageTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
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
    [self.imageEdiateController presentViewController:cutVc animated:NO completion:nil];
    
    
//    
//    _bottomMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, APP_Frame_Height, App_Frame_Width, 80)];
//    _bottomMenuView.backgroundColor = BOTTOMBARCOLOR;
//    [self.imageEdiateController.view addSubview:_bottomMenuView];
//    
//    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 40, 40)];
//    [_cancelButton setImage:[UIImage imageNamed:@"EdiateImageDismissBut"] forState:UIControlStateNormal];
//    [_cancelButton addTarget:self action:@selector(clearDrawViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomMenuView addSubview:_cancelButton];
//    
//    _rotateButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width/4.0, 20, 40, 40)];
//    [_rotateButton setImage:[UIImage imageNamed:@"EdiateImageRotaio"] forState:UIControlStateNormal];
//    [_rotateButton addTarget:self action:@selector(roateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomMenuView addSubview:_rotateButton];
//    
//    _reBackButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width/2.0+20, 20, 40, 40)];
//    [_reBackButton setImage:[UIImage imageNamed:@"EditImageRevokeDisable_21x21_"] forState:UIControlStateNormal];
//    [_reBackButton addTarget:self action:@selector(rebackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomMenuView  addSubview:_reBackButton];
//    
//
//    
//    _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-60, 20, 40, 40)];
//    [_confirmButton setImage:[UIImage imageNamed:@"EdiateImageConfirm"] forState:UIControlStateNormal];
//    [_confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomMenuView addSubview:_confirmButton];
//
//    [UIView animateWithDuration:0.15 animations:^{
//        _bottomMenuView.top = APP_Frame_Height-80;
//    }];
//    
//    [self.imageEdiateController fixZoomScaleWithAnimated:YES];
//    
//    _gridView = [[HQEdiateImageCutView alloc] initWithSuperview:self.imageEdiateController.view frame:self.imageEdiateController.ediateImageView.frame];
//    
////    self.imageEdiateController.scrollView.frame = _gridView.frame;
////    self.imageEdiateController.scrollView.contentSize = CGSizeMake(_gridView.width, _gridView.height);
////    self.imageEdiateController.scrollView.backgroundColor = [UIColor redColor];
////    self.imageEdiateController.scrollView.contentInset = UIEdgeInsetsMake(180, 0, 300, 0);
//    
//    _gridView.backgroundColor = [UIColor clearColor];
//    _gridView.bgColor = [UIColor clearColor];
//    _gridView.gridColor = [[UIColor redColor] colorWithAlphaComponent:0.8];
//    _gridView.clipsToBounds = NO;
//    
//    self.imageEdiateController.ediateImageView.userInteractionEnabled = YES;
//    self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
//    self.imageEdiateController.scrollView.maximumZoomScale = 100;
//    self.imageEdiateController.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
//    self.imageEdiateController.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;

}
- (void)clearCurrentEdiateStatus{
    [super clearCurrentEdiateStatus];
    [self.imageEdiateController resetZoomScaleWithAnimated:YES];
    [_gridView removeFromSuperview];
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _bottomMenuView.top = APP_Frame_Height;
    } completion:^(BOOL finished){
        [_bottomMenuView removeFromSuperview];
        [self resetEdiateControllerOriginalStatus];
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
        [self resetEdiateControllerOriginalStatus];
    }];
}
- (void)resetEdiateControllerOriginalStatus{
    self.imageEdiateController.scrollView.frame = CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height);
    self.imageEdiateController.scrollView.contentSize = CGSizeMake(App_Frame_Width, APP_Frame_Height);
    [self.imageEdiateController resetImageViewFrame];
}
- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock{
    
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



