//
//  HQFacePageView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQFaceModel.h"




@class HQFacePageView;

@protocol HQFacePageViewDelegate <NSObject>

- (void)HQFacePageViewDidSeletedItem:(HQFacePageView *)pageView andFaceModel:(HQFaceModel *)faceModel;
- (void)HQFacePageViewDidDelete:(HQFacePageView *)pageView;
@end

@interface HQFacePageView : UIView

@property (nonatomic,assign)id <HQFacePageViewDelegate>delegate;

@property (nonatomic,strong)NSArray *emojArray;

@end






#pragma mark ------ 表情按钮    -------

@interface HQEmojButton : UIButton


@property (nonatomic,strong)HQFaceModel *faceModel;
@property (nonatomic,strong)HQFaceModel *ZoomModel;



@end


@interface HQDrowView : UIView

/**
 dismiss
 */
- (void)dismissFromSuperView;


/**
 刷新

 @param emojButton 表情按钮
 */
- (void)refershDrowViewWith:(HQEmojButton *)emojButton;

@end

