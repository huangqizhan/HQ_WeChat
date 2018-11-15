//
//  HQMoreListView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQMoreListView.h"
#import "HQFaceMoreCollectionViewCell.h"
#import "HQFaceMorePageView.h"



@interface HQMoreListView ()<HQFaceMorePageViewDelegate>

@property (nonatomic,strong)UIView *topLine;
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)NSMutableArray *moreFaceItems;
@property (nonatomic,strong)UIPageControl *pageControl;

@end



@implementation HQMoreListView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = IColor(237, 237, 246);
        UICollectionViewFlowLayout *layput = [[UICollectionViewFlowLayout alloc] init];
        layput.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layput.sectionInset=UIEdgeInsetsMake(15, 0,15, 0);
        layput.headerReferenceSize = CGSizeMake(App_Frame_Width, 0.1);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, HEIGHT_CHATBOXVIEW-10) collectionViewLayout:layput];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = NO;
        [_collectionView registerClass:[HQFaceMoreCollectionViewCell class] forCellWithReuseIdentifier:@"MorepageCellId"];
        [self addSubview:_collectionView];
        [self addSubview:self.topLine];
        [self addSubview:self.pageControl];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        });
    }
    return self;
}
#pragma mark --- UIcollectionViewDelegate ----
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.moreFaceItems.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *pageCellId = @"MorepageCellId";
    HQFaceMoreCollectionViewCell *pageCell = [collectionView dequeueReusableCellWithReuseIdentifier:pageCellId forIndexPath:indexPath];
    pageCell.moreFaceArray = self.moreFaceItems[indexPath.item];
    pageCell.pageView.delegate = self;
    return pageCell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake (App_Frame_Width, HEIGHT_CHATBOXVIEW);
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

#pragma mark ------ 点击item -----
- (void)HQFaceMorePageViewDidSeleteItem:(HQFaceMorePageView *)pageView andFaceModel:(HQFaceModel *)faceModel{
    if (_delegate && [_delegate respondsToSelector:@selector(HQMoreListViewDidSeleteItem:andFaceModel:)]) {
        [_delegate HQMoreListViewDidSeleteItem:self andFaceModel:faceModel];
    }
}

- (NSMutableArray *)moreFaceItems{
    if (_moreFaceItems == nil) {
        _moreFaceItems = [[NSMutableArray alloc] initWithArray:[HQFaceTools getMoreFaceItems]];
    }
    return _moreFaceItems;
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
        _pageControl.frame = CGRectMake(0, self.collectionView.bottom-10, App_Frame_Width, 10);
        _pageControl.numberOfPages = 2;
        _pageControl.currentPage = 0;
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    }
    return _pageControl;
}

@end
