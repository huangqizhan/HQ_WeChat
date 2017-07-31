//
//  HQFaceMenuView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/2.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQFaceModel.h"

@class HQFaceMenuView;
@protocol HQFaceMenuViewDelegate <NSObject>

- (void)HQFaceMenuViewSendAction:(HQFaceMenuView *)menuView;

- (void)HQFaceMenuView:(HQFaceMenuView *)menuView ClickItem:(NSIndexPath *)indexPath;

@end

@interface HQFaceMenuView : UIView<UICollectionViewDelegate,UICollectionViewDataSource>


@property (nonatomic,assign)id <HQFaceMenuViewDelegate>delegate;

@property (nonatomic,strong)NSMutableArray *emojDataArray;


@end








@interface HQFaceMenuViewCollectionCell : UICollectionViewCell

@property (nonatomic,strong)HQFaceModel *faceModel;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,copy) void (^clickItemCallBack)(NSIndexPath *indexpath);

@end




@interface HQMenuButton : UIButton

@property (nonatomic,strong) HQFaceModel *faceModel;

@end
