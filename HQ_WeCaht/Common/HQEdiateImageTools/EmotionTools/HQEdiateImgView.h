//
//  HQEdiateImgView.h
//  HQ_WeChat
//
//  Created by 黄麒展 on 2017/8/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>



@class HQEmotionEdiateImageTools;

@interface HQEdiateImgView : UIView

////是否是当前选中的要编辑的表情视图
@property (nonatomic,assign) BOOL isSeleted;
////开始拖动 放缩 回调
@property (nonatomic,copy) void (^beginDragCallBack)(HQEdiateImgView *ediateImageView);

////删除回调
@property (nonatomic,copy) void (^deleteEdiateImageViewCallBack)(HQEdiateImgView *ediateImageView);

- (instancetype)initWithContentImage:(UIImage *)contentImage;

- (void)setActiveEmoticonViewWithActive:(BOOL )active;



@end



@interface ScaleButton : UIView

@end
