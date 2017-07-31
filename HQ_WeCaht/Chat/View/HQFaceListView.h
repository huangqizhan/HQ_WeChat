//
//  HQFaceListView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>



@class HQFaceListView , HQFaceModel;

@protocol HQFaceListViewDelegate <NSObject>

/**
 点击表情

 @param listView self
 @param faceModel faceMOdel
 */
- (void)HQFaceListViewDidseletedItem:(HQFaceListView *)listView andFaceModel:(HQFaceModel *)faceModel;


/**
 点击删除

 @param listView self
 */
- (void)HQFaceListViewDidDeleteItem:(HQFaceListView *)listView;



/**
 发送

 @param listView self
 */
- (void)HQFaceListViewDidSendAction:(HQFaceListView *)listView;


@end



@interface HQFaceListView : UIView<UICollectionViewDelegate,UICollectionViewDataSource>


@property (nonatomic,assign)id <HQFaceListViewDelegate>delegate;

@end
