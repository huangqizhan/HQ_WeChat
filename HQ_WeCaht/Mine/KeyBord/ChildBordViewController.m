//
//  ChildBordViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/19.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "ChildBordViewController.h"
#import "HQChatBoxViewController.h"

@interface ChildBordViewController ()<ICChatBoxViewControllerDelegate>

@property (nonatomic,strong) HQChatBoxViewController *childVC;
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation ChildBordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self addChildViewController:self.childVC];
    [self.view addSubview:self.childVC.view];
}

#pragma mark ------ UITableViewDelgate ---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    return cell;
}
#pragma mark -------- 监听键盘高度变化 --------
- (void)chatBoxViewController:(HQChatBoxViewController *)chatboxViewController
       didChangeChatBoxHeight:(CGFloat)height{
    self.childVC.view.top = self.view.bottom-height-64;
//    self.tableView.height = HEIGHT_SCREEN - height - 64;
    if (height != HEIGHT_TABBAR) {
//        [self tableViewScrollToBottomWithAnimated:NO];
    }
//    [self.tableView reloadData];
}
- (void)chatBoxInputStatusController:(HQChatBoxViewController *)chatboxViewController ChatBoxHeight:(CGFloat)height{
    self.childVC.view.top = self.view.bottom-height-64;
//    self.tableView.height = HEIGHT_SCREEN - height - 64;
    if (height != HEIGHT_TABBAR) {
//        [self tableViewScrollToBottomWithAnimated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (HQChatBoxViewController *)childVC{
    if (_childVC == nil) {
        _childVC = [[HQChatBoxViewController alloc] init];
        [_childVC.view setFrame:CGRectMake(0, APP_Frame_Height-64-50, App_Frame_Width, APP_Frame_Height)];
        _childVC.delegate = self;
    }
    return _childVC;
}
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height-64-50) style:UITableViewStyleGrouped];
        _tableView.delegate  = self;
        _tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end



@interface BordViewController ()



@end

@implementation BordViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

}

- (void)keyboardWillHide:(NSNotification *)notification{
//    self.keyboardFrame = CGRectZero;
//    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
//        //        [_delegate chatBoxViewController:self didChangeChatBoxHeight:HEIGHT_TABBAR];
//    }
//    _chatBox.boxStatus = HQChatBoxStatusNothing;
}
- (void)keyboardFrameWillChange:(NSNotification *)notification{
        
        NSDictionary *userInfo = [notification userInfo];
        NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGSize keybordSize = [value CGRectValue].size;
        NSValue *keyAnimationTime  =[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval keyBordTimerval;
        [keyAnimationTime getValue:&keyBordTimerval];
        [UIView animateWithDuration:keyBordTimerval animations:^{
            [_delegate BordViewController:self andHeight:keybordSize.height];
        }completion:^(BOOL finished) {
        }];
    
}


@end
