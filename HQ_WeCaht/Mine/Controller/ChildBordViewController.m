//
//  ChildBordViewController.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/9/19.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "ChildBordViewController.h"

@interface ChildBordViewController ()<BordViewControllerDelegate>

@property (nonatomic,strong) BordViewController *childVC;

@end

@implementation ChildBordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addChildViewController:self.childVC];
    [self.view addSubview:self.childVC.view];
}
- (void) BordViewController :(BordViewController *)controller andHeight:(CGFloat )height{
    self.childVC.view.top = APP_Frame_Height-64 - height -50;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BordViewController *)childVC{
    if (_childVC == nil) {
        _childVC = [[BordViewController alloc] init];
        [_childVC.view setFrame:CGRectMake(0, APP_Frame_Height-64-50, App_Frame_Width, APP_Frame_Height)];
        _childVC.delegate = self;
    }
    return _childVC;
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

@property (nonatomic,strong) UITextView *textView;

@end

@implementation BordViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.textView];
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


- (UITextView *)textView{
    if (_textView == nil) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 10, App_Frame_Width-40, 40)];
        _textView.backgroundColor  = [UIColor redColor];
//        [_textView becomeFirstResponder];
    }
    return _textView;
}
@end
