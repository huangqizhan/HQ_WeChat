//
//  ApplicationController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/11/17.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "ApplicationController.h"

@interface ApplicationController ()<UITableViewDelegate,UITableViewDataSource>{
    TestActionModel *_actionModel;
    CGFloat _headHeight;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIImageView *begView;
@property (nonatomic,strong) HeadweView *headerView;
@property (nonatomic,strong) NewUserInfoDetailStretchHelper *stretchView;
@property (nonatomic,strong) UIView *testView;
@end

@implementation ApplicationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//
//    _testView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    _testView.backgroundColor = [UIColor redColor];
//    [self.view addSubview:_testView];
//
//    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, 20, 40, 40)];
//    button.backgroundColor = [UIColor blackColor];
//    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
    
    
    [self.view addSubview:self.begView];
    [self.view addSubview:self.tableView];
    _stretchView = [[NewUserInfoDetailStretchHelper alloc] initWithBgView:self.begView];
    
   /*
    _actionModel = [TestActionModel new];
    UIApplicationState   status = [[UIApplication sharedApplication] applicationState]; //app状态
    NSLog(@"status = %ld",status);
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:10]; //设置后台运行时间
    NSTimeInterval remainTime = [[UIApplication sharedApplication] backgroundTimeRemaining]; //app后台运行的时间
    NSLog(@"remainTIme = %f",remainTime);
    [[UIApplication sharedApplication] backgroundRefreshStatus]; //后台刷新的状态
    // 指定最小时间间隔在后台获取操作  最小的时间间隔 后台回调结果
    [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"taskOne" expirationHandler:^{
    for (int  i = 0; i<100; i++) {
    NSLog(@" 1 %d %@",i,[NSThread currentThread]);
    }
    }];
    // 指定最小时间间隔在后台获取操作  最小的时间间隔 后台回调结果
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    for (int  i = 0; i<100; i++) {
    NSLog(@" 2 %d %@",i,[NSThread currentThread]);
    }
    }];
    ////结束具体的后台任务
    //    [[UIApplication sharedApplication] endBackgroundTask:1];
    */
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
     [_stretchView scrollViewDidScroll:scrollView];
    if (scrollView.contentOffset.y > 120) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:0.35 animations:^{
             [self.tableView setContentOffset:CGPointMake(0, 255) animated:NO];
        }];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [[UIApplication sharedApplication] sendAction:@selector(action:forEvent:) to:_actionModel from:self forEvent:event];

}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    _testView.center = [touch locationInView:self.view];
}

/*
 //隐藏状态条
 [[UIApplication sharedApplication] setStatusBarHidden:YES];
 [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
 //设置状态条的样式
 [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
 [[UIApplication sharedApplication] statusBarStyle];
 //状态条的Frame
 [[UIApplication sharedApplication] statusBarFrame];
 //网络是否可见
 [[UIApplication sharedApplication] isNetworkActivityIndicatorVisible];
 //badge数字
 [UIApplication sharedApplication].applicationIconBadgeNumber = 2;
 //屏幕的方向
 [[UIApplication sharedApplication] userInterfaceLayoutDirection];
 //不让手机休眠
 [UIApplication sharedApplication].idleTimerDisabled = YES;
 
 ///遥控
 [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
 [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
 
 */
- (UIImageView *)begView{
    if (_begView  == nil) {
        _begView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height*(6.0/13.0))];
        UIImage *image = [UIImage imageNamed:@"img_timg"];
        _begView.image =  image;
    }
    return _begView;
}
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _headHeight = self.headerView.frame.size.height;
        _tableView.tableHeaderView = self.headerView;
    }
    return _tableView;
}
- (HeadweView *)headerView{
    if (_headerView == nil) {
        _headerView =  [[HeadweView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.begView.frame.size.height)];
    }
    return _headerView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end





@implementation   NewUserInfoDetailStretchHelper


- (instancetype)initWithBgView:(UIView *)begView{
    self = [super init];
    if (self) {
        _stretchView = begView;
        _originFrame = begView.frame;
        _imageRatio = begView.bounds.size.height / begView.bounds.size.width;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat yOffset = scrollView.contentOffset.y;
    
    if (yOffset > 0 )  { // 往上移动
        CGRect frame = _originFrame;
        frame.origin.y = _originFrame.origin.y - yOffset;
        _stretchView.frame = frame;
    } else { // 往下移动
        CGRect frame = _originFrame;
        frame.size.height = _originFrame.size.height - yOffset;
        frame.size.width = frame.size.height / _imageRatio;
        frame.origin.x = _originFrame.origin.x - (frame.size.width - _originFrame.size.width) * 0.5;
        _stretchView.frame = frame;
    }
}


@end


 @implementation  HeadweView
- (instancetype)initWithFrame:(CGRect)frame{
    CGRect newframe  = frame;
    newframe.size.height -=  50;
    self = [super initWithFrame:newframe];
    if (self) {
    }
    return self;
}


@end




@implementation  TestActionModel


- (void)action:(id)sender forEvent:(UIEvent *)event{
    NSLog(@"sender = %@ event = %@",sender,event);
}

@end
