//
//  HQDiscoverViewController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQMessageBaseController.h"

@interface HQDiscoverViewController : HQMessageBaseController<UITableViewDelegate,UITableViewDataSource>

@end





@interface DiscoverTempModel : NSObject

@property (nonatomic,copy) NSString *titleStr;
@property (nonatomic,copy) NSString *imageName;

@end


@interface DisCoverCell : UITableViewCell

@property (nonatomic,weak)DiscoverTempModel *model;

@end


