//
//  ARTestViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/10/18.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "ARTestViewController.h"
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>
#import "UIImage+Gallop.h"

typedef NS_OPTIONS(NSUInteger, CollisionCategory) {
    CollisionCategoryBottom  = 1 << 0,
    CollisionCategoryCube    = 1 << 1,
};


@interface ARTestViewController ()<ARSessionDelegate,ARSCNViewDelegate,SCNPhysicsContactDelegate>

@property (nonatomic,strong) UIButton *backButton;

///AR 视图    显示3D界面
@property (nonatomic,strong) ARSCNView *arScnView;

//AR会话，负责管理相机追踪配置及3D相机坐标
@property (nonatomic,strong) ARSession *arSesstion;

//会话追踪配置：负责追踪相机的运动
@property (nonatomic,strong) ARConfiguration *arSessionConfiguration;

///节点
//@property (nonatomic,strong) SCNNode *planeNode;

@property (nonatomic,strong) UILabel *messageLabel;

///花瓶  vase
@property (nonatomic,strong) UIButton *vaseButton;

///椅子 chair
@property (nonatomic,strong) UIButton *chairButton;

/// 蜡烛 candle
@property (nonatomic,strong) UIButton *candleButton;

/// 灯  lamp
@property (nonatomic,strong) UIButton *lampButton;

///刷新  🔄
@property (nonatomic,strong) UIButton *refershButton;

@end

@implementation ARTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.arScnView];
//    [self addPhysics];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.vaseButton];
    [self.view addSubview:self.candleButton];
    [self.view addSubview:self.chairButton];
    [self.view addSubview:self.lampButton];
    [self.view addSubview:self.refershButton];
}
- (void)backButtonClick:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.arSesstion pause];
    [UIApplication.sharedApplication setIdleTimerDisabled:NO];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.arSesstion runWithConfiguration:self.arSessionConfiguration];
    ///保持屏幕一直亮着
     [UIApplication.sharedApplication setIdleTimerDisabled:YES];
//     _arScnView.debugOptions =  SCNDebugOptionRenderAsWireframe;
//    [self addNodeView];
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
    [self showMessgaeWith:error.localizedDescription];
}

- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera{
    NSLog(@"cameraDidChangeTrackingState");
    [self showMessgaeWith:@"cameraDidChangeTrackingState"];
}
- (void)sessionWasInterrupted:(ARSession *)session{
    NSLog(@"sessionWasInterrupted");
    [self showMessgaeWith:@"sessionWasInterrupted"];
}

- (void)sessionInterruptionEnded:(ARSession *)session{
    NSLog(@"sessionInterruptionEnded");
    [self showMessgaeWith:@"Session resumed  回复"];
}
- (void)session:(ARSession *)session didOutputAudioSampleBuffer:(CMSampleBufferRef)audioSampleBuffer{
    NSLog(@"didOutputAudioSampleBuffer");
}
#pragma mark ------- ARSCNViewDelegate inhert  SCNSceneRendererDelegate   ARSessionObserver      -------
- (nullable SCNNode *)renderer:(id <SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor{
    return  renderer.scene.rootNode;
}
- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([anchor isMemberOfClass:[ARPlaneAnchor class]]) {
            [self showMessgaeWith:@"捕捉到平地"];
              //添加一个3D平面模型，ARKit只有捕捉能力，锚点只是一个空间位置，要想更加清楚看到这个空间，我们需要给空间添加一个平地   来放置3D模型
            //1.获取捕捉到的平地锚点
            ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
            //2.创建一个3D物体模型    （系统捕捉到的平地是一个不规则大小的长方形，这里将其变成一个长方形，）
            //参数分别是长宽高和圆角  创建几何模型
            SCNBox *plane = [SCNBox boxWithWidth:planeAnchor.extent.x*0.3 height:0 length:planeAnchor.extent.x*0.3 chamferRadius:0];
            //3.使用Material (材料) 渲染3D模型（默认模型是白色的，这里改成红色）
            plane.firstMaterial.diffuse.contents = [UIColor redColor];
            //4.创建一个基于3D物体模型的节点
            SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
            //5.设置节点的位置为捕捉到的平地的锚点的中心位置  SceneKit框架中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
            planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
            
            //self.planeNode = planeNode;
            [node addChildNode:planeNode];
            
            /////添加3D模型
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/vase/vase.scn"];
                //2.获取花瓶节点（一个场景会有多个节点，此处我们只写，花瓶节点则默认是场景子节点的第一个）
                //所有的场景有且只有一个根节点，其他所有节点都是根节点的子节点
                SCNNode *vaseNode = scene.rootNode.childNodes[0];
                //4.设置花瓶节点的位置为捕捉到的平地的位置，如果不设置，则默认为原点位置，也就是相机位置
                vaseNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
                //5.将花瓶节点添加到当前屏幕中
                //!!!此处一定要注意：花瓶节点是添加到代理捕捉到的节点中，而不是AR试图的根节点。因为捕捉到的平地锚点是一个本地坐标系，而不是世界坐标系
                [node addChildNode:vaseNode];
            });
        }
    });
}
//will刷新节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    
}
//did更新节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
}
///移除节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
}

