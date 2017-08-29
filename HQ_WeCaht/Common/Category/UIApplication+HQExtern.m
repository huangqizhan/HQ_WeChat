//
//  UIApplication+HQExtern.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/26.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "UIApplication+HQExtern.h"

#define UIWindowLevelPopOver 10000000000

@interface LLPopOverRootViewController : UIViewController

@property (nonatomic) BOOL statusBarHidden;

@property (nonatomic) UIStatusBarStyle statusBarStyle;

@end

@implementation LLPopOverRootViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.frame = [UIScreen mainScreen].bounds;
        self.view.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarStyle;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientationMask supportedInterfaceOrientations;
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    supportedInterfaceOrientations = [self getInterfaceOrientations:statusBarOrientation];
    
    return supportedInterfaceOrientations;
}

- (UIInterfaceOrientationMask)getInterfaceOrientations:(UIInterfaceOrientation)interfaceOrientation {
    UIInterfaceOrientationMask supportedInterfaceOrientations;
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationUnknown:
            supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            supportedInterfaceOrientations = UIInterfaceOrientationMaskLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            supportedInterfaceOrientations = UIInterfaceOrientationMaskLandscapeRight;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            supportedInterfaceOrientations = UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
    }
    
    return supportedInterfaceOrientations;
}

@end

static CFRunLoopObserverRef observer;

@implementation UIApplication (HQExtern)
+ (UIViewController *)rootViewController {
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}

+ (UIWindow *)currentWindow {
    return [UIApplication sharedApplication].delegate.window;
}

+ (UIWindow *)popOverWindow {
    static UIWindow *popOverWindow;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        popOverWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        popOverWindow.backgroundColor = [UIColor clearColor];
        popOverWindow.windowLevel = UIWindowLevelPopOver;
        popOverWindow.hidden = YES;
        popOverWindow.rootViewController = [[LLPopOverRootViewController alloc] initWithNibName:nil bundle:nil];
    });
    
    return popOverWindow;
}

+ (void)addViewToPopOverWindow:(UIView *)view {
    LLPopOverRootViewController *vc = (LLPopOverRootViewController *)[UIApplication popOverWindow].rootViewController;
    vc.statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    vc.statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    
    [vc.view addSubview:view];
    [UIApplication popOverWindow].hidden = NO;
    [vc setNeedsStatusBarAppearanceUpdate];
}

+ (void)removeViewFromPopOverWindow:(UIView *)view {
    LLPopOverRootViewController *vc = (LLPopOverRootViewController *)[UIApplication popOverWindow].rootViewController;
    [view removeFromSuperview];
    
    if (vc.view.subviews.count == 0) {
        [UIApplication popOverWindow].hidden = YES;
    }
}


+ (AppDelegate *)appDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

+ (UIViewController *)viewControllerForView:(UIView *)view {
    if (!view) return nil;
    UIResponder *responder = view.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    }
    
    return nil;
}

+ (void)removeViewControllerFromParentViewController:(UIViewController *)viewController {
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

+ (void)addViewController:(UIViewController *)viewController  toViewController:(UIViewController *)parentViewController {
    [parentViewController addChildViewController:viewController];
    //    viewController.view.frame = parentViewController.view.bounds;
    [parentViewController.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:parentViewController];
}



+ (void)startObserveRunLoop
{
    if (observer == nil) {
        // 建立自动释放池
        //  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        // 设置Run Loop observer的运行环境
        CFRunLoopObserverContext context = {0, NULL, NULL, NULL, NULL};
        
        // 创建Run loop observer对象
        // 第一个参数用于分配该observer对象的内存
        // 第二个参数用以设置该observer所要关注的的事件，详见回调函数myRunLoopObserver中注释
        // 第三个参数用于标识该observer是在第一次进入run loop时执行还是每次进入run loop处理时均执行
        // 第四个参数用于设置该observer的优先级
        // 第五个参数用于设置该observer的回调函数
        // 第六个参数用于设置该observer的运行环境
        observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &myRunLoopObserver, &context);
        
    }
    
    
    // 获得当前thread的Run loop
    NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
    // 将Cocoa的NSRunLoop类型转换程Core Foundation的CFRunLoopRef类型
    CFRunLoopRef cfRunLoop = [myRunLoop getCFRunLoop];
    // 将新建的observer加入到当前的thread的run loop
    CFRunLoopAddObserver(cfRunLoop, observer, kCFRunLoopDefaultMode);
    
    
    // Creates and returns a new NSTimer object and schedules it on the current run loop in the default mode
    //    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doFireTimer:) userInfo:nil repeats:YES];
    
    //    NSInteger loopCount = 10;
    //    do
    //    {
    //        // 启动当前thread的run loop直到所指定的时间到达，在run loop运行时，run loop会处理所有来自与该run loop联系的input sources的数据
    //        // 对于本例与当前run loop联系的input source只有Timer类型的source
    //        // 该Timer每隔0.1秒发送触发时间给run loop，run loop检测到该事件时会调用相应的处理方法（doFireTimer:）
    //        // 由于在run loop添加了observer，且设置observer对所有的run loop行为感兴趣
    //        // 当调用runUntilDate方法时，observer检测到run loop启动并进入循环，observer会调用其回调函数，第二个参数所传递的行为时kCFRunLoopEntry
    //        // observer检测到run loop的其他行为并调用回调函数的操作与上面的描述相类似
    //        [myRunLoop runUntilDate:[NSDate dateWithTimeIntervalSiceNow:1.0]];
    //        // 当run loop的运行时间到达时，会退出当前的run loop，observer同样会检测到run loop的退出行为，并调用其回调函数，第二个参数传递的行为是kCFRunLoopExit.
    //        --loopCount;
    //    }while(loopCount);
    
    // 释放自动释放池
    //    [pool release];
}

