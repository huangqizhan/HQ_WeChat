//
//  HQBroswerViewController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/6.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>


@class HQBroswerModel;

@interface HQBroswerViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) NSMutableArray <HQBroswerModel *>*broswerArray;

@property (nonatomic,assign) NSUInteger currnetImageIndex;

@property (nonatomic,copy)void (^currentScanImageIndexCallBack)(HQBroswerModel *model);

@end





