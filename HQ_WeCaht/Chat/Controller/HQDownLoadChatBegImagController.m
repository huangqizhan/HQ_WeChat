//
//  HQDownLoadChatBegImagController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/29.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQDownLoadChatBegImagController.h"
#import "DownloadFileModel+Action.h"
#import "DownLoadBackImageCell.h"



@interface HQDownLoadChatBegImagController ()

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation HQDownLoadChatBegImagController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置聊天背景";
    self.view.backgroundColor = UIColorRGB(45, 49, 50);
    [self.view addSubview:self.tableView];
    UIButton *butt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [butt addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [butt setTitle:@"test" forState:UIControlStateNormal];;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:butt];
    [self readDatasFromDB];
}
- (void)rightButtonAction:(UIButton *)sender{
    [self fillDataModel];
}
- (void)readDatasFromDB{
    WEAKSELF;
    [DownloadFileModel searchChatListModelOnAsyThreadWithSearchType:@"chatBeg" andComplite:^(NSArray *resultList) {
        [weakSelf handleDataSourse:resultList];
    }];
}
- (void)handleDataSourse:(NSArray *)array{
    NSInteger count = array.count;
    NSInteger rows = count/3;
    NSInteger lastItems = count%3;
    for (int i = 0; i < rows; i++) {
        NSMutableArray *tempArray = [NSMutableArray new];
        [tempArray addObject:array[i*3+0]];
        [tempArray addObject:array[i*3+1]];
        [tempArray addObject:array[i*3+2]];
        [self.dataArray addObject:tempArray];
    }
    if (lastItems > 0 && rows > 0) {
        NSMutableArray *temp = [NSMutableArray new];
        if (lastItems == 1) {
            [temp addObject:array[(rows)*3]];
        }else if (lastItems == 2){
            [temp addObject:array[(rows)*3]];
            [temp addObject:array[(rows)*3+1]];
        }
        [self.dataArray addObject:temp];
    }
    [self.tableView reloadData];
}
- (void)fillDataModel{
    //saveToDBChatListModelOnMainThread
    DownloadFileModel *model1 = [DownloadFileModel customerInit];
    model1.fileName = @"beg1";
    model1.downLoadType = @"chatBeg";
    model1.contentUrl = @"http://pic.qiantucdn.com/58pic/13/13/44/15i58PICgec_1024.jpg";
    model1.originUrl = @"http://pic.qiantucdn.com/58pic/13/13/44/15i58PICgec_1024.jpg";
    model1.downLoadProcess = 0;
    model1.isFinish = NO;
    
    DownloadFileModel *model2 = [DownloadFileModel customerInit];
    model2.fileName = @"beg2";
    model2.downLoadType = @"chatBeg";
    model2.contentUrl = @"http://pic.qiantucdn.com/58pic/22/75/97/66P58PICKGi_1024.jpg";
    model2.originUrl = @"http://pic.qiantucdn.com/58pic/22/75/97/66P58PICKGi_1024.jpg";
    model2.downLoadProcess = 0;
    model2.isFinish = NO;
    
    DownloadFileModel *model3 = [DownloadFileModel customerInit];
    model3.fileName = @"beg3";
    model3.downLoadType = @"chatBeg";
    model3.contentUrl = @"http://pic.qiantucdn.com/58pic/12/85/20/08f58PICqmT.jpg";
    model3.originUrl = @"http://pic.qiantucdn.com/58pic/12/85/20/08f58PICqmT.jpg";
    model3.downLoadProcess = 0;
    model3.isFinish = NO;
    
    [self.dataArray addObject:@[model1,model2,model3]];
    
    DownloadFileModel *model4 = [DownloadFileModel customerInit];
    model4.fileName = @"beg4";
    model4.downLoadType = @"chatBeg";
    model4.contentUrl = @"http://pic.qiantucdn.com/58pic/16/57/18/16758PIC4Cs_1024.jpg";
    model4.originUrl = @"http://pic.qiantucdn.com/58pic/16/57/18/16758PIC4Cs_1024.jpg";
    model4.downLoadProcess = 0;
    model4.isFinish = NO;
    
    DownloadFileModel *model5 = [DownloadFileModel customerInit];
    model5.fileName = @"beg5";
    model5.downLoadType = @"chatBeg";
    model5.contentUrl = @"http://pic.qiantucdn.com/58pic/17/10/49/20m58PICeGK_1024.jpg";
    model5.originUrl = @"http://pic.qiantucdn.com/58pic/17/10/49/20m58PICeGK_1024.jpg";
    model5.downLoadProcess = 0;
    model5.isFinish = NO;
    
    DownloadFileModel *model6 = [DownloadFileModel customerInit];
    model6.fileName = @"beg6";
    model6.downLoadType = @"chatBeg";
    model6.contentUrl = @"http://pic.qiantucdn.com/58pic/11/00/57/53358PICPBD.jpg";
    model6.originUrl = @"http://pic.qiantucdn.com/58pic/11/00/57/53358PICPBD.jpg";
    model6.downLoadProcess = 0;
    model6.isFinish = NO;
    
    [self.dataArray addObject:@[model4,model5,model6]];
    
    DownloadFileModel *model7 = [DownloadFileModel customerInit];
    model7.fileName = @"beg7";
    model7.downLoadType = @"chatBeg";
    model7.contentUrl = @"http://pic.qiantucdn.com/58pic/17/29/71/70V58PICasF_1024.jpg";
    model7.originUrl = @"http://pic.qiantucdn.com/58pic/17/29/71/70V58PICasF_1024.jpg";
    model7.downLoadProcess = 0;
    model7.isFinish = NO;
    
    DownloadFileModel *model8 = [DownloadFileModel customerInit];
    model8.fileName = @"beg8";
    model8.downLoadType = @"chatBeg";
    model8.contentUrl = @"http://pic.qiantucdn.com/58pic/22/96/45/44G58PICENX_1024.jpg";
    model8.originUrl = @"http://pic.qiantucdn.com/58pic/22/96/45/44G58PICENX_1024.jpg";
    model8.downLoadProcess = 0;
    model8.isFinish = NO;
    
    DownloadFileModel *model9 = [DownloadFileModel customerInit];
    model9.fileName = @"beg9";
    model9.downLoadType = @"chatBeg";
    model9.contentUrl = @"http://pic.qiantucdn.com/58pic/17/29/71/70V58PICasF_1024.jpg";
    model9.originUrl = @"http://pic.qiantucdn.com/58pic/17/29/71/70V58PICasF_1024.jpg";
    model9.downLoadProcess = 0;
    model9.isFinish = NO;
    
    [self.dataArray addObject:@[model7,model8,model9]];
    
    for (NSArray *arr in self.dataArray) {
        for (DownloadFileModel *model in arr) {
            [model saveToDBChatLisModelAsyThread:^(BOOL result) {
                NSLog(@"result = %d",result);
            }];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (App_Frame_Width-30)/3.0+10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DownLoadBackImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownLoadBackImageCell"];
    cell.dateArray = self.dataArray[indexPath.row];
    cell.listModel = self.listModel;
    WEAKSELF;
    [cell setChatDetailCallBack:^(NSString *titleType){
        [weakSelf setChatBegImageCallBackWithTitle:titleType];
    }];
    return cell;
}
/////设置聊天背景
- (void)setChatBegImageCallBackWithTitle:(NSString *)titleType{
    if (_chatDetailCallBack) {
        _chatDetailCallBack(titleType);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        HQMessageBaseController *messageVC = self.navigationController.viewControllers[1];
        [self.navigationController popToViewController:messageVC animated:YES];
    });
}
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[DownLoadBackImageCell class] forCellReuseIdentifier:@"DownLoadBackImageCell"];
        _tableView.separatorColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}
- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
