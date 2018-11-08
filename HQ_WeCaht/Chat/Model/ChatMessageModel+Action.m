//
//  ChatMessageModel+Action.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "ChatMessageModel+Action.h"
#import <objc/runtime.h>
#import "HQLocalImageManager.h"
#import "HQRecordManager.h"
#import "NSDate+Extension.h"
#import "HQBaseCellLayout.h"



static const char ChatMessageCallBackKey = '\0';

@implementation ChatMessageModel (Action)

+ (ChatMessageModel *)customerInit{
    return [[ChatMessageModel alloc] initWithContext:[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext];
}
+ (ChatMessageModel *)creatAnSnedMesssageWith:(NSString *)contentString andReceiverId:(NSInteger)receiverId andUserName:(NSString *)userName andUserPic:(NSString *)headPic{
    ChatMessageModel *messageModel = [ChatMessageModel customerInit];
    [messageModel setValue:contentString forKey:@"contentString"];
    [messageModel setValue:@1 forKey:@"messageType"];
    [messageModel setValue:userName forKey:@"userName"];
    [messageModel setValue:headPic forKey:@"userHeadImageString"];
    [messageModel setValue:[NSNumber numberWithInteger:[HQPublicManager shareManagerInstance].userinfoModel.userId] forKey:@"speakerId"];
    [messageModel setValue:[NSNumber numberWithInteger:receiverId]  forKey:@"receiveId"];
    [messageModel setValue:@0 forKey:@"messageStatus"];
    [messageModel setValue:@"tempPath" forKey:@"tempPath"];
    messageModel.messageTime = [NSDate returnTheTimeralFrom1970];
    [messageModel setValue:@"config" forKey:@"modelConfig"];
    return messageModel;
}
+ (ChatMessageModel *)creatAnReceiveTextMessageWith:(NSString *)contentStr andSpeakerId:(NSInteger )speakerId andUserName:(NSString *)userName andUserPic:(NSString *)headPic{
    ChatMessageModel *messageModel = [ChatMessageModel customerInit];
    [messageModel setValue:contentStr forKey:@"contentString"];
    [messageModel setValue:@1 forKey:@"messageType"];
    [messageModel setValue:userName forKey:@"userName"];
    [messageModel setValue:headPic forKey:@"userHeadImageString"];
    [messageModel setValue:[NSNumber numberWithInteger:[HQPublicManager shareManagerInstance].userinfoModel.userId] forKey:@"receiveId"];
    [messageModel setValue:[NSNumber numberWithInteger:speakerId]  forKey:@"speakerId"];
    [messageModel setValue:@0 forKey:@"messageStatus"];
    [messageModel setValue:@"tempPath" forKey:@"tempPath"];
    messageModel.messageTime = [NSDate returnTheTimeralFrom1970];
    [messageModel setValue:@"config" forKey:@"modelConfig"];
    return messageModel;
}
+ (ChatMessageModel *)creatAnSendImageMessageWith:(UIImage *)image andImagePath:(NSString *)imagePath andImageName:(NSString *)imageName andReceiverId:(NSInteger)receiverId andUserName:(NSString *)userName andUserPic:(NSString *)headPic{
    ChatMessageModel *messageModel = [ChatMessageModel customerInit];
    [messageModel setValue:@2 forKey:@"messageType"];
    [messageModel setValue:image forKey:@"tempImage"];
    [messageModel setValue:userName forKey:@"userName"];
    [messageModel setValue:headPic forKey:@"userHeadImageString"];
    [messageModel setValue:[NSNumber numberWithInteger:[HQPublicManager shareManagerInstance].userinfoModel.userId] forKey:@"speakerId"];
    [messageModel setValue:[NSNumber numberWithInteger:receiverId]  forKey:@"receiveId"];
    [messageModel setValue:@0 forKey:@"messageStatus"];
    [messageModel setValue:imagePath forKey:@"tempPath"];
    [messageModel setValue:imageName forKey:@"fileName"];
    messageModel.messageTime = [NSDate returnTheTimeralFrom1970];
    [messageModel setValue:@"config" forKey:@"modelConfig"];
    return messageModel;

}
+ (ChatMessageModel *)creatAnSendGifMessageWith:(NSString *)fileName andReceiveId:(NSInteger )receiveid andUserName:(NSString *)userName andUserPic:(NSString *)headPic{
    ChatMessageModel *messageModel = [ChatMessageModel customerInit];
    [messageModel setValue:@3 forKey:@"messageType"];
    [messageModel setValue:userName forKey:@"userName"];
    [messageModel setValue:headPic forKey:@"userHeadImageString"];
    [messageModel setValue:[NSNumber numberWithInteger:[HQPublicManager shareManagerInstance].userinfoModel.userId] forKey:@"speakerId"];
    [messageModel setValue:[NSNumber numberWithInteger:receiveid]  forKey:@"receiveId"];
    [messageModel setValue:@0 forKey:@"messageStatus"];
    [messageModel setValue:fileName forKey:@"fileName"];
    messageModel.messageTime = [NSDate returnTheTimeralFrom1970];
    [messageModel setValue:@"config" forKey:@"modelConfig"];
    return messageModel;

}
+ (ChatMessageModel *)creatAnReceiveGifMessageWith:(NSString *)fileName andSpeakerId:(NSInteger )speakerId andUserName:(NSString *)userName andUserPic:(NSString *)headPic{
    ChatMessageModel *messageModel = [ChatMessageModel customerInit];
    [messageModel setValue:@3 forKey:@"messageType"];
    [messageModel setValue:userName forKey:@"userName"];
    [messageModel setValue:headPic forKey:@"userHeadImageString"];
    [messageModel setValue:[NSNumber numberWithInteger:[HQPublicManager shareManagerInstance].userinfoModel.userId] forKey:@"receiveId"];
    [messageModel setValue:[NSNumber numberWithInteger:speakerId]  forKey:@"speakerId"];
    [messageModel setValue:@0 forKey:@"messageStatus"];
    [messageModel setValue:fileName forKey:@"fileName"];
    messageModel.messageTime = [NSDate returnTheTimeralFrom1970];
    [messageModel setValue:@"config" forKey:@"modelConfig"];
    return messageModel;
}
+ (ChatMessageModel *)createAnSendAudioMessageWith:(NSString *)filePath andReceiveId:(NSInteger)receiveId andUserName:(NSString *)userName andUserPic:(NSString *)headPic{
    ChatMessageModel *messageModel = [ChatMessageModel customerInit];
    [messageModel setValue:@4 forKey:@"messageType"];
    [messageModel setValue:userName forKey:@"userName"];
    [messageModel setValue:headPic forKey:@"userHeadImageString"];
    [messageModel setValue:[NSNumber numberWithInteger:[HQPublicManager shareManagerInstance].userinfoModel.userId] forKey:@"speakerId"];
    [messageModel setValue:[NSNumber numberWithInteger:receiveId]  forKey:@"receiveId"];
    [messageModel setValue:@0 forKey:@"messageStatus"];
    [messageModel setValue:[[filePath lastPathComponent] stringByDeletingPathExtension] forKey:@"fileName"];
    [messageModel setValue:[filePath stringByDeletingPathExtension] forKey:@"filePath"];
    messageModel.messageTime = [NSDate returnTheTimeralFrom1970];
    [messageModel setValue:@"config" forKey:@"modelConfig"];
    return messageModel;
}
+ (ChatMessageModel *)createAnReceiveAudioMessageWith:(NSString *)filePath andSpearkerId:(NSInteger )speakerId andFileSize:(NSString *)fileSize andUserName:(NSString *)userName andUserPic:(NSString *)headPic{
    ChatMessageModel *messageModel = [ChatMessageModel customerInit];
    [messageModel setValue:@4 forKey:@"messageType"];
    [messageModel setValue:fileSize?fileSize:@"" forKey:@"fileSize"];
    [messageModel setValue:userName forKey:@"userName"];
    [messageModel setValue:headPic forKey:@"userHeadImageString"];
    [messageModel setValue:[NSNumber numberWithInteger:speakerId] forKey:@"speakerId"];
    [messageModel setValue:[NSNumber numberWithInteger:[HQPublicManager shareManagerInstance].userinfoModel.userId]  forKey:@"receiveId"];
    [messageModel setValue:@0 forKey:@"messageStatus"];
    [messageModel setValue:[[filePath lastPathComponent] stringByDeletingPathExtension] forKey:@"fileName"];
    [messageModel setValue:[filePath stringByDeletingPathExtension] forKey:@"filePath"];
    messageModel.messageTime = [NSDate returnTheTimeralFrom1970];
    [messageModel setValue:@"config" forKey:@"modelConfig"];
    return messageModel; 
}

+ (ChatMessageModel *)creatAnRecordingMessageWith:(NSString *)filePath andReceiveId:(NSInteger)receiveId andUserName:(NSString *)userName andUserPic:(NSString *)headPic{
    ChatMessageModel *messageModel = [ChatMessageModel customerInit];
    [messageModel setValue:@5 forKey:@"messageType"];
    [messageModel setValue:userName forKey:@"userName"];
    [messageModel setValue:headPic forKey:@"userHeadImageString"];
    [messageModel setValue:[NSNumber numberWithInteger:[HQPublicManager shareManagerInstance].userinfoModel.userId] forKey:@"speakerId"];
    [messageModel setValue:[NSNumber numberWithInteger:receiveId]  forKey:@"receiveId"];
    [messageModel setValue:@0 forKey:@"messageStatus"];
    [messageModel setValue:[[filePath lastPathComponent] stringByDeletingPathExtension] forKey:@"fileName"];
    [messageModel setValue:[filePath stringByDeletingPathExtension] forKey:@"filePath"];
    messageModel.messageTime = [NSDate returnTheTimeralFrom1970];
    [messageModel setValue:@"config" forKey:@"modelConfig"];
    return messageModel;
}
+ (ChatMessageModel *)creatAnSendDateMessageWithReceiveId:(NSInteger)receiveId{
    ChatMessageModel *messageModel = [ChatMessageModel customerInit];
    [messageModel setValue:@99 forKey:@"messageType"];
    [messageModel setValue:[NSNumber numberWithInteger:receiveId] forKey:@"speakerId"];
    [messageModel setValue:[NSNumber numberWithInteger:[HQPublicManager shareManagerInstance].userinfoModel.userId]  forKey:@"receiveId"];
    messageModel.messageTime = [NSDate returnTheTimeralFrom1970];
    [messageModel setValue:@"config" forKey:@"modelConfig"];
    return messageModel;
}
+ (ChatMessageModel *)creatAnReceiveDataMessageWithSpeakerId:(NSInteger)speakerId{
    ChatMessageModel *messageModel = [ChatMessageModel customerInit];
    [messageModel setValue:@99 forKey:@"messageType"];
    [messageModel setValue:[NSNumber numberWithInteger:speakerId] forKey:@"speakerId"];
    [messageModel setValue:[NSNumber numberWithInteger:[HQPublicManager shareManagerInstance].userinfoModel.userId]  forKey:@"receiveId"];
    messageModel.messageTime = [NSDate returnTheTimeralFrom1970];
    [messageModel setValue:@"config" forKey:@"modelConfig"];
    return messageModel;
}
+ (ChatMessageModel *)creatAnSendLoactionMessageWith:(UIImage *)image andLocation:(CLLocationCoordinate2D )coor2d andAddress:(NSString *)address andUserName:(NSString *)userName andPic:(NSString *)headPic andFileName:(NSString *)fileName andReceived:(NSInteger )reveiveId{
    ChatMessageModel *messageModel = [ChatMessageModel customerInit];
    [messageModel setValue:@8 forKey:@"messageType"];
    [messageModel setValue:image forKey:@"tempImage"];
    [messageModel setValue:userName forKey:@"userName"];
    [messageModel setValue:[NSNumber numberWithDouble:coor2d.latitude] forKey:@"latitude"];
    [messageModel setValue:[NSNumber numberWithDouble:coor2d.longitude] forKey:@"longtitude"];
    [messageModel setValue:headPic forKey:@"userHeadImageString"];
    [messageModel setValue:[NSNumber numberWithInteger:[HQPublicManager shareManagerInstance].userinfoModel.userId] forKey:@"speakerId"];
    [messageModel setValue:address forKey:@"contentString"];
    [messageModel setValue:[NSNumber numberWithInteger:reveiveId]  forKey:@"receiveId"];
    [messageModel setValue:@0 forKey:@"messageStatus"];
    [messageModel setValue:fileName forKey:@"fileName"];
    messageModel.messageTime = [NSDate returnTheTimeralFrom1970];
    [messageModel setValue:@"config" forKey:@"modelConfig"];
    return messageModel;
}
+ (ChatMessageModel *)createAnReceiveLocationMessageWith:(UIImage *)image andLocation:(CLLocationCoordinate2D )coor2d andAddress:(NSString *)address andUserName:(NSString *)userName andPic:(NSString *)headPic andFileName:(NSString *)fileName  andSpeakerId:(NSInteger )speakerId{
    ChatMessageModel *messageModel = [ChatMessageModel customerInit];
    [messageModel setValue:@8 forKey:@"messageType"];
    [messageModel setValue:image forKey:@"tempImage"];
    [messageModel setValue:userName forKey:@"userName"];
    [messageModel setValue:[NSNumber numberWithDouble:coor2d.latitude] forKey:@"latitude"];
    [messageModel setValue:[NSNumber numberWithDouble:coor2d.longitude] forKey:@"longtitude"];
    [messageModel setValue:headPic forKey:@"userHeadImageString"];
    [messageModel setValue:[NSNumber numberWithInteger:speakerId] forKey:@"speakerId"];
    [messageModel setValue:address forKey:@"contentString"];
    [messageModel setValue:[NSNumber numberWithInteger:[HQPublicManager shareManagerInstance].userinfoModel.userId]  forKey:@"receiveId"];
    [messageModel setValue:@0 forKey:@"messageStatus"];
    [messageModel setValue:fileName forKey:@"fileName"];
    messageModel.messageTime = [NSDate returnTheTimeralFrom1970];
    [messageModel setValue:@"config" forKey:@"modelConfig"];
    return messageModel;
 
}
- (NSString *)messageCellTypeId{
    if (self.speakerId == [HQPublicManager shareManagerInstance].userinfoModel.userId) {
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
    }else{
        switch (self.messageType) {
            case 1:
                return OtherTextCellid;
                break;
            case 2:
                return OtherImageCellId;
                break;
            case 3:
                return OtherGifCellId;
                break;
            case 4:
                return OtherVoiceCellId;
                break;
            case 6:
                return OtherVidioCellId;
                break;
            case 7:
                return OtherFileCellid;
                break;
            case 8:
                return OtherLocationCellId;
                break;
            case 99:
                return DateMessageCellId;
            default:
                break;
       }
   }
    return @"";
}
//- (void)setModelConfig:(NSString *)modelConfig{
//    if (self.muAttributeString == nil && self.messageType == 1) {
//        self.muAttributeString = [HQFaceTools transferMessageString:self.contentString font:MessageFont lineHeight:17];
//    }
//    if (self.chatLabelRect == nil && self.messageType == 1) {
//        self.chatLabelRect = [MessageRectModel customerInita];
//        CGSize size = [self.muAttributeString boundingRectWithSize:CGSizeMake(CONTENTLABELWIDTH, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
//        self.chatLabelRect.width = size.width;
//        self.chatLabelRect.height = size.height;
//        self.cellHeight = self.chatLabelRect.height+40;
//    }
//    if (self.messageType == 2  && self.speakerId == [HQPublicManager shareManagerInstance].userinfoModel.userId) {
//        if (self.tempImage == nil) {
//            self.tempImage = [[HQLocalImageManager shareImageManager]  getChatMineMessageImageWtihImageName:self.fileName withImageSize:CGSizeMake( self.chatImageRect.width, self.chatImageRect.height)];
//        }else{
//            if (self.chatImageRect == nil ) {
//                self.chatImageRect = [MessageRectModel customerInita];
//                CGSize size = [self handleImage:self.tempImage.size];
//                self.chatImageRect.xx = App_Frame_Width-size.width-65;
//                self.chatImageRect.yy = 10;
//                self.chatImageRect.width = size.width;
//                self.chatImageRect.height = size.height;
//                self.tempImage = [[HQLocalImageManager shareImageManager] compocessImageWithImage:self.tempImage andImageSize:CGSizeMake( self.chatImageRect.width*2, self.chatImageRect.height*2) andIsSender:YES];
//            }
//        }
//        self.cellHeight = self.chatImageRect.height+25;
//    }else if (self.messageType == 3  && self.speakerId == [HQPublicManager shareManagerInstance].userinfoModel.userId){
//        if (self.tempImage == nil) {
//            self.tempImage = [[HQLocalImageManager shareImageManager] loadlocalGifImageWith:self.fileName andScal:2];
//            self.gifImageData = [[HQLocalImageManager shareImageManager] loadLocalGifImageDataWith:self.fileName];
//            self.chatImageRect = [MessageRectModel customerInita];
//            CGSize size = [self handleImage:self.tempImage.size];
//            self.chatImageRect.xx = App_Frame_Width-size.width-65;
//            self.chatImageRect.yy = 10;
//            self.chatImageRect.width = size.width;
//            self.chatImageRect.height = size.height;
//        }
//        self.cellHeight = self.chatImageRect.height+25;
//    }else if (self.messageType == 3  && self.speakerId != [HQPublicManager shareManagerInstance].userinfoModel.userId){
//        if (self.tempImage == nil) {
//            self.tempImage = [[HQLocalImageManager shareImageManager] loadlocalGifImageWith:self.fileName andScal:2];
//            self.gifImageData = [[HQLocalImageManager shareImageManager] loadLocalGifImageDataWith:self.fileName];
//            self.chatImageRect = [MessageRectModel customerInita];
//            CGSize size = [self handleImage:self.tempImage.size];
//            self.chatImageRect.xx = 65;
//            self.chatImageRect.yy = 10;
//            self.chatImageRect.width = size.width;
//            self.chatImageRect.height = size.height;
//        }
//        self.cellHeight = self.chatImageRect.height+25;
//    }else if (self.messageType == 4 || self.messageType == 5){
//        if (self.chatImageRect == nil && self.messageType == 4) {
//            self.chatImageRect = [MessageRectModel customerInita];
//            self.chatImageRect.width = [self caculateVoiceViewWidth:self.fileSize];
//        }
//        self.cellHeight = 60;
//    }else if (self.messageType == 8){
//        if (self.tempImage == nil) {
//            self.tempImage = [[HQLocalImageManager shareImageManager]  getChatMineMessageImageWtihImageName:self.fileName withImageSize:CGSizeMake( self.chatImageRect.width, self.chatImageRect.height)];
//        }
//        if (self.chatImageRect == nil) {
//            self.chatImageRect = [MessageRectModel customerInita];
//            self.chatImageRect.width = App_Frame_Width*3.0/5.0;
//            self.chatImageRect.height = (APP_Frame_Height)/4.0;
//            self.chatImageRect.xx = App_Frame_Width-App_Frame_Width*3.0/5.0-65;
//            self.chatImageRect.yy = 10;
//            self.cellHeight = self.chatImageRect.height+20;
//        }
//    }else if (self.messageType == 99){
//        self.cellHeight = 30;
//        self.contentString = [NSDate currentTimevalDescriptionWith:self.messageTime];
//        if (self.chatLabelRect == nil) {
//        }
//    }
//}
// 缩放，临时的方法
- (CGSize)handleImage:(CGSize)retSize{
    CGFloat scaleH = 0.22;
    CGFloat scaleW = 0.38;
    CGFloat height = 0;
    CGFloat width = 0;
    if (retSize.height / APP_Frame_Height + 0.16 > retSize.width / App_Frame_Width) {
        height = APP_Frame_Height * scaleH;
        width = retSize.width / retSize.height * height;
    } else {
        width = App_Frame_Width * scaleW;
        height = retSize.height / retSize.width * width;
    }
    return CGSizeMake(width, height);
}
- (CGFloat)caculateVoiceViewWidth:(NSString *)fileSize{
    CGFloat width = 80.0;
    int druation;
    if ([NSString isPureInt:fileSize]) {
        druation = [fileSize intValue];
        width += ((CONTENTLABELWIDTH-80)/60.0)*druation;
    }
    return width;
}













































































#pragma mark ------ 网络 -----
- (void)sendTextMessage:(ChatMessageCallBack)callBack{
    self.messageStatus = self.deliverStatus = 1;
    HQReqestSesstionTask *task = [HQNetWorkManager requestWithType:HQhTTPRequestTypePOST urlString:@"http://000000" parameters:[self transmitChatMessagToParmars] successBlock:^(id responseData) {
        self.messageStatus = self.deliverStatus = 2;
        [self saveToDBChatLisModelAsyThread:^{
            NSLog(@"save  success self.content = %@",self.contentString);
        } andError:^{
            NSLog(@"save faild");
        }];
        callBack();
    } failureBlock:^(NSError *error) {
        self.messageStatus = self.deliverStatus = 3;
        [self saveToDBChatLisModelAsyThread:^{
            NSLog(@"save  success self.content = %@",self.contentString);
        } andError:^{
            NSLog(@"save faild");
        }];
        callBack();
    } progress:nil];
    task.requestTimeal = self.requestTimeral = [NSString stringWithFormat:@"%ld",(long)[NSDate returnTheTimeralFrom1970]];
    [self saveToDBChatLisModelAsyThread:^{
        NSLog(@"save  success sele.content = %@",self.contentString);
    } andError:^{
        NSLog(@"save faild");
    }];
}
///语音
- (void)sendVoiceMessageWithCallBack:(ChatMessageCallBack)callBack{
    self.messageStatus = self.deliverStatus = 1;
   HQReqestSesstionTask *task = [HQNetWorkManager uploadFileWithUrlString:@"http://" parameters:[self transmitChatMessagToParmars] filePath:self.filePath fileName:self.filePath.lastPathComponent successBlock:^(id responseData) {
        self.messageStatus = self.deliverStatus = 2;
       if(self.ChatMessageSendStatusCallBack) self.ChatMessageSendStatusCallBack(HQMessageDeliveryState_Delivered);
        [self saveToDBChatLisModelAsyThread:^{
            NSLog(@"save  success self.content = %@",self.contentString);
        } andError:^{
            NSLog(@"save faild");
        }];
        callBack();
       ////发送成功后删除amr文件
       [[HQRecordManager sharedManager] removeAmrVoiceFileWithFileName:self.fileName];
    } failurBlock:^(NSError *error) {
        self.messageStatus = self.deliverStatus = 3;
        [self saveToDBChatLisModelAsyThread:^{
            NSLog(@"save  success self.content = %@",self.contentString);
        } andError:^{
            NSLog(@"save faild");
        }];
        if(self.ChatMessageSendStatusCallBack) self.ChatMessageSendStatusCallBack(HQMessageDeliveryState_Failure);
        callBack();
        ////发送成功后删除amr文件
        [[HQRecordManager sharedManager] removeAmrVoiceFileWithFileName:self.fileName];
    } upLoadProgress:nil];
    if(self.ChatMessageSendStatusCallBack) self.ChatMessageSendStatusCallBack(HQMessageDeliveryState_Delivering);
    task.requestTimeal = self.requestTimeral = [NSString stringWithFormat:@"%ld",(long)[NSDate returnTheTimeralFrom1970]];
    [self saveToDBChatLisModelAsyThread:^{
        NSLog(@"save  success sele.content = %@",self.contentString);
    } andError:^{
        NSLog(@"save faild");
    }];
}





#pragma mark ------- 创建关联 ---------
- (HQMessageDeliveryState)deliverStatus{
    return self.messageStatus;
}

- (void)setDeliverStatus:(HQMessageDeliveryState)deliverStatus{
    self.messageStatus = deliverStatus;
    objc_setAssociatedObject(self, @selector(deliverStatus), @(deliverStatus), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableAttributedString *)muAttributeString{
    return (NSMutableAttributedString *)objc_getAssociatedObject(self, _cmd);
}
- (void)setMuAttributeString:(NSMutableAttributedString *)muAttributeString{
    objc_setAssociatedObject(self, @selector(muAttributeString), muAttributeString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)tempImage{
    return (UIImage *)objc_getAssociatedObject(self, _cmd);
}
- (void)setTempImage:(UIImage *)tempImage{
    objc_setAssociatedObject(self, @selector(tempImage), tempImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSData *)gifImageData{
    return (NSData *)objc_getAssociatedObject(self, _cmd);
}
- (void)setGifImageData:(NSData *)gifImageData{
    objc_setAssociatedObject(self, @selector(gifImageData), gifImageData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setGifPlyIndex:(int)gifPlyIndex{
    objc_setAssociatedObject(self, @selector(gifPlyIndex), @(gifPlyIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (int )gifPlyIndex{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}

- (void)setGifFrameCount:(int)gifFrameCount{
    objc_setAssociatedObject(self, @selector(gifFrameCount), @(gifFrameCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (int)gifFrameCount{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}

- (void)setGifTimestamp:(float)gifTimestamp{
    objc_setAssociatedObject(self, @selector(gifTimestamp), @(gifTimestamp), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)gifTimestamp{
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setCurrentPlayProgress:(float)currentPlayProgress{
    objc_setAssociatedObject(self, @selector(currentPlayProgress), @(currentPlayProgress), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)currentPlayProgress{
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setGifPlayQueue:(NSOperationQueue *)gifPlayQueue{
    objc_setAssociatedObject(self, @selector(gifPlayQueue), gifPlayQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSOperationQueue *)gifPlayQueue{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSourseRef:(CGImageSourceRef)sourseRef{
    objc_setAssociatedObject(self, @selector(sourseRef), (__bridge id)sourseRef, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGImageSourceRef )sourseRef{
    return (__bridge CGImageSourceRef)objc_getAssociatedObject(self, _cmd);
}
- (void)setChatMessageSendStatusCallBack:(void (^)(HQMessageDeliveryState))ChatMessageSendStatusCallBack{
     objc_setAssociatedObject(self, &ChatMessageCallBackKey, ChatMessageSendStatusCallBack, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^)(HQMessageDeliveryState))ChatMessageSendStatusCallBack{
    return objc_getAssociatedObject(self, &ChatMessageCallBackKey);
}
- (void)setIsPlaying:(BOOL)isPlaying{
    objc_setAssociatedObject(self, @selector(isPlaying), @(isPlaying), OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL)isPlaying{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)isSeleted{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setIsSeleted:(BOOL)isSeleted{
    objc_setAssociatedObject(self, @selector(isSeleted), @(isSeleted), OBJC_ASSOCIATION_COPY_NONATOMIC);
}



























#pragma mark ---------- 数据库 ----

///同步保存
- (void)saveToDBChatListModelOnMainThread:(void (^)())success andError:(void (^)())errorCallBack{
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlockAndWait:^{
        NSError *error;
        self.messageTime = [NSDate returnTheTimeralFrom1970];
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error) {
                if (errorCallBack) errorCallBack();
            }else{
                if (success) success();
            }
        });
    }];
}
////异步保存
- (void)saveToDBChatLisModelAsyThread:(void (^)())success andError:(void (^)())faild{
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        if (self.messageType == 2 && self.tempImage != nil) {
        }
        NSError *error;
        self.messageTime = [NSDate returnTheTimeralFrom1970];
        [[HQCoreDataManager shareCoreDataManager].syManagerSaveObjectContext save:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error) {
                if (faild) faild();
            }else{
                if (success) success();
            }
        });
    }];
}

/**
 进入聊天界面时检索聊天数据
 
 @param listModel chatListModel
 @param resultBack 回调
 */

+ (void)searchChatListModelOnAsyThreadWith:(ChatListModel *)listModel andCallBack:(void (^)(NSArray *resultList))resultBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatMessageModel class])];
    NSString *filter;
    if (listModel.chatListType == 101 || listModel.chatListType == 100){
        filter = [NSString stringWithFormat:@"messageType = %d",listModel.chatListType];
    }else{
        filter = [NSString stringWithFormat:@"(speakerId = %ld and receiveId = %lld) or (speakerId = %lld and receiveId = %ld)",[HQPublicManager shareManagerInstance].userinfoModel.userId,listModel.chatListId,listModel.chatListId,[HQPublicManager shareManagerInstance].userinfoModel.userId];
    }
    NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
    request.predicate = pre;
    NSSortDescriptor *sorftDes = [[NSSortDescriptor alloc] initWithKey:@"messageTime" ascending:NO];
    request.sortDescriptors = @[sorftDes];
    request.fetchOffset = 0;
    request.fetchLimit = 10;
    ////异步线程
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        NSArray *arrays = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
//        for (ChatMessageModel *model in arrays) {
//            model.modelConfig = @"config";
//        }
        if (arrays.count) {
            NSSortDescriptor *sorft = [[NSSortDescriptor alloc] initWithKey:@"messageTime" ascending:YES];
          arrays = [arrays sortedArrayUsingDescriptors:@[sorft]];
        }
        NSMutableArray *layouts = [NSMutableArray new];
        for (ChatMessageModel *model in arrays) {
           HQBaseCellLayout *layout = [HQBaseCellLayout layoutWithMessageModel:model];
            if (layout) {
                [layouts addObject:layout];
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (resultBack) resultBack(layouts);
        });
    }];
}
///  异步检索更多聊天数据
+ (void)searchMoreChatListModelOnAsyThreadWith:(ChatListModel *)listModel WithModel:(ChatMessageModel *)model andCallBack:(void (^)(NSArray *resultList))resultBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatMessageModel class])];
    NSString *filter;
    if (listModel.chatListType == 100 || listModel.chatListType == 101) {
        filter = [NSString stringWithFormat:@"messageType = %d",listModel.chatListType];
    }else{
        filter = [NSString stringWithFormat:@"((speakerId = %lu and  receiveId = %lld ) or (speakerId = %lld and receiveId = %ld)) and  messageTime < %f",(unsigned long)[HQPublicManager shareManagerInstance].userinfoModel.userId,listModel.chatListId,listModel.chatListId,[HQPublicManager shareManagerInstance].userinfoModel.userId,model.messageTime];
    }
    NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
    request.predicate = pre;
    NSSortDescriptor *sorftDes = [[NSSortDescriptor alloc] initWithKey:@"messageTime" ascending:NO];
    request.sortDescriptors = @[sorftDes];
    request.fetchOffset = 0;
    request.fetchLimit = 10;
    ////异步线程
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        NSArray *arrays = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
//        for (ChatMessageModel *model in arrays) {
//            model.modelConfig = @"config";
//        }
        if (arrays.count) {
            NSSortDescriptor *sorft = [[NSSortDescriptor alloc] initWithKey:@"messageTime" ascending:YES];
            arrays = [arrays sortedArrayUsingDescriptors:@[sorft]];
        }
        NSMutableArray *layouts = [NSMutableArray new];
        for (ChatMessageModel *model in arrays) {
            HQBaseCellLayout *layout = [HQBaseCellLayout layoutWithMessageModel:model];
            if (layout) {
                [layouts addObject:layout];
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (resultBack) resultBack(layouts);
        });
    }];
}
//// 查询  主线程  要求等待
+ (void)searchChatLstOnMainThreadPerformWait:(void (^)(NSArray *resultArray))resultBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatMessageModel class])];
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlockAndWait:^{
        NSError *error;
        NSArray *arrays = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        if (resultBack) resultBack(arrays);
    }];
}

