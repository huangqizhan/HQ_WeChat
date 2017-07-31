//
//  HQChaRootCell.h
//  HQ_WeChat
//
//  Created by GoodSrc on 2017/6/8.
//  Copyright © 2017年 黄麒展. All rights reserved.
//

#import <UIKit/UIKit.h>

extern BOOL _ChatCellIsEdiating;

@interface HQChaRootCell : UITableViewCell

////是否正在编辑
@property (nonatomic,assign) BOOL isEdiating;

////是否选中
@property (nonatomic,assign) BOOL isSeleted;

////设置cell的编辑状态
- (void)reSetMessageCellEdiatedStatusIsEdiate:(BOOL)isEdiate;

///编辑时点击cell
- (void)didSeleteCellWhenIsEdiating:(BOOL)isSeleted;

////cell将要开始呈现
- (void)willDisplayCell;
///cell将要结束呈现
- (void)didEndDisplayingCell;
@end
