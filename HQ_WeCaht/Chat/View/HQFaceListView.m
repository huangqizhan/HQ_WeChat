//
//  HQFaceListView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQFaceListView.h"
#import "HQFacePageCollectionCell.h"
#import "HQFaceMenuView.h"




@interface HQFaceListView ()<HQFacePageViewDelegate,HQFaceMenuViewDelegate>

@property (nonatomic,strong)UIView *topLine;
@property (nonatomic,strong)NSMutableArray *emojDataArray;
@property (nonatomic,strong)NSMutableArray *gifDataArray;
@property (nonatomic,strong) HQFaceMenuView *menuView;
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)UIPageControl *pageControl;

@end




@implementation HQFaceListView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _menuView =  [[HQFaceMenuView alloc] init];
        _menuView.backgroundColor = [UIColor whiteColor];
        _menuView.delegate = self;
        [self addSubview:_menuView];
        
        UICollectionViewFlowLayout *layput = [[UICollectionViewFlowLayout alloc] init];
        layput.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layput.sectionInset=UIEdgeInsetsMake(15, 0,15, 0);
        layput.headerReferenceSize = CGSizeMake(App_Frame_Width, 0.1);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layput];
        ///CGRectMake(0, 0, App_Frame_Width, HEIGHT_CHATBOXVIEW)
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = YES;
        [_collectionView registerClass:[HQFacePageCollectionCell class] forCellWithReuseIdentifier:@"pageCellId"];
        [_collectionView registerClass:[HQGifPageCollectionCell class] forCellWithReuseIdentifier:@"gifPageCellId"];
        [self addSubview:_collectionView];
        [self addSubview:self.topLine];
        [self addSubview:self.pageControl];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [HQFaceTools getNormalEmotions];
            //[HQFaceTools getCustomerEmotions];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                [self refershMenuView];
            });
        });
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.collectionView.x = 0;
    self.collectionView.y = 0;
    self.collectionView.width  = self.width;
    self.collectionView.height = self.height-46;
    
    self.pageControl.x = 0;
    self.pageControl.y = self.collectionView.bottom;
    self.pageControl.width = App_Frame_Width;
    self.pageControl.height = 10;
    
    self.menuView.x = 0;
    self.menuView.y = self.pageControl.bottom;
    self.menuView.height = HQFaceMenuViewHeight;
    self.menuView.width = self.width;
    
}
#pragma mark --- UIcollectionViewDelegate ----
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.emojDataArray.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.emojDataArray[section] count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section < 1) {
        HQFacePageCollectionCell *pageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"pageCellId" forIndexPath:indexPath];
        pageCell.pageView.delegate = self;
        pageCell.emojArray = self.emojDataArray[indexPath.section][indexPath.item];
        return pageCell;
    }else{
        HQGifPageCollectionCell *gifPageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"gifPageCellId" forIndexPath:indexPath];
        gifPageCell.emojArray = self.emojDataArray[indexPath.section][indexPath.item];
        __weak typeof(self) weakSelf = self;
        [gifPageCell.pageView setClickGifClickCallBack:^(HQFaceModel *model) {
            [weakSelf didseletedGifItemWith:model];
        }];
        return gifPageCell;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake (App_Frame_Width, HEIGHT_CHATBOXVIEW-46);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(CGFLOAT_MIN,HEIGHT_CHATBOXVIEW);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return  CGSizeMake(CGFLOAT_MIN, HEIGHT_CHATBOXVIEW);
}
//cell的左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return CGFLOAT_MIN;
}
//cell的上下间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.pageControl.currentPage = scrollView.contentOffset.x / App_Frame_Width;
}
#pragma mark ----- HQFacePageViewDelegate 点击表情    点击删除  ------
- (void)HQFacePageViewDidSeletedItem:(HQFacePageView *)pageView andFaceModel:(HQFaceModel *)faceModel{
    if (_delegate && [_delegate respondsToSelector:@selector(HQFaceListViewDidseletedItem:andFaceModel:)]) {
        [_delegate HQFaceListViewDidseletedItem:self andFaceModel:faceModel];
    }
}
#pragma mark ------ GIF表情 ----
- (void)didseletedGifItemWith:(HQFaceModel *)faceModel{
    if (_delegate && [_delegate respondsToSelector:@selector(HQFaceListViewDidseletedItem:andFaceModel:)]) {
        [_delegate HQFaceListViewDidseletedItem:self andFaceModel:faceModel];
    }
}
- (void)HQFacePageViewDidDelete:(HQFacePageView *)pageView{
    if (_delegate && [_delegate respondsToSelector:@selector(HQFaceListViewDidDeleteItem:)]) {
        [_delegate HQFaceListViewDidDeleteItem:self];
    }
}
- (void)HQFaceMenuView:(HQFaceMenuView *)menuView ClickItem:(NSIndexPath *)indexPath{
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}
#pragma mark ------ 点击发送 -----
- (void)HQFaceMenuViewSendAction:(HQFaceMenuView *)menuView{
    if (_delegate && [_delegate respondsToSelector:@selector(HQFaceListViewDidSendAction:)]) {
        [_delegate HQFaceListViewDidSendAction:self];
    }
}

#pragma mark ------- getter   setter ------------
- (NSMutableArray *)emojDataArray{
    if (_emojDataArray == nil) {
        _emojDataArray = [NSMutableArray new];
        [_emojDataArray addObject:[HQFaceTools getNormalEmotions]];
//        [_emojDataArray addObject:[HQFaceTools getCustomerEmotions]];
        [_emojDataArray addObject:[HQFaceTools getGifEmotions]];
    }
    return _emojDataArray;
}

- (void)refershMenuView{
    NSMutableArray *tempArr = [NSMutableArray new];
    if (self.emojDataArray.count) {
        for (NSArray *arr in self.emojDataArray) {
            [tempArr addObject:arr.firstObject[0]];
        }
        self.menuView.emojDataArray = tempArr;
    }
}
- (UIView *) topLine{
    if (_topLine == nil) {
        _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
        [_topLine setBackgroundColor:IColor(165, 165, 165)];
    }
    return _topLine;
}
- (UIPageControl *)pageControl{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = 10;
        _pageControl.currentPage = 0;
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        _pageControl.backgroundColor = IColor(237, 237, 246);
    }
    return _pageControl;
}

@end
