//
//  HQEdiateImageCutView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/10.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQEdiateImageCutView.h"
#import "HQEdiateImageController.h"
#import "HQCutImageController.h"


static const NSUInteger LeftTopCircleView = 1;
static const NSUInteger LeftBottomCircleView = 2;
static const NSUInteger RightTopCircleView = 3;
static const NSUInteger RightBottomCircleView = 4;



@interface HQEdiateImageCutView (){
    
    //4个角
    CutCircleView *_ltView;
    CutCircleView *_lbView;
    CutCircleView *_rtView;
    CutCircleView *_rbView;

}



@end

@implementation HQEdiateImageCutView


- (id)initWithSuperview:(UIView*)superview frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [superview addSubview:self];
        _gridLayer = [[CutLineView alloc] init];
        _gridLayer.frame = self.bounds;
        [self.layer addSublayer:_gridLayer];
        
        _ltView = [self clippingCircleWithTag:LeftTopCircleView];
        _lbView = [self clippingCircleWithTag:LeftBottomCircleView];
        _rtView = [self clippingCircleWithTag:RightTopCircleView];
        _rbView = [self clippingCircleWithTag:RightBottomCircleView];
        
//        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGridView:)];
//        [self addGestureRecognizer:panGesture];
//
        self.clippingRect = self.bounds;
    }
    return self;
}

- (void)setClippingRect:(CGRect)clippingRect{
    _clippingRect = clippingRect;
    
    CGRect newRect = [self convertRect:clippingRect toView:self.imageEdiateController.view];
    self.imageEdiateController.scrollView.contentInset = UIEdgeInsetsMake(clippingRect.origin.y, newRect.origin.x-20 ,self.imageEdiateController.scrollView.height-clippingRect.origin.y-clippingRect.size.height , self.imageEdiateController.scrollView.width - newRect.size.width - newRect.origin.x+20);

    _ltView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y) fromView:self];
    _lbView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y+_clippingRect.size.height) fromView:self];
    _rtView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y) fromView:self];
    _rbView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y+_clippingRect.size.height) fromView:self];
    

    _gridLayer.clippingRect = clippingRect;
    [self setNeedsDisplay];
}

- (void)setNeedsDisplay{
    [super setNeedsDisplay];
    [_gridLayer setNeedsDisplay];
}

//4个角的拖动圆球
- (CutCircleView*)clippingCircleWithTag:(NSInteger)tag{
    CutCircleView *view = [[CutCircleView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    view.tag = tag;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCircleView:)];
    panGesture.delegate = self;
    [view addGestureRecognizer:panGesture];
    
    [self.superview addSubview:view];
    
    return view;
}
- (void)setBgColor:(UIColor *)bgColor{
    _gridLayer.bgColor = bgColor;
}

- (void)setGridColor:(UIColor *)gridColor{
    _gridLayer.gridColor = gridColor;
    
}
- (void)removeFromSuperview{
    [super removeFromSuperview];
    
    [_ltView removeFromSuperview];
    [_lbView removeFromSuperview];
    [_rtView removeFromSuperview];
    [_rbView removeFromSuperview];
}
//拖动4个角
- (void)panCircleView:(UIPanGestureRecognizer*)sender{
    CGPoint point = [sender locationInView:self];
    CGPoint dp = [sender translationInView:self];
    CGRect rct = self.clippingRect;
    const CGFloat W = self.frame.size.width;
    const CGFloat H = self.frame.size.height;
    CGFloat minX = 0;
    CGFloat minY = 0;
    CGFloat maxX = W;
    CGFloat maxY = H;
    
    CGFloat ratio = (sender.view.tag == LeftBottomCircleView || sender.view.tag == RightTopCircleView) ? -0 : 0;
    
    switch (sender.view.tag) {
        case LeftTopCircleView:{// upper left
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = rct.origin.y - ratio * rct.origin.x;
                CGFloat x0 = -y0 / ratio;
                minX = MAX(x0, 0);
                minY = MAX(y0, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.x = point.x;
            rct.origin.y = point.y;
            break;
        }
        case LeftBottomCircleView:{// lower left
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio* rct.origin.x ;
                CGFloat xh = (H - y0) / ratio;
                minX = MAX(xh, 0);
                maxY = MIN(y0, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = point.y - rct.origin.y;
            rct.origin.x = point.x;
            break;
        }
        case RightTopCircleView:{
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = rct.origin.y - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat x0 = -y0 / ratio;
                maxX = MIN(x0, W);
                minY = MAX(yw, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.y = point.y;
            break;
        }
        case RightBottomCircleView:{// lower right
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat xh = (H - y0) / ratio;
                maxX = MIN(xh, W);
                maxY = MIN(yw, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = point.y - rct.origin.y;
            break;
        }
        default:
            break;
    }
    self.clippingRect = rct;
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (_delegate && [_delegate respondsToSelector:@selector(EdiateImageCutViewWillBeginDrag:)]) {
            [_delegate EdiateImageCutViewWillBeginDrag:self] ;
        }
    }else if (sender.state == UIGestureRecognizerStateEnded){
        if (_delegate && [_delegate respondsToSelector:@selector(EdiateImageCutViewDidEndDrag:)]) {
            [_delegate EdiateImageCutViewDidEndDrag:self] ;
        }
    }
//    CGRect newRect = [self convertRect:rct toView:self.imageEdiateController.view];
//    self.imageEdiateController.scrollView.contentInset = UIEdgeInsetsMake(rct.origin.y, newRect.origin.x-20 ,self.imageEdiateController.scrollView.height-rct.origin.y-rct.size.height , self.imageEdiateController.scrollView.width - newRect.size.width - newRect.origin.x+20);
}
#pragma mark --------- 事件处理    -----------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    [super hitTest:point withEvent:event];
  if ([self pointInside:point withEvent:event]) {
        return self.imageEdiateController.scrollView;
    }
    return nil;
}


@end






@implementation CutCircleView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rct = self.bounds;
    rct.origin.x = rct.size.width/2-rct.size.width/6;
    rct.origin.y = rct.size.height/2-rct.size.height/6;
    rct.size.width /= 3;
    rct.size.height /= 3;
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(context, rct);
}


@end




@implementation CutLineView

- (void)drawInContext:(CGContextRef)context{
    CGRect rct = self.bounds;
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    CGContextFillRect(context, rct);
    
    //清除范围（截图范围）
    CGContextClearRect(context, _clippingRect);
    
    CGContextSetStrokeColorWithColor(context, self.gridColor.CGColor);
    CGContextSetLineWidth(context, 0.8);
    
    rct = self.clippingRect;
    
    CGContextBeginPath(context);
    CGFloat dW = 0;
    //画竖线
    for(int i=0;i<4;++i){
        CGContextMoveToPoint(context, rct.origin.x+dW, rct.origin.y);
        CGContextAddLineToPoint(context, rct.origin.x+dW, rct.origin.y+rct.size.height);
        dW += _clippingRect.size.width/3;
    }
    dW = 0;
    //画横线
    for(int i=0;i<4;++i){
        CGContextMoveToPoint(context, rct.origin.x, rct.origin.y+dW);
        CGContextAddLineToPoint(context, rct.origin.x+rct.size.width, rct.origin.y+dW);
        dW += rct.size.height/3;
    }
    CGContextStrokePath(context);
}



@end
