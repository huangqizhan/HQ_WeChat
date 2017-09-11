//
//  HQChatViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/2/20.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChatViewController.h"
#import "UIViewController+HQTranstion.h"
#import "ControllerTranstionAnimation.h"
#import "HQChatBoxViewController.h"
#import "HQBroswerViewController.h"
#import "HQBroswerModel.h"
#import "HQBroswerModel.h"
#import "HQDisPlayTextController.h"
#import "HQDeviceVoiceTipView.h"
#import "HQChatEdiateMoreView.h"
#import "HQActionSheet.h"
#import "UIApplication+HQExtern.h"
#import "ContractModel+Action.h"
#import "HQChatDetailController.h"
#import "HQRefershHeaderView.h"






@interface HQChatViewController ()<ICChatBoxViewControllerDelegate,HQChatTableViewCellDelegate,ControllerTranstionAnimationDetaSourse>{
    UIButton *_currntSeletedImageBut;
    NSArray *_rightButtonItems;
    BOOL _messageCellIsEdiating;
}
////键盘控制器
@property (nonatomic) HQChatBoxViewController *chatBoxVC;
////语音播放提示视图
@property (nonatomic,strong) HQDeviceVoiceTipView *voiceTipView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
///底部更多视图
@property (nonatomic,strong) HQChatEdiateMoreView *ediateMoreView;
///选中的cell的indexPath数组
@property (nonatomic,strong) NSMutableArray *seletedIndexPathsArray;
///选中的model数组
@property (nonatomic,strong) NSMutableArray *seletedModelsArray;
@property (nonatomic,assign) BOOL presentFlag;
///背景图片
@property (nonatomic,strong) UIImageView *begImageView;

@end





