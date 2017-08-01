//
//  HQEdiateBottomView.m
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/7/31.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import "HQEdiateBottomView.h"
#import "HQEdiateImageBaseTools.h"




@implementation HQEdiateBottomView

- (instancetype)initWithFrame:(CGRect)frame andClickButtonIndex:(void(^)(HQEdiateImageToolInfo *toolInfo))callClickButtonIndex{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _bottomEdiateViewClick = callClickButtonIndex;
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews{
    CGFloat width  = (App_Frame_Width - 30)/5.0;
    
    NSArray *classes = [HQEdiateImageToolInfo toolsWithToolClass:[HQEdiateImageBaseTools class]];
    
    for (int i = 0; i< classes.count; i++) {
        HQEdiateItem *item = [[HQEdiateItem alloc] initWithFram:CGRectMake(15 + i*width, 10, width, 60)  andToolInfo:classes[i] andClickCallBackAction:^(HQEdiateImageToolInfo *info) {
            if (_bottomEdiateViewClick) {
                _bottomEdiateViewClick(info);
            }
        }];
        [self addSubview:item];
    }
    
}




@end



@interface HQEdiateItem ()

@property (nonatomic,strong) UIImageView *contentImageView;

@property (nonatomic,strong) HQEdiateImageToolInfo *info;

@end

@implementation HQEdiateItem

- (instancetype)initWithFram:(CGRect)frame andToolInfo:(HQEdiateImageToolInfo *)toolInfo   andClickCallBackAction:(void (^)(HQEdiateImageToolInfo *info))clickCallBackAction{
    self = [super initWithFrame:frame];
    if (self) {
        _clickBackAction = clickCallBackAction;
        self.info = toolInfo;
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - 30)/2.0, (self.height - 30)/2.0, 30, 30)];
        _contentImageView.image = toolInfo.iconImage;
        _contentImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_contentImageView];
        
        [self addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)buttonClickAction:(UIControl *)sender{
    if (_clickBackAction) _clickBackAction(self.info);
}
@end













@interface HQEdiateImageToolInfo ()

@property (nonatomic, copy) NSString *toolName;       //readonly
@property (nonatomic, strong) NSArray *subtools;          //readonly

@end

@implementation HQEdiateImageToolInfo


+ (HQEdiateImageToolInfo *)toolInfoForToolClass:(Class<HQEdiateImageProtocal>)toolClass{
    if([(Class)toolClass conformsToProtocol:@protocol(HQEdiateImageProtocal)]){
        HQEdiateImageToolInfo *info = [HQEdiateImageToolInfo new];
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
    HQEdiateImageToolInfo *info;
    NSArray *list = [HQEdiateImageToolInfo subclassesOfClass:toolClass];
    for(Class subtool in list){
        info = [HQEdiateImageToolInfo toolInfoForToolClass:subtool];
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