+ (void)stopObserveRunLoop {
    if (observer) {
        CFRunLoopObserverInvalidate(observer);
        observer = nil;
    }
}


//- (void)doFireTimer:(NSTimer *)timer {
//    NSLog(@"doFireTimer");
//}
//＝＝＝observer的回调函数：
void myRunLoopObserver(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    switch(activity)
    {
            // The entrance of run loop, before entering the event processing loop.
            // This activity occurs once for each call to CFRunLoopRun / CFRunLoopRunInMode
        case kCFRunLoopEntry:
            NSLog(@"run loop entry");
            break;
            // Inside the event processing loop before any timers are processed
        case kCFRunLoopBeforeTimers:
            NSLog(@"run loop before timers");
            break;
            // Inside the event processing loop before any sources are processed
        case kCFRunLoopBeforeSources:
            NSLog(@"run loop before sources");
            break;
            // Inside the event processing loop before the run loop sleeps, waiting for a source or timer to fire
            // This activity does not occur if CFRunLoopRunInMode is called with a timeout of o seconds
            // It also does not occur in a particular iteration of the event processing loop if a version 0 source fires
        case kCFRunLoopBeforeWaiting:
            NSLog(@"run loop before waiting");
            break;
            // Inside the event processing loop after the run loop wakes up, but before processing the event that woke it up
            // This activity occurs only if the run loop did in fact go to sleep during the current loop
        case kCFRunLoopAfterWaiting:
            NSLog(@"run loop after waiting");
            break;
            // The exit of the run loop, after exiting the event processing loop
            // This activity occurs once for each call to CFRunLoopRun and CFRunLoopRunInMode
        case kCFRunLoopExit:
            NSLog(@"run loop exit");
            break;
            /*
             A combination of all the preceding stages
             case kCFRunLoopAllActivities:
             break;
             */
        default:
            break;
    }
}

+ (UIViewController *)mostFrontViewController {
    UIViewController *vc = [self rootViewController];
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    return vc;
}
+ (void)showMessageAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self showMessageAlertWithTitle:title message:message actionTitle:@"确定" actionHandler:nil];
}

+ (void)showMessageAlertWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle {
    [self showMessageAlertWithTitle:title message:message actionTitle:actionTitle actionHandler:nil];
}

+ (void)showMessageAlertWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle actionHandler:(void (^ __nullable)())actionHandler {
    //IOS8.0及以后，采用UIAlertController
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action;
        if (actionHandler) {
            action = [UIAlertAction actionWithTitle:actionTitle
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action){
                                                actionHandler();
                                            }];
        }else {
            action = [UIAlertAction actionWithTitle:actionTitle
                                              style:UIAlertActionStyleCancel
                                            handler:nil];
        }
        
        [alertController addAction:action];
        
        [[self mostFrontViewController] presentViewController:alertController animated:YES completion:nil];
        
    }
    
}

+ (void)showConfirmAlertWithTitle:(NSString *)title message:(NSString *)message yesTitle:(NSString *)yesTitle yesAction:(void (^ __nullable)())yesAction {
    [self showConfirmAlertWithTitle:title message:message yesTitle:yesTitle yesAction:yesAction cancelTitle:@"取消" cancelAction:nil];
}

+ (void)showConfirmAlertWithTitle:(NSString *)title message:(NSString *)message yesTitle:(NSString *)yesTitle yesAction:(void (^ __nullable)())yesAction cancelTitle:(NSString *)cancelTitle cancelAction:(void (^ __nullable)())cancelAction {
    [self showConfirmAlertWithTitle:title message:message firstActionTitle:yesTitle firstAction:yesAction secondActionTitle:cancelTitle secondAction:cancelAction];
}

+ (void)showConfirmAlertWithTitle:(NSString *)title message:(NSString *)message firstActionTitle:(NSString *)firstActionTitle firstAction:(void (^ __nullable)())firstAction secondActionTitle:(NSString *)secondActionTitle secondAction:(void (^ __nullable)())secondAction {
    //IOS8.0及以后，采用UIAlertController
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:firstActionTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){
                                                           if (firstAction)
                                                               firstAction();
                                                       }];
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:secondActionTitle
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *action) {
                                                            if (secondAction)
                                                                secondAction();
                                                        }];
        
        [alertController addAction:action];
        [alertController addAction:action2];
        
        [[self mostFrontViewController] presentViewController:alertController animated:YES completion:nil];
        
    }
}

+ (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait) {
        NSLog(@"UIInterfaceOrientationPortrait");
        return AVCaptureVideoOrientationPortrait;
        
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        NSLog(@"AVCaptureVideoOrientationLandscapeLeft");
        return AVCaptureVideoOrientationLandscapeLeft;
        
    } else if (orientation == UIInterfaceOrientationLandscapeRight){
        NSLog(@"UIInterfaceOrientationLandscapeRight");
        return AVCaptureVideoOrientationLandscapeRight;
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        NSLog(@"UIInterfaceOrientationPortraitUpsideDown");
        return AVCaptureVideoOrientationPortraitUpsideDown;
    }
    
    return AVCaptureVideoOrientationPortrait;
}
+ (CGRect)screenBounds {
    
    UIScreen *screen = [UIScreen mainScreen];
    CGRect screenRect;
    if (![screen respondsToSelector:@selector(fixedCoordinateSpace)] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        //        screenRect = CGRectMake(screen.bounds.origin.x, screen.bounds.origin.y, screen.bounds.size.height, screen.bounds.size.width);
        screenRect = CGRectMake(0, 0, screen.bounds.size.height, screen.bounds.size.width);
    } else {
        screenRect = screen.bounds;
    }
    
    return screenRect;
    
}

@end
