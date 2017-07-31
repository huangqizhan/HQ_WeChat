//
//  DispachViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/16.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "DispachViewController.h"
#import "DownLoadTest.h"



@interface DispachViewController (){
    dispatch_group_t _group;
    UIImageView *_imageView;
}
@property (nonatomic,copy) NSString *localLastModified;
@property (nonatomic,copy) NSString *etag;
@property (nonatomic,strong) NSMutableURLRequest *request;
@property (nonatomic,strong) NSOutputStream *outputStream;
@property (nonatomic,strong) NSInputStream *inputStream;
@property (nonatomic,strong) NSHTTPURLResponse *response;


@end

@implementation DispachViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self groupQueueTest];
//    [self dispachBarrayTest];
//    [self downloadBaseData];
    
//    [self opDemo3];
//    [self OPerationQueue];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:_imageView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 150, 50, 50)];
    button.backgroundColor = [UIColor blackColor];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
- (void)buttonAction:(UIButton *)sender{
    [self downloADtest];
//    [self urlResponseTest];
}
- (void)urlResponseTest{
    NSURL *url = [NSURL URLWithString:@"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1613188758,3826225464&fm=23&gp=0.jpg"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
    self.request = request;
    
    //    // 发送 etag   HTTP 协议规格说明定义ETag为“被请求变量的实体值”
    if (self.etag.length > 0) {
        [request setValue:self.etag forHTTPHeaderField:@"If-None-Match"];
    }
    // 发送 LastModified
    if (self.localLastModified.length > 0) {
        [request setValue:self.localLastModified forHTTPHeaderField:@"If-Modified-Since"];
    }
    
   NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
       NSLog(@"%@ %tu", response, data.length);
       NSLog(@"currntThread = %@",[NSThread currentThread]);
        // 类型转换（如果将父类设置给子类，需要强制转换）
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"statusCode == %@", @(httpResponse.statusCode));
        // 判断响应的状态码是否是 304 Not Modified  服务器数据没有修改 可以使用本地缓存 但前提是 本地做了缓存   NSMutableURLRequest  可以做URL缓存
        if (httpResponse.statusCode == 304) {
            NSLog(@"加载本地缓存图片");
            // 如果是，使用本地缓存
            // 根据请求获取到`被缓存的响应`！
            NSCachedURLResponse *cacheResponse =  [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
            // 拿到缓存的数据
            data = cacheResponse.data;
        }
        // 获取并且纪录 etag，区分大小写
       self.etag = httpResponse.allHeaderFields[@"Etag"];
        // 获取并且纪录 LastModified   f1c2c47a4b66441418a6afc0d4586a6c  f1c2c47a4b66441418a6afc0d4586a6c
        self.localLastModified = httpResponse.allHeaderFields[@"Last-Modified"];
        //        NSLog(@"%@", self.etag);
        NSLog(@"%@", self.localLastModified);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"data = %@",data);
        });
   }];
    [task resume];

}
//下载暂停时提供断点下载功能，修改请求的HTTP头，记录当前下载的文件位置，下次可以从这个位置开始下载。
- (void)pause {
    unsigned long long offset = 0;
    if ([self.outputStream propertyForKey:NSStreamFileCurrentOffsetKey]) {
        offset = [[self.outputStream propertyForKey:NSStreamFileCurrentOffsetKey] unsignedLongLongValue];
    } else {
        offset = [[self.outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] length];
    }
    NSMutableURLRequest *mutableURLRequest = [self.request mutableCopy];
    if ([self.response respondsToSelector:@selector(allHeaderFields)] && [[self.response allHeaderFields] valueForKey:@"ETag"]) {
        //若请求返回的头部有ETag，则续传时要带上这个ETag，
        //ETag用于放置文件的唯一标识，比如文件MD5值
        //续传时带上ETag服务端可以校验相对上次请求，文件有没有变化，
        //若有变化则返回200，回应新文件的全数据，若无变化则返回206续传。
        [mutableURLRequest setValue:[[self.response allHeaderFields] valueForKey:@"ETag"] forHTTPHeaderField:@"If-Range"];
    }
    //给当前request加Range头部，下次请求带上头部，可以从offset位置继续下载
    [mutableURLRequest setValue:[NSString stringWithFormat:@"bytes=%llu-", offset] forHTTPHeaderField:@"Range"];
    self.request = mutableURLRequest;
//    [super pause];
}

