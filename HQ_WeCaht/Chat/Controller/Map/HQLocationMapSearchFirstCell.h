//
//  HQLocationMapSearchFirstCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/10.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

typedef NS_ENUM(NSInteger,HQLocationMapSearchFirstCellType) {
    
    HQLocationMapSearchFirstCellLoadingType,     ///加载状态
    HQLocationMapSearchFirstCellFinishedType,    ///加载完成状态
    HQLocationMapSearchFirstCellFaildType,       ///加载失败状态
};


@interface HQLocationMapSearchFirstCell : UITableViewCell

@property (nonatomic,assign) HQLocationMapSearchFirstCellType type;

@property (nonatomic,copy) NSString *currentSearchKye;

@property (nonatomic,copy) void (^reloadButtonClick)();

@end





@interface HQLocationMapSearchContentCell : UITableViewCell

@property (nonatomic)AMapPOI *poi;
@end



@interface HQLocationMapSearchLoadingFotterView : UIView

@end
