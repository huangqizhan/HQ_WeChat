//
//  HQChatMineBaseCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChatMineBaseCell.h"
#import "HQChatTextView.h"
#import "HQActionSheet.h"
#import "UIApplication+HQExtern.h"



@interface HQChatMineBaseCell (){
    
//    UIView *_longPressView;
}

@property (nonatomic) NSMutableArray <UIMenuItem *> *menuItems;

@end

@implementation HQChatMineBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognizer:)];
//        longRecognizer.minimumPressDuration = 0.6;
//        longRecognizer.delegate=self;
//        longRecognizer.cancelsTouchesInView=YES;
//        ////可移动范围
//        longRecognizer.allowableMovement = 1000;
//        [self.contentView addGestureRecognizer:longRecognizer];
        
    }
    return self;
}
- (void)setupUI {
    [self.contentView addSubview:self.headImageView];
    [self.contentView addSubview:self.activityView];
    [self.contentView addSubview:self.selectControl];
}
//- (void)setMessageModel:(ChatMessageModel *)messageModel{
//    _messageModel = messageModel;
//    self.selectControl.image = [UIImage imageNamed:_messageModel.isSeleted ? @"CellBlueSelected": @"CellNotSelected"];
//    switch (_messageModel.deliverStatus) { // 发送状态
//        case HQMessageDeliveryState_Delivering:{
//            [self.activityView setHidden:NO];
//            [self.activityView startAnimating];
//        }
//            break;
//        case HQMessageDeliveryState_Delivered:{
//            [self.activityView stopAnimating];
//            [self.activityView setHidden:YES];
//
//        }
//            break;
//        case HQMessageDeliveryState_Failure:{
//            [self.activityView stopAnimating];
//            [self.activityView setHidden:YES];
//        }
//            break;
//        default:
//            break;
//    }
//}

- (void)setLayout:(HQBaseCellLayout *)layout{
    _layout = layout;
}
- (void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
}
#pragma mark -------- 编辑 ------
- (void)setIsEdiating:(BOOL)isEdiating{
    if (isEdiating) {
        self.selectControl.hidden = NO;
    }else{
        self.selectControl.hidden = YES;
    }
    [super setIsEdiating:isEdiating];
}
- (void)reSetMessageCellEdiatedStatusIsEdiate:(BOOL)isEdiate{
    [super reSetMessageCellEdiatedStatusIsEdiate:isEdiate];
    [super setIsEdiating:isEdiate];
}
- (void)didSeleteCellWhenIsEdiating:(BOOL)isSeleted{
    self.messageModel.isSeleted = self.isSeleted = isSeleted;
    self.selectControl.image = [UIImage imageNamed:isSeleted ? @"CellBlueSelected": @"CellNotSelected"];
}
#pragma mark ----- 长按  ----
//- (void)longPressRecognizer:(UILongPressGestureRecognizer *)sender{
//    if (self.isEdiating) {
//        return;
//    }
//    if (sender.state == UIGestureRecognizerStateBegan) {
//        [self contentLongPressedBeganInView:_longPressView];
//    }else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled){
//        [self contentLongPressedEndedInView:_longPressView];
//    }
//}
//- (BOOL)canBecomeFirstResponder{
//    if (self.isEdiating) {
//        return NO;
//    }
//    return YES;
//}

//-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
//    if (self.isEdiating) {
//        return NO;
//    }
//    for (NSInteger i = 0; i < self.menuItemActionNames.count; i++) {
//        if (action == NSSelectorFromString(self.menuItemActionNames[i])) {
//            return YES;
//        }
//    }
//    return NO;//隐藏系统默认的菜单项
//}

