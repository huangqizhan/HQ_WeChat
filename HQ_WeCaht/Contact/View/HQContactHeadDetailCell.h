//
//  HQContactHeadDetailCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/16.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContractModel;

@interface HQContactHeadDetailCell : UITableViewCell

@property (nonatomic,strong) ContractModel *contactModel;

@end


@interface HQContactAccessDetailCell : UITableViewCell

@property (nonatomic,strong) NSString *titleString;

@end


@interface HQContactPhoneNumCell : UITableViewCell

@property (nonatomic,copy) NSString *phoneString;

@end


@interface HQContactAddressCell : UITableViewCell

@property (nonatomic,copy) NSString *address;

@end




@interface HQContactFooterView : UITableViewHeaderFooterView

@property (nonatomic,copy) void (^sendButtonDidClickCallBack)();

@end
