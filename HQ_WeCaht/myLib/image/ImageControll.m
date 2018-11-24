//
//  ImageControll.m
//  YYStudyDemo
//
//  Created by hqz  QQ 757618403 on 2018/9/28.
//  Copyright © 2018年 hqz  QQ 757618403. All rights reserved.
//

#import "ImageControll.h"


#define kImageControllLongPressInterval 0.5

@implementation ImageControll{
    UIImage *_image;
    CGPoint _point;
    NSTimer *_timer;
//    BOOL _longPressDetected;
    CGPoint _touchBeginPoint;
    struct {
        ///touch 已经被吸收 持续响应
        unsigned int swallowTouch : 1;
        ///是否touchMoved
        unsigned int isTouchMoved : 1;
        ///是否已经touchend
        unsigned int isToutchEnd : 1;
    }_state;
    
}
- (void)setImage:(UIImage *)image {
    _image = image;
    self.layer.contents = (id)image.CGImage;
}

- (void)dealloc {
    [self endTimer];
}

- (UIImage *)image {
    id content = self.layer.contents;
    if (content != (id)_image.CGImage) {
        CGImageRef ref = (__bridge CGImageRef)(content);
        if (ref && CFGetTypeID(ref) == CGImageGetTypeID()) {
            _image = [UIImage imageWithCGImage:ref scale:self.layer.contentsScale orientation:UIImageOrientationUp];
        } else {
            _image = nil;
        }
    }
    return _image;
}
- (void)_showMenuController{
    if (_state.isToutchEnd) {
        return;
    }
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        return ;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self becomeFirstResponder];
        UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyAciton:)];
        menu.menuItems = @[item1];
        [menu setTargetRect:self.bounds inView:self];
        [menu setMenuVisible:YES animated:YES];
    });
}
- (void)_hiddenMenuController{
    
}
- (void)startTimer {
    [_timer invalidate];
    _timer = [NSTimer timerWithTimeInterval:kImageControllLongPressInterval target:self selector:@selector(timerFire) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)endTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)timerFire {
    [self touchesCancelled:[NSSet set] withEvent:nil];
    if (_longPressBlock) _longPressBlock(self, _point);
    [self _showMenuController];
    [self endTimer];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _state.isToutchEnd = NO;
    _touchBeginPoint = [touches.anyObject locationInView:self];
    if (_touchBlock) {
        _touchBlock(self, UIGestureRecognizerStateBegan, touches, event);
    }
//    if (_longPressBlock) {
//    }
    UITouch *touch = touches.anyObject;
    _point = [touch locationInView:self];
    [self startTimer];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_state.isTouchMoved){
        CGPoint point = [touches.anyObject locationInView:self];
        CGFloat moveH = point.x - _touchBeginPoint.x;
        CGFloat moveV = point.y - _touchBeginPoint.y;
        if (fabs(moveH) > fabs(moveV)) {
            if(fabs(moveH) > 8){
                _state.isTouchMoved = YES;
                [self endTimer];
            }
        }else{
            if(fabs(moveV) > 8){
                _state.isTouchMoved = YES;
                [self endTimer];
            }
        }
    }
//    if (_touchBlock) {
//        _touchBlock(self, UIGestureRecognizerStateEnded, touches, event);
//    }
//    [self endTimer];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _state.isTouchMoved = NO;
    if (_touchBlock) {
        _touchBlock(self, UIGestureRecognizerStateEnded, touches, event);
    }
    [self endTimer];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _state.isTouchMoved = NO;
    if (_touchBlock) {
        _touchBlock(self, UIGestureRecognizerStateCancelled, touches, event);
    }
    [self endTimer];
}
- (BOOL)canBecomeFirstResponder{
    return YES;
}
#pragma mark  ------ Action ----
- (void)copyAciton:(id)sender{
    
}
@end
