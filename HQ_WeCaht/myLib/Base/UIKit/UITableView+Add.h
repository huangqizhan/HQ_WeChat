//
//  UITableView+Add.h
//  YYKitStudy
//
//  Created by GoodSrc on 2017/12/14.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (Add)

//// beginupdate  endupdate  中间部分用block封装
- (void)updateWithBlock:(void (^)(UITableView *tableView))block;

///row or section Action

- (void)scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
- (void)insertRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)clearSelectedRowsAnimated:(BOOL)animated;

@end


NS_ASSUME_NONNULL_END
