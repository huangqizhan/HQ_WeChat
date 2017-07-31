//
//  HQFacePageCollectionCell.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/3/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQFacePageCollectionCell.h"



@interface HQFacePageCollectionCell ()

@end


@implementation HQFacePageCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _pageView = [[HQFacePageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_pageView];
    }
    return self;
}


- (void)setEmojArray:(NSArray *)emojArray{
    _emojArray = emojArray;
    _pageView.emojArray = _emojArray;
}

@end



@interface HQGifPageCollectionCell ()


@end

@implementation HQGifPageCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = IColor(237, 237, 246);
        _pageView = [[HQGifPageView alloc] initWithFrame:CGRectMake(10, 10, self.width-20, self.height-20)];
        [self.contentView addSubview:_pageView];
    }
    return self;
}


- (void)setEmojArray:(NSArray *)emojArray{
    _emojArray = emojArray;
    _pageView.emojArray = _emojArray;
}



@end
