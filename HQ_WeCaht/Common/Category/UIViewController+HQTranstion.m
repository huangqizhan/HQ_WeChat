//
//  UIViewController+HQTranstion.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/10.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "UIViewController+HQTranstion.h"
#import "ControllerTranstionAnimation.h"



static BOOL isScrollView = NO;
@implementation UIViewController (HQTranstion)

#pragma mark -------- 添加属性 -------------
- (UIPercentDrivenInteractiveTransition *)interactivePopTransition{
    return objc_getAssociatedObject(self, @selector(interactivePopTransition));
}

- (void)setInteractivePopTransition:(UIPercentDrivenInteractiveTransition *)interactivePopTransition{
    objc_setAssociatedObject(self, @selector(interactivePopTransition), interactivePopTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScrollView *)scrollView{
    return objc_getAssociatedObject(self, @selector(scrollView));
}

- (void)setScrollView:(UIScrollView *)scrollView{
    objc_setAssociatedObject(self, @selector(scrollView), scrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)toViewControllerImagePointY{
    NSNumber *value = objc_getAssociatedObject(self, @selector(toViewControllerImagePointY));
    return value;
}

- (void)setToViewControllerImagePointY:(NSNumber *)toViewControllerImagePointY{
    objc_setAssociatedObject(self, @selector(toViewControllerImagePointY), toViewControllerImagePointY, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)cancelAnimationPointY{
    NSNumber *value = objc_getAssociatedObject(self, @selector(cancelAnimationPointY));
    return value;
}

- (void)setCancelAnimationPointY:(NSNumber *)cancelAnimationPointY{
    objc_setAssociatedObject(self, @selector(cancelAnimationPointY), cancelAnimationPointY, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)animationDuration{
    NSNumber *value = objc_getAssociatedObject(self, @selector(animationDuration));
    return value;
}

- (void)setAnimationDuration:(NSNumber *)animationDuration{
    objc_setAssociatedObject(self, @selector(animationDuration), animationDuration, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setOrgineViewRect:(CGRect)orgineViewRect{
    objc_setAssociatedObject(self, @selector(orgineViewRect), [NSValue valueWithCGRect:orgineViewRect], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGRect)orgineViewRect{
    NSValue *value = objc_getAssociatedObject(self, @selector(orgineViewRect));
    return [value CGRectValue];
}
#pragma mark -- Public

- (void)hq_setUpReturnBtnWithColor:(UIColor *)color callBackHandler:(void (^)())callBackHandler{
    objc_setAssociatedObject(self, (__bridge void *)(@"hq_return_Action"), callBackHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"App_back"] style:UIBarButtonItemStylePlain target:self action:@selector(returnAction:)];
    if (color) {
        self.navigationItem.leftBarButtonItem.tintColor = color;
    } else {
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor lightGrayColor];
    }
}
- (void)hq_setupReturnBtnWithImage:(UIImage *)image color:(UIColor *)color callBackHandler:(void (^)())callBackHandler{
    objc_setAssociatedObject(self, (__bridge void *)(@"hq_return_Action"), callBackHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    UIImage *btnImage = [UIImage imageNamed:@"hq_navi_back_btn.png"];
    if (image) {
        btnImage = image;
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:btnImage style:UIBarButtonItemStylePlain target:self action:@selector(returnAction:)];
    if (color) {
        self.navigationItem.leftBarButtonItem.tintColor = color;
    } else {
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor lightGrayColor];
    }
}
#pragma mark -- private
- (void)returnAction:(id)sender{
    void (^callBackHandler)() = objc_getAssociatedObject(self, (__bridge void *)(@"hq_return_Action"));
    if(callBackHandler){
        callBackHandler();
    }
}
#pragma mark -- public

- (void)hq_pushTransitionAnimationWithToViewControllerImagePointY:(CGFloat)toViewControllerImagePointY animationDuration:(CGFloat)animationDuration{
    self.toViewControllerImagePointY = @(toViewControllerImagePointY);
    self.animationDuration = @(animationDuration);
}

- (void)hq_popTransitionAnimationWithCurrentScrollView:(UIScrollView*)scrollView
                                      animationDuration:(CGFloat)animationDuration
                                isInteractiveTransition:(BOOL)isInteractiveTransition{
    if (scrollView) {
        self.scrollView = scrollView;
        isScrollView = YES;
    }
    self.animationDuration = @(animationDuration);
    
    if (isInteractiveTransition) {
        UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
        popRecognizer.edges = UIRectEdgeTop;
        [self.view addGestureRecognizer:popRecognizer];
    }
}
- (void)hq_popTransitionAnimationWithCurrentScrollView:(UIScrollView*)scrollView
                                 cancelAnimationCgrect:(CGRect)cancelAnimationCgrect
                                     animationDuration:(CGFloat)animationDuration
                               isInteractiveTransition:(BOOL)isInteractiveTransition{
    if (scrollView) {
        self.scrollView = scrollView;
        isScrollView = YES;
    }
    self.orgineViewRect = cancelAnimationCgrect;
    self.animationDuration = @(animationDuration);
    if (isInteractiveTransition) {
//        UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
//        popRecognizer.edges = UIRectEdgeLeft;
//        [self.view addGestureRecognizer:popRecognizer];
    }
}
- (void)hq_addTransitionDelegate:(UIViewController*)viewController{
    self.navigationController.delegate = self;
    
    if ([viewController isKindOfClass:[UITableViewController class]]) {
        UITableViewController *vc = (UITableViewController *)viewController;
        vc.clearsSelectionOnViewWillAppear = NO;
    }
    
    if ([viewController isKindOfClass:[UICollectionViewController class]]) {
        UICollectionViewController *vc = (UICollectionViewController *)viewController;
        vc.clearsSelectionOnViewWillAppear = NO;
    }
}
- (void)hq_removeTransitionDelegate{
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

#pragma mark -- NavitionContollerDelegate
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
    if (!self.interactivePopTransition) { return nil; }
    return self.interactivePopTransition;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)       navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC{
    
    if ([(id<ControllerTranstionAnimationDetaSourse>)fromVC conformsToProtocol:@protocol(ControllerTranstionAnimationDetaSourse)] &&
        [(id<ControllerTranstionAnimationDetaSourse>)toVC conformsToProtocol:@protocol(ControllerTranstionAnimationDetaSourse)]) {
        
        if (operation == UINavigationControllerOperationPush) {
            
            if (operation != UINavigationControllerOperationPush) { return nil; }
            ControllerTranstionAnimation *animator = [[ControllerTranstionAnimation alloc]init];
            animator.isForward = (operation == UINavigationControllerOperationPush);
            animator.origineRect = self.orgineViewRect;
            animator.toViewControllerImagePointY = [self.toViewControllerImagePointY floatValue];
            animator.animationDuration = [self.animationDuration floatValue];
            return  animator;
            
        } else if (operation == UINavigationControllerOperationPop) {
            
            if (operation != UINavigationControllerOperationPop) { return nil; }
            
            if (isScrollView && self.cancelAnimationPointY != 0) {
                if (self.scrollView.contentOffset.y > [self.cancelAnimationPointY floatValue]) { return nil; }
            }
            ControllerTranstionAnimation *animator = [[ControllerTranstionAnimation alloc]init];
            animator.isForward = (operation == UINavigationControllerOperationPush);
            animator.animationDuration = [self.animationDuration floatValue];
            return  animator;
            
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

#pragma mark UIGestureRecognizer handlers

- (void)handlePopRecognizer:(UIScreenEdgePanGestureRecognizer*)recognizer{
    CGFloat progress = [recognizer translationInView:self.view].x / (self.view.bounds.size.width);
    progress = MIN(1.0, MAX(0.0, progress));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
//        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"process = %f",progress);
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (progress > 0.5) {
            [self.interactivePopTransition finishInteractiveTransition];
        }
        else {
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        self.interactivePopTransition = nil;
    }
}



@end