- (void)loadMP4File{
    NSString *str = @"http://120.25.226.186:32812/resources/videos/minion_%02d.mp4";
    
    [[DownLoadTest shareDownLoadManager] downloadWithUrl:[NSURL URLWithString:str] andOptions:DownLoadOptionsNone andProcess:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        NSLog(@"receivedSize = %ld",receivedSize);
    } andComplite:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        
    }];

}
- (void)downloADtest{
    NSArray *urls = @[
                      @"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=191087132,2112381897&fm=23&gp=0.jpg",
                      @"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=191087132,2112381897&fm=23&gp=0.jpg",
                      @"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=2349162639,2804432016&fm=23&gp=0.jpg",@"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=202298185,1061629417&fm=23&gp=0.jpg",
                      @"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1613188758,3826225464&fm=23&gp=0.jpg"
                      ];
    
    NSMutableArray *images = [NSMutableArray new];
    for (NSString *title in urls) {
        [[DownLoadTest shareDownLoadManager] downloadWithUrl:[NSURL URLWithString:title] andOptions:DownLoadOptionsNone andProcess:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            NSLog(@"receivedSize = %ld",receivedSize);
        } andComplite:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            [images addObject:image];
        }];

    }
    if ([DownLoadTest shareDownLoadManager].currentDownloadCount == 1) {
        NSLog(@"images = %@",images);
    }
}

/**
 *  因为是异步，所以开通了子线程，但是因为是串行队列，所以只需要开通1个子线程（2），它们在子线程中顺序执行。最常用。
 */
-(void)gcdDemo1{
    dispatch_queue_t q1=dispatch_queue_create("com.hellocation.gcdDemo", DISPATCH_QUEUE_SERIAL);
    for (int i=0; i<10; i++) {
        dispatch_async(q1, ^{
            for (int j = 0; j<10; j++) {
                NSLog(@"%@ %d",[NSThread currentThread],i);
            }
        });
    }
}
/**
 *  因为是异步，所以开通了子线程，且因为是并行队列，所以开通了好多个子线程，具体几个，无人知晓，看运气。线程数量无法控制，且浪费。
 */
-(void)gcdDemo2{
    dispatch_queue_t q2=dispatch_queue_create("com.hellocation.gcdDemo", DISPATCH_QUEUE_CONCURRENT);
    for (int i=0; i<10; i++) {
        dispatch_async(q2, ^{
            NSLog(@"%@",[NSThread currentThread]);
        });
    }
}
/**
 *  因为是同步，所以无论是并行队列还是串行队列，都是在主线程中执行
 */
-(void)gcdDemo3{
    dispatch_queue_t q1=dispatch_queue_create("com.hellocation.gcdDemo", DISPATCH_QUEUE_SERIAL);
    for (int i=0; i<10; i++) {
        dispatch_sync(q1, ^{
            NSLog(@"%@",[NSThread currentThread]);
        });
    }
}
/**
 *  全局队列和并行队列类似（全局队列不需要创建直接get即可，而导致其没有名字，不利于后续调试）
 */
-(void)gcdDemo5{
    dispatch_queue_t q=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i=0; i<10; i++) {
        dispatch_sync(q, ^{
            NSLog(@"%@",[NSThread currentThread]);
        });
    }
    for (int i=0; i<10; i++) {
        dispatch_async(q, ^{
            NSLog(@"%@",[NSThread currentThread]);
        });
    }
}
/**
 *  因为是主线程，所以异步任务也会在主线程上运行（1）。而如果是同步任务，则阻塞了，因为主线程一直会在运行，所以后米的任务永远不会被执行。
 *  主要用处，是更新UI，更新UI一律在主线程上实现
 */
-(void)gcdDemo6{
    dispatch_queue_t q=dispatch_get_main_queue();
    for (int i=0; i<10; i++) {
        dispatch_sync(q, ^{
            NSLog(@"%@",[NSThread currentThread]);
        });
    }
    //    for (int i=0; i<10; i++) {
    //        dispatch_async(q, ^{
    //            NSLog(@"%@",[NSThread currentThread]);
    //        });
    //    }  
}

