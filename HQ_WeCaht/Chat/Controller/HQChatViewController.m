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
#import "HQChatViewController+UIHandler.h"




@interface HQChatViewController ()<ICChatBoxViewControllerDelegate,HQChatTableViewCellDelegate,ControllerTranstionAnimationDetaSourse>{
    UIButton *_currntSeletedImageBut;
    NSArray *_rightButtonItems;
    BOOL _messageCellIsEdiating;
}
////键盘控制器
@property (nonatomic) HQChatBoxViewController *chatBoxVC;
@property (nonatomic, strong,readwrite) HQChatTableView *tableView;
@property (nonatomic,strong,readwrite) NSMutableArray <HQBaseCellLayout *> *dataArray;
////语音播放提示视图
@property (nonatomic,strong) HQDeviceVoiceTipView *voiceTipView;
///底部更多视图
@property (nonatomic,strong) HQChatEdiateMoreView *ediateMoreView;
///选中的cell的indexPath数组
@property (nonatomic,strong) NSMutableArray *seletedIndexPathsArray;
///选中的model数组
@property (nonatomic,strong) NSMutableArray <HQBaseCellLayout *> *seletedModelsArray;
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
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self keyBordViewDidResetOriginStatus];
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
    WEAKSELF;
    [self setUpUI];
    [self registerChatCells];
    [ChatMessageModel searchChatListModelOnAsyThreadWith:self.listModel andCallBack:^(NSArray *resultList) {
        if (resultList.count == 0) {
            weakSelf.tableView.headerRefersh = nil;
        }else{
            [weakSelf.dataArray addObjectsFromArray:resultList];
            [weakSelf.tableView reloadData];
            [weakSelf tableViewScrollToBottomWithAnimated:NO];
        }
    }];
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
        [self syncDispalyTableViewReload];
    }];
}
- (void)setUpUI{
    [self.view addSubview:self.begImageView];
    [self addChildViewController:self.chatBoxVC];
    [self.view addSubview:self.chatBoxVC.view];
    [self.view addSubview:self.tableView];
    self.tableView.frame = CGRectMake(0, 0, self.view.width, APP_Frame_Height-HEIGHT_TABBAR-HEIGHT_NAVBAR-HEIGHT_STATUSBAR);
    WEAKSELF;
    self.tableView.headerRefersh = [HQRefershHeaderView headerWithRefreshingBlock:^{
        [weakSelf handleMoreDataFromDb];
    }];
}
#pragma amrk ------ 下拉加载更多数据 -------
- (void)handleMoreDataFromDb{
    if (self.dataArray.count) {
        WEAKSELF;
        [ChatMessageModel searchMoreChatListModelOnAsyThreadWith:self.listModel WithModel:[self.dataArray firstObject].modle andCallBack:^(NSArray *resultList) {
            if (resultList.count) {
                [weakSelf.tableView.headerRefersh endRefreshingWithCallBack:^{
                    [weakSelf.dataArray insertObjects:resultList atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, resultList.count)]];
                    [weakSelf syncDispalyTableViewReload];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HQBaseCellLayout *layout = self.dataArray[indexPath.row];
    return layout.cellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HQBaseCellLayout *layout = self.dataArray[indexPath.row];
    return layout.cellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HQBaseCellLayout *layout = self.dataArray[indexPath.row];
    HQChatMineBaseCell *mineBaseCell = [tableView dequeueReusableCellWithIdentifier:layout.messageCellTypeId];
    mineBaseCell.delegate = self;
    mineBaseCell.indexPath = indexPath;
    mineBaseCell.layout = layout;
    mineBaseCell.isEdiating = _messageCellIsEdiating;
    return mineBaseCell;

//    if (model.speakerId == [HQPublicManager shareManagerInstance].userinfoModel.userId) {
//        HQChatMineBaseCell *mineBaseCell = [tableView dequeueReusableCellWithIdentifier:model.messageCellTypeId];
//        mineBaseCell.delegate = self;
//        mineBaseCell.indexPath = indexPath;
//        mineBaseCell.messageModel = model;
//        mineBaseCell.isEdiating = _messageCellIsEdiating;
//        return mineBaseCell;
//    }else{
//        HQChatOtherBaseCell *otherCell = [tableView dequeueReusableCellWithIdentifier:model.messageCellTypeId];
//        otherCell.delegate = self;
//        otherCell.messageModel = model;
//        otherCell.indexPath = indexPath;
//        otherCell.isEdiating = _messageCellIsEdiating;
//        return otherCell;
//    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_messageCellIsEdiating) {
        HQChaRootCell *rootCell = [tableView cellForRowAtIndexPath:indexPath];
        [rootCell didSeleteCellWhenIsEdiating:!rootCell.isSeleted];
//        [self didseleteTableViewCellWithIndexPath:indexPath];
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
//////清除聊天数据
- (void)clearCurrnetAllChatMessages{
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
}
//////键盘回到底部
- (void)keyBordViewDidResetOriginStatus{
    [self.chatBoxVC.chatBox.textView resignFirstResponder];
    [UIView animateWithDuration:.25 animations:^{
        self.chatBoxVC.view.top = APP_Frame_Height-HEIGHT_TABBAR-64;
        self.tableView.height = APP_Frame_Height-HEIGHT_TABBAR-HEIGHT_NAVBAR-HEIGHT_STATUSBAR;
    } completion:^(BOOL finished) {
        self.chatBoxVC.chatBox.boxStatus = HQChatBoxStatusNothing;
    }];
}
//////选中cell的数据处理
- (void)didseleteTableViewCellWithIndexPath:(NSIndexPath *)indexPath{
    HQBaseCellLayout *layout = self.dataArray[indexPath.row];
    if (layout && ![self.seletedModelsArray containsObject:layout]) {
        [self.seletedModelsArray addObject:layout];
    }else{
        [self.seletedModelsArray removeObject:layout];
    }
    if (![self.seletedIndexPathsArray containsObject:indexPath]) {
        [self.seletedIndexPathsArray addObject:indexPath];
    }else{
        [self.seletedIndexPathsArray removeObject:indexPath];
    }
//    WEAKSELF;
//    [self checkCurrnetMessageIsHasDateMessageWithIndexPath:indexPath andComplite:^(ChatMessageModel *msgModel, NSIndexPath *dateIndexPath) {
//        if (msgModel == nil || dateIndexPath == nil) {
//            return ;
//        }
//        if (msgModel && ![self.seletedModelsArray containsObject:msgModel]) {
//            [weakSelf.seletedModelsArray addObject:msgModel];
//        }else{
//            [weakSelf.seletedModelsArray removeObject:msgModel];
//        }
//        if (![weakSelf.seletedIndexPathsArray containsObject:dateIndexPath]) {
//            [weakSelf.seletedIndexPathsArray addObject:dateIndexPath];
//        }else{
//            [weakSelf.seletedIndexPathsArray removeObject:dateIndexPath];
//        }
//    }];
//    [self.ediateMoreView setEdiateViewActiveStatusWith:self.seletedModelsArray.count];
}
#pragma mark -------- 消息分发测试 --------
- (void)testAction:(UIBarButtonItem *)item{
//    NSDictionary *diction = [self  creatTextNessageWithIndex:1];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationReceiveNewMessageNotification object:diction];
//    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}
- (NSDictionary *)creatTextNessageWithIndex:(int )index{
    NSTimeInterval timeral = [NSDate returnTheTimeralFrom1970];
    NSDictionary *dic = @{
                          @"contentString":@"新华社呼和浩特9月11日电 《联合国防治荒漠化公约》第十三次缔约方大会高级别会议11日在内蒙古鄂尔多斯市开幕。13969768213国家主席习近平发来贺信，向会议的召开致以热烈的祝贺，向出席会议的各国代表、http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm国际机构负责人和各界人士致以诚挚的欢迎，并预祝大会圆满成功。习近平指出，13969768213土地荒漠化是影响人类生存和发展的全球重大生态问题。公约生效21年来，在各方共同努力下http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm，全球荒漠化防治取得明显成效，但形势依然严峻，世界上仍有许多地方的人民饱受荒漠化之苦。http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm这次大会以“携手防治荒漠，http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm共谋人类福祉”为主题，共议公约新战略框架13969768213，http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm必将对维护全球生态安全产生重大而积极的影响。习近平强调，防治荒漠化是人类面临的共同挑战，需要国际社会携手应对。我们要弘扬尊重自然、保护自然的理念，坚13969768213持生态优先、13969768213预防为主，坚定信心，面向未来，制定广泛合作、目标明确的公约新战略框架，共同推进全球荒漠生态系统治理，让荒漠造福人类。http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm中国将坚定不移履行公约义务，按照本次缔约方大会确定的目标，一如既往加强同各成员国13969768213和国际组织的交流合作，共同为建设一个更加美好的世界而努力。国务院副总理汪洋在开幕式上宣读了习近平的贺信并发表主旨演讲。他强调，http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm中国将认真履行习近平主席在139697682132015年联合国发展13969768213峰会上的郑重承诺，以落实2030年可持续发展议程为己任，http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm以新发展理念为引领，把防治荒漠化作为生态文明建设的重要内容，全面加强国际交流合作，http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm努力走出一条中国特色荒漠生态系统治理和民生改善相结合的13969768213道路。联合国秘书长古特雷斯向会议发来视13969768213频致辞。《联合国防治荒漠化公约》是联合国里约可持续发展大会框架下的三大环境公约之一，旨在推动国际社会在防治荒漠化和缓解干旱影响方面加强合作。13969768213缔约方大会是公约的最高决策机构，目前13969768213每两年举行一次，来自196个公约缔约方、20多个国际组织的正式代表约1400人出席本次会议http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm。　相关报道：习近平致《联合国防治荒漠化公约》第十三次缔约方大会高级别会议的贺信　防治荒漠化是人类面临的共同挑战，需要国际社会携手应对。http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm我们要弘扬尊重自然、保护自然的理念，坚持生态优13969768213先、预防为主，坚定信心，面向未来，制定广泛合作、目标明确的公约新战略框架，共同推进全球荒漠生态系统治理，让荒漠造福13969768213人类。http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm中国将坚定不移履行公约义务，按照本次缔约方大会确定的目标，http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm一如既往加强同各成员国和国际组织的交13969768213流合作，共同为建设一个更加美好13969768213的世界而努力！>>http://news.xinhuanet.com/politics/2017-09/11/c_1121644248.htm",
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
- (UITextView *)getCurentTextViewWhenShowMenuController{
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
        [self syncDispalyTableViewReload];
        [self didseleteTableViewCellWithIndexPath:indexPath];
    }];
}
#pragma mark -------- 监听键盘高度变化 --------
- (void)chatBoxViewController:(HQChatBoxViewController *)chatboxViewController
        didChangeChatBoxHeight:(CGFloat)height{
    self.chatBoxVC.view.top = self.view.bottom-height-64;
    self.tableView.height = HEIGHT_SCREEN - height - 64;
    [self syncDispalyTableViewReload];
    [self tableViewScrollToBottomWithAnimated:NO];
}
- (void)chatBoxInputStatusController:(HQChatBoxViewController *)chatboxViewController ChatBoxHeight:(CGFloat)height{
    self.chatBoxVC.view.top = self.view.bottom-height-64;
    self.tableView.height = HEIGHT_SCREEN - height - 64;
    [self tableViewScrollToBottomWithAnimated:NO];
    if (height != HEIGHT_TABBAR) {
    }
}
#pragma mark --------- 发送文本消息 ---------
- (void)chatBoxViewController:(HQChatBoxViewController *)chatboxViewController
               sendTextMessage:(NSString *)messageStr{
    ChatMessageModel *messageModel = [ChatMessageModel creatAnSnedMesssageWith:messageStr andReceiverId:self.listModel.chatListId andUserName:self.listModel.userName andUserPic:self.listModel.messageUser.userHeadImaeUrl];
    [self refershListModelWithMessageModel:messageModel];
//    ChatMessageModel *dateModel = [self checkTheLeastMessageTimeIsBeyondLongestTimeWithCurrentMessageTime:messageModel.messageTime];
//    if (dateModel) {
//        [self.dataArray addObject:dateModel];
//    }
    HQBaseCellLayout *lauout = [HQBaseCellLayout layoutWithMessageModel:messageModel];
    [self.dataArray addObject:lauout];
    [self syncDispalyTableViewReload];
    [self scrollToTableViewBottomWithAnimated:YES andAferDealy:0.05];
    [messageModel sendTextMessage:^{
        NSLog(@"status = %d",messageModel.messageStatus);
    }];
}
//- (void)addNewMessageModel:(ChatMessageModel *)messageModel andDateModel:(ChatMessageModel *)dateModel{
//    NSMutableArray *indexpaths = [NSMutableArray new];
//    if (dateModel) {
//        [indexpaths addObject:[NSIndexPath indexPathForRow:self.dataArray.count?(self.dataArray.count-1) : (self.dataArray.count) inSection:0]];
//        [indexpaths addObject:[NSIndexPath indexPathForRow:self.dataArray.count?(self.dataArray.count) : (self.dataArray.count + 1) inSection:0]];
//        [self.dataArray addObject:dateModel];
//         [self.dataArray addObject:messageModel];
//    }else{
//        [indexpaths addObject:[NSIndexPath indexPathForRow:self.dataArray.count?(self.dataArray.count-1) : (self.dataArray.count) inSection:0]];
//        [self.dataArray addObject:messageModel];
//    }
//    [self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView endUpdates];
//    [self scrollToTableViewBottomWithAnimated:YES andAferDealy:0.05];
//}
#pragma mark --------- 发送GIF -------
- (void)chatBoxViewController:(HQChatBoxViewController *)chatboxViewController sendGifMessage:(NSString *)gifFileName{
    ChatMessageModel *messageModel = [ChatMessageModel creatAnSendGifMessageWith:gifFileName andReceiveId:self.listModel.chatListId andUserName:self.listModel.userName andUserPic:self.listModel.messageUser.userHeadImaeUrl];
    [self refershListModelWithMessageModel:messageModel];
    ChatMessageModel *dateModel = [self checkTheLeastMessageTimeIsBeyondLongestTimeWithCurrentMessageTime:messageModel.messageTime];
    if (dateModel) {
        [self.dataArray addObject:dateModel];
    }
    [self.dataArray addObject:messageModel];
    [self syncDispalyTableViewReload];
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
    [self syncDispalyTableViewReload];
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
    [self syncDispalyTableViewReload];
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
        [self syncDispalyTableViewReload];
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
    [self syncDispalyTableViewReload];
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
////删除消息时检查是否有时间消息
- (void)checkCurrnetMessageIsHasDateMessageWithIndexPath:(NSIndexPath *)indexPath andComplite:(void (^)(ChatMessageModel *msgModel,NSIndexPath *indexPath))complite{
    if (indexPath.row == 0 || indexPath == nil) {
        if (complite) complite(nil,nil);
        return;
    }
    if (indexPath.row > 0) {
        ChatMessageModel *dateModel = self.dataArray[indexPath.row-1];
        if (dateModel.messageType == 99) {
            if (complite) complite(dateModel,[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]);
            return;
        }
    }
    if (complite) complite(nil,nil);
}
/////刷新listModel
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
- (HQChatTableView *)tableView{
    if (nil == _tableView) {
        _tableView = [[HQChatTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _tableView.scrollsToTop = NO;
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






