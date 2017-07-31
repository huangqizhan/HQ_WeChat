//
//  HQFaceMorePageView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/3.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQFaceModel.h"


@class HQFaceMorePageView;

@protocol HQFaceMorePageViewDelegate <NSObject>

- (void)HQFaceMorePageViewDidSeleteItem:(HQFaceMorePageView *)pageView andFaceModel:(HQFaceModel *)faceModel;

@end


@interface HQFaceMorePageView : UIView

@property (nonatomic,assign)id <HQFaceMorePageViewDelegate>delegate;
@property (nonatomic,strong) NSArray *moreFaceArray;

@end











@interface HQMoreViewItem : UIControl


@property (nonatomic,strong)HQFaceModel *faceModel;




@end
