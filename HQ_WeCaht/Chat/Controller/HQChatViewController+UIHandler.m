//
//  HQChatViewController+UIHandler.m
//  HQ_WeChat
//
//  Created by 黄麒展 on 2018/10/28.
//  Copyright © 2018年 黄麒展. All rights reserved.
//

#import "HQChatViewController+UIHandler.h"

@implementation HQChatViewController (UIHandler)


- (void)syncDispalyTableViewReload{
    for (HQBaseCellLayout *layout in self.dataArray) {
        layout.isAsyncDisplay = NO;
    }
    [self.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (HQBaseCellLayout *layout in self.dataArray) {
            layout.isAsyncDisplay = YES;
        }
    });
}
@end

