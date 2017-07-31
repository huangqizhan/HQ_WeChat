//
//  HQDownLoadFileController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/22.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQDownLoadFileController.h"
#import "HQDownLoadTempModel.h"
#import "HQDownLoadTbaleViewCell.h"
#import "HQCFunction.h"
#import <MediaPlayer/MediaPlayer.h>




@interface HQDownLoadFileController ()<UITableViewDelegate,UITableViewDataSource,HQDownLoadTbaleViewCellPlayerDelegete>
@property (nonatomic, nonnull,strong) UITableView *tableView;
@property (nonatomic, nonnull,strong) NSMutableArray *dataArray;

@end

@implementation HQDownLoadFileController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"MyFile";
    UIButton *test = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [test setTitle:@"test" forState:UIControlStateNormal];
    [test addTarget:self action:@selector(testButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:test];

    [self.view addSubview:self.tableView];
    [self laodData];
    for (HQDownLoadTempModel *model in self.dataArray) {
        NSLog(@"status = %ld",(long)model.status);
    }
}
- (void)testButtonAction{
//    NSDictionary *dic = [HQDownLoadTempModel allDownloadReceipts];
//    HQDownLoadTempModel *model = [dic objectForKey:dic.allKeys.firstObject];
//    model.status = HQDownLoadFileStatusComplite;
//    BOOL result = [NSKeyedArchiver archiveRootObject:dic toFile:localReceiptPath()];
//    if (result) {
//        NSLog(@"save ok");
//    }
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
    return 110;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    HQDownLoadTempModel *Model = self.dataArray[indexPath.row];
    UITableViewRowAction * deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self deleteTempModel:Model andIndexPath:indexPath];
    }];
    return  @[deleteRowAction];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HQDownLoadTbaleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    cell.tempMpdel = self.dataArray[indexPath.row];
    cell.indexPath = indexPath;
    cell.delegate = self;
    return cell;
}
- (void)deleteTempModel:(HQDownLoadTempModel *)model andIndexPath:(NSIndexPath *)indexPath{
    [HQDownLoadTempModel DeleteModel:model andComplite:^(BOOL result) {
        [_tableView reloadData];
        [self.dataArray removeObject:model];
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [_tableView endUpdates];
    }];
}
#pragma mark -------- 播放 ------
- (void)HQDownLoadTbaleViewCell:(HQDownLoadTbaleViewCell *)cell PlayClickWith:(HQDownLoadTempModel *)model{
    NSURL *url = [NSURL fileURLWithPath:model.filePath];
    MPMoviePlayerViewController *mpc = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self.navigationController presentViewController:mpc animated:YES completion:nil];
}
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[HQDownLoadTbaleViewCell class] forCellReuseIdentifier:@"cellId"];
    }
    return _tableView;
}
- (void)laodData{
    NSDictionary *dic = [HQDownLoadTempModel allDownloadReceipts];
    if (dic.count == 0) {
        NSMutableDictionary *data = [NSMutableDictionary new];
        for (int i = 1; i<=10; i++) {
            HQDownLoadTempModel *model = [[HQDownLoadTempModel alloc] init];
            model.urlStr = [NSString stringWithFormat:@"http://120.25.226.186:32812/resources/videos/minion_%02d.mp4", i];
            [data setObject:model forKey:model.urlStr];
            [self.dataArray addObject:model];
        }
        [HQDownLoadTempModel saveModels:data];
    }else{
        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.dataArray addObject:obj];
        }];
    }
    [self.tableView reloadData];
}
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

