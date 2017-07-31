//
//  HQActionSheet.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/26.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQActionSheet.h"
#import "UIImage+Extension.h"
#import "UIApplication+HQExtern.h"

typedef NS_ENUM(NSInteger, HQActionItemType) {
    HQActionItemTypeTitle,
    HQActionItemTypeAction,
    HQActionItemTypeCancel
};
static UIView *actionSheetContainer;

#define TITLE_FONT_SIZE 13
#define TITLE_FONT_COLOR [UIColor lightGrayColor]
#define TITLE_BAR_HEIGHT 65

#define ACTION_FONT_SIZE 17
#define ACTION_FONT_DEFAULT_COLOR [UIColor blackColor]
#define ACTION_FONT_DESTRUCTIVE_COLOR [UIColor redColor];
#define ACTION_BAR_HEIGHT 55

#define CANCEL_FONT_SIZE 17
#define CANCEL_FONT_COLOR [UIColor blackColor]
#define CANCEL_BAR_HEIGHT 55

#define CANCEL_BAR_GAP 7
#define kLLBackgroundColor_lightGray [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1]


 HQActionSheetAction *LL_ActionSheetSeperator = nil;



@implementation HQActionSheetAction
+ (void)load {
    if (!LL_ActionSheetSeperator)
        LL_ActionSheetSeperator = [[HQActionSheetAction alloc] init];
}

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(HQActionSheetAction *action))handler {
    return [self actionWithTitle:title handler:handler style:HQActionStyleDefault];
}

+ (instancetype)actionWithTitle:(NSString *)title handler:(ACTION_BLOCK)handler style:(HQActionStyle)style {
    
    HQActionSheetAction * action = [[HQActionSheetAction alloc] init];
    action.title = title;
    action.handler = handler;
    action.style = style;
    
    return action;
}


@end




@interface HQActionSheet ()
@property (nonatomic, copy) NSString *title;

@property (nonatomic) UIView *contentView;

@property (nonatomic) NSMutableArray<HQActionSheetAction *> *actions;


@end



@implementation HQActionSheet{
    CGRect _windowBounds;
}

- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.title = title;
        self.backgroundColor = [UIColor clearColor];
        self.actions = [NSMutableArray array];
        
        self.contentView = [[UIView alloc] init];
        self.contentView.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1];
        [self addSubview:_contentView];
        
        [self addTapGestureRecognizer:@selector(tapHandler:)];
    }
    
    return self;
}
- (void)addAction:(HQActionSheetAction *)action {
    [self.actions addObject:action];
}

- (void)addActions:(NSArray<HQActionSheetAction *> *)actions {
    [self.actions addObjectsFromArray:actions];
}
- (void)showInWindow:(UIWindow *)window {
    if (!actionSheetContainer) {
        actionSheetContainer = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        actionSheetContainer.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.7f];
    }
    
    if (!actionSheetContainer.superview){
        if (!window || window == [UIApplication popOverWindow]) {
            [UIApplication addViewToPopOverWindow:actionSheetContainer];
        }else {
            [window addSubview:actionSheetContainer];
        }
    }
    
    _windowBounds = [UIScreen mainScreen].bounds;
    actionSheetContainer.frame = _windowBounds;
    
    [self setupViews];
    [actionSheetContainer addSubview:self];
    
    self.contentView.top = CGRectGetHeight(_windowBounds);
    if (actionSheetContainer.subviews.count == 1) {
        actionSheetContainer.alpha = 0;
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.contentView.bottom = CGRectGetHeight(_windowBounds);
                         actionSheetContainer.alpha = 1;
                     }
                     completion:nil];
}
- (void)hideInWindow:(UIWindow *)window {
    [self close];
}

