//
//  MySetiewCell.h
//  HQ_WeChat
//
//  Created by 黄麒展  QQ 757618403 on 2018/1/14.
//  Copyright © 2018年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger,MysetCellType) {
    MysetCellSwitchType = 1,
    MysetCellOtherType
};


@interface MySetModel :NSObject

@property (nonatomic,assign)MysetCellType cellType;
@property (nonatomic,copy) NSString *name;
@end





@interface MySetiewCell : UITableViewCell

@property(nonatomic,strong) MySetModel *typeModel;

@end


@interface MySetSwitchCell : MySetiewCell

@property (nonatomic,strong)UISwitch *sw;

@end