@implementation HQChatViewController
- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self keyBordViewDidResetOriginStatus];
    [self hq_removeTransitionDelegate];
    [self hiddenMenuController];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.listModel.unReadCount = 0;
    [self.listModel UPDateFromDBOnOtherThread:nil andError:nil];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [PublicCaculateManager clearChatViewControllerManagers];
}
-(BOOL)navigationShouldPopOnBackButton{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.listModel.userName;
    UIButton *butt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [butt addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [butt setTitle:@"detail" forState:UIControlStateNormal];;
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:butt],[[UIBarButtonItem alloc] initWithTitle:@"msg" style:UIBarButtonItemStylePlain target:self action:@selector(testAction:)]];
//   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sharemore_friendcard"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction:)];
    WEAKSELF;
    [ChatMessageModel searchChatListModelOnAsyThreadWith:self.listModel andCallBack:^(NSArray *resultList) {
        if (resultList.count == 0) {
            weakSelf.tableView.headerRefersh = nil;
        }else{
            [weakSelf.dataArray addObjectsFromArray:resultList];
            [weakSelf.tableView reloadData];
            [weakSelf tableViewScrollToBottomWithAnimated:NO];
        }
    }];
    [self setUpUI];
    [self registerChatCells];
}
- (void)rightButtonAction:(UIButton *)sender{
//    ChatMessageModel *messageModel = [ChatMessageModel createAnReceiveAudioMessageWith:@"/Users/GoodSrc/Library/Developer/CoreSimulator/Devices/22B34738-FD9D-4B15-8356-B80727B56F17/data/Containers/Data/Application/166FC80A-3826-4FD2-B109-8C18DF2AF622/tmp/audioFile/wavAudioTmp/149725646047117" andSpearkerId:self.listModel.chatListId andFileSize:@"8" andUserName:self.listModel.userName andUserPic:self.listModel.messageUser.userHeadImaeUrl];
//   ChatMessageModel *messageModel = [ChatMessageModel creatAnReceiveTextMessageWith:@"/Users/GoodSrc/Library/Developer/CoreSimulator/Devices/22B34738-FD9D-4B15-8356-B80727B56F17/data/Containers/Data/Application/166FC80A-3826-4FD2-B109-8C18DF2AF622/tmp/audioFile/wavAudioTmp/1497256460471" andSpeakerId:self.listModel.chatListId andUserName:self.listModel.userName andUserPic:self.listModel.messageUser.userHeadImaeUrl];
//    self.listModel.message = messageModel;
//    self.listModel.messageTime = [NSDate returnTheTimeralFrom1970];
//    self.listModel.chatListType = 1;
//    [self.dataArray addObject:messageModel];
//    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//    [self tableViewScrollToBottomWithAnimated:YES];
//    [messageModel sendTextMessage:^{
//        NSLog(@"status = %d",messageModel.messageStatus);
//    }];
    WEAKSELF;
    HQChatDetailController *chatDetailVC = [[HQChatDetailController alloc] init];
    chatDetailVC.listMOdel = self.listModel;
    [chatDetailVC setChatDetailCallBack:^(NSString *titleType){
        if ([titleType isEqualToString:@"清除聊天数据"]) {
            [weakSelf clearCurrnetAllChatMessages];
        }else if ([titleType isEqualToString:@"设置背景图片"]){
            [weakSelf setChatBegGroundImage];
        }
    }];
    [self.navigationController pushViewController:chatDetailVC animated:YES];
}
- (void)cancelEditing:(id )sender{
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[HQChaRootCell class]]) {
            HQChaRootCell *rootCell = (HQChaRootCell *)cell;
            [rootCell reSetMessageCellEdiatedStatusIsEdiate:NO];
        }
    }
    _messageCellIsEdiating = NO;
    [UIView animateWithDuration:0.35 animations:^{
        self.ediateMoreView.top =  APP_Frame_Height-64;
        self.chatBoxVC.view.top =  APP_Frame_Height-64-HEIGHT_TABBAR;
        self.navigationItem.leftBarButtonItems = _rightButtonItems;
    } completion:^(BOOL finished) {
        [self.seletedIndexPathsArray removeAllObjects];
        [self.seletedModelsArray removeAllObjects];
        for (ChatMessageModel *model in self.dataArray) {
            model.isSeleted = NO;
        }
        [self.tableView reloadData];
    }];
}
- (void)setUpUI{
    [self.view addSubview:self.begImageView];
    [self addChildViewController:self.chatBoxVC];
    [self.view addSubview:self.chatBoxVC.view];
    [self.view addSubview:self.tableView];
    self.tableView.frame = CGRectMake(0, 0, self.view.width, APP_Frame_Height-HEIGHT_TABBAR-HEIGHT_NAVBAR-HEIGHT_STATUSBAR);
    __weak typeof (self) weakSelf = self;
    self.tableView.headerRefersh = [HQRefershHeaderView headerWithRefreshingBlock:^{
        [weakSelf handleMoreDataFromDb];
    }];
}
#pragma amrk ------ 下拉加载更多数据 -------
- (void)handleMoreDataFromDb{
    if (self.dataArray.count) {
        WEAKSELF;
        [ChatMessageModel searchMoreChatListModelOnAsyThreadWith:self.listModel WithModel:[self.dataArray firstObject] andCallBack:^(NSArray *resultList) {
            if (resultList.count) {
                [weakSelf.dataArray insertObjects:resultList atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, resultList.count)]];
                [weakSelf.tableView.headerRefersh endRefreshingWithCallBack:^{
                    [weakSelf.tableView reloadData];
                    [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:resultList.count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }];
            }else{
                [weakSelf.tableView.headerRefersh endFershingWhenNoMoreData];
            }
        }];
    }
}
#pragma mark---------- 注册cells -------
- (void)registerChatCells{
    [self.tableView registerClass:[HQChatMineTextCell class] forCellReuseIdentifier:MineTextCellId];
    [self.tableView registerClass:[HQChatMineImageCell class] forCellReuseIdentifier:MineImageCellId];
    [self.tableView registerClass:[HqChatMineGifCell class] forCellReuseIdentifier:MineGifCellId];
    [self.tableView registerClass:[HQChatMineVidioCell class] forCellReuseIdentifier:MineVidioCellId];
    [self.tableView registerClass:[HQChatMineVoiceCell class] forCellReuseIdentifier:MineVoiceCellId];
    [self.tableView registerClass:[HQRecordingCell class] forCellReuseIdentifier:MineRecordingCellId];
    [self.tableView registerClass:[HQChatMineFileCell class] forCellReuseIdentifier:MineFileCellId];
    [self.tableView registerClass:[HQChatDateCell class] forCellReuseIdentifier:DateMessageCellId];
    [self.tableView registerClass:[HQChatMineLocationCell class] forCellReuseIdentifier:MineLocationCellId];
    [self.tableView registerClass:[HQChatOtherTextCell class] forCellReuseIdentifier:OtherTextCellid];
    [self.tableView registerClass:[HQChatOtherImageCell class] forCellReuseIdentifier:OtherImageCellId];
    [self.tableView registerClass:[HqChatOtherGifCell class] forCellReuseIdentifier:OtherGifCellId];
    [self.tableView registerClass:[HQChatOtherVidioCell class] forCellReuseIdentifier:OtherVidioCellId];
    [self.tableView registerClass:[HQChatOtherVoiceCell class] forCellReuseIdentifier:OtherVoiceCellId];
    [self.tableView registerClass:[HQChatOtherFileCell class] forCellReuseIdentifier:OtherFileCellid];
    [self.tableView registerClass:[HQChatLocationOtherCell class] forCellReuseIdentifier:OtherLocationCellId];
}
#pragma mark ------ UITableViewDelegate -----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatMessageModel *model = self.dataArray[indexPath.row];
    return model.cellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatMessageModel *model = self.dataArray[indexPath.row];
    if (model.speakerId == [HQPublicManager shareManagerInstance].userinfoModel.userId) {
        HQChatMineBaseCell *mineBaseCell = [tableView dequeueReusableCellWithIdentifier:model.messageCellTypeId];
        mineBaseCell.delegate = self;
        mineBaseCell.indexPath = indexPath;
        mineBaseCell.messageModel = model;
        mineBaseCell.isEdiating = _messageCellIsEdiating;
        return mineBaseCell;
    }else{
        HQChatOtherBaseCell *otherCell = [tableView dequeueReusableCellWithIdentifier:model.messageCellTypeId];
        otherCell.delegate = self;
        otherCell.messageModel = model;
        otherCell.indexPath = indexPath;
        otherCell.isEdiating = _messageCellIsEdiating;
        return otherCell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_messageCellIsEdiating) {
        HQChaRootCell *rootCell = [tableView cellForRowAtIndexPath:indexPath];
        [rootCell didSeleteCellWhenIsEdiating:!rootCell.isSeleted];
        [self didseleteTableViewCellWithIndexPath:indexPath];
    }else{
        [self keyBordViewDidResetOriginStatus];
    }
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hiddenMenuController];
    [self keyBordViewDidResetOriginStatus];
}
- (void)hiddenMenuController{
    if ([UIMenuController sharedMenuController].menuVisible) {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
}
////清除聊天数据
- (void)clearCurrnetAllChatMessages{
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
}
////键盘回到底部
- (void)keyBordViewDidResetOriginStatus{
    [self.chatBoxVC.chatBox.textView resignFirstResponder];
    [UIView animateWithDuration:.25 animations:^{
        self.chatBoxVC.view.top = APP_Frame_Height-HEIGHT_TABBAR-64;
        self.tableView.height = APP_Frame_Height-HEIGHT_TABBAR-HEIGHT_NAVBAR-HEIGHT_STATUSBAR;
    } completion:^(BOOL finished) {
        self.chatBoxVC.chatBox.boxStatus = HQChatBoxStatusNothing;
    }];
}
////选中cell的数据处理
- (void)didseleteTableViewCellWithIndexPath:(NSIndexPath *)indexPath{
    ChatMessageModel *model = self.dataArray[indexPath.row];
    if (model && ![self.seletedModelsArray containsObject:model]) {
        [self.seletedModelsArray addObject:model];
    }else{
        [self.seletedModelsArray removeObject:model];
    }
    if (![self.seletedIndexPathsArray containsObject:indexPath]) {
        [self.seletedIndexPathsArray addObject:indexPath];
    }else{
        [self.seletedIndexPathsArray removeObject:indexPath];
    }
    WEAKSELF;
    [self checkCurrnetMessageIsHasDateMessageWithIndexPath:indexPath andComplite:^(ChatMessageModel *msgModel, NSIndexPath *dateIndexPath) {
        if (msgModel == nil || dateIndexPath == nil) {
            return ;
        }
        if (msgModel && ![self.seletedModelsArray containsObject:msgModel]) {
            [weakSelf.seletedModelsArray addObject:msgModel];
        }else{
            [weakSelf.seletedModelsArray removeObject:msgModel];
        }
        if (![weakSelf.seletedIndexPathsArray containsObject:dateIndexPath]) {
            [weakSelf.seletedIndexPathsArray addObject:dateIndexPath];
        }else{
            [weakSelf.seletedIndexPathsArray removeObject:dateIndexPath];
        }
    }];
    [self.ediateMoreView setEdiateViewActiveStatusWith:self.seletedModelsArray.count];
}

#pragma mark -------- 消息分发测试 --------
- (void)testAction:(UIBarButtonItem *)item{
    NSDictionary *diction = [self  creatTextNessageWithIndex:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationReceiveNewMessageNotification object:diction];
}
- (NSDictionary *)creatTextNessageWithIndex:(int )index{
    NSTimeInterval timeral = [NSDate returnTheTimeralFrom1970];
    NSDictionary *dic = @{
                          @"contentString":@"看惊世毒妃v你收快递费v 是考虑对方v是考虑对方v是考虑对方v 克里斯多夫v是考虑对方v是考虑到局开始对方即可是说说看老地方v刷卡机代理费v 思考劳动局会计师对方即可 是李开复女卡萨丁女会计师快乐圣诞节饭v看似简单风景女士 抗联世纪东方女生肯德基抗联世纪东方v杀戮空间的妇女看似简单  抗联收到v就卡萨丁",
                          @"contentUrlString":@"",
                          @"fileExtion":@"",
                          @"fileName":@"",
                          @"filePath":@"",
                          @"fileSize":@"",
                          @"isGroupChat":@0,
                          @"messageId":[NSNumber numberWithInt:index],
                          @"messageStatus":@0,
                          @"messageTime":[NSNumber numberWithDouble:timeral+index],
                          @"messageType":@1,
                          @"modelConfig":@"",
                          @"receiveId":@10001,
                          @"requestProcess":@0,
                          @"requestTimeral":@0,
                          @"speakerId":[NSNumber numberWithInteger:self.listModel.chatListId],
                          @"tempPath":@"",
                          @"userHeadImageString":@"http://d.lanrentuku.com/down/png/1610/16young-avatar-collection/boy-2.png",
                          @"userName":@"刘威"
                          };
    return dic;
}
- (void)messageHandleWith:(ChatMessageModel *)messageModel{
    [self.dataArray addObject:messageModel];
    [self.tableView reloadData];
    [self scrollToTableViewBottomWithAnimated:YES andAferDealy:0.05];
}
#pragma mark -------- 消息菜单栏按钮处理 -----------
- (void)HQChatMineBaseCell:(UITableViewCell *)cell MenuActionTitle:(NSString *)menuActionTitle andIndexPath:(NSIndexPath *)indexPath andChatModel:(ChatMessageModel *)model{
    if ([menuActionTitle isEqualToString:@"删除"]) {
        WEAKSELF;
        [self checkCurrnetMessageIsHasDateMessageWithIndexPath:indexPath andComplite:^(ChatMessageModel *msgModel, NSIndexPath *dateIndexPath) {
            if (msgModel != nil && dateIndexPath != nil) {
                [weakSelf deleteMessageWithModel:@[model,msgModel] andIndexPath:@[indexPath,dateIndexPath]];
            }else{
                 [weakSelf deleteMessageWithModel:@[model] andIndexPath:@[indexPath]];
            }
        }];
    }else if ([menuActionTitle isEqualToString:@"更多"]){
        [self ediateMesaageWithModel:model andIndexPath:indexPath];
    }
}
///双击
- (void)HQChatDoubleClick:(UITableViewCell *)cell WithChatMessage:(ChatMessageModel *)messageModel{
    WEAK_SELF;
    HQDisPlayTextController *disPlayVC = [[HQDisPlayTextController alloc] init];
    disPlayVC.messageModel = messageModel;
    [disPlayVC showInWindownWithCallBack:^(HQAttrubuteTextData *data) {
        if (data.type == HQAttrubuteTextTypeURL) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf pushToWebViewControllerWithUrl:data.url];
            });
        }
    }];
}
- (HQTextView *)getCurentTextViewWhenShowMenuController{
    return self.chatBoxVC.chatBox.textView.isFirstResponder ? self.chatBoxVC.chatBox.textView : nil;
}
- (void)MenuViewControllerDidHidden{
    self.chatBoxVC.chatBox.textView.textCell = nil;
}
///超链接
- (void)HQChatClickLink:(UITableViewCell *)cell withChatMessage:(ChatMessageModel *)message andLinkUrl:(NSURL *)linkUrl{
    [self pushToWebViewControllerWithUrl:linkUrl];
}
#pragma mark ------- 跳转超链接 ------
- (void)pushToWebViewControllerWithUrl:(NSURL *)url{
    HQWebViewController *webVC = [[HQWebViewController alloc] init];
    webVC.url = url;
    [self.navigationController pushViewController:webVC animated:YES];

}
- (void)changeSpeakerStatus{
    if (!self.voiceTipView.superview) {
        WEAKSELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.view addSubview:self.voiceTipView];
            weakSelf.voiceTipView.alpha = 0.0;
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.voiceTipView.alpha = 1.0;
            }];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.voiceTipView removeFromSuperviewWithAnimaton];
        });
    }
}
////删除消息
- (void)deleteMessageWithModel:(NSArray<ChatMessageModel * >*)models andIndexPath:(NSArray<NSIndexPath *> *)indexPaths{
    if (models.count && indexPaths.count) {
        [self.tableView reloadData];
        [self.dataArray removeObjectsInArray:models];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        if (self.dataArray.count) {
            self.listModel.message = self.dataArray.lastObject;
        }
        WEAKSELF;
        [ChatMessageModel removeMoreMessgaeModels:models andSuccess:^{
            [weakSelf.seletedIndexPathsArray removeAllObjects];
            [weakSelf.seletedModelsArray removeAllObjects];
        } andFaild:^{
        }];
    }
}
////编辑消息(更多)
- (void)ediateMesaageWithModel:(ChatMessageModel *)model andIndexPath:(NSIndexPath *)indexPath{
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelEditing:)];
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.leftBarButtonItem = nil;
    [self keyBordViewDidResetOriginStatus];
    _messageCellIsEdiating = YES;
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[HQChaRootCell class]]) {
            HQChaRootCell *rootCell = (HQChaRootCell *)cell;
            [rootCell reSetMessageCellEdiatedStatusIsEdiate:YES];
        }
    }
    [self.view addSubview:self.ediateMoreView];
    [UIView animateWithDuration:0.35 animations:^{
        self.navigationItem.leftBarButtonItem = cancel;
        self.ediateMoreView.top =  APP_Frame_Height-64-HEIGHT_TABBAR;
        self.chatBoxVC.view.top =  APP_Frame_Height-64;
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
        [self didseleteTableViewCellWithIndexPath:indexPath];
    }];
}
#pragma mark -------- 监听键盘高度变化 --------
- (void)chatBoxViewController:(HQChatBoxViewController *)chatboxViewController
        didChangeChatBoxHeight:(CGFloat)height{
    self.chatBoxVC.view.top = self.view.bottom-height-64;
    self.tableView.height = HEIGHT_SCREEN - height - 64;
    if (height != HEIGHT_TABBAR) {
        [self tableViewScrollToBottomWithAnimated:NO];
    }
    [self.tableView reloadData];
}
- (void)chatBoxInputStatusController:(HQChatBoxViewController *)chatboxViewController ChatBoxHeight:(CGFloat)height{
    self.chatBoxVC.view.top = self.view.bottom-height-64;
    self.tableView.height = HEIGHT_SCREEN - height - 64;
    if (height != HEIGHT_TABBAR) {
        [self tableViewScrollToBottomWithAnimated:NO];
    }
}
#pragma mark --------- 发送文本消息 ---------
- (void)chatBoxViewController:(HQChatBoxViewController *)chatboxViewController
               sendTextMessage:(NSString *)messageStr{
    ChatMessageModel *messageModel = [ChatMessageModel creatAnSnedMesssageWith:messageStr andReceiverId:self.listModel.chatListId andUserName:self.listModel.userName andUserPic:self.listModel.messageUser.userHeadImaeUrl];
    [self refershListModelWithMessageModel:messageModel];
    ChatMessageModel *dateModel = [self checkTheLeastMessageTimeIsBeyondLongestTimeWithCurrentMessageTime:messageModel.messageTime];
    if (dateModel) {
        [self.dataArray addObject:dateModel];
    }
    [self.dataArray addObject:messageModel];
    [self.tableView reloadData];
    [self scrollToTableViewBottomWithAnimated:YES andAferDealy:0.05];
    if (dateModel) {
        [dateModel saveToDBChatLisModelAsyThread:^{
        } andError:^{
        }];
    }
    [messageModel sendTextMessage:^{
        NSLog(@"status = %d",messageModel.messageStatus);
    }];
}
#pragma mark --------- 发送GIF -------
- (void)chatBoxViewController:(HQChatBoxViewController *)chatboxViewController sendGifMessage:(NSString *)gifFileName{
    ChatMessageModel *messageModel = [ChatMessageModel creatAnSendGifMessageWith:gifFileName andReceiveId:self.listModel.chatListId andUserName:self.listModel.userName andUserPic:self.listModel.messageUser.userHeadImaeUrl];
    [self refershListModelWithMessageModel:messageModel];
    ChatMessageModel *dateModel = [self checkTheLeastMessageTimeIsBeyondLongestTimeWithCurrentMessageTime:messageModel.messageTime];
    if (dateModel) {
        [self.dataArray addObject:dateModel];
    }
    [self.dataArray addObject:messageModel];
    [self.tableView reloadData];
    [self scrollToTableViewBottomWithAnimated:YES andAferDealy:0.05];
    [messageModel sendTextMessage:^{
        NSLog(@"status = %d",messageModel.messageStatus);
    }];
}
#pragma mark --------- 发送图片 ----------
- (void)chatBoxViewController:(HQChatBoxViewController *)chatboxViewController
              sendImageMessage:(NSArray<UIImage *> *)image
                     imagePath:(NSArray<NSString *> *)imgPath
                   andFileName:(NSArray<NSString *> *)fileName{
    for (int i = 0 ; i < image.count ; i++) {
        ChatMessageModel *messageModel = [ChatMessageModel creatAnSendImageMessageWith:image[i] andImagePath:fileName[i] andImageName:fileName[i] andReceiverId:self.listModel.chatListId andUserName:self.listModel.userName andUserPic:self.listModel.messageUser.userHeadImaeUrl];
        [self refershListModelWithMessageModel :messageModel];
        ChatMessageModel *dateModel = [self checkTheLeastMessageTimeIsBeyondLongestTimeWithCurrentMessageTime:messageModel.messageTime];
        if (dateModel) {
            [self.dataArray addObject:dateModel];
        }
        [self.dataArray addObject:messageModel];
        [messageModel sendTextMessage:^{
            NSLog(@"status = %d",messageModel.messageStatus);
        }];
    }
    [self.tableView reloadData];
    [self scrollToTableViewBottomWithAnimated:YES andAferDealy:0.05];
}
#pragma mark ------ 语音 -------
- (void)chatBoxViewControllerCreateAudioMessage:(HQChatBoxViewController *)chatboxViewController andFilePath:(NSString *)filePath{
    ChatMessageModel *msgModel = [ChatMessageModel creatAnRecordingMessageWith:filePath andReceiveId:self.listModel.chatListId andUserName:self.listModel.userName andUserPic:self.listModel.messageUser.userHeadImaeUrl];
    [self  refershListModelWithMessageModel:msgModel];
    ChatMessageModel *dateModel = [self checkTheLeastMessageTimeIsBeyondLongestTimeWithCurrentMessageTime:msgModel.messageTime];
    if (dateModel) {
        [self.dataArray addObject:dateModel];
    }
    [self.dataArray addObject:msgModel];
    [self.tableView reloadData];
    [self scrollToTableViewBottomWithAnimated:YES andAferDealy:0.05];
}
///移除语音文件
- (void)chatBoxViewControllerRemoveAudioMessage:(HQChatBoxViewController *)chatboxViewController andFilePath:(NSString *)filePath{
    HQRecordingCell *recordCell = [[HQRecordingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MineRecordingCellId];
    if (recordCell.messageModel && recordCell.indexPath) {
        WEAKSELF;
        [self checkCurrnetMessageIsHasDateMessageWithIndexPath:recordCell.indexPath andComplite:^(ChatMessageModel *msgModel, NSIndexPath *dateIndexPath) {
            if (msgModel != nil && dateIndexPath != nil) {
                [weakSelf deleteMessageWithModel:@[recordCell.messageModel,msgModel] andIndexPath:@[recordCell.indexPath,dateIndexPath]];
            }else{
                [weakSelf deleteMessageWithModel:@[recordCell.messageModel] andIndexPath:@[recordCell.indexPath]];
            }
        }];
    }
}
///更新语音时间
- (void)chatBoxViewControllerUpdateAudioMessage:(HQChatBoxViewController *)chatboxViewController andFilePath:(NSString *)filePath andTimeral:(NSTimeInterval )duration{
    HQRecordingCell *recordCell = [[HQRecordingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MineRecordingCellId];
    if (recordCell) {
        [recordCell updateDurationLabel:(int)duration];
    }
}
///语音录制完成
- (void) chatBoxViewControllerDidFinishRecord:(HQChatBoxViewController *)chatboxViewController andFilePath:(NSString *)filePath andVoiceDuration:(CFTimeInterval)duration{
    HQRecordingCell *recordCell = [[HQRecordingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MineRecordingCellId];
    [recordCell.messageModel setValue:[NSString stringWithFormat:@"%d",(int)duration] forKey:@"fileSize"];
    [recordCell removeAnimationAndUpdateVoiceCell:^{
        [recordCell.messageModel setValue:@4 forKey:@"messageType"];
        [recordCell.messageModel setValue:@"config" forKey:@"modelConfig"];
        [self.listModel refershChatListModelWith:recordCell.messageModel];
        [self.tableView reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [recordCell updateDurationLabel:1];
            [recordCell resetRecordingOrigeStatus];
            [recordCell.messageModel sendVoiceMessageWithCallBack:^{
            }];
        });
    }];
}
///发送位置消息
- (void)chatBoxViewControllerSendlocationMessage:(HQChatBoxViewController *)chatBoxViewController andImage:(UIImage *)image andLocation:(CLLocationCoordinate2D)coor2D andAddress:(NSString *)address andFileName:(NSString *)fileName{
    ChatMessageModel *messageModel = [ChatMessageModel creatAnSendLoactionMessageWith:image andLocation:coor2D andAddress:address andUserName:fileName andPic:self.listModel.messageUser.userHeadImaeUrl andFileName:fileName andReceived:self.listModel.chatListId];
//    ChatMessageModel *messageModel  = [ChatMessageModel createAnReceiveLocationMessageWith:image andLocation:coor2D andAddress:address andUserName:self.listModel.userName andPic:self.listModel.messageUser.userHeadImaeUrl andFileName:fileName andSpeakerId:self.listModel.chatListId];
    [self refershListModelWithMessageModel :messageModel];
    ChatMessageModel *dateModel = [self checkTheLeastMessageTimeIsBeyondLongestTimeWithCurrentMessageTime:messageModel.messageTime];
    if (dateModel) {
        [self.dataArray addObject:dateModel];
    }
    [self.dataArray addObject:messageModel];
    [self.tableView reloadData];
    [self scrollToTableViewBottomWithAnimated:YES andAferDealy:0.05];
    [messageModel sendTextMessage:^{
        NSLog(@"status = %d",messageModel.messageStatus);
    }];
}
///检查是否需要添加时间消息
- (ChatMessageModel *)checkTheLeastMessageTimeIsBeyondLongestTimeWithCurrentMessageTime:(double)curentTime{
    double lastTime = 0;
    if (self.dataArray.count > 0){
        ChatMessageModel *model = [self.dataArray lastObject];
        lastTime = model.messageTime;
    }
    if ((curentTime - lastTime) > ChatMessagePeriodTime) {
        return [ChatMessageModel creatAnSendDateMessageWithReceiveId:self.listModel.chatListId];
    }
    return nil;
}
//删除消息时检查是否有时间消息
- (void)checkCurrnetMessageIsHasDateMessageWithIndexPath:(NSIndexPath *)indexPath andComplite:(void (^)(ChatMessageModel *msgModel,NSIndexPath *indexPath))complite{
    if (indexPath.row == 0 || indexPath == nil) {
        if (complite) complite(nil,nil);
        return;
    }
    ChatMessageModel *dateModel = self.dataArray[indexPath.row-1];
    if (dateModel.messageType == 99) {
        if (complite) complite(dateModel,[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]);
        return;
    }
    if (complite) complite(nil,nil);
}
///刷新listModel
- (void)refershListModelWithMessageModel:(ChatMessageModel *)msgModel{
    [self.listModel refershChatListModelWith:msgModel];
    if (self.listModel.isShow == NO) {
        self.listModel.isShow = YES;
        [self.listModel UpDateFromDBONMainThread:nil andError:nil];
        if (self.reloadChatListFromDBCallBack) _reloadChatListFromDBCallBack();
    }
}
#pragma mark ------- 查看大图  -----
- (void)HQChatMineBaseCell:(HQChatMineBaseCell *)cell didScanOriginePictureWith:(ChatMessageModel *)messageModel andPicBtn:(UIButton *)picButton{
    [self searchCurrentChatImageMessageWith:messageModel callBackResult:^(NSMutableArray *resultArr, NSInteger index) {
        [self hq_addTransitionDelegate:self];
        [self hq_popTransitionAnimationWithCurrentScrollView:nil  animationDuration:0.25 isInteractiveTransition:YES];
        _currntSeletedImageBut = picButton;
        HQBroswerViewController *broswerVC = [[HQBroswerViewController alloc] init];
        broswerVC.currnetImageIndex = index;
        broswerVC.broswerArray = resultArr;
        broswerVC.navigationController.delegate = self;
        [broswerVC setCurrentScanImageIndexCallBack:^(HQBroswerModel *model) {
            UITableViewCell *imageCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:model.origineIndex inSection:0]];
            if (imageCell) {
                if ([imageCell isKindOfClass:[HQChatMineImageCell class]]) {
                    HQChatMineImageCell  *mineImageCell = (HQChatMineImageCell *)imageCell;
                    NSArray *visbleCellss = [_tableView indexPathsForVisibleRows];
                    if ([visbleCellss containsObject:mineImageCell.indexPath]) {
                        _currntSeletedImageBut = mineImageCell.imageBtn;
                    }else{
                        _currntSeletedImageBut = nil;
                    }
                }else{
                    HQChatOtherImageCell  *otherImageCell = (HQChatOtherImageCell *)imageCell;
                    NSArray *visbleCellss = [_tableView indexPathsForVisibleRows];
                    if ([visbleCellss containsObject:otherImageCell.indexPath]) {
                        _currntSeletedImageBut = otherImageCell.imageBtn;
                    }else{
                        _currntSeletedImageBut = nil;
                    }
                }
            }else if ([imageCell isKindOfClass:[HQChatOtherImageCell class]]){
                
            }else{
                _currntSeletedImageBut = nil;
            }
        }];
        [self.navigationController pushViewController:broswerVC animated:YES];
    }];
}
#pragma mark ------- 查看大图时检索界面的图片数据  -------
- (void)searchCurrentChatImageMessageWith:(ChatMessageModel *)msgModel callBackResult:(void (^)(NSMutableArray *resultArr ,NSInteger index))callBackResult{
    NSString *filterStr = [NSString stringWithFormat:@"messageType = 2"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:filterStr];
    NSArray *resultArray = [self.dataArray filteredArrayUsingPredicate:pre];
    NSSortDescriptor *des = [[NSSortDescriptor alloc] initWithKey:@"messageTime" ascending:YES];
    resultArray = [resultArray sortedArrayUsingDescriptors:@[des]];
    NSInteger index = 0;
    if ([resultArray containsObject:msgModel]) {
        index = [resultArray indexOfObject:msgModel];
    }
    NSMutableArray *imageArr = [NSMutableArray new];
    for (ChatMessageModel *msmodel in resultArray) {
        HQBroswerModel *model = [[HQBroswerModel alloc] init];
        model.tempImage = msmodel.tempImage;
        model.localPath = msmodel.filePath;
        model.fileName = msmodel.fileName;
        model.urlString = msmodel.contentString;
        model.speakerId = msmodel.speakerId;
        model.origineIndex = [self.dataArray indexOfObject:msmodel];
        [imageArr addObject:model];
    }
    if(callBackResult) callBackResult(imageArr,index);
}
#pragma mark ------ 监听侧滑返回 -----
- (void)willMoveToParentViewController:(UIViewController*)parent{
    if ([self isViewLoaded]) {
        NSLog(@"will pop");
    }
}
- (void)didMoveToParentViewController:(UIViewController*)parent{
    
}
- (void)showCustomerActionSheetViewWithTitle:(NSString *)title{
    HQActionSheet *actionSheet = [[HQActionSheet alloc] initWithTitle:title];
    WEAK_SELF;
    HQActionSheetAction *action = [HQActionSheetAction actionWithTitle:@"确定" handler:^(HQActionSheetAction *action) {
        [weakSelf deleteMessageWithModel:self.seletedModelsArray andIndexPath:self.seletedIndexPathsArray];
    } style:HQActionStyleDestructive];
    [actionSheet addAction:action];
    [actionSheet showInWindow:[UIApplication popOverWindow]];
}
- (void)tableViewScrollToBottomWithAnimated:(BOOL)animated{
    if (self.dataArray.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}
- (void)scrollToTableViewBottomWithAnimated:(BOOL)animated andAferDealy:(CGFloat)delay{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.dataArray.count > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    });
}
- (void)setChatBegGroundImage{
    self.begImageView.image = [[HQLocalImageManager shareImageManager] getChatBegImageWith:self.listModel.chatBegImageFilePath];
    self.begImageView.clipsToBounds = YES;
    self.begImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.begImageView.backgroundColor = IColor(240, 237, 237);
}
#pragma mark ------- geter setter  -----------
- (HQChatEdiateMoreView *)ediateMoreView{
    if (_ediateMoreView == nil) {
        _ediateMoreView = [[[NSBundle mainBundle] loadNibNamed:@"HQChatEdiateMoreView" owner:self options:nil] lastObject];
        _ediateMoreView.frame = CGRectMake(0, APP_Frame_Height-HEIGHT_TABBAR-64, App_Frame_Width, 50);
        WEAKSELF;
        [_ediateMoreView setEdiateMoreViewClickCallBack:^(NSString *titleString){
            if ([titleString isEqualToString:@"删除"]) {
                [weakSelf showCustomerActionSheetViewWithTitle:@"您确定要删除已选择的消息?"];
            }
        }];
    }
    return _ediateMoreView;
}
- (HQChatBoxViewController *)chatBoxVC{
    if (_chatBoxVC == nil) {
        _chatBoxVC = [[HQChatBoxViewController alloc] init];
        [_chatBoxVC.view setFrame:CGRectMake(0,APP_Frame_Height-HEIGHT_TABBAR-64, App_Frame_Width, APP_Frame_Height)];
        _chatBoxVC.delegate = self;
    }
    return _chatBoxVC;
}
- (HQDeviceVoiceTipView *)voiceTipView{
    if (_voiceTipView == nil) {
        _voiceTipView = [[[NSBundle mainBundle] loadNibNamed:@"HQDeviceVoiceTipView" owner:self options:nil] lastObject];
    }
    return _voiceTipView;
}
-(UITableView *)tableView{
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
//        tapGesture.numberOfTapsRequired = 1;
//        tapGesture.numberOfTouchesRequired = 1;
//        [_tableView addGestureRecognizer:tapGesture];
    }
    return _tableView;
}
- (UIImageView *)begImageView{
    if (_begImageView == nil) {
        _begImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64)];
        _begImageView.image = [[HQLocalImageManager shareImageManager] getChatBegImageWith:self.listModel.chatBegImageFilePath];
        _begImageView.clipsToBounds = YES;
        _begImageView.contentMode = UIViewContentModeScaleAspectFill;
        _begImageView.backgroundColor = IColor(240, 237, 237);
    }
    return _begImageView;
}
- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}
- (NSMutableArray *)seletedIndexPathsArray{
    if (_seletedIndexPathsArray == nil) {
        _seletedIndexPathsArray = [NSMutableArray new];
    }
    return _seletedIndexPathsArray;
}
- (NSMutableArray *)seletedModelsArray{
    if (_seletedModelsArray == nil) {
        _seletedModelsArray = [NSMutableArray new];
    }
    return _seletedModelsArray;
}
- (UIButton *)pushTransitionImageView{
    return _currntSeletedImageBut;
}
- (UIButton *)popTransitionImageView{
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
@end






