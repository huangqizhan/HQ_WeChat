//
//  LoadGifImageCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/5.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYAnimatedImageView.h"


@interface LoadGifImageCell : UITableViewCell

@property (nonatomic,copy) NSString *urlString;

@property (nonatomic,strong) YYAnimatedImageView *webImageView;

@end
