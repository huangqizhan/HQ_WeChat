//
//  HQCameraController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/20.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQCameraController.h"
#import "HQCameraManager.h"
#import "HQCameraSlider.h"
#import "UIImage+Resize.h"

#define SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE      0   //对焦框是否一直闪到对焦完成

#define SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA   1   //没有拍照功能的设备，是否给一张默认图片体验一下

//height
#define CAMERA_TOPVIEW_HEIGHT   44  //title
#define CAMERA_MENU_VIEW_HEIGH  44  //menu

//color
#define bottomContainerView_UP_COLOR     [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.f]       //bottomContainerView的上半部分
#define bottomContainerView_DOWN_COLOR   [UIColor colorWithRed:68/255.0f green:68/255.0f blue:68/255.0f alpha:1.f]       //bottomContainerView的下半部分
#define DARK_GREEN_COLOR        [UIColor colorWithRed:10/255.0f green:107/255.0f blue:42/255.0f alpha:1.f]    //深绿色
#define LIGHT_GREEN_COLOR       [UIColor colorWithRed:143/255.0f green:191/255.0f blue:62/255.0f alpha:1.f]    //浅绿色


//对焦
#define ADJUSTINT_FOCUS @"adjustingFocus"
#define LOW_ALPHA   0.7f
#define HIGH_ALPHA  1.0f



@interface HQCameraController ()<HQCameraManagerDelehate>{
    
    int alphaTimes;
    CGPoint currTouchPoint;
    UIButton *_recameraBut;
    UIButton *_useImageBut;
    UIImage *_currentCameraImage;
    NSDictionary *_currentImageInfo;
    NSString *_currentIdentifer;
}

@property (nonatomic,strong) UIImageView *cameraImageView;

@property (nonatomic, strong) HQCameraManager *cameraManager;

@property (nonatomic, strong) UIView *topContainerView;//顶部view
@property (nonatomic, strong) UILabel *topLbl;//顶部的标题

@property (nonatomic, strong) UIView *bottomContainerView;//除了顶部标题、拍照区域剩下的所有区域
@property (nonatomic, strong) UIView *cameraMenuView;//网格、闪光灯、前后摄像头等按钮
@property (nonatomic, strong) NSMutableSet *cameraBtnSet;

@property (nonatomic, strong) UIView *doneCameraUpView;
@property (nonatomic, strong) UIView *doneCameraDownView;

//对焦
@property (nonatomic, strong) UIImageView *focusImageView;

@property (nonatomic, strong) HQCameraSlider *scSlider;


@end

@implementation HQCameraController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        alphaTimes = -1;
        currTouchPoint = CGPointZero;
        _cameraBtnSet = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //navigation bar
    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    //status bar
//    if (!self.navigationController) {
//        _isStatusBarHiddenBeforeShowCamera = [UIApplication sharedApplication].statusBarHidden;
//        if ([UIApplication sharedApplication].statusBarHidden == NO) {
//            //iOS7，需要plist里设置 View controller-based status bar appearance 为NO
//            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
//        }
//    }
    if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = YES;
    [self creatCamreaManager];
    [self addTopViewWithText:@"拍照"];
    [self addbottomContainerView];
    [self addCameraMenuView];
    [self addFocusView];
    [self addCameraCover];
    [self addPinchGesture];
    
    [_cameraManager.session startRunning];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"相机不支持");
    }
}
- (void)creatCamreaManager{
    HQCameraManager *manager = [[HQCameraManager alloc] init];
    manager.delegate = self;
    //AvcaptureManager
    if (CGRectEqualToRect(_previewRect, CGRectZero)) {
        self.previewRect = CGRectMake(0, 0, SC_APP_SIZE.width, SC_APP_SIZE.width + CAMERA_TOPVIEW_HEIGHT);
    }
    [manager configureWithParentLayer:self.view previewRect:_previewRect];
    self.cameraManager = manager; 
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = NO;
}
#pragma mark -------------UI---------------
//顶部标题
- (void)addTopViewWithText:(NSString*)text {
    if (!_topContainerView) {
        CGRect topFrame = CGRectMake(0, 0, SC_APP_SIZE.width, CAMERA_TOPVIEW_HEIGHT);
        
        UIView *tView = [[UIView alloc] initWithFrame:topFrame];
        tView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tView];
        self.topContainerView = tView;
        
        UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, topFrame.size.width, topFrame.size.height)];
        emptyView.backgroundColor = [UIColor blackColor];
        emptyView.alpha = 0.4f;
        [_topContainerView addSubview:emptyView];
        
        topFrame.origin.x += 10;
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, topFrame.size.height)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont systemFontOfSize:25.f];
        [_topContainerView addSubview:lbl];
        self.topLbl = lbl;
    }
    _topLbl.text = text;
}

