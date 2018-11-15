//
//  HQMoreListView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQMoreListView,HQFaceModel;

@protocol HQMoreListViewDelegate <NSObject>

- (void)HQMoreListViewDidSeleteItem:(HQMoreListView *)listView andFaceModel:(HQFaceModel *)faceModel;

@end




@interface HQMoreListView : UIView<UICollectionViewDelegate,UICollectionViewDataSource>


@property (nonatomic,assign) id <HQMoreListViewDelegate>delegate;

@end
