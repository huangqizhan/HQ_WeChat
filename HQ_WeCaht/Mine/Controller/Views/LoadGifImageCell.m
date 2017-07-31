//
//  LoadGifImageCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/5/5.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "LoadGifImageCell.h"
#import "UIImageView+YYWebImage.h"
#import "UIImageView+YYWebImage.h"

@interface LoadGifImageCell ()



@end

@implementation LoadGifImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.webImageView];
    }
    return self;
}
- (void)setUrlString:(NSString *)urlString{
    _urlString = urlString;
    [self.webImageView yy_setImageWithURL:[NSURL URLWithString:urlString] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionShowNetworkActivity | YYWebImageOptionSetImageWithFadeAnimation];
}
- (YYAnimatedImageView *)webImageView{
    if (_webImageView == nil) {
        _webImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, ceil((App_Frame_Width) * 3.0 / 4.0))];
    }
    return _webImageView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
