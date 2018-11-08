//
//  HQBroswerViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/6.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQBroswerViewController.h"
#import "ControllerTranstionAnimation.h"
#import "UIViewController+HQTranstion.h"
#import "HQBroswerCollectionViewCell.h"
#import "HQBroswerModel.h"
#import "UIImage+Resize.h"
#import "HQLocalImageManager.h"


@interface HQBroswerViewController ()<ControllerTranstionAnimationDetaSourse>{
    
    UIView *_naviBar;
    UIButton *_backButton;
    
}
@property (nonatomic,strong) UIButton *imageButton;
@property (nonatomic,strong) UICollectionView *collectionView;
@end

@implementation HQBroswerViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    
    [self configCollectionView];
//    [self configCustomNaviBar];
    
    [self hq_addTransitionDelegate:self];
    
    [self hq_popTransitionAnimationWithCurrentScrollView:self.collectionView  animationDuration:0.25 isInteractiveTransition:YES];
    WEAKSELF;
    [self hq_setupReturnBtnWithImage:nil color:nil callBackHandler:^{
         [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
//    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singelTapAction:)];
//    [self.view addGestureRecognizer:tap1];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hq_removeTransitionDelegate];
//    [HQLocalImageManager clearImageCacheOriginImageWhenBroswerFinishWith:self.broswerArray];
    [self.broswerArray removeAllObjects];
    [self.navigationController setNavigationBarHidden:NO];
    if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = NO;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = YES;
}
- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.view.width + 20, self.view.height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.width + 20, self.view.height) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    _collectionView.contentSize = CGSizeMake(self.broswerArray.count * (App_Frame_Width + 20), 0);
    _collectionView.contentOffset = CGPointMake(self.currnetImageIndex*(App_Frame_Width + 20), 0);
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[HQBroswerCollectionViewCell class] forCellWithReuseIdentifier:@"HQBroswerCollectionViewCellId"];
}
- (void)configCustomNaviBar {
    
    _naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.tz_width, 64)];
    _naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:0.7];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 44, 44)];
    [_backButton setImage:[UIImage imageNamedFromMyBundle:@"navi_back.png"] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_naviBar addSubview:_backButton];
    [self.view addSubview:_naviBar];
}
#pragma mark  UICollectionViewDelegate ------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.broswerArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HQBroswerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HQBroswerCollectionViewCellId" forIndexPath:indexPath];
    cell.broswerModel = self.broswerArray[indexPath.row];
    WEAKSELF;
    [cell setSingleTapGestureBlock:^{
        [weakSelf singelTapAction];
    }];
    return cell;
}

- (void)singelTapAction{
    self.currnetImageIndex =  self.collectionView.contentOffset.x/App_Frame_Width;
    if (self.currnetImageIndex < self.broswerArray.count) {
        HQBroswerModel *model = [self.broswerArray objectAtIndex:self.currnetImageIndex];
        if (_currentScanImageIndexCallBack) _currentScanImageIndexCallBack(model);
        [_imageButton setBackgroundImage:model.tempImage forState:UIControlStateNormal];
        _imageButton.frame = [UIImage caculateBroswerImageSizeWith:model.tempImage];
        _imageButton.center = CGPointMake(App_Frame_Width/2.0, APP_Frame_Height/2.0);
    }
    [self returnAction:nil];
}

- (void)backButtonClick:(UIButton *)sender{
    self.currnetImageIndex =  self.collectionView.contentOffset.x/App_Frame_Width;
    if (self.currnetImageIndex < self.broswerArray.count) {
        HQBroswerModel *model = [self.broswerArray objectAtIndex:self.currnetImageIndex];
        if (_currentScanImageIndexCallBack) _currentScanImageIndexCallBack(model);
        [_imageButton setBackgroundImage:model.tempImage forState:UIControlStateNormal];
        _imageButton.frame = [UIImage caculateBroswerImageSizeWith:model.tempImage];
        _imageButton.center = CGPointMake(App_Frame_Width/2.0, APP_Frame_Height/2.0);
    }
    [self returnAction:sender];
}
- (UIButton *)pushTransitionImageView{
    return self.imageButton;
}
- (UIButton *)popTransitionImageView{
    return self.imageButton;
}
- (UIButton *)imageButton{
    if (_imageButton == nil) {
        HQBroswerModel *model = [self.broswerArray objectAtIndex:self.currnetImageIndex];
        _imageButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _imageButton.frame =  [UIImage caculateBroswerImageSizeWith:model.tempImage];
        _imageButton.center = CGPointMake(App_Frame_Width/2.0, APP_Frame_Height/2.0);
        [self.view addSubview:_imageButton];
    }
    return _imageButton;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end


