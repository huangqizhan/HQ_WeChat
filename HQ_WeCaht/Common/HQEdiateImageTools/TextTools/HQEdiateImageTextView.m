//
//  HQEdiateImageTextView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/18.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEdiateImageTextView.h"
#import "HQTextEdiateImageTools.h"
#import "HQEdiateImageController.h"
#import "UIImage+Gallop.h"





@interface HQEdiateImageTextView ()

@property (nonatomic,copy) NSAttributedString *attrubuteString;
@property (nonatomic) UIImageView *contentImageView;

@end

@implementation HQEdiateImageTextView


- (instancetype)initWithTextTool:(HQTextEdiateImageTools *)textTool andAttrubuteString:(NSAttributedString *)attrubute{
    _textTool = textTool;
    _attrubuteString = attrubute;
    CGRect frame = [HQEdiateImageTextView caculateContentStringWithAttrubuteString:attrubute andTool:_textTool];
    self = [super initWithFrame:frame];
    if (self) {
        [self createContentImageView];
    }
     return self;
}
- (void)createContentImageView{
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.width-10, self.height - 10)];
    tempLabel.numberOfLines = 0;
    tempLabel.attributedText = self.attrubuteString;
    UIImage *image = [UIImage lw_imageFromView:tempLabel];
    _contentImageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:_contentImageView];
}



+  (CGRect)caculateContentStringWithAttrubuteString:(NSAttributedString *)attrubuteStr andTool:(HQTextEdiateImageTools *)textTool{
    if (attrubuteStr == nil) {
        attrubuteStr = [[NSAttributedString alloc] initWithString:@""];
    }
    CGRect frame = [attrubuteStr boundingRectWithSize:CGSizeMake(textTool.imageEdiateController.ediateImageView.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    frame.size.width += 10;
    frame.size.height += 10;
    frame.origin.x = (textTool.imageEdiateController.ediateImageView.width-frame.size.width)/2.0;
    frame.origin.y = (textTool.imageEdiateController.ediateImageView.height -frame.size.height)/2.0;
    return frame;
}


@end




