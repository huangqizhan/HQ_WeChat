//
//  UIScrollView+Add.h
//  YYKitStudy
//
//  Created by GoodSrc on 2017/12/14.
//  Copyright © 2017年 GoodSrc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (Add)

////ScrollView   ScrollAction

- (void)scrollToTop ;
- (void)scrollToBottom ;
- (void)scrollToLeft ;
- (void)scrollToRight;
- (void)scrollToTopAnimated:(BOOL)animated ;
- (void)scrollToBottomAnimated:(BOOL)animated;
- (void)scrollToLeftAnimated:(BOOL)animated ;
- (void)scrollToRightAnimated:(BOOL)animated;
@end


NS_ASSUME_NONNULL_END
