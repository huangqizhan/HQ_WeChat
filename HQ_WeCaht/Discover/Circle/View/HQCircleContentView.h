//
//  HQCircleContentView.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/11/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQCircleModel.h"
#import "YYLabel.h"
#import "HQCircleTableViewCell.h"




/**
 显示微博内容的view
 */
@interface HQCircleContentView : UIView

@property (nonatomic,strong)HQCircleModel *circleModel;

@end

/**
 显示标题
 */
@interface  HQCircleTitleView : UIView
@property (nonatomic, strong) YYLabel *titleLabel;
@property (nonatomic, strong) UIButton *arrowButton;
@property (nonatomic, weak) HQCircleTableViewCell *cell;

@end


/**
 显示个人资料
 */
@interface  HQCirclePrefileView : UIView

@end



/**
 卡片
 */
@interface HQCircleCardView : UIView

@end



/**
 底部的tag view 
 */
@interface HQCircleBottomTagView : UIView

@end



/**
 底部工具栏
 */
@interface HQCircleBottomToolBarView :UIView

@end



