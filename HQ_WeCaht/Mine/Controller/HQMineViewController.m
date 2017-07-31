//
//  HQMineViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQMineViewController.h"
#import "TranstionAnimationViewController.h"
#import "ProcessController.h"
#import "GifTempViewController.h"
#import "DynamicTextViewController.h"
#import "DispachViewController.h"
#import "NSStreamViewController.h"
#import "HQWifiViewController.h"
#import "HQDownLoadFileController.h"
#import "VisualEffectViewController.h"
#import "SendMessageTestViewController.h"
#import "RefershViewController.h"
#import "HQEdiateImageController.h"



@interface HQMineViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
}
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation HQMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 12;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"customer process view";
    }else if (indexPath.row == 1){
        cell.textLabel.text = @"customer transitionAnimation";
    }else if (indexPath.row == 2){
        cell.textLabel.text = @"giftest";
    }else if (indexPath.row == 3){
        cell.textLabel.text = @"imageFuzzy";
    }else if (indexPath.row == 4){
        cell.textLabel.text = @"dispach";
    }else if (indexPath.row == 5){
        cell.textLabel.text = @"NSStream";
    }else if (indexPath.row == 6){
        cell.textLabel.text = @"WIFI";
    }else if (indexPath.row == 7){
        cell.textLabel.text = @"downLoadTest";
    }else if (indexPath.row == 8){
        cell.textLabel.text = @"visualEffectView";
    }else if (indexPath.row == 9){
        cell.textLabel.text = @"distributionMessage";
    }else if (indexPath.row == 10){
        cell.textLabel.text = @"RefershViewController";
    }else{
        cell.textLabel.text = @"HQEdiateImageController";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        ProcessController *processVC = [[ProcessController alloc] init];
        [self.navigationController pushViewController:processVC animated:YES];
    }else if (indexPath.row == 1){
        TranstionAnimationViewController *transVC = [[TranstionAnimationViewController alloc] init];
        [self.navigationController pushViewController:transVC animated:YES];
    }else if (indexPath.row == 2){
        GifTempViewController *gifVC = [[GifTempViewController alloc] init];
        [self.navigationController pushViewController:gifVC animated:YES];
    }else if (indexPath.row == 3){
        DynamicTextViewController *textViewVC = [[DynamicTextViewController alloc] init];
        [self.navigationController pushViewController:textViewVC animated:YES];
    }else if (indexPath.row == 4){
        DispachViewController *disVC  = [[DispachViewController alloc] init];
        [self.navigationController pushViewController:disVC animated:YES];
    }else if (indexPath.row == 5){
        NSStreamViewController *vc = [[NSStreamViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 6){
        HQWifiViewController *wifiVC = [[HQWifiViewController alloc] init];
        [self.navigationController pushViewController:wifiVC animated:YES];
    }else if (indexPath.row == 7){
        HQDownLoadFileController *downLoadVc =[[HQDownLoadFileController alloc] init];
        [self.navigationController pushViewController:downLoadVc animated:YES];
    }else if (indexPath.row == 8){
        VisualEffectViewController *effectView = [[VisualEffectViewController alloc] init];
        [self.navigationController pushViewController:effectView animated:YES];
    }else if (indexPath.row == 9){
        SendMessageTestViewController *sendMsgVC = [[SendMessageTestViewController alloc] init];
        [self.navigationController pushViewController:sendMsgVC animated:YES];
    }else if (indexPath.row == 10){
        RefershViewController *refershVC  = [[RefershViewController alloc] init];
        [self.navigationController pushViewController:refershVC animated:YES];
    }else{
        HQEdiateImageController *ediateImageVC = [[HQEdiateImageController alloc] init];
        [self.navigationController pushViewController:ediateImageVC animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
