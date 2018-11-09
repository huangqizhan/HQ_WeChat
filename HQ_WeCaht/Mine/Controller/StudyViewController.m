//
//  StudyViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/11/16.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "StudyViewController.h"


@interface StudyViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;


@end

@implementation StudyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"学习";
    self.view.backgroundColor = [UIColor blackColor];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:_tableView];
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
    return 10.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *className = _dataArray[indexPath.row];
    Class vcClass = NSClassFromString(className);
    UIViewController *vc = [[vcClass alloc] init];
    if ([className isEqualToString:@"HQEdiateImageController"]) {
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }else{
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
        [_dataArray addObjectsFromArray:@[@"ProcessController",@"TranstionAnimationViewController",@"VisualEffectViewController",@"HQEdiateImageController",@"GestureViewController",@"PoperViewController",@"TestPopViewController",@"JSWebViewController",@"LabelViewController",@"TextViewController"]];
    }
    return _dataArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