//bottomContainerView，总体
- (void)addbottomContainerView {
    
    CGFloat bottomY = _cameraManager.previewLayer.frame.origin.y + _cameraManager.previewLayer.frame.size.height;
    CGRect bottomFrame = CGRectMake(0, bottomY, SC_APP_SIZE.width, SC_APP_SIZE.height - bottomY);
    
    UIView *view = [[UIView alloc] initWithFrame:bottomFrame];
    view.backgroundColor = bottomContainerView_UP_COLOR;
    [self.view addSubview:view];
    self.bottomContainerView = view;
}

//拍照菜单栏
- (void)addCameraMenuView {
    
    //拍照按钮
    CGFloat downH = (isHigherThaniPhone4_SC ? CAMERA_MENU_VIEW_HEIGH : 0);
    CGFloat cameraBtnLength = 90;
   UIButton *cameraBut = [self buildButton:CGRectMake((SC_APP_SIZE.width - cameraBtnLength) / 2, (_bottomContainerView.frame.size.height - downH - cameraBtnLength) / 2 , cameraBtnLength, cameraBtnLength)
         normalImgStr:@"shot"
      highlightImgStr:@"shot_h"
       selectedImgStr:@""
               action:@selector(takePictureBtnPressed:)
           parentView:_bottomContainerView];
    
    
    //拍照的菜单栏view（屏幕高度大于480的，此view在上面，其他情况在下面）
    CGFloat menuViewY = (isHigherThaniPhone4_SC ? SC_DEVICE_SIZE.height - CAMERA_MENU_VIEW_HEIGH : 0);
    UIView *menuView = [[UIView alloc] initWithFrame:CGRectMake(0, menuViewY, self.view.frame.size.width, CAMERA_MENU_VIEW_HEIGH)];
    menuView.backgroundColor = (isHigherThaniPhone4_SC ? bottomContainerView_DOWN_COLOR : [UIColor clearColor]);
    [self.view addSubview:menuView];
    self.cameraMenuView = menuView;
    
    _recameraBut = [[UIButton alloc] initWithFrame:CGRectMake(20, cameraBut.bottom, 80, 30)];
    [_recameraBut setTitle:@"重新拍照" forState:UIControlStateNormal];
    [_recameraBut addTarget:self action:@selector(reCaputueCameraImage) forControlEvents:UIControlEventTouchUpInside];
    _recameraBut.hidden = YES;
    [_bottomContainerView addSubview:_recameraBut];
    
    _useImageBut = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-100, cameraBut.bottom, 80, 30)];
    [_useImageBut addTarget:self action:@selector(useImageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _useImageBut.hidden = YES;
    [_useImageBut setTitle:@"使用照片" forState:UIControlStateNormal];
    [_bottomContainerView addSubview:_useImageBut];
    
    [self addMenuViewButtons];
}

//拍照菜单栏上的按钮
- (void)addMenuViewButtons {
    NSMutableArray *normalArr = [[NSMutableArray alloc] initWithObjects:@"close_cha.png", @"camera_line.png", @"switch_camera.png", @"flashing_off.png", nil];
    NSMutableArray *highlightArr = [[NSMutableArray alloc] initWithObjects:@"close_cha_h.png", @"", @"", @"", nil];
    NSMutableArray *selectedArr = [[NSMutableArray alloc] initWithObjects:@"", @"camera_line_h.png", @"switch_camera_h.png", @"", nil];
    
    NSMutableArray *actionArr = [[NSMutableArray alloc] initWithObjects:@"dismissBtnPressed:", @"gridBtnPressed:", @"switchCameraBtnPressed:", @"flashBtnPressed:", nil];
    
    CGFloat eachW = SC_APP_SIZE.width / actionArr.count;
    
    [UIImage drawALineWithFrame:CGRectMake(eachW, 0, 1, CAMERA_MENU_VIEW_HEIGH) andColor:rgba_SC(102, 102, 102, 1.0000) inLayer:_cameraMenuView.layer];
    
    
    //屏幕高度大于480的，后退按钮放在_cameraMenuView；小于480的，放在_bottomContainerView
    for (int i = 0; i < actionArr.count; i++) {
        
        CGFloat theH = (!isHigherThaniPhone4_SC && i == 0 ? _bottomContainerView.frame.size.height : CAMERA_MENU_VIEW_HEIGH);
        UIView *parent = (!isHigherThaniPhone4_SC && i == 0 ? _bottomContainerView : _cameraMenuView);
        
        UIButton * btn = [self buildButton:CGRectMake(eachW * i, 0, eachW, theH)
                              normalImgStr:[normalArr objectAtIndex:i]
                           highlightImgStr:[highlightArr objectAtIndex:i]
                            selectedImgStr:[selectedArr objectAtIndex:i]
                                    action:NSSelectorFromString([actionArr objectAtIndex:i])
                                parentView:parent];
        
        btn.showsTouchWhenHighlighted = YES;
        [_cameraBtnSet addObject:btn];
    }
}

- (UIButton*)buildButton:(CGRect)frame
            normalImgStr:(NSString*)normalImgStr
         highlightImgStr:(NSString*)highlightImgStr
          selectedImgStr:(NSString*)selectedImgStr
                  action:(SEL)action
              parentView:(UIView*)parentView {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (normalImgStr.length > 0) {
        UIImage *image = [UIImage imageNamed:normalImgStr];
        [btn setImage:image forState:UIControlStateNormal];
    }
    if (highlightImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:highlightImgStr] forState:UIControlStateHighlighted];
    }
    if (selectedImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:selectedImgStr] forState:UIControlStateSelected];
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [parentView addSubview:btn];
    
    return btn;
}

