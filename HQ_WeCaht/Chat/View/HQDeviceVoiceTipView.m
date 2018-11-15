//
//  HQDeviceVoiceTipView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/6.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQDeviceVoiceTipView.h"

@implementation HQDeviceVoiceTipView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.width = App_Frame_Width;
}

- (void)removeFromSuperviewWithAnimaton{
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}
- (IBAction)reoveButtonAction:(id)sender {
    [self removeFromSuperviewWithAnimaton];
}


@end
