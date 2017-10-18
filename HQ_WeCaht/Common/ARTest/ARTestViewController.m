//
//  ARTestViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/10/18.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "ARTestViewController.h"
#import <ARKit/ARKit.h>
//#import <SceneKit/SceneKit.h>
#import "UIImage+Gallop.h"


@interface ARTestViewController ()<ARSessionDelegate,ARSCNViewDelegate>

@property (nonatomic,strong) UIButton *backButton;

///AR 视图    显示3D界面
@property (nonatomic,strong) ARSCNView *arScnView;

//AR会话，负责管理相机追踪配置及3D相机坐标
@property (nonatomic,strong) ARSession *arSesstion;

//会话追踪配置：负责追踪相机的运动
@property (nonatomic,strong) ARConfiguration *arSessionConfiguration;

///节点
//@property (nonatomic,strong) SCNNode *planeNode;

@end

@implementation ARTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.arScnView];
    [self.view addSubview:self.backButton];
}
- (void)backButtonClick:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.arSesstion runWithConfiguration:self.arSessionConfiguration options:ARSessionRunOptionResetTracking];
    [self addNodeView];
}
#pragma mark     ------  ARSessionDelegate   inherit   ARSessionObserver ------
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame{
    NSLog(@"didUpdateFrame");
}
- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor*>*)anchors{
    NSLog(@"didAddAnchors");
}
- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<ARAnchor*>*)anchors{
    NSLog(@"didUpdateAnchors");
}
- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<ARAnchor*>*)anchors{
    NSLog(@"didRemoveAnchors");
}
#pragma mark ------- ARSessionObserver ---

- (void)session:(ARSession *)session didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
}

- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera{
    NSLog(@"cameraDidChangeTrackingState");
}
- (void)sessionWasInterrupted:(ARSession *)session{
    NSLog(@"sessionWasInterrupted");
}

- (void)sessionInterruptionEnded:(ARSession *)session{
    NSLog(@"sessionInterruptionEnded");
}


#pragma mark ------- ARSCNViewDelegate -------

- (void)session:(ARSession *)session didOutputAudioSampleBuffer:(CMSampleBufferRef)audioSampleBuffer{
    
}
- (nullable SCNNode *)renderer:(id <SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor{
    return nil;
}
- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    
}

- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    
}
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    
}


-(void)addNodeView{
    //1.使用场景加载scn文件（scn格式文件是一个基于3D建模的文件，使用3DMax软件可以创建，这里系统有一个默认的3D飞机）--------许多3D模型，只需要替换文件名即可
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/chair/chair.scn"];
    //2.获取飞机节点（一个场景会有多个节点，此处我们只写，飞机节点则默认是场景子节点的第一个）
    //所有的场景有且只有一个根节点，其他所有节点都是根节点的子节点
    SCNNode *shipNode = scene.rootNode.childNodes[0];
    
    //椅子比较大，可以可以调整Z轴的位置让它离摄像头远一点，，然后再往下一点（椅子太高我们坐不上去）就可以看得全局一点
    shipNode.position = SCNVector3Make(0, -1, -1);//x/y/z/坐标相对于世界原点，也就是相机位置
    
    //3.将飞机节点添加到当前屏幕中
    [self.arScnView.scene.rootNode addChildNode:shipNode];
}

- (ARSession *)arSesstion{
    if (_arSesstion == nil) {
        _arSesstion = [[ARSession alloc] init];
        _arSesstion.delegate = self;
    }
    return _arSesstion;
}
- (ARSCNView *)arScnView{
    if (_arScnView == nil) {
        _arScnView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
        ////设置视图会话
        _arScnView.session = self.arSesstion;
        ///自动开启闪关灯
        _arScnView.autoenablesDefaultLighting = YES;
        _arScnView.delegate = self;
        
    }
    return _arScnView;
}
- (ARConfiguration *)arSessionConfiguration{
    if (_arSessionConfiguration == nil) {
        //1.创建世界追踪会话配置（使用ARWorldTrackingSessionConfiguration效果更加好），需要A9芯片支持 设备支持在 6s以上
        ARWorldTrackingConfiguration *configration = [[ARWorldTrackingConfiguration alloc] init];
        //2.设置追踪方向（追踪平面，后面会用到）
        configration.planeDetection =  ARPlaneDetectionHorizontal;
        //3.自适应灯光（相机从暗到强光快速过渡效果会平缓一些）
        _arSessionConfiguration.lightEstimationEnabled = YES;
        _arSessionConfiguration = configration;
    }
    return _arSessionConfiguration;
}
- (UIButton *)backButton{
    if (_backButton == nil) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake((App_Frame_Width-50)/2.0, APP_Frame_Height-60, 50, 50)];
        UIImage *image = [UIImage imageNamedFromMyBundle:@"navi_back.png"];
       image = [image lw_imageRotatedByDegrees:270];
        [_backButton setImage: image forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end



/**
 1 *   <ARKit> 的摄像头捕捉后在ARSNCView显示的画面      是现实世界的三维效果
 2 *   <SceneKit> 渲染显示3D模型场景   及3D模型
 3*   ARSNCView   添加SCNScene 3D场景和3D模型
 4*
 
 
 
 一：相机捕捉现实世界图像  主要显示3d 视图
 由ARKit来实现
 二：在图像中显示虚拟3D模型  场景渲染
 由SceneKit来实现
 
 
 
 <ARKit>框架只负责将真实世界画面转变为一个3D场景，这一个转变的过程主要分为两个环节：由ARCamera负责捕捉摄像头画面，由ARSession负责搭建3D场景
 
 */