//对焦的框
- (void)addFocusView {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"touch_focus_x.png"]];
    imgView.alpha = 0;
    [self.view addSubview:imgView];
    self.focusImageView = imgView;
}
//拍完照后的遮罩
- (void)addCameraCover {
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SC_APP_SIZE.width, 0)];
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    self.doneCameraUpView = upView;
    
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, _bottomContainerView.frame.origin.y, SC_APP_SIZE.width, 0)];
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    self.doneCameraDownView = downView;
}

- (void)showCameraCover:(BOOL)toShow andComplittion:(void (^)())complition{
    
    [UIView animateWithDuration:0.15f animations:^{
        CGRect upFrame = _doneCameraUpView.frame;
        upFrame.size.height = (toShow ? SC_APP_SIZE.width / 2 + CAMERA_TOPVIEW_HEIGHT : 0);
        _doneCameraUpView.frame = upFrame;
        
        CGRect downFrame = _doneCameraDownView.frame;
        downFrame.origin.y = (toShow ? SC_APP_SIZE.width / 2 + CAMERA_TOPVIEW_HEIGHT : _bottomContainerView.frame.origin.y);
        downFrame.size.height = (toShow ? SC_APP_SIZE.width / 2 : 0);
        _doneCameraDownView.frame = downFrame;
    }completion:^(BOOL finished) {
        if (finished) {
            complition();
        }
    }];
}
//伸缩镜头的手势
- (void)addPinchGesture {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinch];
    
    //横向
    //    CGFloat width = _previewRect.size.width - 100;
    //    CGFloat height = 40;
    //    SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake((SC_APP_SIZE.width - width) / 2, SC_APP_SIZE.width + CAMERA_MENU_VIEW_HEIGH - height, width, height)];
    
    //竖向
    CGFloat width = 40;
    CGFloat height = _previewRect.size.height - 100;
    HQCameraSlider *slider = [[HQCameraSlider alloc] initWithFrame:CGRectMake(_previewRect.size.width - width, (_previewRect.size.height + CAMERA_MENU_VIEW_HEIGH - height) / 2, width, height) direction:HQSliderDirectionVertical];
    slider.alpha = 0.f;
    slider.minValue = MIN_PINCH_SCALE_NUM;
    slider.maxValue = MAX_PINCH_SCALE_NUM;
    
    WEAKSELF_SC
    [slider buildDidChangeValueBlock:^(CGFloat value) {
        [weakSelf_SC.cameraManager pinchCameraViewWithScalNum:value];
    }];
    [slider buildTouchEndBlock:^(CGFloat value, BOOL isTouchEnd) {
        [weakSelf_SC setSliderAlpha:isTouchEnd];
    }];
    
    [self.view addSubview:slider];
    
    self.scSlider = slider;
}
- (void)setSliderAlpha:(BOOL)isTouchEnd {
    if (_scSlider) {
        _scSlider.isSliding = !isTouchEnd;
        
        if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
            double delayInSeconds = 3.88;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
                    [UIView animateWithDuration:0.3f animations:^{
                        _scSlider.alpha = 0.f;
                    }];
                }
            });
        }
    }
}
//监听对焦是否完成了
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:ADJUSTINT_FOCUS]) {
        BOOL isAdjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
        //        SCDLog(@"Is adjusting focus? %@", isAdjustingFocus ? @"YES" : @"NO" );
        //        SCDLog(@"Change dictionary: %@", change);
        if (!isAdjustingFocus) {
            alphaTimes = -1;
        }
    }
}
- (void)showFocusInPoint:(CGPoint)touchPoint {
    
    [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        int alphaNum = (alphaTimes % 2 == 0 ? HIGH_ALPHA : LOW_ALPHA);
        self.focusImageView.alpha = alphaNum;
        alphaTimes++;
        
    } completion:^(BOOL finished) {
        
        if (alphaTimes != -1) {
            [self showFocusInPoint:currTouchPoint];
        } else {
            self.focusImageView.alpha = 0.0f;
        }
    }];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //    [super touchesBegan:touches withEvent:event];
    
    alphaTimes = -1;
    
    UITouch *touch = [touches anyObject];
    currTouchPoint = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(_cameraManager.previewLayer.bounds, currTouchPoint) == NO) {
        return;
    }
    
    [_cameraManager focusInPoint:currTouchPoint];
    
    //对焦框
    [_focusImageView setCenter:currTouchPoint];
    _focusImageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _focusImageView.alpha = 1.f;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _focusImageView.alpha = 0.f;
        } completion:nil];
    }];
}
#pragma mark -------------button actions---------------
//拍照页面，拍照按钮
- (void)takePictureBtnPressed:(UIButton*)sender {
#if SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"设备不支持拍照功能T_T");
        return;
    }