- (void)opDemo3{
    NSBlockOperation *op1=[NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 10; i++) {
            NSLog(@"下载图片 %@",[NSThread currentThread]);
        }
    }];
    NSBlockOperation *op2=[NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i<10; i++) {
            NSLog(@"修饰图片 %@",[NSThread currentThread]);
        }
    }];
    NSBlockOperation *op3=[NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i<10; i++) {
            NSLog(@"保存图片 %@",[NSThread currentThread]);
        }
    }];
    NSBlockOperation *op4=[NSBlockOperation blockOperationWithBlock:^{
        
        NSLog(@"更新UI %@",[NSThread currentThread]);
    }];
    [op4 addDependency:op3];
    [op3 addDependency:op2];
    [op2 addDependency:op1];
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    //设置同一时刻最大开启的线程数，这是NSOperationQueue特有的
    [queue setMaxConcurrentOperationCount:2];
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    [[NSOperationQueue mainQueue]addOperation:op4];
}


- (void)dispachBarrayTest{
    dispatch_queue_t queue = dispatch_queue_create("wqew", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        for (int i = 0; i<100; i++) {
            NSLog(@"1-1 currentThread = %@ i= %d",[NSThread currentThread],i);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i<100; i++) {
            NSLog(@"2-2 currentThread = %@ i= %d" ,[NSThread currentThread],i);
        }
    });
    /*
     ///dispatch_barrier_async  会等待前面的两个异步操作操作完成之后 再把自己的异步操作添加到系列 而且执行完自己的操作之后 再添加自己后面的操作
     
     dispatch_barrier_async(queue, ^{
     for (int i = 0; i<100; i++) {
     NSLog(@"dispatch_barrier_async currentThread = %@ i = %d",[NSThread currentThread],i);
     }
     });
     dispatch_async(queue, ^{
     for (int i = 0; i<100; i++) {
     NSLog(@"3-3 currentThread = %@ i= %d" ,[NSThread currentThread],i);
     }
     });
     */

    
    /*
     
     */
    dispatch_barrier_async(queue, ^{
        for (int i = 0; i<1000; i++) {
            NSLog(@"dispatch_barrier_async currentThread = %@ i = %d",[NSThread currentThread],i);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i<1000; i++) {
            NSLog(@"3-3 currentThread = %@ i= %d" ,[NSThread currentThread],i);
        }
    });
}
- (void)groupQueueTest{
    // 全局并行队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    // 创建一个group
    dispatch_group_t group = dispatch_group_create();
    ///异步操作
    dispatch_group_async(group, globalQueue, ^{
        for (int i = 0; i<1000; i++) {
            NSLog(@"async1  operation1  currentThread = %@",[NSThread currentThread]);
        }
        // 执行请求1... （这里的代码需要时同步执行才能达到效果）
    });
    dispatch_group_async(group, globalQueue, ^{
        for (int i = 0; i<1000; i++) {
            NSLog(@"async2  operation2 currentThread = %@",[NSThread currentThread]);
        }
        // 执行请求2...
    });
    dispatch_group_async(group, globalQueue, ^{
        for (int i = 0; i<1000; i++) {
            NSLog(@"async3  operation2 currentThread = %@",[NSThread currentThread]);
        }
        // 执行请求N...
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"全部请求执行完毕! currentThread = %@",[NSThread currentThread]);
    });
    ///当dispatch_group_async的block里面执行的是异步任务，如果还是使用上面的方法你会发现异步任务还没跑完就已经进入到了dispatch_group_notify方法里面了，这时用到dispatch_group_enter和dispatch_group_leave就可以解决这个问题
}
- (void)downloadBaseData{
    // 全局变量group
    _group = dispatch_group_create();
    // 并行队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 进入组（进入组和离开组必须成对出现, 否则会造成死锁）
    dispatch_group_enter(_group);
    dispatch_group_async(_group, queue, ^{
        // 执行异步任务1
        [self fetchBaseData];
    });
    
    // 进入组
    dispatch_group_enter(_group);
    dispatch_group_async(_group, queue, ^{
        // 执行异步任务2
        [self fetchInspectorBaseData];
    });
    
    dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
        NSLog(@"reback main queue");
    });
}
- (void)fetchBaseData{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    });
    for (int i = 0; i<10000; i++) {
        NSLog(@"2-2   i  = %d",i);
    }
    dispatch_group_leave(_group);
}

- (void)fetchInspectorBaseData{
    for (int i = 0; i<10000; i++) {
        NSLog(@"1-1   i  = %d currnetThread = %@",i,[NSThread currentThread]);
    }
    dispatch_group_leave(_group);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end




@implementation MyOperation


- (void)operationAction{
    
    for (int i = 0; i<100; i++) {
        NSLog(@"%@ i = %d currnetThread = %@",self.title,i,[NSThread currentThread]);
    }
//    dispatch_queue_t queue = dispatch_queue_create("myqueue",DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queue, ^{
//    });
}
@end
