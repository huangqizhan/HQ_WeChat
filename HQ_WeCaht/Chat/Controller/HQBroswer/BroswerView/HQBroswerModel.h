//
//  HQBroswerModel.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/4/12.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HQBroswerModel : NSObject

@property (nonatomic,strong) UIImage *tempImage;
@property (nonatomic,strong) UIImage *origineImage;
@property (nonatomic,copy) NSString *fileName;
@property (nonatomic,copy) NSString *localPath;
@property (nonatomic,copy) NSString *urlString;
@property (nonatomic,assign) NSUInteger origineIndex;
@property (nonatomic,assign) NSInteger speakerId;

@end
