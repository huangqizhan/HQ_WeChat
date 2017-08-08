//
//  HQEdiateToolInfo.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/8/1.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEdiateToolInfo.h"



@interface HQEdiateToolInfo ()

@property (nonatomic, copy) NSString *toolName;       //readonly
@property (nonatomic, strong) NSArray *subtools;          //readonly

@end



@implementation HQEdiateToolInfo




+ (HQEdiateToolInfo *)toolInfoForToolClass:(Class<HQEdiateImageProtocal>)toolClass{
    if([(Class)toolClass conformsToProtocol:@protocol(HQEdiateImageProtocal)]){
        HQEdiateToolInfo *info = [HQEdiateToolInfo new];
        info.toolName  = NSStringFromClass(toolClass);
        info.title     = [toolClass defaultTitle];
        info.iconImage = [toolClass defaultIconImage];
        info.subtools = [toolClass subtools];
        info.orderNum = [toolClass orderNum];
        return info;
    }
    return nil;
}
+ (NSArray *)toolsWithToolClass:(Class<HQEdiateImageProtocal>)toolClass{
    NSMutableArray *array = [NSMutableArray array];
    HQEdiateToolInfo *info;
    NSArray *list = [HQEdiateToolInfo subclassesOfClass:toolClass];
    for(Class subtool in list){
        info = [HQEdiateToolInfo toolInfoForToolClass:subtool];
        if(info){
            [array addObject:info];
        }
    }
    NSArray *newArray = [NSArray arrayWithArray:array];
    newArray = [newArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CGFloat dockedNum1 = [obj1 orderNum];
        CGFloat dockedNum2 = [obj2 orderNum];
        if(dockedNum1 < dockedNum2){
            return NSOrderedAscending;
        }
        else if(dockedNum1 > dockedNum2){
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    return newArray;
}


@end
