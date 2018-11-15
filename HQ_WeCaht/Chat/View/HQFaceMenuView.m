//
//  HQFaceMenuView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/2.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQFaceMenuView.h"
#import "HQFacePageView.h"


@interface HQFaceMenuView ()

@property (nonatomic,strong)UIButton *sendButton;
@property (nonatomic,strong)UICollectionView *menuCollectionView;


@end


@implementation HQFaceMenuView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = IColor(237, 237, 246);
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI{
    UICollectionViewFlowLayout *layput = [[UICollectionViewFlowLayout alloc] init];
    layput.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layput.sectionInset=UIEdgeInsetsMake(0,0,0,0);
    layput.headerReferenceSize = CGSizeMake(App_Frame_Width, 0.1);
    
    _menuCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layput];
    _menuCollectionView.backgroundColor = [UIColor whiteColor];
    _menuCollectionView.dataSource = self;
    _menuCollectionView.delegate = self;
    _menuCollectionView.showsHorizontalScrollIndicator = NO;
    _menuCollectionView.pagingEnabled = YES;
    _menuCollectionView.bounces = NO;
    [_menuCollectionView registerClass:[HQFaceMenuViewCollectionCell class] forCellWithReuseIdentifier:@"MenupageCellId"];
    [self addSubview:_menuCollectionView];
    _sendButton = [[UIButton alloc] init];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_sendButton setBackgroundColor:[UIColor blueColor]];
    [_sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendButton];

}
- (void)layoutSubviews{
    [super layoutSubviews];
    _menuCollectionView.frame = CGRectMake(0, 0, App_Frame_Width-60,HQFaceMenuViewHeight );
    _sendButton.frame = CGRectMake(_menuCollectionView.right, 0, 60, HQFaceMenuViewHeight);
}

- (void)sendButtonAction:(UIButton *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(HQFaceMenuViewSendAction:)]) {
        [_delegate HQFaceMenuViewSendAction:self];
    }
}
- (void)setEmojDataArray:(NSMutableArray *)emojDataArray{
    _emojDataArray = emojDataArray;
    if (_emojDataArray.count) {
        HQFaceModel *mode = [_emojDataArray firstObject];
        mode.isSeleted = YES;
    }
    [self.menuCollectionView reloadData];
}
#pragma mark --- UIcollectionViewDelegate ----
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.emojDataArray count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *pageCellId = @"MenupageCellId";
    HQFaceMenuViewCollectionCell *pageCell = [collectionView dequeueReusableCellWithReuseIdentifier:pageCellId forIndexPath:indexPath];
    pageCell.faceModel = _emojDataArray[indexPath.item];
    pageCell.indexPath = indexPath;
    __weak typeof(self) weekSelf = self;
    [pageCell setClickItemCallBack:^(NSIndexPath *indexPath) {
        [weekSelf faceListScrollToIndexPath:indexPath];
    }];
    return pageCell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake (HQFaceMenuViewHeight-2, HQFaceMenuViewHeight-2);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(CGFLOAT_MIN,HQFaceMenuViewHeight);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return  CGSizeMake(CGFLOAT_MIN, HQFaceMenuViewHeight);
}
//cell的左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}
//cell的上下间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (void)faceListScrollToIndexPath:(NSIndexPath *)indexPath{
    for (HQFaceModel *mode in self.emojDataArray) {
        mode.isSeleted  = NO;
    }
    HQFaceModel *model = self.emojDataArray[indexPath.row];
    model.isSeleted = YES;
    [self.menuCollectionView reloadData];
    if (_delegate && [_delegate respondsToSelector:@selector(HQFaceMenuView:ClickItem:)]) {
        [_delegate HQFaceMenuView:self ClickItem:indexPath];
    }
}
@end






@interface HQFaceMenuViewCollectionCell ()

@property (nonatomic,strong)HQMenuButton *menuButton;

@end

@implementation HQFaceMenuViewCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.menuButton];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _menuButton.top = 0;
    _menuButton.left = 0;
    _menuButton.width = self.contentView.width;
    _menuButton.height = self.contentView.height;
}

- (HQMenuButton *)menuButton{
    if (_menuButton == nil) {
        _menuButton = [[HQMenuButton alloc] init];
        [_menuButton addTarget:self action:@selector(menuItemClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuButton;
}
- (void)menuItemClickAction{
    if (_clickItemCallBack) {
        _clickItemCallBack(_indexPath);
    }
}
- (void)setFaceModel:(HQFaceModel *)faceModel{
    _faceModel = faceModel;
    _menuButton.faceModel = _faceModel;
}
@end





@implementation HQMenuButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    return self;
}
- (void)setFaceModel:(HQFaceModel *)faceModel{
    _faceModel = faceModel;
    UIImage *image = [UIImage imageNamed:_faceModel.face_name];
    if (image) {
        [self setImage:image forState:UIControlStateNormal];
    }else{
        [self setTitle:@"gif" forState:UIControlStateNormal];
    }
    if (_faceModel.isSeleted){
        self.backgroundColor  =[UIColor groupTableViewBackgroundColor];
    }else{
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
