//
//  HQSearchBar.m
//  ChatListSearchDemo
//
//  Created by GoodSrc on 2017/6/20.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import "HQSearchBar.h"



#define kLLTextColor_green [UIColor colorWithRed:29/255.0 green:185/255.0 blue:14/255.0 alpha:1]

#define BAR_TINT_COLOR [UIColor colorWithRed:240/255.0 green:239/255.0 blue:245/255.0 alpha:1]

#define SEARCH_TEXT_FIELD_HEIGHT 28



#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width


// icon宽度
static CGFloat const searchIconW = 20.0;
// icon与placeholder间距
static CGFloat const iconSpacing = 10.0;
// 占位文字的字体大小
static CGFloat const placeHolderFont = 15.0;



@interface HQSearchBar ()
// placeholder 和icon 与间隙的整体宽度
@property (nonatomic, assign) CGFloat placeholderWidth;

@end



@implementation HQSearchBar
+ (void)initialize {
    
    if (self == [HQSearchBar class]) {
        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[HQSearchBar class]]] setTintColor:kLLTextColor_green];
        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[HQSearchBar class]]] setTitle:@"取消"];
    }
}

-(void) layoutSubviews{
    [super layoutSubviews];
    UITextField *searchTextField = nil;
    // 经测试, 需要设置barTintColor后, 才能拿到UISearchBarTextField对象
    self.barTintColor = [UIColor whiteColor];
    searchTextField = [self searchTextField];
    CGRect newFrame = searchTextField.frame;
    newFrame.origin.y=7.5;
    newFrame.size.height = 30;
    searchTextField.frame = newFrame;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    NSAttributedString *attri = [[NSAttributedString alloc] initWithString:@"搜索" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15 ], NSParagraphStyleAttributeName:style}];
    searchTextField.textAlignment = NSTextAlignmentCenter;
    searchTextField.attributedPlaceholder = attri;
    if (@available(iOS 11.0, *)) {
        // 先默认居中placeholder
        if (!_isActive) {
            [self setPositionAdjustment:UIOffsetMake((searchTextField.frame.size.width-self.placeholderWidth)/2, 0) forSearchBarIcon:UISearchBarIconSearch];
        }
    }
}

// 计算placeholder、icon、icon和placeholder间距的总宽度
- (CGFloat)placeholderWidth {
    if (!_placeholderWidth) {
        CGSize size = [self.placeholder boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:placeHolderFont]} context:nil].size;
        _placeholderWidth = size.width + iconSpacing + searchIconW;
    }
    return _placeholderWidth;
}
+ (instancetype)defaultSearchBarWithIsActive:(BOOL)isActive{
    return [self defaultSearchBarWithFrame:CGRectMake(0,0, SCREEN_WIDTH, [self defaultSearchBarHeight]) andActive:isActive];
}

+ (instancetype)defaultSearchBarWithFrame:(CGRect)frame andActive:(BOOL)isActive{
    HQSearchBar *searchBar = [[HQSearchBar alloc] initWithFrame:frame];
    searchBar.isActive = isActive;
    [searchBar setImage:[UIImage imageNamed:@"VoiceSearchStartBtn"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    searchBar.showsCancelButton = NO;
    searchBar.barStyle = UISearchBarStyleMinimal;
    searchBar.backgroundColor = BAR_TINT_COLOR;
    
    searchBar.barTintColor = BAR_TINT_COLOR;
    searchBar.backgroundImage = [HQSearchBar imageWithColor:[UIColor clearColor]];
    searchBar.tintColor = kLLTextColor_green;
    
    searchBar.keyboardType = UIKeyboardTypeDefault;
    searchBar.returnKeyType = UIReturnKeySearch;
    searchBar.enablesReturnKeyAutomatically = YES;
    
    UITextField *searchTextField = [searchBar searchTextField];
    searchTextField.backgroundColor = [UIColor whiteColor];
    searchTextField.textColor = [UIColor blackColor];
    
    return searchBar;
}
- (CGFloat)endEdiateWidth{
    return  ( [self searchTextField].frame.size.width-self.placeholderWidth);
}
+ (NSInteger)defaultSearchBarHeight {
    return SEARCH_TEXT_FIELD_HEIGHT + 16;
}

- (UITextField *)searchTextField {
    UITextField *searchTextField = nil;
    for (UIView* subview in self.subviews[0].subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            searchTextField = (UITextField*)subview;
            break;
        }
    }
    NSAssert(searchTextField, @"UISearchBar结构改变");
    
    return searchTextField;
}

- (UIButton *)searchCancelButton {
    UIButton *btn;
    
    NSArray<UIView *> *subviews = self.subviews[0].subviews;
    for(UIView *view in subviews) {
        if([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            btn = (UIButton *)view;
            break;
        }
    }
    
    return btn;
}

- (void)resignFirstResponderWithCancelButtonRemainEnabled {
    [self resignFirstResponder];
    
    UIButton *cancelButton = [self searchCancelButton];
    [cancelButton setEnabled:YES];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated {
    [super setShowsCancelButton:showsCancelButton animated:animated];
    
    [self configCancelButton];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton {
    [self setShowsCancelButton:showsCancelButton animated:NO];
}

- (void)configCancelButton {
    UIButton *cancelButton = [self searchCancelButton];
    if (cancelButton) {
        UIColor *color = [cancelButton titleColorForState:UIControlStateNormal];
        [cancelButton setTitleColor:color forState:UIControlStateDisabled];
    }
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1, 1)];
}
@end
