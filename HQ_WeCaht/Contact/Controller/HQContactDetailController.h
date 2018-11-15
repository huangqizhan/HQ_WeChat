//
//  HQContactDetailController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/16.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQMessageBaseController.h"


@class ContractModel;

@interface HQContactDetailController : HQMessageBaseController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) ContractModel *contactModel;

@end
