//
//  DownLoadBackImageCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/29.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadFileModel+Action.h"


@interface DownLoadBackImageCell : UITableViewCell

@property (nonatomic,weak) NSArray *dateArray;

@property (nonatomic,weak) ChatListModel *listModel;

@property (nonatomic,copy) void (^chatDetailCallBack)(NSString *titleType);

@end










@interface DownLoadContentImageView : UIView

@property (nonatomic,weak) NSArray *dateArray;
@property (nonatomic,weak) ChatListModel *listModel;
@property (nonatomic,copy) void (^chatDetailCallBack)(NSString *titleType);

@end






@interface DownLoadImageView : UIImageView

@property (nonatomic,weak) DownloadFileModel *model;
@property (nonatomic,weak) ChatListModel *listModel;

@property (nonatomic,copy) void (^chatDetailCallBack)(NSString *titleType);

@end






@interface DownLoadProcessView : UIView

@property (nonatomic)DownloadFileModel *downLoadModel;

@end

