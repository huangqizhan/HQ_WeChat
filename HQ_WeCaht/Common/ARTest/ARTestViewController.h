//
//  ARTestViewController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/10/18.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ARTestType) {
    
    ARTest_Plane_Type,               /////添加明面 （首先是在虚拟三维中捕捉到平面 再在平面上添加3D模型）
    ARTest_Move_Type,               ////3D模型 跟随摄像头移动
    ARTest_Rotation_Type          ///3D模型旋转  
    
};


@interface ARTestViewController : UIViewController

@property (nonatomic,assign) ARTestType  type;

@end
