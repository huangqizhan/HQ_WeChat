//
//  HQSearchBar.h
//  ChatListSearchDemo
//
//  Created by GoodSrc on 2017/6/20.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQSearchBar : UISearchBar

@property (nonatomic,assign) BOOL isActive;

@property (nonatomic,assign) CGFloat endEdiateWidth;

+ (NSInteger)defaultSearchBarHeight;

+ (instancetype)defaultSearchBarWithIsActive:(BOOL)isActive;

- (UITextField *)searchTextField;

- (UIButton *)searchCancelButton;

- (void)resignFirstResponderWithCancelButtonRemainEnabled;

- (void)configCancelButton;



@end
