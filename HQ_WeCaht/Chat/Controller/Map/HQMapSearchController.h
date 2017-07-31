//
//  HQMapSearchController.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/11.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQBaseViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>


@class HQLocationMapController;

@interface HQMapSearchController : HQBaseViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,copy) void (^searchResultCallBack)(AMapAOI *poi);




- (void)showSearchVCWith:(HQLocationMapController *)locationVC andNavigationView:(UIView *)navigationView andSearchBar:(HQSearchBar *)searchBar;


@end




@interface HQMapSearchVcCell : UITableViewCell

@property (nonatomic,weak) AMapPOI *poi;

@end
