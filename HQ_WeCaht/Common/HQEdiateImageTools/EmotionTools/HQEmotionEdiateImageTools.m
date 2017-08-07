//
//  HQEmotionEdiateImageTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEmotionEdiateImageTools.h"
#import "HQEdiateImageController.h"

@interface HQEmotionEdiateImageTools ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    
    CGSize _originalImageSize;
    
}

@property (nonatomic) UIView *drawMenuView;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSMutableArray *emotionArray;
@property (nonatomic) UIView *workView;

@end


@implementation HQEmotionEdiateImageTools
- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateToolInfo:(HQEdiateToolInfo *)toolInfo{
    return [super initWithEdiateController:ediateController andEdiateToolInfo:toolInfo];
}

- (void)setUpCurrentEdiateStatus{
    [super setUpCurrentEdiateStatus];
    
    _originalImageSize = self.imageEdiateController.ediateImageView.image.size;
    
    
    _originalImageSize = self.imageEdiateController.ediateImageView.image.size;
    
    _workView = [[UIView alloc] initWithFrame:self.imageEdiateController.ediateImageView.bounds];
    _workView.backgroundColor = [UIColor clearColor];
    [self.imageEdiateController.ediateImageView addSubview:_workView];
    
    self.imageEdiateController.ediateImageView.userInteractionEnabled = YES;
    self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.imageEdiateController.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.imageEdiateController.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;

    self.imageEdiateController.ediateImageView.userInteractionEnabled = YES;
    self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.imageEdiateController.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.imageEdiateController.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
    
    
    _drawMenuView =  [[UIView alloc] initWithFrame:CGRectMake(0, APP_Frame_Height, App_Frame_Width, 120)];
    _drawMenuView.backgroundColor = [UIColor clearColor];
    UIButton *cancelBut = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [cancelBut setImage:[UIImage imageNamed:@"EdiateImageDismissBut"] forState:UIControlStateNormal];
    [cancelBut addTarget:self action:@selector(clearDrawViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_drawMenuView addSubview:cancelBut];
    
    _backButton  = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width-40, 0, 40, 30)];
    [_backButton setImage:[UIImage imageNamed:@"EditImageRevokeDisable_21x21_"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_drawMenuView addSubview:_backButton];
    
    [self.imageEdiateController.view addSubview:_drawMenuView];
    
    [_drawMenuView addSubview:self.collectionView];
    
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _drawMenuView.top = APP_Frame_Height- 120;
    } completion:nil];
}

- (void)backButtonAction:(UIButton *)sender{
}
- (void)clearDrawViewButtonAction:(UIButton *)sender{
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _drawMenuView.top = APP_Frame_Height;
    } completion:^(BOOL finished){
        [_drawMenuView removeFromSuperview];
        [_workView removeFromSuperview];
        [self.imageEdiateController resetBottomViewEdiateStatus];
    }];
}
- (void)clearCurrentEdiateStatus{
    [super clearCurrentEdiateStatus];
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        _drawMenuView.top = APP_Frame_Height;
    } completion:^(BOOL finished){
        [_drawMenuView removeFromSuperview];
        [_workView removeFromSuperview];
    }];
}
- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock{
}
#pragma mark   -------- UICollectionViewDelegate   UICollectionViewDataSourse --------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.emotionArray.count;
}

- ( UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    EmotionCollectionViewCell *ediateImageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmotionCollectionViewCell" forIndexPath:indexPath];
    ediateImageCell.imageName = self.emotionArray[indexPath.item];
    return ediateImageCell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
}
- (NSMutableArray *)emotionArray{
    if (_emotionArray == nil) {
        _emotionArray = [NSMutableArray new];
        [_emotionArray addObjectsFromArray:@[@"EdiateImage001",@"EdiateImage002",@"EdiateImage003",@"EdiateImage004",@"EdiateImage005",@"EdiateImage006",@"EdiateImage007",@"EdiateImage008",@"EdiateImage009",@"EdiateImage010"]];
    }
    return _emotionArray;
}
- (UICollectionView *)collectionView{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layput = [[UICollectionViewFlowLayout alloc] init];
        layput.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layput.sectionInset = UIEdgeInsetsMake(0, 0,0, 0);
//        layput.headerReferenceSize = CGSizeMake(App_Frame_Width, 0.1);

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 40, App_Frame_Width-20, 70) collectionViewLayout:layput];
        _collectionView.delegate  = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = YES;
        [_collectionView registerClass:[EmotionCollectionViewCell class] forCellWithReuseIdentifier:@"EmotionCollectionViewCell"];
    }
    return _collectionView;
}
//图片
+ (UIImage*)defaultIconImage{
    return [UIImage imageNamed:@"ToolViewEmotion"];
}

//工具名称
+ (NSString*)defaultTitle{
    return nil;
    
}

//显示顺序
+ (NSUInteger)orderNum{
    return 3;
}


@end




@interface EmotionCollectionViewCell ()

@property (nonatomic) UIImageView *contentImageView;

@end

@implementation EmotionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.contentImageView];
    }
    return  self;
}
- (void)setImageName:(NSString *)imageName{
    _imageName = imageName;
    self.contentImageView.image =   [UIImage imageNamed:_imageName];
}
- (UIImageView *)contentImageView{
    if (_contentImageView == nil) {
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    }
    return _contentImageView;
}


@end
