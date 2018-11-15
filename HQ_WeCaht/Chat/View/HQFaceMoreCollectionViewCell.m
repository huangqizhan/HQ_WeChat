//
//  HQFaceMoreCollectionViewCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/6.
//  Copyright © 2017年 黄麒展  QQ 757618403. All rights reserved.
//

#import "HQFaceMoreCollectionViewCell.h"





@interface HQFaceMoreCollectionViewCell ()



@end


@implementation HQFaceMoreCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _pageView = [[HQFaceMorePageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_pageView];
    }
    return self;
}

- (void)setMoreFaceArray:(NSArray *)moreFaceArray{
    _moreFaceArray = moreFaceArray;
    _pageView.moreFaceArray = _moreFaceArray;
}
@end
