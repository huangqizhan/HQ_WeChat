//
//  VisualEffectViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/3.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "VisualEffectViewController.h"

@interface VisualEffectViewController ()<HQPickerImageViewControllerDelegate>

@property (nonatomic,strong) UIImageView *begImageView;

@property (nonatomic, strong) UIVisualEffectView *effectView;


@end

@implementation VisualEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.begImageView];
    [self.view addSubview:self.effectView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"photo" style:UIBarButtonItemStylePlain target:self action:@selector(seleteBackGroundImageFromAlbom)];
}

#pragma mark -------- 相册选取图片 -------
- (void)seleteBackGroundImageFromAlbom{
    HQPickerImageViewController *pickerImageVC = [[HQPickerImageViewController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    [self presentViewController:pickerImageVC animated:YES completion:nil];
}
#pragma mark ------ 图片选择后处理    -------
- (void)imagePickerController:(HQPickerImageViewController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceImageUuids:(NSArray *)imageUuids{
    if (photos.count) {
        self.begImageView.image = photos.firstObject;
//        [self.view addSubview:self.effectView];
    }
}

- (UIImageView *)begImageView{
    if (_begImageView == nil) {
        _begImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64)];
        _begImageView.clipsToBounds = YES;
        _begImageView.contentMode = UIViewContentModeScaleAspectFill;
//        _begImageView.backgroundColor = IColor(240, 237, 237);
        NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_0373" ofType:@".jpg"];
        _begImageView.image  = [UIImage imageWithContentsOfFile:path];
    }
    return _begImageView;
}

- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        _effectView = [[UIVisualEffectView alloc] initWithEffect: [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _effectView.frame = CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64);
        UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _effectView.frame.size.width, _effectView.frame.size.height * 0.5)];
        [saveBtn setTitle:@"保存图片" forState:UIControlStateNormal];
        saveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//        [saveBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, _effectView.frame.size.height*0.5, _effectView.frame.size.width, _effectView.frame.size.height * 0.5)];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
//        [_effectView addSubview:saveBtn];
//        [_effectView addSubview:cancelBtn];
        CALayer *lineLayer = [CALayer layer];
        lineLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
        lineLayer.frame = CGRectMake(0, _effectView.frame.size.height*0.5, _effectView.frame.size.width, 0.5);
//        [_effectView.layer addSublayer:lineLayer];
    }
    return _effectView;
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