- (void)setupViews {
    CGFloat _y = 0;
    if (self.title && self.title.length > 0) {
        UIView *titleView = [self createItemWithType:HQActionItemTypeTitle
                                                data:nil];
        [self.contentView addSubview:titleView];
        _y = CGRectGetMaxY(titleView.frame);
    }
    
    for (HQActionSheetAction *action in self.actions) {
        if (action == LL_ActionSheetSeperator) {
            _y += CANCEL_BAR_GAP;
        }else {
            UIView *actionButton = [self createItemWithType:HQActionItemTypeAction
                                                       data:action];
            [self.contentView addSubview:actionButton];
            actionButton.top = _y;
            _y += CGRectGetHeight(actionButton.frame);
        }
    }
    
    UIView *cancelButton = [self createItemWithType:HQActionItemTypeCancel
                                               data:nil];
    [self.contentView addSubview:cancelButton];
    _y += CANCEL_BAR_GAP;
    cancelButton.top = _y;
    _y += CGRectGetHeight(cancelButton.frame);
    
    self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(_windowBounds), _y);
}
- (CGFloat)barHeightForType:(HQActionItemType)type {
    switch(type) {
        case HQActionItemTypeTitle:
            return TITLE_BAR_HEIGHT;
        case HQActionItemTypeAction:
            return ACTION_BAR_HEIGHT;
        case HQActionItemTypeCancel:
            return CANCEL_BAR_HEIGHT;
    }
}

- (UIView *)createItemWithType:(HQActionItemType)type data:(HQActionSheetAction *)data {
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(_windowBounds), [self barHeightForType:type]);
    
    if (type == HQActionItemTypeTitle) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.textColor = TITLE_FONT_COLOR;
        titleLabel.font = [UIFont systemFontOfSize:TITLE_FONT_SIZE];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = self.title;
        return titleLabel;
    }else {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setBackgroundImage: [UIImage gxz_imageWithColor:kLLBackgroundColor_lightGray] forState:UIControlStateHighlighted];
        
        
        if (type == HQActionItemTypeAction) {
            [button setTitle:data.title forState:UIControlStateNormal];
            button.tag = [self.actions indexOfObject:data];
            [button addTarget:self action:@selector(tapAction:)
             forControlEvents:UIControlEventTouchUpInside];
            
            UIColor *buttonTitleColor = data.style == HQActionStyleDefault ? ACTION_FONT_DEFAULT_COLOR : ACTION_FONT_DESTRUCTIVE_COLOR;
            [button setTitleColor:buttonTitleColor forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:ACTION_FONT_SIZE];
            
            CALayer *line = [CALayer layer];
            line.backgroundColor = kLLBackgroundColor_lightGray.CGColor;
            line.frame = CGRectMake(0, 0, App_Frame_Width, 1/[UIScreen mainScreen].scale);
            [button.layer addSublayer:line];
        }else if (type == HQActionItemTypeCancel) {
            [button setTitle:@"取消" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(tapCancel:)
             forControlEvents:UIControlEventTouchUpInside];
            [button setTitleColor:CANCEL_FONT_COLOR forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:CANCEL_FONT_SIZE];
        }
        
        return button;
    }
    
    return nil;
}

- (UITapGestureRecognizer *)addTapGestureRecognizer:(SEL)action {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    
    [self addGestureRecognizer:tap];
    
    return tap;
}
- (void)tapAction:(UIButton *)sender {
    HQActionSheetAction *action = self.actions[sender.tag];
    if (action.handler) {
        action.handler(action);
        [self close];
    }
}
- (void)tapHandler:(id)sender {
    [self close];
}
- (void)tapCancel:(id)sender {
    [self close];
}
- (void)close {
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.top = CGRectGetHeight(_windowBounds);
        
        if (actionSheetContainer.subviews.count == 1){
            actionSheetContainer.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (actionSheetContainer.subviews.count == 0){
            if (actionSheetContainer.window == [UIApplication popOverWindow])
                [UIApplication removeViewFromPopOverWindow:actionSheetContainer];
            else {
                [actionSheetContainer removeFromSuperview];
            }
        }
    }];
    
}

@end
