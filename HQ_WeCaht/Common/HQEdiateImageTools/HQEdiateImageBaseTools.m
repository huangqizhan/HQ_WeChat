//
//  HQEdiateImageBaseTools.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/25.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEdiateImageBaseTools.h"

@implementation HQEdiateImageBaseTools

- (instancetype)initWithEdiateController:(HQEdiateImageController *)ediateController andEdiateType:(HQEdiateImageType )type{
    self = [super init];
    if (self) {
        self.ediateType =  type;
        self.imageEdiateController = ediateController;
        [self setUpCurrentEdiateStatus];
    }
    return self;
}

- (void)setUpCurrentEdiateStatus{
    
}

- (void)clearCurrentEdiateStatus{
    
}

@end
