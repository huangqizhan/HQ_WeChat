//
//  HQBaseCellLayout.h
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/10/26.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HQBaseCellLayout : NSObject


+ (instancetype)layoutWithMessageModel:(ChatMessageModel *)model;

///初始化
- (instancetype)initWith:(ChatMessageModel *)model;

///数据
@property (nonatomic,strong) ChatMessageModel *modle;

@property (nonatomic,assign) BOOL isAsyncDisplay;
///cell 高度
@property (nonatomic,assign) CGFloat cellHeight;

///消息类型
@property (nonatomic,assign) int messageType;

- (NSString *)messageCellTypeId;

@end

NS_ASSUME_NONNULL_END
