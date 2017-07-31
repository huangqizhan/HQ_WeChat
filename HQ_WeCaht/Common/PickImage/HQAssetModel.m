//
//  HQAssetModel.m
//  HQPickerImage
//
//  Created by GoodSrc on 2017/3/16.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import "HQAssetModel.h"

@implementation HQAssetModel

+ (instancetype)modelWithAsset:(id)asset type:(HQAssetModelMediaType)type{
    HQAssetModel *model = [[HQAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(id)asset type:(HQAssetModelMediaType)type timeLength:(NSString *)timeLength {
    HQAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}


@end








@implementation HQAlbumModel



@end
