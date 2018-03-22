//
//  HQSetChatBegImageController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/28.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQSetChatBegImageController.h"
#import "HQCameraController.h"
#import "HQCameraNavigationController.h"
#import "HQDownLoadChatBegImagController.h"
#import "HQActionSheet.h"
#import "UIApplication+HQExtern.h"

@interface HQSetChatBegImageController ()<HQPickerImageViewControllerDelegate,HQCameraControllerDelegate>

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation HQSetChatBegImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置背景图片";
    [self.view addSubview:self.tableView];
}

#pragma mark   UITableViewDelegate  &&dataSourse  
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if(section == 1){
        return 2;
    }else{
        return 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }else{
        return 30;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HQSetChatBegImageAccessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HQSetChatBegImageAccessCell"];
    if (indexPath.section == 0) {
        cell.titleString = @"选择背景图";
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.titleString = @"从手机相册选取";
        }else{
            cell.titleString = @"拍一张";
        }
    }else{
        cell.titleString = @"清除聊天背景";
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self PushToloadBegChatImageController];
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self seleteBackGroundImageFromAlbom];
        }else if (indexPath.row == 1){
            [self customerCaptureCamera];
        }
    }else {
        [self clearChatBegImage];
    }
}
#pragma mark -------- 下载背景图 -----
- (void)PushToloadBegChatImageController{
    HQDownLoadChatBegImagController *imageVC = [[HQDownLoadChatBegImagController alloc] init];
    imageVC.listModel = self.listModel;
    imageVC.chatDetailCallBack = _chatDetailCallBack;
    [self.navigationController pushViewController:imageVC animated:YES];
}


#pragma mark -------- 相册选取图片 -------
- (void)seleteBackGroundImageFromAlbom{
    HQPickerImageViewController *pickerImageVC = [[HQPickerImageViewController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    [self presentViewController:pickerImageVC animated:YES completion:nil];
}
#pragma mark -------- 自定义拍照 ------
- (void)customerCaptureCamera{
    HQCameraController *camVC = [[HQCameraController alloc] init];
    HQCameraNavigationController *cameraVC = [[HQCameraNavigationController alloc] initWithRootViewController:camVC];
    camVC.delegate = self;
    [self presentViewController:cameraVC animated:YES completion:nil];
}
- (void)HQCameraController:(HQCameraController *)cameraVC andCameraImage:(UIImage *)cameraImage andInfo:(NSDictionary *)info andIdentifer:(NSString *)identufer{
    if (cameraImage) {
        [self saveChatBegImageWith:cameraImage];
    }
}
#pragma mark ------ 图片选择后处理    -------
- (void)imagePickerController:(HQPickerImageViewController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceImageUuids:(NSArray *)imageUuids{
    if (photos.count) {
        [self saveChatBegImageWith:[photos firstObject]];
    }
}

/////保存背景图片
- (void)saveChatBegImageWith:(UIImage *)imaage{
    NSString *fileName = [NSString stringWithFormat:@"ChatBegImageName_%lld",self.listModel.chatListId];
    self.listModel.chatBegImageFilePath = fileName;
    [[HQLocalImageManager shareImageManager] saveChatBegImage:imaage withFileName:fileName andScale:0.5 andComplite:^(BOOL result){
        if (_chatDetailCallBack) {
            if (result) {
                _chatDetailCallBack(@"设置背景图片");
            }else{
                NSLog(@"图片保存失败 请重试!");
            }
        }
    }];
}

#pragma mark ------- 清除聊天背景 -------
- (void)clearChatBegImage{
    HQActionSheet *actionSheet = [[HQActionSheet alloc] initWithTitle:@"清除聊天背景"];
    WEAKSELF;
    HQActionSheetAction *action = [HQActionSheetAction actionWithTitle:@"删除" handler:^(HQActionSheetAction *action) {
        [weakSelf removeChatBegImage];
    } style:HQActionStyleDestructive];
    [actionSheet addAction:action];
    [actionSheet showInWindow:[UIApplication popOverWindow]];
}
////清除聊天背景
- (void)removeChatBegImage{
    self.listModel.chatBegImageFilePath = nil;
    [[HQLocalImageManager shareImageManager] removeChatBegImageWith:self.listModel.chatBegImageFilePath];
    if (_chatDetailCallBack) {
        _chatDetailCallBack(@"设置背景图片");
    }
}
#pragma mark -------- Getter   Setter -------
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_tableView registerClass:[HQSetChatBegImageAccessCell class] forCellReuseIdentifier:@"HQSetChatBegImageAccessCell"];
    }
    return _tableView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end



@interface HQSetChatBegImageAccessCell ()

@property (nonatomic,strong) UILabel *contentLabel;

@end

@implementation HQSetChatBegImageAccessCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.contentLabel];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}
- (UILabel *)contentLabel{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, App_Frame_Width/3.0, 20)];
        _contentLabel.font  = [UIFont systemFontOfSize:SCREENSCALE*17];
    }
    return _contentLabel;
}

- (void)setTitleString:(NSString *)titleString{
    _titleString = titleString;
    _contentLabel.text = _titleString;
}
@end