#pragma mark ------- UIGestureDelegate -----
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if (self.isEdiating) {
//        return NO;
//    }
//    if (self.hidden || !self.userInteractionEnabled || self.alpha < 0.01) {
//        return NO;
//    }
//    CGPoint point;
//    BOOL isTapGesture = [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];
//    BOOL isMenuControlShow = [UIMenuController sharedMenuController].menuVisible;
//    if (isTapGesture && isMenuControlShow) {
//        [self performSelectorOnMainThread:@selector(hideMenuController) withObject:nil waitUntilDone:NO];
//    }
//    ////获取手势事件响应的视图
//    UIView *hitView;
//    point = [touch locationInView:self.contentView];
//    if (isTapGesture) {
//
//    }else{
//        _longPressView = hitView = [self hitTestForlongPressedGestureRecognizer:point];
//    }
//    if (isTapGesture) {
//        if (hitView) {
//            __weak typeof(self) weakSelf = self;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [weakSelf delayCallBack:touch];
//            });
//            return YES;
//        }else{
//            return isMenuControlShow;
//        }
//    }else{
//        return hitView != nil;
//    }
//    return YES;
//}
//- (void)showMenuControllerInRect:(CGRect )rect inView:(UIView *)contentView{
//    HQChatTextView *textView;
//    if (self.delegate && [self.delegate respondsToSelector:@selector(getCurentTextViewWhenShowMenuController)]) {
//        textView = [self.delegate getCurentTextViewWhenShowMenuController];
//    }
//    UIMenuController *menu = [UIMenuController sharedMenuController];
//    [menu setMenuItems:self.menuItems];
//    [menu setTargetRect:rect inView:contentView];
//    menu.arrowDirection = UIMenuControllerArrowDefault;
//    if (textView == nil) {
//        [self becomeFirstResponder];
//    }else{
//        textView.textCell = self;
//    }
//    [menu setMenuVisible:YES animated:YES];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHideCallback:) name:UIMenuControllerDidHideMenuNotification object:menu];
//}
//- (void)hideMenuController {
//    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
//}

- (void)menuDidHideCallback:(NSNotification *)notify {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    
    ((UIMenuController *)notify.object).menuItems = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(MenuViewControllerDidHidden)]) {
        [self menuControllerDidHidden];
        [self.delegate MenuViewControllerDidHidden];
    }
}
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    if (self.isEdiating) {
//        return self.contentView;
//    }
//    if (self.hidden || !self.userInteractionEnabled || self.alpha <= 0.01)
//        return nil;
//    if ([self.contentView pointInside:[self convertPoint:point toView:self.contentView] withEvent:event]) {
//        return self.contentView;
//    }
//    return nil;
//}

#pragma mark - Getter and Setter
- (ImageControll *)headImageView {
    if (_headImageView == nil) {
        _headImageView = [[ImageControll alloc] initWithFrame:CGRectMake(App_Frame_Width-10-CHATHEADIMAGEWIDTH, 10, CHATHEADIMAGEWIDTH, CHATHEADIMAGEWIDTH)];
        _headImageView.backgroundColor = [UIColor blackColor];
        _headImageView.image = [UIImage imageNamed:@"hqz"];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.clipsToBounds = YES;
    }
    return _headImageView;
}
- (UIImageView *)selectControl {
    if (!_selectControl) {
        _selectControl = [[UIImageView alloc] initWithFrame:CGRectMake(-40, 0, 40, 40)];
        _selectControl.contentMode = UIViewContentModeCenter;
        _selectControl.image = [UIImage imageNamed:@"CellNotSelected"];
        _selectControl.hidden = YES;
        [self.contentView addSubview:_selectControl];
    }
    
    return _selectControl;
}
//- (NSArray<UIMenuItem *> *)menuItems{
//    if (_menuItems == nil) {
//        self.menuItems = [NSMutableArray arrayWithCapacity:self.menuItemNames.count];
//        for (NSInteger i =0; i < self.menuItemNames.count; i++) {
//            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:self.menuItemNames[i] action:NSSelectorFromString(self.menuItemActionNames[i])];
//            [self.menuItems addObject:item];
//        }
//    }
//    return _menuItems;
//}
- (UIActivityIndicatorView *)activityView {
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityView;
}

///tap 手势
- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)aPoint{
    return self.contentView;
}
///长按手势
- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)aPoint{
    return self.contentView;
}
- (void)menuControllerDidHidden{
}
- (void)delayCallBack:(UITouch *)touch{
}
- (void)contentLongPressedBeganInView:(UIView *)view {
}
- (void)contentLongPressedEndedInView:(UIView *)view {
}
- (void)copyAction:(id)sender{
    [ApplicationHelper copyToPasteboard:self.layout.modle.contentString];
}
- (void)transforAction:(id)sender{

}
- (void)favoriteAction:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(HQChatMineBaseCell:MenuActionTitle:andIndexPath:andChatModel:)]) {
        [self.delegate HQChatMineBaseCell:self MenuActionTitle:@"收藏" andIndexPath:self.indexPath andChatModel:self.messageModel];
    }
}
- (void)translateAction:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(HQChatMineBaseCell:MenuActionTitle:andIndexPath:andChatModel:)]) {
        [self.delegate HQChatMineBaseCell:self MenuActionTitle:@"翻译" andIndexPath:self.indexPath andChatModel:self.messageModel];
    }
}
- (void)deleteAction:(id)sender{
    HQActionSheet *actionSheet = [[HQActionSheet alloc] initWithTitle:@"是否删除该条消息？"];
    WEAK_SELF;
    HQActionSheetAction *action = [HQActionSheetAction actionWithTitle:@"确定" handler:^(HQActionSheetAction *action) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(HQChatMineBaseCell:MenuActionTitle:andIndexPath:andChatModel:)]) {
            [weakSelf.delegate HQChatMineBaseCell:self MenuActionTitle:@"删除" andIndexPath:self.indexPath andChatModel:self.messageModel];
        }
        
    } style:HQActionStyleDestructive];
    [actionSheet addAction:action];
    [actionSheet showInWindow:[UIApplication popOverWindow]];

}
- (void)moreAction:(id)sender{
    [self didSeleteCellWhenIsEdiating:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(HQChatMineBaseCell:MenuActionTitle:andIndexPath:andChatModel:)]) {
        [self.delegate HQChatMineBaseCell:self MenuActionTitle:@"更多" andIndexPath:self.indexPath andChatModel:self.messageModel];
    }
}
- (void)addToEmojiAction:(id)sender{
}
- (void)forwardAction:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(HQChatMineBaseCell:MenuActionTitle:andIndexPath:andChatModel:)]) {
        [self.delegate HQChatMineBaseCell:self MenuActionTitle:@"转发" andIndexPath:self.indexPath andChatModel:self.messageModel];
    }
}
- (void)showAlbumAction:(id)sender{
}
- (void)playAction:(id)sender{
}
- (void)translateToWordsAction:(id)sender{
}
//- (void)willDisplayCell{
//    
//}
/////cell将要结束呈现
//- (void)didEndDisplayingCell{
//    
//}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
