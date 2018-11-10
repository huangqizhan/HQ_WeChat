//
//  HQBaseCellLayout.m
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/10/26.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import "HQBaseCellLayout.h"
#import "CellTextLayout.h"
#import "CellImageLayout.h"
#import "CellGifLayout.h"

@implementation HQBaseCellLayout
/// 1 文本    2 图片  3GIF 4语音  5正在录音  6视频  7文件  8定位  99时间  100 系统消息  101 工作通知
- (NSString *)messageCellTypeId{
    switch (self.messageType) {
        case 1:
            return MineTextCellId;
            break;
        case 2:
            return MineImageCellId;
            break;
        case 3:
            return MineGifCellId;
            break;
        case 4:
            return MineVoiceCellId;
            break;
        case 5:
            return MineRecordingCellId;
            break;
        case 6:
            return MineVidioCellId;
            break;
        case 7:
            return MineFileCellId;
            break;
        case 8:
            return MineLocationCellId;
            break;
        default:
            break;
    }
//    if (self.speakerId == [HQPublicManager shareManagerInstance].userinfoModel.userId) {
//
//    }else{
//        switch (self.messageType) {
//            case 1:
//                return OtherTextCellid;
//                break;
//            case 2:
//                return OtherImageCellId;
//                break;
//            case 3:
//                return OtherGifCellId;
//                break;
//            case 4:
//                return OtherVoiceCellId;
//                break;
//            case 6:
//                return OtherVidioCellId;
//                break;
//            case 7:
//                return OtherFileCellid;
//                break;
//            case 8:
//                return OtherLocationCellId;
//                break;
//            case 99:
//                return DateMessageCellId;
//            default:
//                break;
//        }
//    }
    return @"";
}
- (instancetype)initWith:(ChatMessageModel *)model{
    self = [super init];
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _isAsyncDisplay = YES;
    }
    return self;
}
+ (instancetype)layoutWithMessageModel:(ChatMessageModel *)model{
    HQBaseCellLayout *layout = nil;
    if (model.messageType == 1) {
       layout = [[CellTextLayout alloc] initWith:model];
    }else if (model.messageType == 2){
        layout = [[CellImageLayout alloc] initWith:model];
    }else if (model.messageType == 3){
        layout = [[CellGifLayout alloc] initWith:model];
    }else{
        layout = [self new];
    }
    layout.modle = model;
    layout.messageType = model.messageType;
    return layout;
}

@end
