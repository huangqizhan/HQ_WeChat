//
//  HQChatEdiateMoreView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQChatEdiateMoreView.h"

@interface HQChatEdiateMoreView ()

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *collectionButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@end

@implementation HQChatEdiateMoreView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.width = App_Frame_Width;
}

- (IBAction)moreButtonAction:(UIButton *)sender {
    [self moreViewDidClickWith:@"更多"];
}
- (IBAction)deleteButtonAction:(id)sender {
    [self moreViewDidClickWith:@"删除"];
}
- (IBAction)collectionButtonAction:(id)sender {
    [self moreViewDidClickWith:@"收藏"];
}
- (IBAction)shareButtonAction:(id)sender {
    [self moreViewDidClickWith:@"分享"];
}

- (void)moreViewDidClickWith:(NSString *)titleString{
    if (_EdiateMoreViewClickCallBack) {
        _EdiateMoreViewClickCallBack(titleString);
    }
}
- (void)setEdiateViewActiveStatusWith:(NSInteger)seletedNum{
    if (seletedNum <= 0) {
        [self.moreButton setImage:[UIImage imageNamed:@"Session_Multi_More_HL"] forState:UIControlStateNormal];
        [self.deleteButton setImage:[UIImage imageNamed:@"Session_Multi_Delete_HL"] forState:UIControlStateNormal];
        [self.collectionButton setImage:[UIImage imageNamed:@"Session_Multi_Fav_HL"] forState:UIControlStateNormal];
        [self.shareButton setImage:[UIImage imageNamed:@"Session_Multi_Forward_HL"] forState:UIControlStateNormal];
    }else{
        [self.moreButton setImage:[UIImage imageNamed:@"Session_Multi_More"] forState:UIControlStateNormal];
        [self.deleteButton setImage:[UIImage imageNamed:@"Session_Multi_Delete"] forState:UIControlStateNormal];
        [self.collectionButton setImage:[UIImage imageNamed:@"Session_Multi_Fav"] forState:UIControlStateNormal];
        [self.shareButton setImage:[UIImage imageNamed:@"Session_Multi_Forward"] forState:UIControlStateNormal];
    }
}

@end
