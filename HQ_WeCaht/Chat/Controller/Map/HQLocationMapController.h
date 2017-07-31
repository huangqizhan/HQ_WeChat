//
//  HQLocationMapController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/5.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQBaseViewController.h"

@interface HQLocationMapController : HQBaseViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>


@property (nonatomic,copy) void (^searchResultCallBack)(UIImage *image , CLLocationCoordinate2D coor2D,NSString *address);

@end



