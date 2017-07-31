//
//  HQDownLoadTbaleViewCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/23.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQDownLoadTempModel.h"

@class HQDownLoadTbaleViewCell;

@protocol HQDownLoadTbaleViewCellPlayerDelegete <NSObject>

- (void)HQDownLoadTbaleViewCell:(HQDownLoadTbaleViewCell *)cell PlayClickWith:(HQDownLoadTempModel *)model;

@end

@interface HQDownLoadTbaleViewCell : UITableViewCell

@property (nonatomic,assign) id <HQDownLoadTbaleViewCellPlayerDelegete>delegate;

@property (nonatomic,strong) HQDownLoadTempModel *tempMpdel;

@property (nonatomic,strong) NSIndexPath *indexPath;




@end