#endif
    
    [self showCameraCover:YES andComplittion:^{
        
    }];
    
    __block UIActivityIndicatorView *actiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    actiView.center = CGPointMake(self.view.center.x, self.view.center.y - CAMERA_TOPVIEW_HEIGHT);
    [actiView startAnimating];
    [self.view addSubview:actiView];
    
    WEAKSELF_SC
    [_cameraManager takePicture:^(UIImage *stillImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[HQImageManager manager] NewSavePhotoWithImage:stillImage completion:^(UIImage *photo, NSDictionary *info, NSString *identifier) {
                _currentCameraImage = photo;
                _currentImageInfo = info;
                _currentIdentifer = identifier;
            } faild:^(NSError *error) {
                NSLog(@"保存图片失败");
            }];
        });
        [actiView stopAnimating];
        [actiView removeFromSuperview];
        actiView = nil;
        
        double delayInSeconds = 2.f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            sender.userInteractionEnabled = YES;
            [weakSelf_SC showCameraCover:NO andComplittion:^{
                _currentCameraImage = stillImage;
                [weakSelf_SC ShowCurrentCameraImageWith:stillImage];
            }];
        });
        
    }];
}
- (void)didCapturePhoto:(UIImage *)stillImage{
    
}
- (void)ShowCurrentCameraImageWith:(UIImage *)stillImage{
    _recameraBut.hidden = NO;
    _useImageBut.hidden = NO;
    self.cameraImageView.hidden = NO;
    self.cameraImageView.image = stillImage;
}
- (void)reCaputueCameraImage{
    _recameraBut.hidden = YES;
    _useImageBut.hidden = YES;
    self.cameraImageView.hidden = YES;
    self.cameraImageView.image = nil;
}
- (void)useImageButtonAction:(UIButton *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(HQCameraController:andCameraImage:andInfo:andIdentifer:)]) {
        [_delegate HQCameraController:self andCameraImage:_currentCameraImage andInfo:_currentImageInfo andIdentifer:_currentIdentifer];
        [self dismissBtnPressed:nil];
    }
}
//拍照页面，"X"按钮
- (void)dismissBtnPressed:(id)sender {
    if (self.navigationController) {
        if (self.navigationController.viewControllers.count == 1) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)tmpBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//拍照页面，网格按钮
- (void)gridBtnPressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    [_cameraManager switchGrid:sender.selected];
}

//拍照页面，切换前后摄像头按钮按钮
- (void)switchCameraBtnPressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    [_cameraManager switchCamera:sender.selected];
}

//拍照页面，闪光灯按钮
- (void)flashBtnPressed:(UIButton*)sender {
    [_cameraManager switchFlashMode:sender];
}
#pragma mark -------------pinch camera---------------
//伸缩镜头
- (void)handlePinch:(UIPinchGestureRecognizer*)gesture {
    
    [_cameraManager pinchCameraView:gesture];
    
    if (_scSlider) {
        if (_scSlider.alpha != 1.f) {
            [UIView animateWithDuration:0.3f animations:^{
                _scSlider.alpha = 1.f;
            }];
        }
        [_scSlider setValue:_cameraManager.scaleNum shouldCallBack:NO];
        
        if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
            [self setSliderAlpha:YES];
        } else {
            [self setSliderAlpha:NO];
        }
    }
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
//    if (!self.navigationController) {
//        if ([UIApplication sharedApplication].statusBarHidden != _isStatusBarHiddenBeforeShowCamera) {
//            [[UIApplication sharedApplication] setStatusBarHidden:_isStatusBarHiddenBeforeShowCamera withAnimation:UIStatusBarAnimationSlide];
//        }
//    }
    self.cameraManager = nil;
}
- (UIImageView *)cameraImageView{
    if (_cameraImageView == nil) {
        _cameraImageView = [[UIImageView alloc] initWithFrame:self.previewRect];
        [self.view addSubview:_cameraImageView];
    }
    return _cameraImageView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
