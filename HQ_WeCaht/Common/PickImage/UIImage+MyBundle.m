//
//  UIImage+MyBundle.m
//  HQPickerImage
//
//  Created by GoodSrc on 2017/3/14.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import "UIImage+MyBundle.h"

@implementation UIImage (MyBundle)

+ (UIImage *)imageNamedFromMyBundle:(NSString *)name{
    return  [UIImage imageNamed:[@"HQPickerSourse.bundle" stringByAppendingPathComponent:name]];
}

@end
