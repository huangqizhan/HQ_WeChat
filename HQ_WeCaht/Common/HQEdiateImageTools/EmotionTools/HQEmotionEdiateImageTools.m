//
//  HQEmotionEdiateImageTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEmotionEdiateImageTools.h"
#import "HQEdiateImageController.h"
#import "HQEdiateImgView.h"



@interface HQEmotionEdiateImageTools ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    
    CGSize _originalImageSize;
    //修改前的图片
    UIImage *_originalImage;
    
}

@property (nonatomic) UIView *drawMenuView;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSMutableArray *emotionArray;
@property (nonatomic) NSMutableArray *emotionViewArray;
@property (nonatomic) UIView *workView;

@end


@implementation HQEmotionEdiateImageTools
- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateToolInfo:(HQEdiateToolInfo *)toolInfo{
    return [super initWithEdiateController:ediateController andEdiateToolInfo:toolInfo];
}

- (void)setUpCurrentEdiateStatus{
    [super setUpCurrentEdiateStatus];
    
    _originalImageSize = self.imageEdiateController.ediateImageView.image.size;
    
    _originalImage = self.imageEdiateController.ediateImageView.image;
    _originalImageSize = self.imageEdiateController.ediateImageView.image.size;
    
    _workView = [[UIView alloc] initWithFrame:self.imageEdiateController.ediateImageView.bounds];
    _workView.clipsToBounds = YES;
    [self.imageEdiateController.ediateImageView addSubview:_workView];
    
    self.imageEdiateController.ediateImageView.userInteractionEnabled = YES;
    self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.imageEdiateController.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.imageEdiateController.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;

    self.imageEdiateController.ediateImageView.userInteractionEnabled = YES;
    self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.imageEdiateController.scrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.imageEdiateController.scrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;
    
    
    _drawMenuView =  [[UIView alloc] initWithFrame:CGRectMake(0, APP_Frame_Height, App_Frame_Width, 80)];
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
        _drawMenuView.top = APP_Frame_Height- 80;
    } completion:nil];
}

- (void)backButtonAction:(UIButton *)sender{
    if (self.emotionViewArray.count) {
        HQEdiateImgView *ediateView = self.emotionViewArray.lastObject;
        [self deleteEdiateImageViewWith:ediateView];
    }
    [self setReBackButtonStatusWith:self.emotionViewArray.count?YES:NO];
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self clearaAllEdiateImageViewSeleteStatus];
        UIImage *image = [self buildImage:_originalImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
            self.imageEdiateController.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
            [self clearDrawViewButtonAction:nil];
        });
    });
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
    [self ClickEmotionItem:indexPath];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake (35, 35);
}
#pragma mark -------- 点击表情处理 -------
- (void)ClickEmotionItem:(NSIndexPath *)indexPath{
    [self clearaAllEdiateImageViewSeleteStatus];
    HQEdiateImgView *ediateImage = [[HQEdiateImgView  alloc] initWithContentImage:[UIImage imageNamed:self.emotionArray[indexPath.item]]];
    ediateImage.center = CGPointMake(_workView.width/2, _workView.height/2);
    [ediateImage setActiveEmoticonViewWithActive:YES];
    WEAKSELF;
    [ediateImage setBeginDragCallBack:^(HQEdiateImgView *ediateView){
        [weakSelf clearaAllEdiateImageViewSeleteStatus];
    }];
    [ediateImage setDeleteEdiateImageViewCallBack:^(HQEdiateImgView *ediateView){
        [weakSelf deleteEdiateImageViewWith:ediateView];
    }];
    [self.emotionViewArray addObject:ediateImage];
    [_workView addSubview:ediateImage];
    [self setReBackButtonStatusWith:self.emotionViewArray.count?YES:NO];
}
- (void)clearaAllEdiateImageViewSeleteStatus{
    for (HQEdiateImgView *emotionView in self.emotionViewArray) {
        [emotionView setActiveEmoticonViewWithActive:NO];
    }
}
- (void)deleteEdiateImageViewWith:(HQEdiateImgView *)ediateImageVierw{
    if (ediateImageVierw) {
        [self.emotionViewArray removeObject:ediateImageVierw];
        [ediateImageVierw removeFromSuperview];
        if (self.emotionViewArray.count) {
            HQEdiateImgView *LastemotionView = self.emotionViewArray.lastObject;
            [LastemotionView setActiveEmoticonViewWithActive:YES];
        }
    }
    [self setReBackButtonStatusWith:self.emotionViewArray.count?YES:NO];
}
- (NSMutableArray *)emotionArray{
    if (_emotionArray == nil) {
        _emotionArray = [NSMutableArray new];
        [_emotionArray addObjectsFromArray:@[@"EdiateImage001",@"EdiateImage002",@"EdiateImage003",@"EdiateImage004",@"EdiateImage005",@"EdiateImage006",@"EdiateImage007",@"EdiateImage008",@"EdiateImage009",@"EdiateImage010"]];
    }
    return _emotionArray;
}
- (NSMutableArray *)emotionViewArray{
    if (_emotionViewArray== nil) {
        _emotionViewArray = [NSMutableArray new];
    }
    return _emotionViewArray;
}
- (UICollectionView *)collectionView{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layput = [[UICollectionViewFlowLayout alloc] init];
        layput.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layput.sectionInset = UIEdgeInsetsMake(0, 0,0, 0);

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 35, App_Frame_Width-20, 30) collectionViewLayout:layput];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate  = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = YES;
        [_collectionView registerClass:[EmotionCollectionViewCell class] forCellWithReuseIdentifier:@"EmotionCollectionViewCell"];
    }
    return _collectionView;
}
- (void)setReBackButtonStatusWith:(BOOL)active{
    [UIView animateKeyframesWithDuration: 0.35 delay: 0 options: 0 animations: ^{
        [UIView addKeyframeWithRelativeStartTime: 0
                                relativeDuration: 1 / 3.0
                                      animations: ^{
                                          if (active) {
                                              _backButton.transform = CGAffineTransformMakeScale(1.5, 1.5);
                                          }else{
                                              _backButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                          }
                                      }];
        //        [UIView addKeyframeWithRelativeStartTime: 1 / 3.0
        //                                relativeDuration: 1 / 3.0
        //                                      animations: ^{
        //                                          _backButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
        //                                      }];
        //        [UIView addKeyframeWithRelativeStartTime: 2 / 3.0
        //                                relativeDuration: 1 / 3.0
        //                                      animations: ^{
        //                                          _backButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
        //                                      }];
    } completion: ^(BOOL finished) {
        
    }];
}
- (UIImage*)buildImage:(UIImage*)image{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    [image drawAtPoint:CGPointZero];
    
    //缩放比例
    CGFloat scale = image.size.width / _workView.width;
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
    [_workView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tmp;
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