////检索object数量  异步
+ (void)countForChatListToDBAsyThread:(void (^)(NSInteger count))success andError:(void (^)())errorBack{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatMessageModel class])];
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        NSInteger count = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext countForFetchRequest:request error:&error];
        if (error) {
            if (errorBack) errorBack();
        }else{
            if (success) success(count);
        }
    }];
}


/////同步删除
- (void)removeFromDBOnMainThread:(void (^)())success andError:(void (^)())faild{
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlockAndWait:^{
        NSError *error;
        if (self.messageType == 2) {
            [HQLocalImageManager removeImageWithImageName:self.fileName];
        }else if (self.messageType == 4 || self.messageType == 5){
            [[HQRecordManager sharedManager] removeVoiceFileWithFileName:self.fileName];
        }
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext deleteObject:self];
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        if (error) {
            NSLog(@"delete faild");
            if (faild) faild();
        }else{
            NSLog(@"delete success");
            if (success) success();
        }
    }];
}
////异步删除
- (void)removeFromDBOnOtherThread:(void(^)())success andError:(void (^)())faild{
    [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext performBlock:^{
        if (self.messageType == 2 || self.messageType == 8) {
            [HQLocalImageManager removeImageWithImageName:self.fileName];
        }else if (self.messageType == 4 || self.messageType == 5){
            [[HQRecordManager sharedManager] removeVoiceFileWithFileName:self.fileName];
        }
        [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext deleteObject:self];
         NSError *error;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"delete faild");
                if (faild) faild();
            }else{
                NSLog(@"delete success");
                if (success) success();
            }
        });
    }];
}
////同步修改
- (void)UpDateFromDBONMainThread:(void(^)())success andError:(void (^)())faild{
    [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext performBlockAndWait:^{
        [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext refreshObject:self mergeChanges:YES];
        NSError *error;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        if (error) {
            if(faild) faild();
        }else{
            if (success) success();
        }
    }];
}
////异步修改
- (void)UPDateFromDBOnOtherThread:(void(^)())success andError:(void (^)())faild{
     [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext performBlock:^{
         [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext refreshObject:self mergeChanges:YES];
         NSError *error;
         [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
         dispatch_async(dispatch_get_main_queue(), ^{
             if (error) {
                 if(faild) faild();
             }else{
                 if (success) success();
             }
         });
     }];
}
////删除一组聊天数据
+ (void)deleteChatGroupMessageWith:(ChatListModel *)listModel andComplite:(void (^)(BOOL isSuccess))complite{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatMessageModel class])];
    NSString *filter;
    if (listModel.chatListType == 100 || listModel.chatListType == 101) {
        filter = [NSString stringWithFormat:@"messageType = %d",listModel.chatListType];
    }else{
        filter = [NSString stringWithFormat:@"(speakerId = %ld and  receiveId = %lld) or (speakerId = %lld and  receiveId = %ld)",[HQPublicManager shareManagerInstance].userinfoModel.userId,listModel.chatListId,listModel.chatListId,[HQPublicManager shareManagerInstance].userinfoModel.userId];
    }
    NSPredicate *pre = [NSPredicate predicateWithFormat:filter];
    request.predicate = pre;
    ////异步线程
    [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext performBlock:^{
        NSError *error;
        NSArray *arrays = [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext executeFetchRequest:request error:&error];
        for (ChatMessageModel *model in arrays) {
            if (model.messageType == 2 || model.messageType == 8) {
                [HQLocalImageManager removeImageWithImageName:model.fileName];
            }else if (model.messageType == 4 || model.messageType == 5){
                [[HQRecordManager sharedManager] removeVoiceFileWithFileName:model.fileName];
            }
            [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext deleteObject:model];
        }
        NSError *saveError;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&saveError];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error) {
                if (complite) {
                    complite(NO);
                }
            }else{
                if (complite) {
                    complite(YES);
                }
            }
        });
    }];
}
////异步删除多条消息
+ (void)removeMoreMessgaeModels:(NSArray <ChatMessageModel *>*)models andSuccess:(void (^)())success andFaild:(void (^)())faild{
    [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext performBlock:^{
        for (ChatMessageModel *model in models) {
            [[HQCoreDataManager shareCoreDataManager] .asyManagerSaveObjextContext deleteObject:model];
            if (model.messageType == 2 || model.messageType == 8) {
                [HQLocalImageManager removeImageWithImageName:model.fileName];
            }else if (model.messageType == 4 || model.messageType == 5){
                [[HQRecordManager sharedManager] removeVoiceFileWithFileName:model.fileName];
            }
        }
        NSError *error;
        [[HQCoreDataManager shareCoreDataManager].asyManagerSaveObjextContext save:&error];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"delete faild");
                if (faild) faild();
            }else{
                NSLog(@"delete success");
                if (success) success();
            }
        });
    }];
}

#pragma mark ----- private method -----
- (NSMutableDictionary *)transmitChatMessagToParmars{
    /////待处理
    return [[NSMutableDictionary alloc] init];
}

@end
