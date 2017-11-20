//
//  AsySellTicketsViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/11/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "AsySellTicketsViewController.h"

@interface AsySellTicketsViewController (){
    TotalTicketsModel *_totalModel;
    NSMutableArray *_dataArray;
    NSLock *_lock;
    dispatch_semaphore_t _semaphore;
}

@end

@implementation AsySellTicketsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _dataArray = [NSMutableArray new];
    _lock = [[NSLock alloc] init];
//    for (int i = 0 ; i<10; i++) {
//        TotalTicketsModel *model1 = [TotalTicketsModel new];
//        model1.totalAmount = i;
//        [_dataArray addObject:model1];
//    }
    self.title  = @"模拟买票";
    _totalModel = [TotalTicketsModel new];
    _totalModel.totalAmount = 10;
    _semaphore = dispatch_semaphore_create(3);
    
    
//    [self sallWithoutLock];
//    [self testAction];
    [self dispathSeme];
    
}

- (void)sallWithoutLock{
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(threadAction2) object:nil];
    thread1.name = @"'A";
    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(threadAction2) object:nil];
    thread2.name = @"B";
    NSThread *thread3 = [[NSThread alloc] initWithTarget:self selector:@selector(threadAction2) object:nil];
    thread3.name = @"C";
    [thread1 start];
    [thread2 start];
    [thread3 start];

}
- (void)threadAction{
    /*
     不加锁 状态
     'A--卖了一张票，还剩余9张票
     C--卖了一张票，还剩余9张票
     B--卖了一张票，还剩余9张票
     'A--卖了一张票，还剩余8张票
     B--卖了一张票，还剩余8张票
     C--卖了一张票，还剩余8张票
     'A--卖了一张票，还剩余7张票
     B--卖了一张票，还剩余7张票
     C--卖了一张票，还剩余7张票
     'A--卖了一张票，还剩余6张票
     C--卖了一张票，还剩余6张票
     B--卖了一张票，还剩余6张票
     C--卖了一张票，还剩余5张票
     'A--卖了一张票，还剩余5张票
     B--卖了一张票，还剩余5张票
     'A--卖了一张票，还剩余4张票
     C--卖了一张票，还剩余4张票
     B--卖了一张票，还剩余4张票
     C--卖了一张票，还剩余3张票
     'A--卖了一张票，还剩余3张票
     B--卖了一张票，还剩余3张票
     C--卖了一张票，还剩余2张票
     B--卖了一张票，还剩余2张票
     'A--卖了一张票，还剩余2张票
     C--卖了一张票，还剩余1张票
     'A--卖了一张票，还剩余1张票
     B--卖了一张票，还剩余1张票
     'A--卖了一张票，还剩余0张票
     B--卖了一张票，还剩余0张票
     C--卖了一张票，还剩余0张票
     */
    while (1) {
        NSInteger num = _totalModel.totalAmount;
        if (num > 0) {
            //暂停一段时间
            [NSThread sleepForTimeInterval:0.002];
            
            //2.票数-1
            _totalModel.totalAmount= num-1;
            
            //获取当前线程
            NSThread *current=[NSThread currentThread];
            NSLog(@"%@--卖了一张票，还剩余%ld张票", current.name, _totalModel.totalAmount);

        }else{
            [NSThread exit];
        }
    }
}
- (void)threadAction1{
    /*
     加上锁之后  每一个内存数据同一时间只能有一个线程访问 或 修改
     
     
      'A--卖了一张票，还剩余9张票
     B--卖了一张票，还剩余8张票
      C--卖了一张票，还剩余7张票
      'A--卖了一张票，还剩余6张票
      B--卖了一张票，还剩余5张票
     C--卖了一张票，还剩余4张票
     'A--卖了一张票，还剩余3张票
      B--卖了一张票，还剩余2张票
      C--卖了一张票，还剩余1张票
      'A--卖了一张票，还剩余0张票
     */
    while (1) {
        @synchronized(self){ ///互斥锁
            NSInteger num = _totalModel.totalAmount;
            if (num > 0) {
                //暂停一段时间
                [NSThread sleepForTimeInterval:0.002];
                
                //2.票数-1
                _totalModel.totalAmount= num-1;
                
                //获取当前线程
                NSThread *current=[NSThread currentThread];
                NSLog(@"%@--卖了一张票，还剩余%ld张票", current.name, _totalModel.totalAmount);
                
            }else{
                [NSThread exit];
            }
        }
    }
}
- (void)threadAction2{
   
    
    while (1) {
         [_lock lock];
        NSInteger num = _totalModel.totalAmount;
        if (num > 0) {
            //暂停一段时间
            [NSThread sleepForTimeInterval:0.002];
            
            //2.票数-1
            _totalModel.totalAmount= num-1;
            
            //获取当前线程
            NSThread *current=[NSThread currentThread];
            NSLog(@"%@--卖了一张票，还剩余%ld张票", current.name, _totalModel.totalAmount);
            
        }else{
            [NSThread exit];
        }
          [_lock unlock];
    }
}
- (void)threadAction3{
    while (1) {
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
                NSInteger num = _totalModel.totalAmount;
                if (num > 0) {
                    //暂停一段时间
                    [NSThread sleepForTimeInterval:0.002];
                    
                    //2.票数-1
                    _totalModel.totalAmount= num-1;
                    
                    //获取当前线程
                    NSThread *current=[NSThread currentThread];
                    NSLog(@"%@--卖了一张票，还剩余%ld张票", current.name, _totalModel.totalAmount);
                    
                }else{
                    [NSThread exit];
                }
        dispatch_semaphore_signal(_semaphore);
    }
}
- (void)dispathSeme{
    dispatch_group_t group = dispatch_group_create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i = 0; i < 100; i++){
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_group_async(group, queue, ^{
            for (int j = 0; j<100; j++) {
               NSLog(@"i = %d j = %d",i,j);
            }
            dispatch_semaphore_signal(semaphore);
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end




@implementation   TotalTicketsModel


@end
