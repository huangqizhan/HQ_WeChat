//
//  HQCameraController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HQCameraControllerDelegate;

@interface HQCameraController : UIViewController


@property (nonatomic,assign)id <HQCameraControllerDelegate>delegate;

@property (nonatomic, assign) CGRect previewRect;

@property (nonatomic, assign) BOOL isStatusBarHiddenBeforeShowCamera;


@end





@protocol HQCameraControllerDelegate <NSObject>

- (void)HQCameraController:(HQCameraController *)cameraVC andCameraImage:(UIImage *)cameraImage andInfo:(NSDictionary *)info andIdentifer:(NSString *)identufer;

@end