#pragma mark --------- SCNSceneRendererDelegate  渲染  -------
- (void)renderer:(id <SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time{

}
- (void)renderer:(id <SCNSceneRenderer>)renderer didApplyAnimationsAtTime:(NSTimeInterval)time{

}
- (void)renderer:(id <SCNSceneRenderer>)renderer didSimulatePhysicsAtTime:(NSTimeInterval)time {

}
- (void)renderer:(id <SCNSceneRenderer>)renderer didApplyConstraintsAtTime:(NSTimeInterval)time{

}

- (void)renderer:(id <SCNSceneRenderer>)renderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time{
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time{
}
#pragma mark ------  SCNPhysicsContactDelegate  ---
//- (void)physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(SCNPhysicsContact *)contact{
//    NSLog(@"didBeginContact");
//}
//- (void)physicsWorld:(SCNPhysicsWorld *)world didUpdateContact:(SCNPhysicsContact *)contact{
//
//}
//- (void)physicsWorld:(SCNPhysicsWorld *)world didEndContact:(SCNPhysicsContact *)contact{
//
//}
- (void)showMessgaeWith:(NSString *)message{
    self.messageLabel.text = message;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.messageLabel.text = @"";
    });
}
/////添加几何体
- (void)addPhysics{
    SCNBox *bottomPlane = [SCNBox boxWithWidth:10 height:5 length:10 chamferRadius:2.0];
    SCNMaterial *bottomMaterial = [SCNMaterial new];
    
    // Make it transparent so you can't see it
    bottomMaterial.diffuse.contents = [UIColor redColor];
    //[UIColor colorWithWhite:1.0 alpha:0.0];
    bottomPlane.materials = @[bottomMaterial];
    SCNNode *bottomNode = [SCNNode nodeWithGeometry:bottomPlane];
    
    // Place it way below the world origin to catch all falling cubes
    bottomNode.position = SCNVector3Make(0, -10, 0);
    bottomNode.physicsBody = [SCNPhysicsBody
                              bodyWithType:SCNPhysicsBodyTypeKinematic
                              shape: nil];
    bottomNode.physicsBody.categoryBitMask = CollisionCategoryBottom;
    bottomNode.physicsBody.contactTestBitMask = CollisionCategoryCube;
    
    SCNScene *scene = self.arScnView.scene;
    [scene.rootNode addChildNode:bottomNode];
    scene.physicsWorld.contactDelegate = self;
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
#pragma mark ------- button Actions  ------
- (void)vaseButtonAction:(UIButton *)sender{
//    [self addNodeView];
}
- (void)candleButtonAction:(UIButton *)sender{
    
}
- (void)chairButtonAction:(UIButton *)sender{
    
}
- (void)lampButtonAction:(UIButton *)sender{
    
}
- (void)refershButtonAction:(UIButton *)sender{
    
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
        _arScnView.delegate = self;
        ////设置视图会话
        _arScnView.session = self.arSesstion;
        ///自动开启闪关灯
        _arScnView.autoenablesDefaultLighting = YES;
        // Make things look pretty 
        _arScnView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
        ///捕捉到的3D世界的测试场景   ARSCNDebugOptionShowWorldOrigin
        _arScnView.debugOptions =  ARSCNDebugOptionShowFeaturePoints;
        /// 场景  是添加所有几何体的类   （如果想渲染就必须先添加几何体 ）
        SCNScene *scene = [SCNScene new];
        _arScnView.scene = scene;
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
- (UILabel *)messageLabel{
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((App_Frame_Width - 100)/2.0, (APP_Frame_Height - 60)/2.0, 100, 20)];
        [self.view addSubview:_messageLabel];
    }
    return _messageLabel;
}
- (UIButton *)vaseButton{
    if (_vaseButton == nil) {
        _vaseButton = [[UIButton alloc] initWithFrame:CGRectMake(10, APP_Frame_Height/2.0, 40, 40)];
        [_vaseButton setTitle:@"⚱️" forState:UIControlStateNormal];
        [_vaseButton addTarget:self action:@selector(vaseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _vaseButton;
}
- (UIButton *)candleButton{
    if (_candleButton == nil) {
        _candleButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.vaseButton.bottom+10, 40, 40)];
        [_candleButton setTitle:@"🕯" forState:UIControlStateNormal];
        [_candleButton addTarget:self action:@selector(candleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _candleButton;
}
- (UIButton *)chairButton{
    if (_chairButton == nil) {
        _chairButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.candleButton.bottom+ 10, 40, 40)];
        [_chairButton setTitle:@"💺" forState:UIControlStateNormal];
        [_chairButton addTarget:self action:@selector(chairButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chairButton;
}
- (UIButton *)lampButton{
    if (_lampButton == nil) {
        _lampButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.chairButton.bottom+10, 40, 40)];
        [_lampButton setTitle:@"💡" forState:UIControlStateNormal];
        [_lampButton addTarget:self action:@selector(lampButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lampButton;
}
- (UIButton *)refershButton{
    if (_refershButton == nil) {
        _refershButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.lampButton.bottom, 40, 40)];
        [_refershButton setTitle:@"🔄" forState:UIControlStateNormal];
        [_refershButton addTarget:self action:@selector(refershButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refershButton;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end



/**
 ARKit  框架简介
 1，ARAnchor   表示一个物体在3D空间的位置和方向（ARAnchor通常称为物体的3D锚点，有点像UIKit框架中CALayer的Anchor）
 
 2，ARCamera   AR相机
 
 3，ARError
 
 4，ARFrame  主要是追踪相机当前的状态，这个状态不仅仅只是位置，还有图像帧及时间等参数
 
 5，ARHitTestResult：点击回调结果，这个类主要用于虚拟增强现实技术（AR技术）中现实世界与3D场景中虚拟物体的交互。 比如我们在相机中移动。拖拽3D虚拟物体，都可以通过这个类来获取ARKit所捕捉的结果
 
 6，ARLightEstimate是一个灯光效果，它可以让你的AR场景看起来更加的好
 
 7，ARPlaneAnchor   平地锚点。ARKit能够自动识别平地，并且会默认添加一个锚点到场景中，当然要想看到真实世界中的平地效果，需要我们自己使用SCNNode来渲染这个锚点
 
 8，ARPointCloud    点状渲染云，主要用于渲染场景
 
 9，ARSCNView    ARSCNView是3D的AR场景视图
 
 10，ARSession    是ARCamera 和 ARSNCView 之间的桥梁  是硬件跟软件之间的桥梁
 
 11，ARSessionConfiguration
 
 
 大概的工作流程   由ZRCamera 捕捉到数据 给 ARSession 后  session 创建SNCScene  把数据转成ARFrame
 再通过代理输出   添加3D模型 也需要创建一个场景  一个节点 最后添加到根节点上
 
 
 
 
 
 
 1 *   <ARKit> 的摄像头捕捉后在ARSNCView显示的画面      是现实世界的三维效果
 2 *   <SceneKit> 渲染显示3D模型场景   及3D模型
 3*   ARSNCView   添加SCNScene 3D场景和3D模型
 4*
 
 
 
 一：相机捕捉现实世界图像  主要显示3d 视图
 由ARKit来实现
 二：在图像中显示虚拟3D模型  场景渲染
 由SceneKit来实现
 
 ARAnchor：真实世界的位置和方向，使用它的方法驾到ARSession里面。
 ARPlaneAnchor：在ARSession中检测到真实世界平面的位置和方向的信息
 
 ARSNCView -> ARScne -> ARSNode ->  (几何体 比如:SCNBox)
 
 
 <ARKit>框架只负责将真实世界画面转变为一个3D场景，这一个转变的过程主要分为两个环节：由ARCamera负责捕捉摄像头画面，由ARSession负责搭建3D场景
 
 
 
 ARKit框架只负责捕捉真实世界的图像，虚拟世界的场景由SceneKit框架来加载。所以ARKit捕捉到的是一个平地的空间，而这个空间本身是没有东西的（一片空白，只是空气而已），要想让别人能够更加真实的看到这一个平地的空间，需要我们使用一个3D虚拟物体来放入这个空间
 
 
 
 每一个虚拟的物体都是一个节点SCNNode,每一个节点构成了一个场景SCNScene,无数个场景构成了3D世界
 
 */
